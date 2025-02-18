import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String content;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  const InfoCard({
    Key? key,
    required this.icon,
    required this.content,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get theme colors from the current theme
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            color: iconColor ?? theme.colorScheme.secondary,
            size: 24.0,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold, // This line ensures bold text
              ),
            ),
          ),
        ],
      ),
    );
  }
}
