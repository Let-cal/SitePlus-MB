import 'package:flutter/material.dart';

class SecondaryCardContent extends StatelessWidget {
  final List<InfoSection> sections;
  final EdgeInsetsGeometry padding;

  const SecondaryCardContent({
    Key? key,
    required this.sections,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Skip rendering if no sections
    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity, // Explicit width constraint
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          top: BorderSide(color: colorScheme.onSurface.withOpacity(0.1)),
          bottom: BorderSide(color: colorScheme.onSurface.withOpacity(0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(sections.length, (index) {
          final section = sections[index];

          return Padding(
            padding: EdgeInsets.only(top: index > 0 ? 12 : 0),
            child: section,
          );
        }),
      ),
    );
  }
}

class InfoSection extends StatelessWidget {
  final List<InfoItem> items;

  const InfoSection({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Skip rendering if no items
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    // Use IntrinsicHeight to ensure all items in the row have the same height
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(items.length, (index) {
          final item = items[index];

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: index > 0 ? 16 : 0),
              child: item,
            ),
          );
        }),
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String label;
  final String value;

  const InfoItem({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
