import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/utils/TaskPage/task_api_model.dart';
import 'package:siteplus_mb/utils/TaskPage/task_status.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCard({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Viền trái theo status
                Container(
                  width: 8,
                  height: 100,
                  decoration: BoxDecoration(
                    color: getStatusColor(context, task.status),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                // Icon
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    LucideIcons.clipboardList,
                    color: colorScheme.primary,
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task ID
                        Text(
                          'Task #${task.id}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Task Description
                        Text(
                          task.description.isNotEmpty
                              ? task.description
                              : 'No Infomation',
                          style: theme.textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Deadline và Area Name
                        Row(
                          children: [
                            Icon(
                              LucideIcons.calendar,
                              size: 16,
                              color: colorScheme.onSurface,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(task.deadline),
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              LucideIcons.mapPin,
                              size: 16,
                              color: colorScheme.onSurface,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.areaName.isNotEmpty
                                  ? task.areaName
                                  : 'District 1, Ho Chi Minh City',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Status và Priority ở góc phải trên
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  _buildStatusBadge(context, task.status, colorScheme),
                  const SizedBox(width: 4),
                  _buildPriorityBadge(context, task.priority, colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(context, String status, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: getStatusColor(context, status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        getStatusText(status),
        style: TextStyle(
          color: getStatusColor(context, status),
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(
    context,
    String priority,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: getStatusPriorityColor(context, priority).withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: getStatusPriorityColor(context, priority),
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
