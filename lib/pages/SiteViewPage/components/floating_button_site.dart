import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/components/floating_action_menu.dart';

class FloatingButtonSite extends StatelessWidget {
  final VoidCallback onCreateSiteByTask;
  final VoidCallback onProposeSite;

  const FloatingButtonSite({
    super.key,
    required this.onCreateSiteByTask,
    required this.onProposeSite,
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
      ],
      mainIcon: Icons.add, // Dấu cộng
    );
  }
}
