import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/utils/TaskPage/dead_line_utils.dart';
import 'package:siteplus_mb/utils/TaskPage/task_api_model.dart';
import 'package:siteplus_mb/utils/TaskPage/task_status.dart';
import 'package:siteplus_mb/utils/constants.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCard({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Only show deadline warning for tasks that are not completed
    final bool showDeadlineWarning =
        task.status != STATUS_HOAN_THANH && task.isDeadlineWarning;

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
          border:
              showDeadlineWarning && task.daysToDeadline < 0
                  ? Border.all(color: Colors.red.withOpacity(0.5), width: 1)
                  : null,
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Status bar on the left
                Container(
                  width: 8,
                  height: 110, // Fixed height, as layout adjusts dynamically
                  decoration: BoxDecoration(
                    color: getStatusColor(context, task.status),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                // Task icon
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
                              : 'No Information',
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Conditional layout for deadline warning
                        if (showDeadlineWarning) ...[
                          // Deadline warning row
                          Row(
                            children: [
                              Icon(
                                LucideIcons.calendar,
                                size: 16,
                                color: DeadlineUtils.getDeadlineColor(
                                  task.daysToDeadline,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(task.deadline),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: DeadlineUtils.getDeadlineColor(
                                    task.daysToDeadline,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                DeadlineUtils.getDeadlineIcon(
                                  task.daysToDeadline,
                                ),
                                size: 16,
                                color: DeadlineUtils.getDeadlineColor(
                                  task.daysToDeadline,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  DeadlineUtils.getDeadlineMessage(
                                    task.daysToDeadline,
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: DeadlineUtils.getDeadlineColor(
                                      task.daysToDeadline,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Deadline and Area name row
                          Row(
                            children: [
                              Icon(
                                LucideIcons.mapPin,
                                size: 16,
                                color: colorScheme.onSurface,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  task.areaName.isNotEmpty
                                      ? task.areaName
                                      : 'District 1, Ho Chi Minh City',
                                  style: theme.textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // No deadline warning: single row
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
                              Expanded(
                                child: Text(
                                  task.areaName.isNotEmpty
                                      ? task.areaName
                                      : 'District 1, Ho Chi Minh City',
                                  style: theme.textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Status and Priority badges
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

  Widget _buildDeadlineWarning(BuildContext context) {
    final color = DeadlineUtils.getDeadlineColor(task.daysToDeadline);
    final icon = DeadlineUtils.getDeadlineIcon(task.daysToDeadline);
    final message = DeadlineUtils.getDeadlineMessage(task.daysToDeadline);

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
