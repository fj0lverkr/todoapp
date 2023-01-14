import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        ),
        home: const MainPage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var items = <TodoItem>[];
  late TodoItem myItem;

  void storeItem() {
    items.add(myItem);
    items.sort((a, b) => a.created.compareTo(b.created));
    notifyListeners();
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
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class ItemListPage extends StatelessWidget {
  final Function _setIndex;
  const ItemListPage(this._setIndex, {super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Flexible(
              child: ListView(
                children: [
                  TitleCard('Todo Items:', theme: theme),
                  if (appState.items.isEmpty) ...[
                    const ListTile(
                      title: Text('No items yet...'),
                    )
                  ] else ...[
                    for (var item in appState.items)
                      ListTile(
                        title: Text(item.title),
                      ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.secondary,
        onPressed: () {
          _setIndex(1);
        },
        tooltip: 'Add new Todo',
        child: Icon(
          Icons.add,
          color: theme.colorScheme.onSecondary,
        ),
      ),
    );
  }
}

class NewItemPage extends StatelessWidget {
  final Function _setIndex;
  final _formKey = GlobalKey<FormState>();
  NewItemPage(this._setIndex, {super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: TextFormField(
              validator: (String? value) {
                return (value == null || value.isEmpty)
                    ? 'Please provide a title.'
                    : null;
              },
              decoration: const InputDecoration(
                labelText: 'Title*',
                icon: Icon(Icons.title),
                hintText: 'Enter a title for your item.',
              ),
              onSaved: (value) => appState.myItem = TodoItem(value!),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: TextFormField(
              onSaved: (newValue) => appState.myItem.description = newValue,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Description',
                  icon: Icon(Icons.description),
                  hintText: 'Enter a description for your item.'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text("Save"),
                  onPressed: () {
                    if (_formKey.currentState != null &&
                        _formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      appState.storeItem();
                      _setIndex(0);
                    }
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    _setIndex(0);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TitleCard extends StatelessWidget {
  const TitleCard(
    this.title, {
    Key? key,
    required this.theme,
  }) : super(key: key);

  final ThemeData theme;
  final String title;

  @override
  Widget build(BuildContext context) {
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Align(
      alignment: Alignment.centerLeft,
      child: Card(
        elevation: 2,
        color: theme.colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            title,
            style: style,
          ),
        ),
      ),
    );
  }
}
