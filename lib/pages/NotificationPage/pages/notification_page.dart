import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siteplus_mb/main_scaffold.dart';
import 'package:siteplus_mb/utils/NotificationModel/notification_model.dart';
import 'package:siteplus_mb/utils/NotificationModel/notification_provider.dart';

import '../components/notification_card.dart';

class NotificationPage extends StatefulWidget {
  final bool isCompactView;

  const NotificationPage({super.key, this.isCompactView = false});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Set<int> _readNotificationIds = {};
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadReadNotificationIds();
  }

  // Tải danh sách ID thông báo đã đọc từ SharedPreferences
  Future<void> _loadReadNotificationIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readIdsString = prefs.getString('read_notification_ids') ?? '[]';
      final readIds = List<int>.from(jsonDecode(readIdsString));

      if (mounted) {
        setState(() {
          _readNotificationIds = Set<int>.from(readIds);
          _initialized = true;
        });
      }

      // Cập nhật trạng thái đã đọc cho provider
      final provider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      if (provider.notifications.isNotEmpty) {
        _updateReadStatus(provider.notifications);
      } else {
        // Tải thông báo nếu chưa có
        provider.fetchNotifications().then((_) {
          _updateReadStatus(provider.notifications);
        });
      }
    } catch (e) {
      print('Lỗi khi tải danh sách đã đọc: $e');
      setState(() {
        _initialized = true;
      });
    }
  }

  // Cập nhật trạng thái đã đọc cho danh sách thông báo
  void _updateReadStatus(List<NotificationDto> notifications) {
    for (var dto in notifications) {
      dto.isRead = _readNotificationIds.contains(dto.id);
    }
    // Cập nhật unread count vào shared preferences
    _saveUnreadNotificationCount(notifications.where((n) => !n.isRead).length);
  }

  // Lưu số lượng thông báo chưa đọc vào SharedPreferences
  Future<void> _saveUnreadNotificationCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unread_notification_count', count);
  }

  // Lưu danh sách ID thông báo đã đọc vào SharedPreferences
  Future<void> _saveReadNotificationIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'read_notification_ids',
      jsonEncode(_readNotificationIds.toList()),
    );
  }

  void _markAsRead(int notificationId) async {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    setState(() {
      _readNotificationIds.add(notificationId);
    });

    // Cập nhật trạng thái đọc trong provider
    notificationProvider.markAsRead(notificationId);

    // Lưu trạng thái đã đọc vào SharedPreferences
    await _saveReadNotificationIds();
    _saveUnreadNotificationCount(notificationProvider.unreadCount);
  }

  void _markAllAsRead() async {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    setState(() {
      for (var dto in notificationProvider.notifications) {
        _readNotificationIds.add(dto.id);
      }
    });

    // Cập nhật trạng thái đọc trong provider
    notificationProvider.markAllAsRead();

    // Lưu trạng thái đã đọc vào SharedPreferences
    await _saveReadNotificationIds();
    await _saveUnreadNotificationCount(0);
  }

  Future<void> _refreshNotifications() async {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    try {
      await notificationProvider.fetchNotifications();
      final notifications = notificationProvider.notifications;
      _updateReadStatus(notifications);
    } catch (e) {
      // Lỗi đã được xử lý trong provider
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        // Hiển thị loading khi đang khởi tạo hoặc đang tải dữ liệu
        if (!_initialized || notificationProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Xử lý lỗi
        if (notificationProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.circleAlert,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Không thể tải thông báo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface, // Primary text color
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    notificationProvider.error!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          theme
                              .colorScheme
                              .onSurfaceVariant, // Secondary text color
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _refreshNotifications,
                  icon: const Icon(LucideIcons.refreshCw),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        // Lấy danh sách thông báo phù hợp với view mode
        final notifications = notificationProvider.notifications;
        final displayedNotifications =
            widget.isCompactView
                ? notifications.where((n) => !n.isRead).toList()
                : notifications;

        // Chuyển đổi sang model để hiển thị
        final displayedModels =
            displayedNotifications
                .map(
                  (dto) =>
                      widget.isCompactView
                          ? dto.toCompactModel()
                          : dto.toModel(),
                )
                .toList();

        // Hiển thị dữ liệu
        final unreadCount = notificationProvider.unreadCount;

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
                            color:
                                theme
                                    .colorScheme
                                    .onSurface, // Primary text color
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
                          onPressed: unreadCount > 0 ? _markAllAsRead : null,
                          icon: Icon(
                            LucideIcons.check,
                            color: theme.colorScheme.primary,
                          ),
                          label: Text(
                            'Đánh dấu tất cả là đã đọc',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color:
                                  theme.colorScheme.primary, // Emphasized text
                            ),
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
                  ],
                ),
              ),

            // Notifications list
            Expanded(
              child:
                  displayedModels.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.isCompactView
                                  ? LucideIcons.circleAlert
                                  : LucideIcons.bellOff,
                              size: 64,
                              color:
                                  theme
                                      .colorScheme
                                      .onSurfaceVariant, // Adjusted for dark theme
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.isCompactView
                                  ? 'Không có thông báo mới'
                                  : 'Không có thông báo nào',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color:
                                    theme
                                        .colorScheme
                                        .onSurface, // Primary text color
                              ),
                            ),
                          ],
                        ),
                      )
                      : RefreshIndicator(
                        onRefresh: _refreshNotifications,
                        child: ListView.builder(
                          key: ValueKey(
                            'notifications-${displayedModels.length}',
                          ),
                          itemCount: displayedModels.length,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (context, index) {
                            final notification = displayedModels[index];
                            final originalId = displayedNotifications[index].id;

                            return NotificationCard(
                                  notification: notification,
                                  isCompact: widget.isCompactView,
                                  onTap: () => _markAsRead(originalId),
                                )
                                .animate(
                                  delay: Duration(milliseconds: 50 * index),
                                )
                                .fadeIn(duration: 300.ms)
                                .slideY(begin: 0.1, curve: Curves.easeOutQuad);
                          },
                        ),
                      ),
            ),
          ],
        );
      },
    );
  }
}

// Compact Notification Dialog triggered from Bell icon
class CompactNotificationDialog extends StatelessWidget {
  const CompactNotificationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final unreadCount = notificationProvider.unreadCount;

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
                  Row(
                    children: [
                      Text(
                        'Thông báo mới',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              theme.colorScheme.onSurface, // Primary text color
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  theme
                                      .colorScheme
                                      .onPrimary, // Text on primary background
                            ),
                          ),
                        ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      LucideIcons.x,
                      color: theme.colorScheme.onSurface,
                    ),
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
                    // Navigate to the full notification page
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder:
                            (context) => const MainScaffold(initialIndex: 3),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Xem tất cả thông báo',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color:
                          theme
                              .colorScheme
                              .onPrimary, // Text on primary background
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
