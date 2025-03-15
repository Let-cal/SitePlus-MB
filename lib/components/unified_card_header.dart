import 'package:flutter/material.dart';

class UnifiedCardHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  // Primary badge (right side)
  final String badgeText;
  final IconData badgeIcon;
  final Color badgeColor;

  // Optional secondary badge (can be used for location or category)
  final String? secondaryBadgeText;
  final IconData? secondaryBadgeIcon;
  final Color? secondaryBadgeColor;

  // Layout options
  final bool showSecondaryBadge;
  final bool secondaryBadgeBelow;

  const UnifiedCardHeader({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.badgeText,
    required this.badgeIcon,
    required this.badgeColor,
    this.secondaryBadgeText,
    this.secondaryBadgeIcon,
    this.secondaryBadgeColor,
    this.showSecondaryBadge = false,
    this.secondaryBadgeBelow = true,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth =
            constraints.hasBoundedWidth
                ? constraints.maxWidth
                : MediaQuery.of(context).size.width;
        return Container(
          width: containerWidth,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.05),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon and title information
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: iconColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Primary badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBadge(
                        text: badgeText,
                        icon: badgeIcon,
                        color: badgeColor,
                      ),
                      // Secondary badge below primary badge
                      if (showSecondaryBadge && !secondaryBadgeBelow)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildBadge(
                            text: secondaryBadgeText ?? '',
                            icon: secondaryBadgeIcon ?? Icons.circle,
                            color:
                                secondaryBadgeColor ??
                                theme.colorScheme.secondary,
                            isSmall: true,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              // Optional secondary badge at bottom of the header
              if (showSecondaryBadge && secondaryBadgeBelow)
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 46),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBadge(
                        text: secondaryBadgeText ?? '',
                        icon: secondaryBadgeIcon ?? Icons.circle,
                        color:
                            secondaryBadgeColor ?? theme.colorScheme.secondary,
                        isSmall: true,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge({
    required String text,
    required IconData icon,
    required Color color,
    bool isSmall = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min, // Ensure Row takes minimum required space
        children: [
          Icon(icon, size: isSmall ? 14 : 16, color: color),
          SizedBox(width: isSmall ? 4 : 6),
          Text(
            text,
            style: TextStyle(
              fontSize: isSmall ? 12 : 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis, // Added to handle text overflow
          ),
        ],
      ),
    );
  }
}
