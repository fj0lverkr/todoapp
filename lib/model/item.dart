import 'dart:convert';

import 'package:intl/intl.dart';

class TodoItem {
  String id;
  String title;
  String? description;
  DateTime created = DateTime.now();
  DateTime? expires;
  bool done = false;
  bool isShared;
  String owner;
  String ownerDisplayName;

  TodoItem(this.id, this.title, this.owner, this.ownerDisplayName,
      {this.description, this.expires, this.isShared = false});

  factory TodoItem.fromJson(dynamic json) {
    json = jsonDecode(json);
    var item = TodoItem(
        json['id'], json['title'], json['owner'], json['ownerDisplayName']);
    String? description = json['description'] as String?;
    DateTime created = DateFormat.yMMMd().parse(json['created'] as String);
    bool done = json['done'] as bool;
    String? expires = json['expires'] as String?;

    if (description != null && description.isNotEmpty) {
      item.description = description;
    }

    item.created = created;
    item.done = done;

    if (expires != null && expires.isNotEmpty) {
      item.expires = DateFormat.yMMMd().add_Hm().parse(expires);
    }
    return item;
  }
}

class TodoItemProvider {}
