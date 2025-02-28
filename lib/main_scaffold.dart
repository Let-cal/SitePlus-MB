import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siteplus_mb/custom_app_bar.dart';
import 'package:siteplus_mb/pages/HomePage/pages/home_page.dart';
import 'package:siteplus_mb/pages/NotificationPage/pages/notification_page.dart';
import 'package:siteplus_mb/pages/TaskPage/pages/task_view_page.dart';

class MainScaffold extends StatefulWidget {
  final int initialIndex;

  const MainScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  int _unreadNotifications = 0;
  // Tải số lượng thông báo chưa đọc từ SharedPreferences
  Future<void> _loadUnreadNotificationCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('unread_notification_count') ?? 0;
    setState(() {
      _unreadNotifications = count;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadUnreadNotificationCount();
    print("thông báo chưa đọc : ${_unreadNotifications}");
  }

  // Titles và descriptions cho từng tab
  final List<Map<String, String>> _pageInfo = [
    {'title': 'Dashboard', 'description': 'Tổng quan hoạt động của dự án'},
    {'title': 'Tasks', 'description': 'Quản lý công việc của bạn'},
    {'title': 'Notifications', 'description': 'Thông báo và cập nhật mới nhất'},
  ];

  final List<Widget> _pages = [
    const HomePageWidget(),
    const TasksPage(),
    const NotificationPage(), // NotificationPage ở chế độ đầy đủ
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: _pageInfo[_selectedIndex]['title'] ?? 'SitePlus',
        description: _pageInfo[_selectedIndex]['description'],
        notificationCount:
            _unreadNotifications, // Truyền số lượng thông báo chưa đọc
        // Thêm các action buttons khác tùy theo màn hình
        // additionalActions:
        //     _selectedIndex == 0
        //         ? [
        //           IconButton(
        //             icon: const Icon(LucideIcons.user),
        //             onPressed: () {
        //               // Xử lý khi nhấn vào profile
        //             },
        //           ),
        //         ]
        //         : null,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: theme.colorScheme.surfaceContainerLow,
        onDestinationSelected: (index) async {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 2) {
            setState(() {
              _unreadNotifications = 0;
            });
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('unread_notification_count', 0);
          }
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(LucideIcons.house),
            selectedIcon: Icon(LucideIcons.house, fill: 1),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(LucideIcons.clipboardList),
            selectedIcon: Icon(LucideIcons.clipboardList, fill: 1),
            label: 'Tasks',
          ),
          // Badge cho tab Notifications
          NavigationDestination(
            icon: Badge(
              isLabelVisible: (_unreadNotifications ?? 0) > 0,
              label: Text(
                _unreadNotifications.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              child: const Icon(LucideIcons.bell),
            ),
            selectedIcon: const Icon(LucideIcons.bell, fill: 1),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}
