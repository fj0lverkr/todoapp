import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:todoapp/model/item.dart';

class ItemWidget extends StatelessWidget {
  const ItemWidget({
    Key? key,
    required this.item,
  }) : super(key: key);

  final TodoItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
      child: ListTile(
        title: Text(item.title),
        onTap: () async {
          await showDialog(
              context: context,
              builder: (BuildContext context) =>
                  _buildPopupDialog(context, item));
        },
      ),
    );
  }
}

Widget _buildPopupDialog(BuildContext context, TodoItem item) {
  return AlertDialog(
    title: Text(item.title),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.description != null ? item.description! : ''),
        item.expires != null
            ? Text('Expires: ${DateFormat.yMMMd().format(item.expires!)}')
            : const SizedBox(),
      ],
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Close'),
      ),
    ],
  );
}
