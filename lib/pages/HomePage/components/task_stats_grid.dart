import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../TaskPage/components/task.dart';

class TaskStatsGrid extends StatelessWidget {
  final List<Task> tasks;
  final Map<String, List<double>> weeklyData;

  const TaskStatsGrid({
    super.key,
    required this.tasks,
    required this.weeklyData,
  });

  double _getGrowthRate(String type) {
    final data = weeklyData[type]!;
    final current = data.last;
    final previous = data[data.length - 2];
    return ((current - previous) / previous * 100);
  }

  String _getNextDeadline(List<Task> tasks) {
    final now = DateTime.now();
    final upcomingTasks =
        tasks
            .where((t) => t.status != 'Done' && t.deadline.isAfter(now))
            .toList()
          ..sort((a, b) => a.deadline.compareTo(b.deadline));

    if (upcomingTasks.isEmpty) return 'No deadlines';

    final nextDeadline = upcomingTasks.first.deadline;
    final diff = nextDeadline.difference(now).inDays;
    return '${diff}d left';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.task_alt,
                  label: 'Total Tasks',
                  value: tasks.length.toString(),
                  color: Colors.blue,
                  subtitle: 'Last 7 days',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.radio_button_checked,
                  label: 'Active Tasks',
                  value:
                      tasks
                          .where((t) => t.status == 'Active')
                          .length
                          .toString(),
                  color: Colors.purple,
                  subtitle: 'Current',
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideX(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.pending_actions,
                  label: 'In Progress',
                  value:
                      tasks
                          .where((t) => t.status == 'In Progress')
                          .length
                          .toString(),
                  color: Colors.orange,
                  subtitle: _getNextDeadline(tasks),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.check_circle_outline,
                  label: 'Completed',
                  value:
                      tasks.where((t) => t.status == 'Done').length.toString(),
                  color: Colors.green,
                  subtitle: 'This week',
                ),
              ),
            ],
          ).animate().fadeIn(delay: 400.ms).slideX(),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row with icon, label, and trend
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1200.ms, color: color.withOpacity(0.3)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 20,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots:
                        weeklyData['total']!
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value))
                            .toList(),
                    isCurved: true,
                    color: color,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
