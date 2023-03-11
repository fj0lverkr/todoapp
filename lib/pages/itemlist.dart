import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todoapp/main.dart';
import 'package:todoapp/widgets/titlecard.dart';
import 'package:todoapp/widgets/item.dart';

class ItemListPage extends StatelessWidget {
  final Function _setIndex;
  final String uid;
  const ItemListPage(this._setIndex, this.uid, {super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    String udn = appState.userDisplayName;
    String owningUser = udn.endsWith('s') ? "$udn'" : "$udn's";
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
                  TitleCard('$owningUser to-do list:', theme: theme),
                  if (appState.items.isEmpty) ...[
                    const ListTile(
                      title: Text('No items yet...'),
                    )
                  ] else ...[
                    for (var item in appState.items)
                      ItemWidget(uid: uid, item: item),
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
