import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/NotificationModel/notification_model.dart';

import 'signalr_service.dart'; // Import SignalRService

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SignalRService _signalRService = SignalRService();
  List<NotificationDto> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationDto> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    initSignalR(); // Khởi tạo SignalR khi provider được tạo
  }

  // Khởi tạo kết nối SignalR
  Future<void> initSignalR() async {
    try {
      await _signalRService.startConnection();
      _signalRService.onReceiveNotification((notification) {
        notification.isRead =
            false; // Đảm bảo thông báo mới luôn được đánh dấu là chưa đọc
        _notifications.insert(
          0,
          notification,
        ); // Thêm thông báo mới vào đầu danh sách

        // Cập nhật unread count trong SharedPreferences
        _updateUnreadCountInPrefs();

        notifyListeners(); // Cập nhật UI
      });
    } catch (e) {
      print('Lỗi khi khởi tạo SignalR: $e');
    }
  }

  Future<void> _updateUnreadCountInPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unread_notification_count', unreadCount);
  }

  Future<void> fetchNotifications({bool force = false}) async {
    if (_notifications.isNotEmpty && !_isLoading && !force) {
      return; // Tránh gọi lại API nếu danh sách không rỗng và không yêu cầu force
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final fetchedNotifications = await _apiService.fetchNotifications();
      _notifications = List<NotificationDto>.from(fetchedNotifications);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void markAsRead(int notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }
}
