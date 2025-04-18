import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:siteplus_mb/utils/HomePage/task_statistics.dart';
import 'package:siteplus_mb/utils/TaskPage/task_api_model.dart';

class CompactTaskStatsGrid extends StatelessWidget {
  final List<Task> tasks;
  final TaskStatistics? statistics;
  final Map<String, List<double>> weeklyData;

  const CompactTaskStatsGrid({
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

  String _formatGrowthRate(String type) {
    final rate = _getGrowthRate(type);
    final sign = rate >= 0 ? '+' : '';
    return '$sign${rate.toStringAsFixed(1)}%';
  }

  String _getNextDeadline(List<Task> tasks) {
    final now = DateTime.now();
    final upcomingTasks =
        tasks
            .where((t) => t.status != 'Done' && t.deadline.isAfter(now))
            .toList()
          ..sort((a, b) => a.deadline.compareTo(b.deadline));

    if (upcomingTasks.isEmpty) return 'No deadline';

    final nextDeadline = upcomingTasks.first.deadline;
    final diff = nextDeadline.difference(now).inDays;
    return '$diff days remaining';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get values from statistics if available
    final totalTasks = statistics?.totalAllDays ?? 0;
    final assignedTasks = statistics?.totalByStatus.assigned ?? 0;
    final inProgressTasks = statistics?.totalByStatus.inProgress ?? 0;
    final completedTasks = statistics?.totalByStatus.completed ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
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
                  value: totalTasks.toString(),
                  color: Colors.blue,
                  subtitle: 'Past 7 days',
                  dataKey: 'total',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.radio_button_checked,
                  label: 'Assigned Tasks',
                  value: assignedTasks.toString(),
                  color: Colors.purple,
                  subtitle: 'Currently',
                  dataKey: 'assigned',
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideX(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.pending_actions,
                  label: 'In Progress',
                  value: inProgressTasks.toString(),
                  color: Colors.orange,
                  subtitle: _getNextDeadline(tasks),
                  dataKey: 'inProgress',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.check_circle_outline,
                  label: 'Completed',
                  value: completedTasks.toString(),
                  color: Colors.green,
                  subtitle: 'This week',
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
    
    // Calculate growth rate for this data type
    final growthRate = _formatGrowthRate(dataKey);
    final isPositive = !growthRate.startsWith('-');

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
          // Value with growth rate indicator (similar to report cards)
          Row(
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().shimmer(duration: 1200.ms, color: color.withOpacity(0.3)),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      color: color,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      growthRate,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                minX: 0,
                maxX: chartData.length - 1.0,
                minY: 0,
                maxY: chartData.isEmpty ? 10 : 
                    chartData.reduce((max, value) => value > max ? value : max) * 1.2,
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