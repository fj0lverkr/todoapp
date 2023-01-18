import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

selectDate(BuildContext context, DateTime selectedDate,
    TextEditingController textEditingController) async {
  var theme = Theme.of(context);
  DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
              surface: theme.colorScheme.surface,
              onSurface: theme.colorScheme.onSurface,
            ),
            dialogBackgroundColor: theme.colorScheme.primaryContainer,
          ),
          child: child!,
        );
      });

  if (newSelectedDate != null) {
    selectedDate = newSelectedDate;
    textEditingController
      ..text = DateFormat.yMMMd().format(selectedDate)
      ..selection = TextSelection.fromPosition(TextPosition(
          offset: textEditingController.text.length,
          affinity: TextAffinity.upstream));
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
