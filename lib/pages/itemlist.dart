import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todoapp/main.dart';
import 'package:todoapp/widgets/titlecard.dart';

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
