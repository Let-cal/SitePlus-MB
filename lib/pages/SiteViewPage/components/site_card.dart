import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/components/SiteCardvsTaskCard/primary_card_content.dart';
import 'package:siteplus_mb/components/SiteCardvsTaskCard/secondary_card_content.dart';
import 'package:siteplus_mb/components/unified_card_footer.dart';
import 'package:siteplus_mb/components/unified_card_header.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/site_detail_popup.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_status.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_view_model.dart';

class SiteCard extends StatelessWidget {
  final Site site;
  final Map<int, String> siteCategoryMap;
  final Map<int, String> areaMap;
  final VoidCallback? onTap;
  final VoidCallback? onCreateReport;
  final void Function(int? filterTaskId)? onNavigateToTaskTab;
  const SiteCard({
    super.key,
    required this.site,
    required this.siteCategoryMap,
    required this.areaMap,
    this.onTap,
    this.onCreateReport,
     this.onNavigateToTaskTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine if secondary content exists
    final hasSecondaryContent =
        site.task != null ||
        (site.siteCategoryId == 1 && site.building != null);

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
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Site Header with Featured Information
                  UnifiedCardHeader(
                    title: 'Mặt bằng #${site.id}',
                    subtitle: siteCategoryMap[site.siteCategoryId] ?? 'N/A',
                    icon: LucideIcons.landmark,
                    iconColor: theme.colorScheme.primary,
                    badgeText: getVietnameseStatus(site.status),
                    badgeIcon: getStatusIcon(site.status),
                    badgeColor: getStatusColor(context, site.status),
                    showSecondaryBadge: false,
                  ),

                  // Primary Content - Site Information
                  PrimaryCardContent(
                    featuredItems: [
                      FeaturedItem(
                        icon: LucideIcons.ruler,
                        label: 'Diện tích',
                        value: '${site.size} m²',
                      ),
                      FeaturedItem(
                        icon: LucideIcons.mapPin,
                        label: 'Địa chỉ',
                        value: site.address ?? 'N/A',
                        flex: 2,
                      ),
                    ],
                    additionalInfo: Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: 16,
                          color: colorScheme.secondary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ngày tạo: ${_formatDate(site.createdAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Secondary Content - Task & Building Info
                  if (hasSecondaryContent) _buildSiteSecondaryContent(context),

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
                      ViewDetailSite.show(
                        context,
                        site,
                        siteCategoryMap,
                        areaMap,
                        onNavigateToTaskTab: onNavigateToTaskTab
                      );
                    },
                    onPrimaryActionTap:
                        site.status == 1 ? onCreateReport : null,
                    primaryActionLabel: site.status == 1 ? 'Tạo báo cáo' : null,
                    primaryActionIcon: LucideIcons.fileText,
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

  Widget _buildSiteSecondaryContent(BuildContext context) {
    final sections = <InfoSection>[];

    // Task information section
    if (site.task != null) {
      sections.add(
        InfoSection(
          items: [
            InfoItem(
              icon: LucideIcons.clipboardList,
              iconColor: Colors.amber,
              iconBackgroundColor: Colors.amber.withOpacity(0.2),
              label: 'Nhiệm vụ #${site.task?.id}',
              value: site.task?.name ?? 'N/A',
            ),
          ],
        ),
      );
    }

    // Building and Area information
    if (site.siteCategoryId == 1 && site.building != null) {
      final buildingItems = <InfoItem>[];

      // Building info
      buildingItems.add(
        InfoItem(
          icon: LucideIcons.building,
          iconColor: Colors.blue,
          iconBackgroundColor: Colors.blue.withOpacity(0.2),
          label: 'Tòa nhà',
          value: site.building?.name ?? 'N/A',
        ),
      );

      // Area info
      if (site.building != null) {
        buildingItems.add(
          InfoItem(
            icon: LucideIcons.mapPin,
            iconColor: Colors.blueGrey,
            iconBackgroundColor: Colors.blueGrey.withOpacity(0.2),
            label: 'Khu vực',
            value: areaMap[site.building!.areaId] ?? 'N/A',
          ),
        );
      }

      if (buildingItems.isNotEmpty) {
        sections.add(InfoSection(items: buildingItems));
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
