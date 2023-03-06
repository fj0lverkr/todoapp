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
    required this.uid,
  }) : super(key: key);

  final TodoItem item;
  final String uid;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);
    var itemTitleStyle = theme.textTheme.titleMedium!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
    );
    var itemTitleDoneStyle = theme.textTheme.titleMedium!.copyWith(
      color: Colors.grey,
      decoration: TextDecoration.lineThrough,
    );
    var itemDescriptionStyle = theme.textTheme.titleSmall!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
    );
    var itemDescriptionDoneStyle = theme.textTheme.titleSmall!.copyWith(
      color: Colors.grey,
      decoration: TextDecoration.lineThrough,
    );
    bool itemExpired = (!item.done &&
        item.expires != null &&
        item.expires!.compareTo(DateTime.now()) < 0);
    bool itemShared = item.isShared;
    return Dismissible(
      key: Key(item.id),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          appState.deleteItem(item);
          appState.refreshItems();
        } else {
          TodoDatabase(uid).setItemDone(item);
          appState.refreshItems();
        }
        return false;
      },
      background: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Icon(Icons.done),
            ),
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.delete),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 1, 5, 0),
        child: Card(
          color: itemExpired
              ? theme.colorScheme.errorContainer
              : item.done
                  ? itemShared
                      ? theme.colorScheme.surfaceVariant
                      : theme.colorScheme.secondaryContainer
                  : itemShared
                      ? theme.colorScheme.surface
                      : theme.colorScheme.primaryContainer,
          elevation: 2,
          child: ListTile(
            leading: item.done
                ? const Icon(Icons.done)
                : itemExpired
                    ? const Icon(Icons.av_timer)
                    : const Icon(Icons.circle_outlined),
            title: Text(
                item.expires != null
                    ? "${item.title} (do by ${DateFormat.yMMMd().format(item.expires!)})"
                    : item.title,
                style: item.done ? itemTitleDoneStyle : itemTitleStyle),
            subtitle: (item.description != null && item.description != "")
                ? Text(item.description!,
                    overflow: TextOverflow.ellipsis,
                    style: item.done
                        ? itemDescriptionDoneStyle
                        : itemDescriptionStyle)
                : null,
            trailing: itemShared
                ? const Icon(Icons.people_outline)
                : const Icon(Icons.lock_outline),
            onTap: () async {
              await showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      _buildPopupDialog(context, item, appState, uid));
            },
          ),
        ),
      ),
    );
  }
}

Widget _buildPopupDialog(
    BuildContext context, TodoItem item, MyAppState appState, String uid) {
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
            TodoDatabase(uid).setItemDone(item);
            appState.refreshItems();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.done),
        ),
      IconButton(
          onPressed: () {
            appState.deleteItem(item);
            appState.refreshItems();
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
