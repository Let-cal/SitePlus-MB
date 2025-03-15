import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/components/unified_card_footer.dart';
import 'package:siteplus_mb/components/unified_card_header.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/site_detail_popup.dart';
import 'package:siteplus_mb/utils/Site/site_model.dart';

class SiteCard extends StatelessWidget {
  final Site site;
  final Map<int, String> siteCategoryMap;
  final Map<int, String> areaMap;
  final VoidCallback? onTap;
  final VoidCallback? onCreateReport;

  const SiteCard({
    Key? key,
    required this.site,
    required this.siteCategoryMap,
    required this.areaMap,
    this.onTap,
    this.onCreateReport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                badgeText: _getVietnameseStatus(site.status),
                badgeIcon: _getStatusIcon(site.status),
                badgeColor: _getStatusColor(context, site.status),
                showSecondaryBadge: false,
              ),

              // Primary Content - Site Information
              _buildPrimarySiteContent(context),

              // Secondary Content - Task & Building Info (Collapsible/Expandable)
              _buildSecondaryContent(context),

              // Actions Footer
              UnifiedCardFooter(
                onDetailTap: () {
                  ViewDetailSite.show(context, site, siteCategoryMap, areaMap);
                },
                onPrimaryActionTap: site.status == 1 ? onCreateReport : null,
                primaryActionLabel: site.status == 1 ? 'Tạo báo cáo' : null,
                primaryActionIcon: LucideIcons.fileText,
                showDetailButtonBorder:
                    true, // Thêm border cho nút xem chi tiết
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPrimarySiteContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildFeaturedItem(
                  context,
                  icon: LucideIcons.ruler,
                  label: 'Diện tích',
                  value: '${site.size} m²',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _buildFeaturedItem(
                  context,
                  icon: LucideIcons.mapPin,
                  label: 'Địa chỉ',
                  value: site.address ?? 'N/A',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
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
        ],
      ),
    );
  }

  Widget _buildSecondaryContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          top: BorderSide(color: colorScheme.onSurface.withOpacity(0.1)),
          bottom: BorderSide(color: colorScheme.onSurface.withOpacity(0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task Information Section
          if (site.task != null) _buildTaskInfo(context),

          // Building Information (Conditional)
          if (site.siteCategoryId == 1 && site.building != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (site.task != null) const SizedBox(height: 12),
                _buildBuildingInfo(context),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTaskInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            LucideIcons.clipboardList,
            size: 16,
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nhiệm vụ #${site.task?.id}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                site.task?.name ?? 'N/A',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBuildingInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(LucideIcons.building, size: 16, color: Colors.blue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tòa nhà',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                site.building?.name ?? 'N/A',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (site.building != null && site.building!.areaId != null) ...[
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Khu vực',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  areaMap[site.building!.areaId] ?? 'N/A',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFeaturedItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: colorScheme.secondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getVietnameseStatus(int status) {
    switch (status) {
      case 1:
        return 'Có sẵn';
      case 2:
        return 'Đang tiến hành';
      case 3:
        return 'Chờ phê duyệt';
      case 4:
        return 'Bị từ chối';
      case 5:
        return 'Đã đóng';
      default:
        return 'Không xác định';
    }
  }

  // Phần cần sửa cho phương thức _getStatusIcon
  IconData _getStatusIcon(int status) {
    switch (status) {
      case 1:
        return LucideIcons.check;
      case 2:
        return LucideIcons.loader;
      case 3:
        return LucideIcons.clock;
      case 4:
        return LucideIcons.x;
      case 5:
        return LucideIcons.folderClosed;
      default:
        return LucideIcons.handHelping;
    }
  }

  // Phần cần sửa cho phương thức _getStatusColor
  Color _getStatusColor(BuildContext context, int status) {
    final theme = Theme.of(context);
    switch (status) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 4:
        return theme.colorScheme.error;
      case 5:
        return Colors.grey;
      default:
        return theme.colorScheme.secondary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
