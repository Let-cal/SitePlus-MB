import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siteplus_mb/main_scaffold.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/NotificationModel/notification_model.dart';
import 'package:siteplus_mb/utils/NotificationModel/notification_provider.dart';

import '../components/notification_card.dart';

class NotificationPage extends StatefulWidget {
  final bool isCompactView;

  const NotificationPage({Key? key, this.isCompactView = false})
    : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ApiService _apiService = ApiService();
  List<NotificationDto> _notificationDtos = [];
  bool _isLoading = true;
  String? _errorMessage;
  Set<int> _readNotificationIds = {};

  @override
  void initState() {
    super.initState();
    _loadReadNotificationIds(); // Tải danh sách ID đã đọc từ SharedPreferences

    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    if (notificationProvider.notifications.isNotEmpty &&
        !notificationProvider.isLoading) {
    } else {
      notificationProvider.fetchNotifications();
    }
  }

  // Lưu số lượng thông báo chưa đọc vào SharedPreferences
  Future<void> _saveUnreadNotificationCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unread_notification_count', count);
  }

  // Cập nhật số lượng thông báo chưa đọc
  void _updateUnreadNotificationCount() async {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    await _saveUnreadNotificationCount(unreadCount);
  }

  // Tải danh sách ID thông báo đã đọc từ SharedPreferences
  Future<void> _loadReadNotificationIds() async {
    final prefs = await SharedPreferences.getInstance();
    final readIdsString = prefs.getString('read_notification_ids') ?? '[]';
    final readIds = List<int>.from(jsonDecode(readIdsString));

    setState(() {
      _readNotificationIds = Set<int>.from(readIds);
    });

    _fetchNotifications(); // Sau khi tải xong danh sách đã đọc, mới tải thông báo
  }

  // Lưu danh sách ID thông báo đã đọc vào SharedPreferences
  Future<void> _saveReadNotificationIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'read_notification_ids',
      jsonEncode(_readNotificationIds.toList()),
    );
  }

  Future<void> _fetchNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Sử dụng dữ liệu từ Provider
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );

      // Lấy dữ liệu từ provider (có thể là cached hoặc mới)
      final providerData = await notificationProvider.fetchNotifications();

      setState(() {
        // Cập nhật trạng thái đã đọc dựa trên SharedPreferences
        _notificationDtos =
            providerData.map((item) {
              final dto = item as NotificationDto; 
              dto.isRead = _readNotificationIds.contains(dto.id);
              return dto;
            }).toList();

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<NotificationModel> get _notifications {
    return _notificationDtos.map((dto) => dto.toModel()).toList();
  }

  List<NotificationModel> get _displayedNotifications {
    return widget.isCompactView
        ? _notifications.where((notification) => !notification.isRead).toList()
        : _notifications;
  }

  void _markAsRead(int index) async {
    final tappedNotification = _displayedNotifications[index];

    setState(() {
      final originalIndex = _notificationDtos.indexWhere(
        (dto) => dto.id == tappedNotification.notificationId,
      );
      if (originalIndex != -1) {
        _notificationDtos[originalIndex].isRead = true;
        _readNotificationIds.add(tappedNotification.notificationId);
      }
    });

    // Lưu trạng thái đã đọc vào SharedPreferences
    await _saveReadNotificationIds();
    _updateUnreadNotificationCount();
  }

  void _markAllAsRead() async {
    setState(() {
      for (var dto in _notificationDtos) {
        dto.isRead = true;
        _readNotificationIds.add(dto.id);
      }
    });

    // Lưu trạng thái đã đọc vào SharedPreferences
    await _saveReadNotificationIds();
    _updateUnreadNotificationCount();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      body: FutureBuilder(
        // Khởi tạo future khi build được gọi (nếu chưa có dữ liệu)
        future: _notificationDtos.isEmpty ? _fetchNotifications() : null,
        builder: (context, snapshot) {
          // Xử lý trạng thái loading
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Xử lý lỗi
          if (_errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.alarmClock,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không thể tải thông báo',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error.withOpacity(0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _fetchNotifications,
                    icon: const Icon(LucideIcons.refreshCw),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          // Hiển thị dữ liệu
          final unreadCount = _notifications.where((n) => !n.isRead).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (!widget.isCompactView)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                            'Có $unreadCount thông báo chưa đọc',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          .animate()
                          .slideX(
                            begin: -1,
                            end: 0,
                            duration: 300.ms,
                            curve: Curves.easeOut,
                          )
                          .fadeIn(duration: 300.ms),

                      TextButton.icon(
                            onPressed: _markAllAsRead,
                            icon: const Icon(LucideIcons.check),
                            label: const Text('Đánh dấu tất cả là đã đọc'),
                          )
                          .animate()
                          .slideX(
                            begin: -1,
                            end: 0,
                            duration: 300.ms,
                            curve: Curves.easeOut,
                          )
                          .fadeIn(duration: 300.ms),
                    ],
                  ),
                ),

              // Notifications list
              Expanded(
                child:
                    _displayedNotifications.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.bellOff,
                                size: 64,
                                color: theme.colorScheme.secondary.withOpacity(
                                  0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Không có thông báo mới',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        )
                        : RefreshIndicator(
                          onRefresh: _fetchNotifications,
                          child: ListView.builder(
                            key: ValueKey(
                              'notifications-${_displayedNotifications.length}',
                            ),
                            itemCount: _displayedNotifications.length,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemBuilder: (context, index) {
                              final notification =
                                  _displayedNotifications[index];
                              return NotificationCard(
                                    notification: notification,
                                    isCompact: widget.isCompactView,
                                    onTap: () => _markAsRead(index),
                                  )
                                  .animate(
                                    delay: Duration(milliseconds: 100 * index),
                                  )
                                  .fadeIn(duration: 400.ms)
                                  .slideY(
                                    begin: 0.2,
                                    curve: Curves.easeOutQuad,
                                  );
                            },
                          ),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Compact Notification Dialog triggered from Bell icon
class CompactNotificationDialog extends StatelessWidget {
  const CompactNotificationDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thông báo mới',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Divider
            const Divider(height: 1),

            // List of notifications
            Flexible(child: NotificationPage(isCompactView: true)),

            // View all notifications button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Here we would navigate to the full notification page
                    // through the bottom navigation bar
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder:
                            (context) => const MainScaffold(initialIndex: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6F61EF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Xem tất cả thông báo'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
