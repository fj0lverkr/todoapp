import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:todoapp/pages/itemlist.dart';
import 'package:todoapp/pages/newitem.dart';
import 'package:todoapp/pages/logout.dart';
import 'package:todoapp/model/database.dart';
import 'package:todoapp/model/item.dart';
import 'package:todoapp/model/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();

  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user == null) {
      if (prefs.getString('fb_uid') != null) {
        String mail = prefs.getString('fb_userMail') != null
            ? prefs.getString('fb_userMail')!
            : "";
        runApp(MyApp(prefs.getString('fb_uid')!, mail, true, true));
      } else {
        runApp(const MyApp('', '', false, true));
      }
    } else {
      if (user.emailVerified) {
        await prefs.setString('fb_uid', user.uid);
        await prefs.setString(
            'fb_usermail', user.email != null ? user.email! : "");
        runApp(
            MyApp(user.uid, user.email != null ? user.email! : '', true, true));
      } else {
        prefs.remove('fb_uid');
        prefs.remove('fb_userMail');
        user.sendEmailVerification();
        FirebaseAuth.instance.signOut();
        //runApp(const MyApp('', '', false, false));
      }
    }
  });
}

class MyApp extends StatelessWidget {
  final String uid;
  final String userEmail;
  final bool isLoggedIn;
  final bool isMailVerified;
  const MyApp(this.uid, this.userEmail, this.isLoggedIn, this.isMailVerified,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          MyAppState(uid, userEmail, isLoggedIn, isMailVerified),
      child: MaterialApp(
        title: 'Todo App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        ),
        home: isLoggedIn ? MainPage(uid) : const LoginPage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  String uid;
  String userEmail;
  bool isDataInitiated = false;
  bool isLoggedIn;
  bool isMailVerified;
  bool isAppLoading = true;
  MyAppState(this.uid, this.userEmail, this.isLoggedIn, this.isMailVerified);
  List<TodoItem> items = [];
  late TodoItem myItem;

  initData() {
    refreshItems();
    TodoDatabase(uid).itemsRef.onValue.listen((_) {
      setAppLoadingState(true);
      refreshItems();
    });
    isDataInitiated = true;
  }

  void refreshItems() async {
    items = await TodoDatabase(uid).getAllItems();
    items.sort((a, b) => a.created.compareTo(b.created));
    setAppLoadingState(false);
  }

  void storeItem(bool isShared) {
    setAppLoadingState(true);
    String location = isShared ? "sharedItems" : uid;
    TodoDatabase(location).createItem(myItem);
    refreshItems();
  }

  void setItemDone(TodoItem item) {
    setAppLoadingState(true);
    TodoDatabase(uid).setItemDone(item);
    refreshItems();
  }

  void deleteItem(TodoItem item) {
    setAppLoadingState(true);
    TodoDatabase(uid).deleteItem(item);
    refreshItems();
  }

  void setAppLoadingState(bool isLoading) {
    isAppLoading = isLoading;
    notifyListeners();
  }
}

class MainPage extends StatefulWidget {
  final String uid;
  const MainPage(this.uid, {super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  int oldIndex = 0;
  void _setIndex(int index) {
    setState(() {
      oldIndex = selectedIndex;
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    if (!appState.isDataInitiated) {
      appState.initData();
    }
    String uid = appState.uid;
    String email = appState.userEmail;
    Widget? page;
    switch (selectedIndex) {
      case 0:
        page = ItemListPage(_setIndex, uid);
        break;
      case 1:
        page = NewItemPage(_setIndex);
        break;
      case 2:
        page = LogoutPage(_setIndex, uid, email, oldIndex);
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          Scaffold(
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    extended: constraints.maxWidth >= 600,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.list),
                        label: Text('Todo list'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.add),
                        label: Text('New Todo'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.logout_outlined),
                        label: Text('Logout'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    color: theme.colorScheme.primaryContainer,
                    child: page,
                  ),
                ),
              ],
            ),
          ),
          if (appState.isAppLoading)
            Opacity(
              opacity: 0.7,
              child: ModalBarrier(
                  dismissible: false, color: theme.colorScheme.inverseSurface),
            ),
          if (appState.isAppLoading)
            Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.onInverseSurface,
              ),
            ),
        ],
      );
    });
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late String login;
  late String password;

  Future<LoginResult> _doLogin(String email, String password) async {
    return await TodoLogin().signInWithEmailAndPassword(email, password);
  }

  Future<LoginResult> _doCreateUser(String email, String password) async {
    return await TodoLogin().createUser(email, password);
  }

  void _showSnackbar(String title, {int durationSeconds = 10}) {
    final snackbar = SnackBar(
      content: Text(title),
      duration: Duration(seconds: durationSeconds),
    );
    scaffoldMessengerKey.currentState?.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    return LayoutBuilder(builder: (context, constraints) {
      if (!appState.isMailVerified) {
        _showSnackbar("Please verify your e-mail before logging in.",
            durationSeconds: 30);
      }
      return ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          body: Container(
            color: theme.colorScheme.background,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: TextFormField(
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) async {
                          if (_formKey.currentState != null &&
                              _formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            LoginResult result =
                                await _doLogin(login, password);
                            if (result.success) {
                              appState.isLoggedIn = true;
                              appState.uid = result.message!;
                            } else {
                              _showSnackbar(result.message!);
                            }
                          }
                        },
                        validator: (String? value) {
                          return (value == null || value.isEmpty)
                              ? 'Invalid E-mail address.'
                              : null;
                        },
                        decoration: const InputDecoration(
                            labelText: 'E-mail address',
                            icon: Icon(Icons.mail),
                            hintText: 'Your e-mail.'),
                        onSaved: (value) => login = value!,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: TextFormField(
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) async {
                          if (_formKey.currentState != null &&
                              _formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            LoginResult result =
                                await _doLogin(login, password);
                            if (result.success) {
                              appState.isLoggedIn = true;
                              appState.uid = result.message!;
                            } else {
                              _showSnackbar(result.message!);
                            }
                          }
                        },
                        validator: (String? value) {
                          return (value == null || value.isEmpty)
                              ? 'Invalid password.'
                              : null;
                        },
                        onSaved: (newValue) => password = newValue!,
                        obscureText: true,
                        decoration: const InputDecoration(
                            labelText: 'Password',
                            icon: Icon(Icons.password),
                            hintText: 'Your password.'),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 35,
                          ),
                          ElevatedButton(
                            child: const Text("Login"),
                            onPressed: () async {
                              if (_formKey.currentState != null &&
                                  _formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                LoginResult result =
                                    await _doLogin(login, password);
                                if (result.success) {
                                  appState.isLoggedIn = true;
                                  appState.uid = result.message!;
                                } else {
                                  _showSnackbar(result.message!);
                                }
                              }
                            },
                          ),
                          const SizedBox(
                            width: 25,
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (_formKey.currentState != null &&
                                  _formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                LoginResult result =
                                    await _doCreateUser(login, password);
                                if (result.success) {
                                  appState.isLoggedIn = true;
                                  appState.uid = result.message!;
                                } else {
                                  _showSnackbar(result.message!);
                                }
                              }
                            },
                            child: const Text('create account'),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
