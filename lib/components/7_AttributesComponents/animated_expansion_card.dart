import 'package:flutter/material.dart';

class AnimatedExpansionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final ThemeData theme;
  final bool initiallyExpanded;
  final bool showInfo;
  final String? description; 
  final String? infoTitle; 
  final List<String>? bulletPoints; 
  final bool useBulletPoints; 

  const AnimatedExpansionCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.children,
    required this.theme,
    this.initiallyExpanded = false,
    this.showInfo = false,
    this.description,
    this.infoTitle,
    this.bulletPoints,
    this.useBulletPoints = false,
  });

  void _showInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(infoTitle ?? title, style: theme.textTheme.titleMedium),
        content: SingleChildScrollView(
          child: useBulletPoints && bulletPoints != null && bulletPoints!.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: bulletPoints!.map((point) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(point, style: theme.textTheme.bodyMedium)),
                        ],
                      ),
                    );
                  }).toList(),
                )
              : Text(description ?? '', style: theme.textTheme.bodyMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Đóng',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      );
    },
  );
}

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
        title: Row(
          children: [
            Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
            if (showInfo)
              IconButton(
                icon: Icon(
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () => _showInfoDialog(context),
                tooltip: 'Thông tin',
              ),
          ],
        ),
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
