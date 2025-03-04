import 'package:flutter/material.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/NotificationModel/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<NotificationDto> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationDto> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Lấy số lượng thông báo chưa đọc
  int get unreadCount => _notifications.where((notification) => !notification.isRead).length;

  Future<void> fetchNotifications() async {
  if (_notifications.isNotEmpty && !_isLoading) {
    return; // Tránh gọi lại API nếu danh sách không rỗng
  }

  try {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final List<NotificationDto> fetchedNotifications = await _apiService.fetchNotifications();

    // Đảm bảo danh sách là List<NotificationDto>
    _notifications = List<NotificationDto>.from(fetchedNotifications);
    
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _isLoading = false;
    _error = e.toString();
    notifyListeners();
  }
}


  // Đánh dấu thông báo là đã đọc
  void markAsRead(int notificationId) {
    final index = _notifications.indexWhere((notification) => notification.id == notificationId);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  // Đánh dấu tất cả thông báo là đã đọc
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    notifyListeners();
  }
}