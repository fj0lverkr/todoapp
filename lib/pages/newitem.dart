import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';

import 'package:todoapp/main.dart';
import 'package:todoapp/model/item.dart';

class NewItemPage extends StatefulWidget {
  final Function _setIndex;

  const NewItemPage(this._setIndex, {super.key});

  @override
  State<NewItemPage> createState() => _NewItemPageState();
}

class _NewItemPageState extends State<NewItemPage> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;

  final TextEditingController _textEditingController = TextEditingController();

  bool itemIsShared = false;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
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
                      hintText: 'Enter a title for your item.'),
                  onSaved: (value) => appState.myItem = TodoItem(
                      const Uuid().v4(),
                      value!,
                      appState.uid,
                      appState.userDisplayName),
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
                child: TextFormField(
                    keyboardType: TextInputType.none,
                    readOnly: true,
                    controller: _textEditingController,
                    onTap: () async {
                      _selectedDate =
                          await _showDatePickerDialog(context, _selectedDate);
                      _textEditingController
                        ..text = _selectedDate != null
                            ? DateFormat.yMMMd().add_Hm().format(_selectedDate!)
                            : ""
                        ..selection = TextSelection.fromPosition(
                          TextPosition(
                            offset: _textEditingController.text.length,
                            affinity: TextAffinity.upstream,
                          ),
                        );
                    },
                    decoration: const InputDecoration(
                        labelText: 'Expires',
                        icon: Icon(Icons.date_range),
                        hintText: 'Select the expiry date for the item.'),
                    onSaved: (value) {
                      if (value != null && value.isNotEmpty) {
                        try {
                          appState.myItem.expires =
                              DateFormat.yMMMd().add_Hm().parse(value);
                        } on FormatException {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Invalid date input, ignoring date."),
                          ));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text("Error while setting expiration date: $e"),
                          ));
                        }
                      }
                    }),
              ),
              const SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.people_outline),
                    const SizedBox(
                      width: 5,
                    ),
                    Checkbox(
                      value: itemIsShared,
                      onChanged: (value) {
                        setState(() {
                          itemIsShared = value!;
                        });
                      },
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text("Shared item")
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 15,
                    ),
                    ElevatedButton(
                      child: const Text("Save"),
                      onPressed: () {
                        if (_formKey.currentState != null &&
                            _formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          widget._setIndex(0);
                          appState.storeItem(itemIsShared);
                        }
                      },
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      child: const Text("Cancel"),
                      onPressed: () {
                        widget._setIndex(0);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<DateTime?> _showDatePickerDialog(
    BuildContext context, DateTime? initDT) async {
  var theme = Theme.of(context);
  String minDate = DateTime.now().toIso8601String();
  String maxDate =
      DateTime.now().add(const Duration(days: 3650)).toIso8601String();
  String initDate = initDT != null ? initDT.toIso8601String() : minDate;
  const String dateFormat = "yyyy-MM-dd,HH:mm";
  DateTime selectedDate = DateTime.parse(minDate);
  return showDialog<DateTime?>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Pick date and time'),
        backgroundColor: theme.colorScheme.background,
        content: SingleChildScrollView(
          child: DateTimePickerWidget(
            minDateTime: DateTime.parse(minDate),
            maxDateTime: DateTime.parse(maxDate),
            initDateTime: DateTime.parse(initDate),
            dateFormat: dateFormat,
            onMonthChangeStartWithFirstDate: true,
            pickerTheme: DateTimePickerTheme(
              showTitle: false,
              itemTextStyle: theme.textTheme.bodySmall!,
              backgroundColor: const Color.fromARGB(0, 0, 0, 0),
              itemHeight: 40,
            ),
            onChange: (dateTime, selectedIndex) {
              selectedDate = dateTime;
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('set'),
            onPressed: () {
              Navigator.of(context).pop(selectedDate);
            },
          ),
          TextButton(
            child: Text(initDT == null ? 'cancel' : 'clear'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
