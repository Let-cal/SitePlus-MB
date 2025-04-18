import 'package:flutter/material.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/HomePage/site_report_statistics.dart';

class SiteReportProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  SiteReportStatistics? _siteReportStatistics;
  Map<String, List<double>> _reportData = {
    'total': [0, 0, 0, 0, 0, 0, 0],
    'available': [0, 0, 0, 0, 0, 0, 0],
    'pendingApproval': [0, 0, 0, 0, 0, 0, 0],
    'Decline': [0, 0, 0, 0, 0, 0, 0],
  };
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasLoadedOnce = false;

  // Getters
  SiteReportStatistics? get siteReportStatistics => _siteReportStatistics;
  Map<String, List<double>> get reportData => _reportData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasLoadedOnce => _hasLoadedOnce;

  // Phương thức tải dữ liệu báo cáo site
  Future<void> fetchSiteReportStatistics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _apiService.getToken();
      final userId = await _apiService.getUserId();
      final statistics = await _apiService.getWeeklySiteReportStatistics(
        token!,
        userId!,
      );
      final reportData = _apiService.convertToSiteReportData(statistics);

      _siteReportStatistics = statistics;
      _reportData = reportData;
      _hasLoadedOnce = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Phương thức để buộc tải lại dữ liệu
  Future<void> refreshSiteReportStatistics() async {
    await fetchSiteReportStatistics();
  }

  // Tính phần trăm thay đổi của dữ liệu
  String calculatePercentageChange(List<double> data) {
    if (data.length < 2) return '+0.0%';

    double current = data.last;
    double previous = data[data.length - 2];

    if (previous == 0) return current > 0 ? '+100.0%' : '+0.0%';

    double change = ((current - previous) / previous) * 100;
    return '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%';
  }
}
