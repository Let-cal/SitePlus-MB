import 'package:flutter/material.dart';

class HelpDialog extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const HelpDialog({
    super.key,
    this.title = 'Guide',
    required this.content,
    this.buttonText = 'Got it',
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        content,
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.justify,
      ),
      actions: [
        TextButton(
          onPressed: onButtonPressed ?? () => Navigator.pop(context),
          child: Text(
            buttonText,
            style: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }

  static void show(
    BuildContext context, {
    String title = 'Guide',
    required String content,
    String buttonText = 'Got it',
    VoidCallback? onButtonPressed,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => HelpDialog(
            title: title,
            content: content,
            buttonText: buttonText,
            onButtonPressed: onButtonPressed,
          ),
    );
  }
}
