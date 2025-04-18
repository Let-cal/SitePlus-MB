import 'package:flutter/material.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/HomePage/task_statistics.dart';

class TaskStatisticsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  TaskStatistics? _taskStatistics;
  Map<String, List<double>> _weeklyData = {
    'total': [0, 0, 0, 0, 0, 0, 0],
    'assigned': [0, 0, 0, 0, 0, 0, 0],
    'inProgress': [0, 0, 0, 0, 0, 0, 0],
    'completed': [0, 0, 0, 0, 0, 0, 0],
  };
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasLoadedOnce = false;

  // Getters
  TaskStatistics? get taskStatistics => _taskStatistics;
  Map<String, List<double>> get weeklyData => _weeklyData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasLoadedOnce => _hasLoadedOnce;

  // Phương thức tải dữ liệu
  Future<void> fetchTaskStatistics() async {
    // Nếu đã tải dữ liệu rồi, không tải lại
    if (_hasLoadedOnce && _taskStatistics != null) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Lấy token từ ApiService
      final token = await _apiService.getToken();
      final userId = await _apiService.getUserId();

      // Gọi API để lấy thống kê nhiệm vụ
      final statistics = await _apiService.getWeeklyTaskStatistics(
        token!,
        userId!,
      );

      // Chuyển đổi dữ liệu thống kê sang định dạng biểu đồ hàng tuần
      final weeklyData = _apiService.convertToWeeklyData(statistics);

      _taskStatistics = statistics;
      _weeklyData = weeklyData;
      _hasLoadedOnce = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Phương thức để buộc tải lại dữ liệu (khi người dùng thực hiện refresh)
  Future<void> refreshTaskStatistics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _apiService.getToken();
      final userId = await _apiService.getUserId();
      final statistics = await _apiService.getWeeklyTaskStatistics(
        token!,
        userId!,
      );
      final weeklyData = _apiService.convertToWeeklyData(statistics);

      _taskStatistics = statistics;
      _weeklyData = weeklyData;
      _hasLoadedOnce = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
