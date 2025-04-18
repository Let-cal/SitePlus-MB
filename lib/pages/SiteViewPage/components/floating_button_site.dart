import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/components/floating_action_menu.dart';

class FloatingButtonSite extends StatelessWidget {
  final VoidCallback onCreateSiteByTask;
  final VoidCallback onProposeSite;
  final VoidCallback onShowFilter;
  const FloatingButtonSite({
    super.key,
    required this.onCreateSiteByTask,
    required this.onProposeSite,
    required this.onShowFilter,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionMenu(
      items: [
        FloatingActionMenuItem(
          label: 'Create Site',
          icon: LucideIcons.landmark,
          onTap: onCreateSiteByTask,
        ),
        FloatingActionMenuItem(
          label: 'Propose Site',
          icon: LucideIcons.lightbulb,
          onTap: onProposeSite,
        ),
        FloatingActionMenuItem(
          label: 'Filter Sites',
          icon: LucideIcons.filter,
          onTap: onShowFilter,
        ),
      ],
      mainIcon: Icons.add, // Dấu cộng
    );
  }
}
