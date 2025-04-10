import 'package:flutter/material.dart';
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
        _notifications.insert(0, notification); // Thêm thông báo mới vào đầu danh sách
        notifyListeners(); // Cập nhật UI
      });
    } catch (e) {
      print('Lỗi khi khởi tạo SignalR: $e');
    }
  }

  Future<void> fetchNotifications() async {
    if (_notifications.isNotEmpty && !_isLoading) {
      return; // Tránh gọi lại API nếu danh sách không rỗng
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