import 'package:flutter/material.dart';

class FloatingActionMenu extends StatefulWidget {
  final List<FloatingActionMenuItem> items;
  final IconData mainIcon;
  final Color? backgroundColor;
  final Color? iconColor;

  const FloatingActionMenu({
    super.key,
    required this.items,
    this.mainIcon = Icons.add,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  State<FloatingActionMenu> createState() => _FloatingActionMenuState();
}

class _FloatingActionMenuState extends State<FloatingActionMenu> {
  bool isExpanded = false;

  void _toggle() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.primary;
    final iconColor = widget.iconColor ?? theme.colorScheme.onPrimary;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Nền mờ khi mở FAB
        if (isExpanded)
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.translucent,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
        // Các nút con
        ...widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: isExpanded ? 70.0 * (index + 1.2) : 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: isExpanded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Row(
                children: [
                  if (isExpanded)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    heroTag: "fab_${index}",
                    onPressed: item.onTap,
                    backgroundColor: backgroundColor,
                    child: Icon(item.icon, color: iconColor),
                    mini: true,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        // Nút chính
        FloatingActionButton(
          heroTag: "mainFab",
          onPressed: _toggle,
          backgroundColor: backgroundColor,
          child: AnimatedRotation(
            turns: isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              isExpanded ? Icons.close : widget.mainIcon,
              color: iconColor,
            ),
          ),
        ),
      ],
    );
  }
}

class FloatingActionMenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  FloatingActionMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}
