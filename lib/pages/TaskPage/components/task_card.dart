import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/components/unified_card_footer.dart';
import 'package:siteplus_mb/components/unified_card_header.dart';
import 'package:siteplus_mb/pages/TaskPage/components/task_detail_popup.dart';
import 'package:siteplus_mb/utils/TaskPage/task_api_model.dart';
import 'package:siteplus_mb/utils/constants.dart';

class EnhancedTaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const EnhancedTaskCard({Key? key, required this.task, this.onTap})
    : super(key: key);

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
              onTap:
                  onTap ??
                  () {
                    ViewDetailTask.show(context, task);
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
                    showSecondaryBadge: false, // Không hiển thị secondary badge
                  ),

                  // Primary Content - Task Information
                  _buildPrimaryTaskContent(context),

                  // Secondary Content - Brand & Site Info (if available)
                  if (task.request?.brand != null || (task.site != null))
                    _buildSecondaryContent(context),

                  // Actions Footer
                  UnifiedCardFooter(
                    onDetailTap: () {
                      ViewDetailTask.show(context, task);
                    },
                    statusBadgeText: _getVietnameseStatus(task.status),
                    statusBadgeIcon: _getStatusIcon(task.status),
                    statusBadgeColor: _getStatusColor(context, task.status),
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

  Widget _buildPrimaryTaskContent(BuildContext context) {
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
                  icon: LucideIcons.calendar,
                  label: 'Hạn chót',
                  value: _formatDate(task.deadline),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _buildFeaturedItem(
                  context,
                  icon: LucideIcons.mapPin,
                  label: 'Khu vực',
                  value:
                      task.areaName.isNotEmpty
                          ? task.areaName
                          : 'Quận 1, TP. Hồ Chí Minh',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getDescription(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
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
          // Brand Information Section
          if (task.request?.brand != null) _buildBrandInfo(context),

          // Site Information
          if (task.site?.id != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [const SizedBox(height: 12), _buildSiteInfo(context)],
            ),
        ],
      ),
    );
  }

  Widget _buildBrandInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brand = task.request?.brand;

    if (brand == null) return const SizedBox.shrink();

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
            LucideIcons.briefcase,
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
                'Thương hiệu',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                brand.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (task.request != null) ...[
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yêu cầu',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  '#${task.request!.id.split('-').last}',
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

  Widget _buildSiteInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final site = task.site;

    if (site == null) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(LucideIcons.landmark, size: 16, color: Colors.blue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mặt bằng',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                site.address,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (site.building != null) ...[
          const SizedBox(width: 16),
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
                  site.building!.name,
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
          child: Icon(icon, size: 14, color: colorScheme.secondary),
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

  String _getVietnameseStatus(String status) {
    switch (status) {
      case STATUS_CHUA_NHAN:
        return 'Chưa nhận';
      case STATUS_DA_NHAN:
        return 'Đang xử lý';
      case STATUS_HOAN_THANH:
        return 'Hoàn thành';
      default:
        return 'Không xác định';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case STATUS_CHUA_NHAN:
        return Icons.radio_button_checked;
      case STATUS_DA_NHAN:
        return LucideIcons.clock;
      case STATUS_HOAN_THANH:
        return Icons.check_circle;
      default:
        return LucideIcons.circle;
    }
  }

  Color _getStatusColor(BuildContext context, String status) {
    final theme = Theme.of(context);
    switch (status) {
      case STATUS_CHUA_NHAN:
        return theme.colorScheme.primary;
      case STATUS_DA_NHAN:
        return Colors.orange;
      case STATUS_HOAN_THANH:
        return Colors.green;
      default:
        return theme.colorScheme.secondary;
    }
  }

  String _getDescription() {
    // Nếu có request_id, hiển thị mô tả của request
    if (task.requestId != null && task.request != null) {
      return task.request!.description;
    }
    // Nếu không, hiển thị mô tả của task
    return task.description;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
