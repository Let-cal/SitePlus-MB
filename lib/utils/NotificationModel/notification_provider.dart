import 'dart:async';

import 'package:flutter/material.dart';
import 'package:siteplus_mb/service/api_service.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List _notifications = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  Timer? _pollingTimer;
  DateTime _lastFetchTime = DateTime(1970);

  List get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // Hàm này sẽ kiểm tra nếu dữ liệu đã được tải gần đây, trả về cache
  Future<List> fetchNotifications({bool forceRefresh = false}) async {
    try {
      // Nếu đã tải trong vòng 3 giây trước đó và không bắt buộc refresh
      final now = DateTime.now();
      if (!forceRefresh &&
          _notifications.isNotEmpty &&
          now.difference(_lastFetchTime).inSeconds < 3) {
        return _notifications; // Sử dụng dữ liệu cached
      }

      // Chỉ set loading nếu notifications đang trống
      if (_notifications.isEmpty) {
        _isLoading = true;
        notifyListeners();
      }

      final response = await _apiService.getNotifications();
      _notifications = response.data;
      _lastFetchTime = now;
      _isInitialized = true;

      _isLoading = false;
      notifyListeners();
      return _notifications;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Error fetching notifications: $e");
      return _notifications;
    }
  }

  void startPollingNotifications() {
    // Hủy timer cũ nếu có
    _pollingTimer?.cancel();

    // Tạo timer mới - chỉ poll nếu không đang loading
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!_isLoading) {
        await fetchNotifications(forceRefresh: true);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
