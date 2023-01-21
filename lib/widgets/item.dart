import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:todoapp/main.dart';
import 'package:todoapp/model/item.dart';
import 'package:todoapp/model/database.dart';

class ItemWidget extends StatelessWidget {
  const ItemWidget({
    Key? key,
    required this.item,
  }) : super(key: key);

  final TodoItem item;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
      child: ListTile(
        title: Text(item.title),
        onTap: () async {
          await showDialog(
              context: context,
              builder: (BuildContext context) =>
                  _buildPopupDialog(context, item, appState));
        },
      ),
    );
  }
}

Widget _buildPopupDialog(
    BuildContext context, TodoItem item, MyAppState appState) {
  return AlertDialog(
    title: Text(item.title),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.description != null ? item.description! : ''),
        Text(item.expires != null
            ? 'Expires: ${DateFormat.yMMMd().format(item.expires!)}'
            : ''),
      ],
    ),
    actions: <Widget>[
      if (!item.done)
        IconButton(
          onPressed: () {
            TodoDatabase().setItemDone(item.id);
            appState.initData();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.done),
        ),
      IconButton(
          onPressed: () {
            appState.deleteItem(item);
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.delete)),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Close'),
      ),
    ],
  );
}
