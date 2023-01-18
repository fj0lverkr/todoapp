import 'package:flutter/material.dart';

class TitleCard extends StatelessWidget {
  const TitleCard(
    this.title, {
    Key? key,
    required this.theme,
  }) : super(key: key);

  final ThemeData theme;
  final String title;

  @override
  Widget build(BuildContext context) {
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Align(
      alignment: Alignment.centerLeft,
      child: Card(
        elevation: 2,
        color: theme.colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            title,
            style: style,
          ),
        ),
      ),
    );
  }
}
