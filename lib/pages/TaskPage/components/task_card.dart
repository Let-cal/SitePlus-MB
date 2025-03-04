import 'package:flutter/material.dart';
import 'package:siteplus_mb/pages/TaskPage/components/task_detail_popup.dart';
import 'package:siteplus_mb/utils/TaskPage/task_api_model.dart'; // Update import to use our unified model
import 'package:siteplus_mb/utils/constants.dart';

class EnhancedTaskCard extends StatelessWidget {
  final Task task;

  const EnhancedTaskCard({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row chứa ID
                          Row(
                            children: [
                              Text(
                                'ID#: ',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                task.id,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          // Vị trí với icon
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: theme.colorScheme.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getLocationText(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      _buildPriorityBadge(context),
                    ],
                  ),
                ),

                // Brand info section (if available)
                if (task.request?.brand != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 8),
                    child: _buildBrandInfo(context),
                  ),

                // Title and deadline section
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          task.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(task.deadline),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Description section
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
                  child: Text(
                    _getDescription(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Site info section (if completed)
                if (task.status == STATUS_HOAN_THANH && task.site != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 8),
                    child: _buildSiteInfo(context),
                  ),

                Column(
                  children: [
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: theme.colorScheme.outlineVariant,
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        12,
                        12,
                        12,
                        8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildViewDetailsButton(context),
                          _buildStatusBadge(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandInfo(BuildContext context) {
    final theme = Theme.of(context);
    final brand = task.request?.brand;

    if (brand == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.business, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            brand.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '| Request #${task.request!.id.split('-').last}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteInfo(BuildContext context) {
    final theme = Theme.of(context);
    final site = task.site;

    if (site == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.place, size: 16, color: theme.colorScheme.tertiary),
              const SizedBox(width: 8),
              Text(
                site.areaName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          if (site.building != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 24),
              child: Text(
                'Tòa nhà: ${site.building!.name}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.tertiary.withOpacity(0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 24),
            child: Text(
              site.address,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.tertiary.withOpacity(0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getLocationText() {
    return task.areaName.isNotEmpty ? task.areaName : 'Quận 1, TP. Hồ Chí Minh';
  }

  String _getDescription() {
    // Nếu có request_id, hiển thị mô tả của request
    if (task.requestId != null && task.request != null) {
      return task.request!.description;
    }
    // Nếu không, hiển thị mô tả của task
    return task.description;
  }

  Widget _buildPriorityBadge(BuildContext context) {
    final theme = Theme.of(context);
    final isHighPriority = task.priority == PRIORITY_CAO;

    return Container(
      height: 28,
      decoration: BoxDecoration(
        color:
            isHighPriority
                ? theme.colorScheme.errorContainer
                : theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isHighPriority ? Icons.priority_high : Icons.low_priority,
              size: 16,
              color:
                  isHighPriority
                      ? theme.colorScheme.error
                      : theme.colorScheme.tertiary,
            ),
            const SizedBox(width: 4),
            Text(
              task.priority,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    isHighPriority
                        ? theme.colorScheme.error
                        : theme.colorScheme.tertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewDetailsButton(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        // Show the ViewDetailTask bottom sheet
        ViewDetailTask.show(context, task);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outline, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Xem chi tiết',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final theme = Theme.of(context);
    final status = task.status;

    late final ColorScheme colors;
    late final IconData icon;

    switch (status) {
      case STATUS_CHUA_NHAN:
        colors = ColorScheme.fromSeed(
          seedColor: theme.colorScheme.primary,
          brightness: theme.brightness,
        );
        icon = Icons.radio_button_checked;
        break;
      case STATUS_DA_NHAN:
        colors = ColorScheme.fromSeed(
          seedColor: theme.colorScheme.tertiary,
          brightness: theme.brightness,
        );
        icon = Icons.pending;
        break;
      case STATUS_HOAN_THANH:
        colors = ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: theme.brightness,
        );
        icon = Icons.check_circle;
        break;
      default:
        colors = theme.colorScheme;
        icon = Icons.circle_outlined;
    }

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: colors.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.primary, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: colors.primary),
            const SizedBox(width: 6),
            Text(
              status,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
