// site_report_statistics.dart
class SiteReportStatistics {
  final int totalAllDays;
  final Map<String, int> totalByStatus;
  final List<DailyReport> dailyReports;

  SiteReportStatistics({
    required this.totalAllDays,
    required this.totalByStatus,
    required this.dailyReports,
  });

  factory SiteReportStatistics.fromJson(Map<String, dynamic> json) {
    return SiteReportStatistics(
      totalAllDays: json['totalAllDays'] ?? 0,
      totalByStatus: Map<String, int>.from(json['totalByStatus'] ?? {}),
      dailyReports:
          (json['dailyReports'] as List? ?? [])
              .map((report) => DailyReport.fromJson(report))
              .toList(),
    );
  }
}

class DailyReport {
  final DateTime date;
  final int total;
  final Map<String, int> statusTotals;

  DailyReport({
    required this.date,
    required this.total,
    required this.statusTotals,
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      total: json['total'] ?? 0,
      statusTotals: Map<String, int>.from(json['statusTotals'] ?? {}),
    );
  }
}
