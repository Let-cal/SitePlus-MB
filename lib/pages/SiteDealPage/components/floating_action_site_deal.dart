import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/components/floating_action_menu.dart';

class FloatingActionSiteDeal extends StatelessWidget {
  final VoidCallback onCreateSiteDeal;
  final VoidCallback onShowFilter;

  const FloatingActionSiteDeal({
    super.key,
    required this.onCreateSiteDeal,
    required this.onShowFilter,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionMenu(
      items: [
        FloatingActionMenuItem(
          label: 'Create Site Deal',
          icon: LucideIcons.handshake,
          onTap: onCreateSiteDeal,
        ),
        FloatingActionMenuItem(
          label: 'Filter Deals',
          icon: LucideIcons.filter,
          onTap: onShowFilter,
        ),
      ],
      mainIcon: Icons.add, // Dấu cộng
    );
  }
}
