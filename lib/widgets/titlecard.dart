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
    var style = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      elevation: 2,
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 0, 8),
        child: Text(
          title,
          style: style,
        ),
      ),
    );
  }
}
