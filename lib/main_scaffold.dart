import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siteplus_mb/custom_app_bar.dart';
import 'package:siteplus_mb/pages/HomePage/pages/home_page.dart';
import 'package:siteplus_mb/pages/NotificationPage/pages/notification_page.dart';
import 'package:siteplus_mb/pages/SiteViewPage/pages/site_view_page.dart';
import 'package:siteplus_mb/pages/TaskPage/pages/task_view_page.dart';

class MainScaffold extends StatefulWidget {
  final int initialIndex;

  const MainScaffold({super.key, this.initialIndex = 0});
  static final GlobalKey<_MainScaffoldState> scaffoldKey =
      GlobalKey<_MainScaffoldState>();
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  int _unreadNotifications = 0;
  int? _filterSiteId;
  int? _filterTaskId;

  void navigateToSiteTab(int? filterSiteId) {
    setState(() {
      _selectedIndex = 2; // Chuyển sang tab "Mặt Bằng"
      _filterSiteId = filterSiteId; // Cập nhật filterSiteId
      _filterTaskId = null;
    });
  }

  void navigateToTaskTab(int? filterTaskId) {
    setState(() {
      _selectedIndex = 1; // Chuyển sang tab "Nhiệm Vụ"
      _filterTaskId = filterTaskId;
      _filterSiteId = null; // Reset filterSiteId khi chuyển sang tab khác
    });
  }

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
    print("thông báo chưa đọc : $_unreadNotifications");
  }

  // Titles và descriptions cho từng tab
  final List<Map<String, String>> _pageInfo = [
    {'title': 'Thống kê', 'description': 'Tổng quan hoạt động của dự án'},
    {'title': 'Nhiệm Vụ', 'description': 'Quản lý công việc của bạn'},
    {
      'title': 'Mặt Bằng',
      'description': 'Quản lý mặt bằng và tạo bản báo cáo chi tiết',
    },
    {'title': 'Thông Báo', 'description': 'Thông báo và cập nhật mới nhất'},
  ];

  List<Widget> _getPages() => [
    const HomePageWidget(),
    TasksPage(
      onNavigateToSiteTab: navigateToSiteTab, // Truyền callback vào TasksPage
      filterTaskId: _filterTaskId,
    ),
    SiteViewPage(
      onNavigateToTaskTab: navigateToTaskTab,
      filterSiteId: _filterSiteId,
    ),
    const NotificationPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: MainScaffold.scaffoldKey,
      appBar: CustomAppBar(
        title: _pageInfo[_selectedIndex]['title'] ?? 'SitePlus',
        description: _pageInfo[_selectedIndex]['description'],
        notificationCount:
            _unreadNotifications, // Truyền số lượng thông báo chưa đọc
      ),
      body: _getPages()[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: theme.colorScheme.surfaceContainerLow,
        onDestinationSelected: (index) async {
          setState(() {
            _selectedIndex = index;
            _filterSiteId = null;
            _filterTaskId = null;
          });

          if (index == 3) {
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
            label: 'Trang Chủ',
          ),
          const NavigationDestination(
            icon: Icon(LucideIcons.clipboardList),
            selectedIcon: Icon(LucideIcons.clipboardList, fill: 1),
            label: 'Nhiệm Vụ',
          ),
          const NavigationDestination(
            icon: Icon(LucideIcons.building),
            selectedIcon: Icon(LucideIcons.building, fill: 1),
            label: 'Mặt Bằng',
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
            label: 'Thông Báo',
          ),
        ],
      ),
    );
  }
}
