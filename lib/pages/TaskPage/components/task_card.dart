import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/components/SiteCardvsTaskCard/primary_card_content.dart';
import 'package:siteplus_mb/components/SiteCardvsTaskCard/secondary_card_content.dart';
import 'package:siteplus_mb/components/unified_card_footer.dart';
import 'package:siteplus_mb/components/unified_card_header.dart';
import 'package:siteplus_mb/pages/TaskPage/components/task_detail_popup.dart';
import 'package:siteplus_mb/utils/TaskPage/task_api_model.dart';
import 'package:siteplus_mb/utils/TaskPage/task_status.dart';
import 'package:siteplus_mb/utils/constants.dart';

class EnhancedTaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final void Function(int? filterSiteId)? onNavigateToSiteTab;
  const EnhancedTaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onNavigateToSiteTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine if secondary content exists
    final hasSecondaryContent =
        task.request?.brand != null || (task.site != null);

    return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap:
                  onTap ??
                  () {
                    ViewDetailTask.show(
                      context,
                      task,
                      onNavigateToSiteTab: onNavigateToSiteTab,
                    );
                  },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Header with Featured Information
                  UnifiedCardHeader(
                    title: 'Nhiệm vụ #${task.id}',
                    subtitle: task.name,
                    icon: LucideIcons.clipboardList,
                    iconColor: theme.colorScheme.primary,
                    badgeText: task.priority ?? '',
                    badgeIcon:
                        task.priority == PRIORITY_CAO
                            ? Icons.priority_high
                            : task.priority == PRIORITY_TRUNG_BINH
                            ? Icons.density_medium
                            : Icons.low_priority,
                    badgeColor:
                        task.priority == PRIORITY_CAO
                            ? theme.colorScheme.error
                            : task.priority == PRIORITY_TRUNG_BINH
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.tertiary,
                    showSecondaryBadge: false,
                  ),

                  // Primary Content - Task Information
                  PrimaryCardContent(
                    featuredItems: [
                      FeaturedItem(
                        icon: LucideIcons.calendar,
                        label: 'Hạn chót',
                        value: _formatDate(task.deadline),
                        preventLineBreak:
                            true, // Prevent date from breaking to next line
                      ),
                      FeaturedItem(
                        icon: LucideIcons.mapPin,
                        label: 'Khu vực',
                        value:
                            task.areaName.isNotEmpty
                                ? task.areaName
                                : 'Quận 1, TP. Hồ Chí Minh',
                        flex: 2,
                      ),
                    ],
                    description: task.description,
                  ),

                  // Secondary Content - Brand & Site Info (if available)
                  if (hasSecondaryContent) _buildTaskSecondaryContent(context),

                  // Add divider if there's no secondary content
                  if (!hasSecondaryContent)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: colorScheme.onSurface.withOpacity(0.1),
                    ),

                  // Actions Footer
                  UnifiedCardFooter(
                    onDetailTap: () {
                      ViewDetailTask.show(context, task);
                    },
                    statusBadgeText: getVietnameseStatus(task.status),
                    statusBadgeIcon: getStatusIcon(task.status),
                    statusBadgeColor: getStatusColor(context, task.status),
                    showDetailButtonBorder: true,
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildTaskSecondaryContent(BuildContext context) {
    final theme = Theme.of(context);
    final sections = <InfoSection>[];

    // Brand and Request section
    if (task.request?.brand != null) {
      final brandItems = <InfoItem>[];

      // Brand info
      brandItems.add(
        InfoItem(
          icon: LucideIcons.briefcase,
          iconColor: Colors.amber,
          iconBackgroundColor: Colors.amber.withOpacity(0.2),
          label: 'Thương hiệu',
          value: task.request!.brand.name,
        ),
      );

      // Request info
      if (task.request != null) {
        brandItems.add(
          InfoItem(
            icon: LucideIcons.clipboardPen,
            iconColor: Colors.amber,
            iconBackgroundColor: Colors.amber.withOpacity(0.2),
            label: 'Yêu cầu',
            value: '#${task.request!.id.split('-').last}',
          ),
        );
      }

      sections.add(InfoSection(items: brandItems));
    }

    // Site and Building section
    if (task.site?.id != null) {
      final siteItems = <InfoItem>[];

      // Site info
      siteItems.add(
        InfoItem(
          icon: LucideIcons.landmark,
          iconColor: theme.colorScheme.primary,
          iconBackgroundColor: theme.colorScheme.primary.withOpacity(0.2),
          label: 'Mặt bằng #${task.site?.id}',
          value: task.site!.address,
        ),
      );

      // Building info
      if (task.site?.building != null) {
        siteItems.add(
          InfoItem(
            icon: LucideIcons.building,
            iconColor: Colors.blue,
            iconBackgroundColor: Colors.blue.withOpacity(0.2),
            label: 'Tòa nhà',
            value: task.site!.building!.name,
          ),
        );
      }
      if (siteItems.isNotEmpty) {
        sections.add(InfoSection(items: siteItems));
      }
    }
    if (sections.isEmpty) {
      return const SizedBox(height: 0);
    }
    return SecondaryCardContent(sections: sections);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
