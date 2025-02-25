import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:siteplus_mb/pages/TaskPage/components/task.dart';

import '../utils/report_navigation.dart';
import './report_selection_dialog.dart';

class ViewDetailTask extends StatelessWidget {
  final Task task;

  const ViewDetailTask({Key? key, required this.task}) : super(key: key);

  // Method to show the bottom sheet
  static Future<void> show(BuildContext context, Task task) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ViewDetailTask(task: task),
    );
  }

  void _showReportSelection(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => ReportSelectionDialog(
            onReportSelected: (String reportType) {
              ReportNavigation.navigateToReport(context, reportType);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildTaskTitle(context),
                      const SizedBox(height: 24),
                      _buildInfoCard(
                        context,
                        title: 'Task Information',
                        icon: Icons.assignment,
                        child: _buildTaskInfo(context),
                      ),
                      const SizedBox(height: 16),
                      if (task.request?.brand != null) ...[
                        _buildInfoCard(
                          context,
                          title: 'Brand Information',
                          icon: Icons.business,
                          child: _buildBrandInfo(context),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (task.site != null) ...[
                        _buildInfoCard(
                          context,
                          title: 'Site Information',
                          icon: Icons.location_on,
                          child: _buildSiteInfo(context),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildInfoCard(
                        context,
                        title: 'Task Description',
                        icon: Icons.description,
                        child: _buildDescription(context),
                      ),
                      const SizedBox(height: 24),
                      _buildActionButtons(context),
                      const SizedBox(height: 32),
                    ],
                  )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slide(
                    duration: 400.ms,
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                    curve: Curves.easeOutQuad,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.article_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Task Details',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTitle(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ID#: ',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            Text(
              task.id,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            _buildStatusBadge(context),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          task.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildTaskInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context,
          label: 'Priority',
          value: task.priority,
          valueColor:
              task.priority.toLowerCase() == 'high'
                  ? theme.colorScheme.error
                  : theme.colorScheme.tertiary,
          icon:
              task.priority.toLowerCase() == 'high'
                  ? Icons.priority_high
                  : Icons.low_priority,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          label: 'Deadline',
          value: _formatDate(task.deadline),
          icon: Icons.calendar_today,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          label: 'Status',
          value: task.status,
          icon: _getStatusIcon(task.status),
          valueColor: _getStatusColor(context, task.status),
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          label: 'Location',
          value: _getLocationText(),
          icon: Icons.location_on,
        ),
        if (task.request != null) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            label: 'Request ID',
            value: task.requestId ?? 'N/A',
            icon: Icons.numbers,
          ),
        ],
      ],
    );
  }

  Widget _buildBrandInfo(BuildContext context) {
    final theme = Theme.of(context);
    final brand = task.request?.brand;

    if (brand == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context,
          label: 'Brand Name',
          value: brand.name,
          icon: Icons.business,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSiteInfo(BuildContext context) {
    final theme = Theme.of(context);
    final site = task.site;

    if (site == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context,
          label: 'Site Name',
          value: site.name,
          icon: Icons.place,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          label: 'Address',
          value: site.address,
          icon: Icons.map,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          label: 'District',
          value: site.district,
          icon: Icons.location_city,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          label: 'City',
          value: site.city,
          icon: Icons.location_on,
        ),
        if (site.building != null) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            label: 'Building',
            value: site.building!.name,
            icon: Icons.business,
          ),
        ],
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    final theme = Theme.of(context);

    String description = _getDescription();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.secondary.withOpacity(0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            label: const Text('Close'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: theme.colorScheme.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _showReportSelection(context),
            icon: const Icon(Icons.edit),
            label: const Text('Create Report'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final theme = Theme.of(context);
    final status = task.status.toLowerCase();
    final color = _getStatusColor(context, task.status);
    final icon = _getStatusIcon(task.status);

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              task.status,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocationText() {
    if (task.site != null) {
      return '${task.site!.district}, ${task.site!.city}';
    }
    return 'Quận 1, TP. Hồ Chí Minh'; // Default location
  }

  String _getDescription() {
    // If there's a request_id, show the request description
    if (task.requestId != null && task.request != null) {
      return task.request!.description;
    }
    // Otherwise, show the task description
    return task.description;
  }

  Color _getStatusColor(BuildContext context, String status) {
    final theme = Theme.of(context);
    final statusLower = status.toLowerCase();

    switch (statusLower) {
      case 'active':
        return theme.colorScheme.primary;
      case 'in progress':
        return theme.colorScheme.tertiary;
      case 'done':
        return Colors.green;
      default:
        return theme.colorScheme.secondary;
    }
  }

  IconData _getStatusIcon(String status) {
    final statusLower = status.toLowerCase();

    switch (statusLower) {
      case 'active':
        return Icons.radio_button_checked;
      case 'in progress':
        return Icons.pending;
      case 'done':
        return Icons.check_circle;
      default:
        return Icons.circle_outlined;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
