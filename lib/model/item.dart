//import 'package:sqflite/sqflite.dart';

const String tableTodo = 'todo';
const String columnId = '_id';
const String columnTitle = 'title';
const String columnDescription = 'description';
const String columnCreated = 'created';
const String columnExists = 'exists';
const String columnDone = 'done';

class TodoItem {
  String title;
  String? description;
  DateTime created = DateTime.now();
  DateTime? expires;
  bool done = false;

  TodoItem(this.title, {this.description, this.expires});

  void toggleDone() {
    done = !done;
  }
}

class TodoItemProvider {}
