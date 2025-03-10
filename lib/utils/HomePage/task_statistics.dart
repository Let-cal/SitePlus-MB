// lib/models/task_statistics.dart
class TaskStatistics {
  final int totalAllDays;
  final StatusTotals totalByStatus;
  final List<DailyReport> dailyReports;

  TaskStatistics({
    required this.totalAllDays,
    required this.totalByStatus,
    required this.dailyReports,
  });

  factory TaskStatistics.fromJson(Map<String, dynamic> json) {
    return TaskStatistics(
      totalAllDays: json['totalAllDays'] ?? 0,
      totalByStatus: StatusTotals.fromJson(json['totalByStatus'] ?? {}),
      dailyReports: (json['dailyReports'] as List)
          .map((item) => DailyReport.fromJson(item))
          .toList(),
    );
  }
}

class StatusTotals {
  final int assigned;
  final int inProgress;
  final int completed;

  StatusTotals({
    required this.assigned,
    required this.inProgress,
    required this.completed,
  });

  factory StatusTotals.fromJson(Map<String, dynamic> json) {
    return StatusTotals(
      assigned: json['Assigned'] ?? 0,
      inProgress: json['InProgress'] ?? 0,
      completed: json['Completed'] ?? 0,
    );
  }
}

class DailyReport {
  final DateTime date;
  final int total;
  final StatusTotals statusTotals;

  DailyReport({
    required this.date,
    required this.total,
    required this.statusTotals,
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      date: DateTime.parse(json['date']),
      total: json['total'] ?? 0,
      statusTotals: StatusTotals.fromJson(json['statusTotals'] ?? {}),
    );
  }
}