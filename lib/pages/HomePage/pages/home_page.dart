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
  final Map<String, List<double>> _reportData = {
    'total': [45, 52, 48, 55, 50, 58, 62], // Tổng số báo cáo
    'accepted': [38, 43, 40, 48, 42, 50, 53], // Báo cáo được chấp nhận
    'declined': [7, 9, 8, 7, 8, 8, 9], // Báo cáo bị từ chối
  };

  @override
  void initState() {
    super.initState();
    // Kiểm tra nếu dữ liệu chưa được tải, thì tải lên
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TaskStatisticsProvider>(
        context,
        listen: false,
      );
      if (!provider.hasLoadedOnce) {
        provider.fetchTaskStatistics();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Sử dụng Consumer để lắng nghe thay đổi từ TaskStatisticsProvider
    return Consumer<TaskStatisticsProvider>(
      builder: (context, taskStatsProvider, child) {
        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh:
                  () =>
                      taskStatsProvider
                          .refreshTaskStatistics(), // Sử dụng refreshTaskStatistics
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
              color: Colors.white,
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
    final isPositive = !percentage.startsWith('-');
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
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
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
                      color: color.withOpacity(0.1),
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
