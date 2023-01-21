import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import 'package:todoapp/model/item.dart';

class TodoDatabase {
  FirebaseDatabase todoDatabase = FirebaseDatabase.instance;
  void createItem(TodoItem item) async {
    String expires =
        item.expires != null ? DateFormat.yMMMd().format(item.expires!) : '';
    DatabaseReference ref = todoDatabase.ref("items/${item.id}");
    await ref.set({
      "id": item.id,
      "title": item.title,
      "description": item.description,
      "created": DateFormat.yMMMd().format(item.created),
      "expires": expires,
      "done": item.done
    });
  }

  Future<List<TodoItem>> getAllItems() async {
    var items = <TodoItem>[];
    final DatabaseReference ref = todoDatabase.ref("items");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      for (var element in snapshot.children) {
        items.add(TodoItem.fromJson(jsonEncode(element.value)));
      }
    }
    return items;
  }

  void setItemDone(String itemId) {
    final DatabaseReference ref = todoDatabase.ref("items/$itemId");
    ref.update({"done": true});
  }

  void deleteItem(TodoItem item) {
    final DatabaseReference ref = todoDatabase.ref("items/${item.id}");
    ref.remove();
  }
}
