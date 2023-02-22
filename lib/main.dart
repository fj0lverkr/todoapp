import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'package:todoapp/pages/itemlist.dart';
import 'package:todoapp/pages/newitem.dart';
import 'package:todoapp/model/database.dart';
import 'package:todoapp/model/item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      runApp(const MyApp('', false));
    } else {
      runApp(MyApp(user.uid, true));
    }
  });
}

class MyApp extends StatelessWidget {
  final String uid;
  final bool isLoggedIn;
  const MyApp(this.uid, this.isLoggedIn, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(uid, isLoggedIn),
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
  final String uid;
  bool isLoggedIn;
  MyAppState(this.uid, this.isLoggedIn);
  List<TodoItem> items = [];
  late TodoItem myItem;

  String initData() {
    refreshItems();
    TodoDatabase(uid).itemsRef.onValue.listen((_) {
      refreshItems();
    });
    return uid;
  }

  void refreshItems() async {
    items = await TodoDatabase(uid).getAllItems();
    items.sort((a, b) => a.created.compareTo(b.created));
    notifyListeners();
  }

  void storeItem() {
    TodoDatabase(uid).createItem(myItem);
    refreshItems();
  }

  void deleteItem(TodoItem item) {
    TodoDatabase(uid).deleteItem(item);
    refreshItems();
  }
}

class MainPage extends StatefulWidget {
  final String uid;
  const MainPage(this.uid, {super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var selectedIndex = 0;
  void _setIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    var uid = appState.initData();
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = ItemListPage(_setIndex, uid);
        break;
      case 1:
        page = NewItemPage(_setIndex);
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
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
  late String login;
  late String password;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
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
                          width: 15,
                        ),
                        ElevatedButton(
                          child: const Text("Login"),
                          onPressed: () {
                            if (_formKey.currentState != null &&
                                _formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              UnimplementedError('to be implemented');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
