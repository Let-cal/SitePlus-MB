import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:siteplus_mb/utils/HomePage/task_statistics.dart';
import 'package:siteplus_mb/utils/TaskPage/task_api_model.dart';


class TaskStatsGrid extends StatelessWidget {
  final List<Task> tasks;
  final TaskStatistics? statistics;
  final Map<String, List<double>> weeklyData;

  const TaskStatsGrid({
    super.key,
    required this.tasks,
    required this.weeklyData,
    this.statistics,
  });

  double _getGrowthRate(String type) {
    final data = weeklyData[type];
    if (data == null || data.length < 2) return 0;
    final current = data.last;
    final previous = data[data.length - 2];
    if (previous == 0) return 0;
    return ((current - previous) / previous * 100);
  }

  String _getNextDeadline(List<Task> tasks) {
    final now = DateTime.now();
    final upcomingTasks =
        tasks
            .where((t) => t.status != 'Done' && t.deadline.isAfter(now))
            .toList()
          ..sort((a, b) => a.deadline.compareTo(b.deadline));

    if (upcomingTasks.isEmpty) return 'Không có hạn chót';

    final nextDeadline = upcomingTasks.first.deadline;
    final diff = nextDeadline.difference(now).inDays;
    return '$diff ngày còn lại';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Lấy giá trị từ statistics nếu có
    final totalTasks = statistics?.totalAllDays ?? 0;
    final assignedTasks = statistics?.totalByStatus.assigned ?? 0;
    final inProgressTasks = statistics?.totalByStatus.inProgress ?? 0;
    final completedTasks = statistics?.totalByStatus.completed ?? 0;

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
                  label: 'Tổng số nhiệm vụ',
                  value: totalTasks.toString(),
                  color: Colors.blue,
                  subtitle: '7 ngày qua',
                  dataKey: 'total',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.radio_button_checked,
                  label: 'Nhiệm vụ đã giao',
                  value: assignedTasks.toString(),
                  color: Colors.purple,
                  subtitle: 'Hiện tại',
                  dataKey: 'assigned',
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
                  label: 'Đang tiến hành',
                  value: inProgressTasks.toString(),
                  color: Colors.orange,
                  subtitle: _getNextDeadline(tasks),
                  dataKey: 'inProgress',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.check_circle_outline,
                  label: 'Đã hoàn thành',
                  value: completedTasks.toString(),
                  color: Colors.green,
                  subtitle: 'Tuần này',
                  dataKey: 'completed',
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
    required String dataKey,
  }) {
    final theme = Theme.of(context);
    // Ensure we have data to display, or use fallback
    final chartData =
        weeklyData[dataKey] ?? weeklyData['total'] ?? _getDefaultData();

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
          // Header row with icon and label
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
                    spots: _getSpots(chartData),
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

  // Helper method to generate spots safely
  List<FlSpot> _getSpots(List<double> data) {
    // Ensure we have some data
    if (data.isEmpty) {
      return _getDefaultData()
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList();
    }

    return data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
  }

  // Provide default data if nothing is available
  List<double> _getDefaultData() {
    return [0, 0, 0, 0, 0, 0, 0];
  }
}