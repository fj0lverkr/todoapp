import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import 'package:todoapp/model/item.dart';

class TodoDatabase {
  final String _uid;
  TodoDatabase(this._uid);
  final FirebaseDatabase _todoDatabase = FirebaseDatabase.instance;
  DatabaseReference itemsRef = FirebaseDatabase.instance.ref("items");

  void createItem(TodoItem item) async {
    String expires =
        item.expires != null ? DateFormat.yMMMd().format(item.expires!) : '';
    DatabaseReference ref = _todoDatabase.ref("items/$_uid/${item.id}");
    await ref.set({
      "id": item.id,
      "title": item.title,
      "description": item.description,
      "created": DateFormat.yMMMd().format(item.created),
      "expires": expires,
      "done": item.done,
      "owner": item.owner,
      "ownerDisplayName": item.ownerDisplayName
    });
  }

  Future<List<TodoItem>> getAllItems() async {
    var items = <TodoItem>[];
    final DatabaseReference ref = _todoDatabase.ref("items/$_uid/");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      for (var element in snapshot.children) {
        items.add(TodoItem.fromJson(jsonEncode(element.value)));
      }
    }
    List<TodoItem> sharedItems = await getSharedItems();
    for (var sharedItem in sharedItems) {
      items.add(sharedItem);
    }
    return items;
  }

  Future<List<TodoItem>> getSharedItems() async {
    var items = <TodoItem>[];
    final DatabaseReference ref = _todoDatabase.ref("items/sharedItems/");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      for (var element in snapshot.children) {
        TodoItem item = TodoItem.fromJson(jsonEncode(element.value));
        item.isShared = true;
        items.add(item);
      }
    }
    return items;
  }

  void setItemDone(TodoItem item) {
    String owner = item.isShared ? "sharedItems" : _uid;
    final DatabaseReference ref = _todoDatabase.ref("items/$owner/${item.id}");
    ref.update({"done": true});
  }

  void deleteItem(TodoItem item) {
    String owner = item.isShared ? "sharedItems" : _uid;
    final DatabaseReference ref = _todoDatabase.ref("items/$owner/${item.id}");
    ref.remove();
  }
}
