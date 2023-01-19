import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:todoapp/main.dart';
import 'package:todoapp/widgets/selectdate.dart';
import 'package:todoapp/model/item.dart';

class NewItemPage extends StatefulWidget {
  final Function _setIndex;

  const NewItemPage(this._setIndex, {super.key});

  @override
  State<NewItemPage> createState() => _NewItemPageState();
}

class _NewItemPageState extends State<NewItemPage> {
  final _formKey = GlobalKey<FormState>();

  final DateTime _selectedDate = DateTime.now();

  final TextEditingController _textEditingController = TextEditingController();

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
                  onSaved: (value) => appState.myItem = TodoItem(value!),
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
                    keyboardType: TextInputType.datetime,
                    controller: _textEditingController,
                    //enabled: false,
                    onTap: () {
                      selectDate(
                          context, _selectedDate, _textEditingController);
                    },
                    decoration: const InputDecoration(
                        labelText: 'Expires',
                        icon: Icon(Icons.date_range),
                        hintText: 'Select the expiry date for the item.'),
                    onSaved: (value) {
                      if (value != null && value.isNotEmpty) {
                        try {
                          appState.myItem.expires =
                              DateFormat.yMMMd().parse(value);
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
                          appState.storeItem();
                          widget._setIndex(0);
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
