import 'package:flutter/material.dart';

class AnimatedExpansionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final ThemeData theme;
  final bool initiallyExpanded; // Thêm thuộc tính này

  const AnimatedExpansionCard({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.children,
    required this.theme,
    this.initiallyExpanded = false, // Mặc định là đóng
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded, // Áp dụng giá trị từ tham số
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle:
            subtitle != null
                ? Text(subtitle!, style: theme.textTheme.bodyMedium)
                : null,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}
