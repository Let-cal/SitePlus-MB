import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:siteplus_mb/pages/StatisticsPage/components/custom_scroll.dart';
import 'package:siteplus_mb/pages/StatisticsPage/components/task_stats_grid.dart';
import 'package:siteplus_mb/utils/HomePage/site_report_provider.dart';
import 'package:siteplus_mb/utils/HomePage/task_statistics_provider.dart';

class StatisticsSummary extends StatefulWidget {
  const StatisticsSummary({Key? key}) : super(key: key);

  @override
  State<StatisticsSummary> createState() => _StatisticsSummaryState();
}

class _StatisticsSummaryState extends State<StatisticsSummary> {
  final PageController _statsPageController = PageController();
  int _currentStatsPage = 0;

  void _changeStatsPage(int page) {
    if (_currentStatsPage == page)
      return; // Tránh animation khi nhấn vào tab hiện tại

    // Sử dụng hiệu ứng lướt ngang cho việc chuyển trang
    _statsPageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 600), // Thời gian dài hơn
      curve: Curves.easeInOutCubic, // Đường cong mượt mà hơn
    );

    setState(() {
      _currentStatsPage = page;
    });
  }

  @override
  void initState() {
    super.initState();
    final siteReportProvider = Provider.of<SiteReportProvider>(
      context,
      listen: false,
    );
    siteReportProvider.fetchSiteReportStatistics();
  }

  @override
  void dispose() {
    _statsPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context)
              .animate()
              .fadeIn(delay: 100.ms)
              .slideY(begin: -0.2, end: 0, curve: Curves.easeOutQuad),
          const SizedBox(height: 16),

          // Horizontal scrollable content for statistics
          _buildStatisticsCarousel().animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where your vision meets the perfect space',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'We turn possibilities into prosperous places',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Statistics tabs
        Row(
          children: [
            _buildTab(
              'Task Statistics',
              isActive: _currentStatsPage == 0,
              index: 0,
            ),
            const SizedBox(width: 16),
            _buildTab(
              'Report Statistics',
              isActive: _currentStatsPage == 1,
              index: 1,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Scrollable statistics section - removing fixed height to adapt to content
        // Sửa trong _buildStatisticsCarousel()
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              constraints: BoxConstraints(minHeight: 200, maxHeight: 325),
              child: PageView(
                controller: _statsPageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentStatsPage = page;
                  });
                },
                // Thêm hiệu ứng cuộn trang
                pageSnapping: true, // Đảm bảo trang "snap" vào vị trí
                physics:
                    const CustomScrollPhysics(), // Tạo physics tùy chỉnh nếu cần
                children: [
                  _buildTaskStatisticsSection()
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideX(
                        begin: _currentStatsPage > 0 ? -0.1 : 0.1,
                        end: 0,
                      ),

                  _buildReportStatisticsSection()
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideX(
                        begin: _currentStatsPage < 1 ? 0.1 : -0.1,
                        end: 0,
                      ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTab(String title, {required bool isActive, required int index}) {
    return GestureDetector(
          onTap: () => _changeStatsPage(index),
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 500,
            ), // Thời gian chuyển màu dài hơn
            curve: Curves.easeInOut, // Đường cong mượt mà cho chuyển đổi
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isActive
                      ? Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(isActive ? 1.0 : 0.0)
                      : Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Thêm hiệu ứng pulse cho tab active
                if (isActive)
                  Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.greenAccent,
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scaleXY(begin: 0.8, end: 1.0, duration: 800.ms)
                      .then(delay: 200.ms),

                Text(
                  title,
                  style: TextStyle(
                    color:
                        isActive
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(target: isActive ? 1 : 0)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.05, 1.05), // Làm cho active tab hơi lớn hơn
          duration: 300.ms,
          curve: Curves.easeOutBack, // Đường cong làm cho animation nảy nhẹ
        )
        .then()
        .scale(
          begin: const Offset(1.05, 1.05),
          end: const Offset(1.0, 1.0),
          duration: 200.ms,
        )
        .slideY(
          begin: 0.1,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildTaskStatisticsSection() {
    return Consumer<TaskStatisticsProvider>(
      builder: (context, taskStatsProvider, child) {
        if (taskStatsProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (taskStatsProvider.errorMessage != null) {
          return _buildErrorWidget(
            taskStatsProvider.errorMessage!,
            onRetry: () => taskStatsProvider.refreshTaskStatistics(),
          );
        } else if (taskStatsProvider.taskStatistics == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Text('No task data available'),
            ),
          );
        }

        // Using compact style task stats
        return CompactTaskStatsGrid(
          tasks: [], // Your task list
          weeklyData: taskStatsProvider.weeklyData,
          statistics: taskStatsProvider.taskStatistics,
        );
      },
    );
  }

  Widget _buildReportStatisticsSection() {
    return Consumer<SiteReportProvider>(
      builder: (context, siteReportProvider, child) {
        if (siteReportProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (siteReportProvider.errorMessage != null) {
          return _buildErrorWidget(
            siteReportProvider.errorMessage!,
            onRetry: () => siteReportProvider.refreshSiteReportStatistics(),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
        } else if (siteReportProvider.siteReportStatistics == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Text('No report data available'),
            ),
          ).animate().fadeIn(delay: 200.ms);
        }

        return _buildCompactReportStats(
          siteReportProvider,
        ).animate().fadeIn(delay: 200.ms);
      },
    );
  }

  Widget _buildErrorWidget(String message, {required VoidCallback onRetry}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 48,
          ).animate().shakeX(amount: 0.2, duration: 700.ms),
          const SizedBox(height: 8),
          Text(
            'Unable to load data',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(color: theme.colorScheme.onErrorContainer),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: const Text('Try Again'),
          ).animate().scale(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildCompactReportStats(SiteReportProvider provider) {
    final theme = Theme.of(context);
    final statistics = provider.siteReportStatistics;
    final reportData = provider.reportData;

    // ignore: unnecessary_null_comparison
    if (statistics == null || reportData == null) {
      return const Center(child: Text('No report data available'));
    }

    // Tính totalAllDays chỉ cho 3 status được chọn
    final selectedStatuses = ['PendingApproval', 'Available', 'Refuse'];
    int totalAllDaysSelected = 0;
    for (var status in selectedStatuses) {
      totalAllDaysSelected += statistics.totalByStatus[status] ?? 0;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Total và Available
          Row(
            children: [
              Expanded(
                child: _buildCompactReportCard(
                  'Total Reports',
                  totalAllDaysSelected.toString(),
                  reportData['total'] != null
                      ? provider.calculatePercentageChange(reportData['total']!)
                      : '+0.0%',
                  theme.colorScheme.primary,
                  reportData['total'] ?? [0, 0, 0, 0, 0, 0, 0],
                  Icons.description,
                  'Past 7 days',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactReportCard(
                  'Available',
                  (statistics.totalByStatus['Available'] ?? 0).toString(),
                  reportData['available'] != null
                      ? provider.calculatePercentageChange(
                        reportData['available']!,
                      )
                      : '+0.0%',
                  theme.colorScheme.tertiary,
                  reportData['available'] ?? [0, 0, 0, 0, 0, 0, 0],
                  Icons.check_circle_outline,
                  'Currently',
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideX(),
          const SizedBox(height: 12),
          // Row 2: Pending và Decline
          Row(
            children: [
              Expanded(
                child: _buildCompactReportCard(
                  'Pending',
                  (statistics.totalByStatus['PendingApproval'] ?? 0).toString(),
                  reportData['pendingApproval'] != null
                      ? provider.calculatePercentageChange(
                        reportData['pendingApproval']!,
                      )
                      : '+0.0%',
                  theme.colorScheme.secondary,
                  reportData['pendingApproval'] ?? [0, 0, 0, 0, 0, 0, 0],
                  Icons.pending_actions,
                  'Awaiting review',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactReportCard(
                  'Decline',
                  (statistics.totalByStatus['Refuse'] ?? 0).toString(),
                  reportData['Decline'] != null
                      ? provider.calculatePercentageChange(
                        reportData['Decline']!,
                      )
                      : '+0.0%',
                  theme.colorScheme.error,
                  reportData['Decline'] ?? [0, 0, 0, 0, 0, 0, 0],
                  Icons.cancel_outlined,
                  'This week',
                ),
              ),
            ],
          ).animate().fadeIn(delay: 400.ms).slideX(),
        ],
      ),
    );
  }

  Widget _buildCompactReportCard(
    String title,
    String value,
    String percentage,
    Color color,
    List<double> data,
    IconData icon,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final isPositive = !percentage.startsWith('-');

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
          // Header row with icon and label (similar to TaskStatsGrid)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
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
          // Value with growth rate indicator
          Row(
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().shimmer(
                duration: 1200.ms,
                color: color.withOpacity(0.3),
              ),
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
                      percentage,
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
          // Add subtitle like in _buildStatCard
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
                maxX: 6,
                minY: 0,
                maxY:
                    data.reduce((max, value) => value > max ? value : max) *
                    1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots:
                        data
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
