import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:siteplus_mb/components/SectionHeader.dart';
import 'package:siteplus_mb/utils/HomePage/site_report_provider.dart';
import 'package:siteplus_mb/utils/HomePage/task_statistics_provider.dart';

import '../components/task_stats_grid.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  @override
  void initState() {
    super.initState();
    // Kiểm tra nếu dữ liệu chưa được tải, thì tải lên
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskStatisticsProvider>(
        context,
        listen: false,
      );
      final siteProvider = Provider.of<SiteReportProvider>(
        context,
        listen: false,
      );
      if (!taskProvider.hasLoadedOnce) {
        taskProvider.fetchTaskStatistics();
      }
      if (!siteProvider.hasLoadedOnce) {
        siteProvider.fetchSiteReportStatistics();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng Consumer để lắng nghe thay đổi từ TaskStatisticsProvider
    return Consumer<TaskStatisticsProvider>(
      builder: (context, taskStatsProvider, child) {
        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                final siteReportProvider = Provider.of<SiteReportProvider>(
                  context,
                  listen: false,
                );
                await Future.wait([
                  taskStatsProvider.refreshTaskStatistics(),
                  siteReportProvider.refreshSiteReportStatistics(),
                ]);
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          SectionHeader(
                            title: 'Thống kê nhiệm vụ',
                            subtitle: 'Hiệu suất 7 ngày qua',
                            icon: LucideIcons.clipboardList,
                          ),
                          const SizedBox(height: 16),
                          if (taskStatsProvider.isLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (taskStatsProvider.errorMessage != null)
                            _buildErrorWidgetTask(taskStatsProvider)
                          else
                            TaskStatsGrid(
                              tasks: [], // Danh sách nhiệm vụ của bạn
                              weeklyData: taskStatsProvider.weeklyData,
                              statistics: taskStatsProvider.taskStatistics,
                            ),
                          const SizedBox(height: 24),
                          SectionHeader(
                            title: 'Thống kê báo cáo',
                            subtitle: 'Phân tích hoàn thành báo cáo',
                            icon: LucideIcons.fileChartLine,
                          ),
                          const SizedBox(height: 16),
                          _buildReportStats(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidgetTask(TaskStatisticsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(
            'Không thể tải dữ liệu',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(provider.errorMessage ?? 'Đã xảy ra lỗi không xác định'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => provider.refreshTaskStatistics(),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidgetSite(SiteReportProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(
            'Không thể tải dữ liệu báo cáo site',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(provider.errorMessage ?? 'Đã xảy ra lỗi không xác định'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => provider.refreshSiteReportStatistics(),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportStats() {
    return Consumer<SiteReportProvider>(
      builder: (context, siteReportProvider, child) {
        final theme = Theme.of(context);
        if (siteReportProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (siteReportProvider.errorMessage != null) {
          return _buildErrorWidgetSite(siteReportProvider);
        } else {
          final statistics = siteReportProvider.siteReportStatistics;
          final reportData = siteReportProvider.reportData;

          // Nếu chưa có dữ liệu, hiển thị thông báo
          if (statistics == null) {
            return const Center(child: Text('Không có dữ liệu báo cáo'));
          }

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildReportCard(
                  'Tổng số báo cáo',
                  statistics.totalAllDays.toString(),
                  siteReportProvider.calculatePercentageChange(
                    reportData['total']!,
                  ),
                  Colors.blue,
                  reportData['total']!,
                  'Báo cáo đã gửi trong tuần',
                ),
                const Divider(height: 32),
                _buildReportCard(
                  'Báo cáo khả dụng',
                  (statistics.totalByStatus['Available'] ?? 0).toString(),
                  siteReportProvider.calculatePercentageChange(
                    reportData['available']!,
                  ),
                  Colors.green,
                  reportData['available']!,
                  'Tỉ lệ: ${statistics.totalByStatus['Available'] != null && statistics.totalAllDays > 0 ? ((statistics.totalByStatus['Available']! / statistics.totalAllDays) * 100).toStringAsFixed(1) : '0.0'}%',
                ),
                const Divider(height: 32),
                _buildReportCard(
                  'Báo cáo chờ phê duyệt',
                  (statistics.totalByStatus['PendingApproval'] ?? 0).toString(),
                  siteReportProvider.calculatePercentageChange(
                    reportData['pendingApproval']!,
                  ),
                  Colors.orange,
                  reportData['pendingApproval']!,
                  'Tỉ lệ: ${statistics.totalByStatus['PendingApproval'] != null && statistics.totalAllDays > 0 ? ((statistics.totalByStatus['PendingApproval']! / statistics.totalAllDays) * 100).toStringAsFixed(1) : '0.0'}%',
                ),
                const Divider(height: 32),
                _buildReportCard(
                  'Báo cáo bị từ chối',
                  (statistics.totalByStatus['Refuse'] ?? 0).toString(),
                  siteReportProvider.calculatePercentageChange(
                    reportData['refuse']!,
                  ),
                  Colors.red,
                  reportData['refuse']!,
                  'Tỉ lệ: ${statistics.totalByStatus['Refuse'] != null && statistics.totalAllDays > 0 ? ((statistics.totalByStatus['Refuse']! / statistics.totalAllDays) * 100).toStringAsFixed(1) : '0.0'}%',
                ),
                const Divider(height: 32),
                _buildReportCard(
                  'Báo cáo đã đóng',
                  (statistics.totalByStatus['Closed'] ?? 0).toString(),
                  siteReportProvider.calculatePercentageChange(
                    reportData['closed']!,
                  ),
                  Colors.grey,
                  reportData['closed']!,
                  'Tỉ lệ: ${statistics.totalByStatus['Closed'] != null && statistics.totalAllDays > 0 ? ((statistics.totalByStatus['Closed']! / statistics.totalAllDays) * 100).toStringAsFixed(1) : '0.0'}%',
                ),
              ],
            ),
          ).animate().fadeIn().slideY();
        }
      },
    );
  }

  Widget _buildReportCard(
    String title,
    String value,
    String percentage,
    Color color,
    List<double> data,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final isPositive = !percentage.startsWith('-');

    // Use theme colors for better contrast and consistency
    final cardTextColor = theme.colorScheme.onSurface;
    final cardSubtitleColor = theme.colorScheme.onSurface.withOpacity(0.6);
    final percentageBackgroundColor = color.withOpacity(
      theme.brightness == Brightness.light ? 0.1 : 0.2,
    );

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: cardSubtitleColor, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: cardTextColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: percentageBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive
                              ? LucideIcons.trendingUp
                              : LucideIcons.trendingDown,
                          color: color,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          percentage,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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
                style: TextStyle(color: cardSubtitleColor, fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 60,
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
                      color: color.withOpacity(
                        theme.brightness == Brightness.light ? 0.1 : 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
