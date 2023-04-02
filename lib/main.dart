import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:todoapp/pages/itemlist.dart';
import 'package:todoapp/pages/newitem.dart';
import 'package:todoapp/pages/login.dart';
import 'package:todoapp/pages/logout.dart';
import 'package:todoapp/model/database.dart';
import 'package:todoapp/model/item.dart';
import 'package:todoapp/util/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();
  await NotificationService().requestIOSPermissions();

  SharedPreferences prefs = await SharedPreferences.getInstance();

  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user == null) {
      if (prefs.getString('fb_uid') != null) {
        String displayName = prefs.getString('fb_display') != null
            ? prefs.getString('fb_display')!
            : "";
        runApp(MyApp(prefs.getString('fb_uid')!, displayName, true, true));
      } else {
        runApp(const MyApp('', '', false, true));
      }
    } else {
      if (user.emailVerified) {
        await prefs.setString('fb_uid', user.uid);
        await prefs.setString(
            'fb_display', user.displayName != null ? user.displayName! : "");
        runApp(MyApp(user.uid,
            user.displayName != null ? user.displayName! : "", true, true));
      } else {
        prefs.remove('fb_uid');
        prefs.remove('fb_display');
        runApp(const MyApp('', '', false, false));
      }
    }
  });
}

class MyApp extends StatelessWidget {
  final String uid;
  final String userDisplayName;
  final bool isLoggedIn;
  final bool isMailVerified;
  const MyApp(
      this.uid, this.userDisplayName, this.isLoggedIn, this.isMailVerified,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          MyAppState(uid, userDisplayName, isLoggedIn, isMailVerified),
      child: MaterialApp(
        title: 'Todo App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        ),
        home: isLoggedIn ? const MainPage() : const LoginPage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  String uid;
  String userDisplayName;
  bool isDataInitiated = false;
  bool isLoggedIn;
  bool isMailVerified;
  bool isAppLoading = true;
  MyAppState(
      this.uid, this.userDisplayName, this.isLoggedIn, this.isMailVerified);
  List<TodoItem> items = [];
  late TodoItem myItem;

  initData() async {
    TodoDatabase(uid).itemsRef.onValue.listen((_) {
      setAppLoadingState(true);
      refreshItems();
    });
    isDataInitiated = true;
  }

  Future<void> refreshItems() async {
    items = await TodoDatabase(uid).getAllItems();
    items.sort((a, b) => a.created.compareTo(b.created));
    await setReminders(items, formatDate);
    setAppLoadingState(false);
  }

  void storeItem(bool isShared) {
    setAppLoadingState(true);
    String location = isShared ? "sharedItems" : uid;
    TodoDatabase(location).createItem(myItem);
  }

  void setItemDone(TodoItem item, bool done) {
    setAppLoadingState(true);
    if (done) {
      final NotificationService notificationService = NotificationService();
      notificationService.clearScheduledNotificationForItem(item.id);
    }
    TodoDatabase(uid).toggleItemDone(item, done);
  }

  void deleteItem(TodoItem item) {
    setAppLoadingState(true);
    final NotificationService notificationService = NotificationService();
    notificationService.clearScheduledNotificationForItem(item.id);
    TodoDatabase(uid).deleteItem(item);
  }

  void setAppLoadingState(bool isLoading) {
    isAppLoading = isLoading;
    notifyListeners();
  }

  String formatDate(
      DateTime date, String locale, bool doLongFormat, bool includeTime) {
    initializeDateFormatting(locale, null);
    String formattedDate = doLongFormat
        ? includeTime
            ? DateFormat.yMMMMd(locale).add_Hm().format(date)
            : DateFormat.yMMMMd(locale).format(date)
        : includeTime
            ? DateFormat.yMd(locale).add_Hm().format(date)
            : DateFormat.yMd(locale).format(date);
    return formattedDate;
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  void _setIndex(int index) {
    setState(() {
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
    String displayName = appState.userDisplayName;
    Widget? page;
    switch (selectedIndex) {
      case 0:
        page = ItemListPage(_setIndex, uid);
        break;
      case 1:
        page = NewItemPage(_setIndex);
        break;
      case 2:
        page = LogoutPage(_setIndex, uid, displayName);
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
                    leading: Image.asset(
                      "assets/images/logo-bw.png",
                      width: 55,
                    ),
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

Future<void> setReminders(List<TodoItem> items, Function formatDate) async {
  for (var item in items) {
    if (item.expires != null && !item.done) {
      final DateTime now = DateTime.now();
      final NotificationService notificationService = NotificationService();
      if (now.isBefore(item.expires!)) {
        Duration offset = const Duration(minutes: 5);
        final Duration diff = item.expires!.difference(now);
        if (diff.inDays >= 365) {
          offset = const Duration(days: 183);
        } else if (diff.inDays >= 183) {
          offset = const Duration(days: 92);
        } else if (diff.inDays >= 92) {
          offset = const Duration(days: 30);
        } else if (diff.inDays >= 30) {
          offset = const Duration(days: 14);
        } else if (diff.inDays >= 14) {
          offset = const Duration(days: 7);
        } else if (diff.inDays >= 7) {
          offset = const Duration(days: 1);
        } else if (diff.inDays >= 1) {
          offset = const Duration(hours: 12);
        } else if (diff.inHours >= 12) {
          offset = const Duration(hours: 6);
        } else if (diff.inHours >= 6) {
          offset = const Duration(hours: 4);
        } else if (diff.inHours >= 4) {
          offset = const Duration(hours: 2);
        } else if (diff.inHours >= 2) {
          offset = const Duration(hours: 1);
        } else if (diff.inHours >= 1) {
          offset = const Duration(minutes: 30);
        } else if (diff.inMinutes >= 30) {
          offset = const Duration(minutes: 15);
        }

        DateTime schedule = item.expires!.subtract(offset);
        await notificationService.scheduleNotifications(
            id: item.id,
            body:
                "This item expires on ${formatDate(item.expires!, 'en_GB', true, true)}.",
            title: "TodoApp reminder: ${item.title}",
            time: schedule);
      }
    }
  }
}
