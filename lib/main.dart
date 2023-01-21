import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Todo App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        ),
        home: const MainPage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  List<TodoItem> items = [];
  late TodoItem myItem;

  void initData() {
    refreshItems();
    TodoDatabase().itemsRef.onValue.listen((_) {
      refreshItems();
    });
  }

  void refreshItems() async {
    items = await TodoDatabase().getAllItems();
    items.sort((a, b) => a.created.compareTo(b.created));
    notifyListeners();
  }

  void storeItem() {
    TodoDatabase().createItem(myItem);
    refreshItems();
  }

  void deleteItem(TodoItem item) {
    TodoDatabase().deleteItem(item);
    refreshItems();
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

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
    appState.initData();
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = ItemListPage(_setIndex);
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
