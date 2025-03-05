import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/components/SectionHeader.dart';

import '../components/task_stats_grid.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  final Map<String, List<double>> _weeklyData = {
    'total': [10, 12, 8, 15, 11, 13, 14],
    'active': [2, 2, 1, 9, 0, 2, 2],
    'inProgress': [5, 6, 4, 7, 5, 6, 8],
    'completed': [3, 1, 2, 6, 4, 5, 4],
  };

  final Map<String, List<double>> _reportData = {
    'total': [45, 52, 48, 55, 50, 58, 62], // Tổng số báo cáo
    'accepted': [38, 43, 40, 48, 42, 50, 53], // Báo cáo được chấp nhận
    'declined': [7, 9, 8, 7, 8, 8, 9], // Báo cáo bị từ chối
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: SafeArea(
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
                    TaskStatsGrid(
                      tasks: [], // Danh sách nhiệm vụ của bạn
                      weeklyData: _weeklyData,
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
    );
  }

  Widget _buildReportStats() {
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
            '62',
            '+7.3%',
            Colors.blue,
            _reportData['total']!,
            'Báo cáo đã gửi trong tuần',
          ),
          const Divider(height: 32),
          _buildReportCard(
            'Báo cáo được chấp nhận',
            '53',
            '+85.4%',
            Colors.green,
            _reportData['accepted']!,
            'Tỉ lệ chấp nhận: 85.4%',
          ),
          const Divider(height: 32),
          _buildReportCard(
            'Báo cáo bị từ chối',
            '9',
            '-2.1%',
            Colors.red,
            _reportData['declined']!,
            'Tỉ lệ từ chối: 14.6%',
          ),
        ],
      ),
    ).animate().fadeIn().slideY();
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
