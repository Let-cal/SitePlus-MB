import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class UnifiedCardFooter extends StatelessWidget {
  /// Function called when detail button is tapped
  final VoidCallback? onDetailTap;

  /// Function called when primary action button is tapped (if available)
  final VoidCallback? onPrimaryActionTap;

  /// Primary action button label (optional)
  final String? primaryActionLabel;

  /// Primary action button icon (optional)
  final IconData? primaryActionIcon;

  /// Status badge to display on the left side (optional)
  final String? statusBadgeText;

  /// Icon for the status badge (optional)
  final IconData? statusBadgeIcon;

  /// Color for the status badge (optional)
  final Color? statusBadgeColor;

  /// Whether to show border around the detail button
  final bool showDetailButtonBorder;

  /// Optional custom widgets to display on left side
  final List<Widget>? leftWidgets;

  /// Optional custom widgets to display on right side (before buttons)
  final List<Widget>? rightWidgets;

  /// Additional padding for the footer
  final EdgeInsets padding;

  /// Whether to use a filled primary button style
  final bool usePrimaryButtonStyle;

  /// Custom text for the detail button (defaults to "Xem chi tiết")
  final String detailButtonText;

  const UnifiedCardFooter({
    Key? key,
    this.onDetailTap,
    this.onPrimaryActionTap,
    this.primaryActionLabel,
    this.primaryActionIcon,
    this.statusBadgeText,
    this.statusBadgeIcon,
    this.statusBadgeColor,
    this.showDetailButtonBorder = false,
    this.leftWidgets,
    this.rightWidgets,
    this.padding = const EdgeInsets.all(16),
    this.usePrimaryButtonStyle = true,
    this.detailButtonText = 'Xem chi tiết',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          // Left side - Status badge or custom widgets - Always on the left
          if (statusBadgeText != null)
            _buildStatusBadge(context)
          else if (leftWidgets != null && leftWidgets!.isNotEmpty)
            ...leftWidgets!,

          // Flexible spacer to push buttons to the right
          const Spacer(),

          // Right side - Custom widgets
          if (rightWidgets != null) ...rightWidgets!,

          // Primary action button if provided
          if (onPrimaryActionTap != null && primaryActionLabel != null) ...[
            ElevatedButton.icon(
              onPressed: onPrimaryActionTap,
              icon: Icon(primaryActionIcon ?? LucideIcons.fileText, size: 18),
              label: Text(primaryActionLabel!),
              style: ElevatedButton.styleFrom(
                foregroundColor: colorScheme.onPrimary,
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Detail button - always present and always on the right
          if (showDetailButtonBorder)
            OutlinedButton.icon(
              onPressed: onDetailTap,
              icon: const Icon(LucideIcons.arrowRight, size: 18),
              label: Text(detailButtonText),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(color: colorScheme.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: onDetailTap,
              icon: const Icon(LucideIcons.arrowRight, size: 18),
              label: Text(detailButtonText),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            statusBadgeColor?.withOpacity(0.1) ??
            colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusBadgeColor ?? colorScheme.primary,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (statusBadgeIcon != null) ...[
            Icon(
              statusBadgeIcon,
              size: 16,
              color: statusBadgeColor ?? colorScheme.primary,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            statusBadgeText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: statusBadgeColor ?? colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
