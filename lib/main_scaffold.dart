import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siteplus_mb/custom_app_bar.dart';
import 'package:siteplus_mb/pages/HomePage/pages/home_page.dart';
import 'package:siteplus_mb/pages/NotificationPage/pages/notification_page.dart';
import 'package:siteplus_mb/pages/SiteDealPage/pages/site_deal_view_page.dart';
import 'package:siteplus_mb/pages/SiteViewPage/pages/site_view_page.dart';
import 'package:siteplus_mb/pages/TaskPage/pages/task_view_page.dart';
import 'package:siteplus_mb/utils/NotificationModel/notification_provider.dart';

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
  int? _filterTaskStatus;

  void navigateToTaskTabWithoutFilter() {
    setState(() {
      _selectedIndex = 1; // Chuyển sang tab "Tasks"
      _filterTaskId = null;
      _filterTaskStatus = null;
      _filterSiteId = null;
    });
  }

  void navigateToSiteTabWithoutFilter() {
    setState(() {
      _selectedIndex = 2; // Chuyển sang tab "Sites"
      _filterSiteId = null;
      _filterTaskId = null;
      _filterTaskStatus = null;
    });
  }

  void navigateToSiteTab(int? filterSiteId) {
    setState(() {
      _selectedIndex = 2; // Chuyển sang tab "Mặt Bằng"
      _filterSiteId = filterSiteId; // Cập nhật filterSiteId
      _filterTaskId = null;
      _filterTaskStatus = null;
    });
  }

  void navigateToTaskTab(int? filterTaskId, {int? filterTaskStatus}) {
    setState(() {
      _selectedIndex = 1; // Chuyển sang tab "Nhiệm Vụ"
      _filterTaskId = filterTaskId;
      _filterTaskStatus = filterTaskStatus;
      _filterSiteId = null;
    });
  }

  void navigateToNotificationsTab() {
    setState(() {
      _selectedIndex = 4;
      _filterSiteId = null;
      _filterTaskId = null;
      _filterTaskStatus = null;
      _unreadNotifications = 0;
    });
    // Update shared preferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('unread_notification_count', 0);
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

  void resetTaskStatusFilter() {
    setState(() {
      _filterTaskStatus = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).fetchNotifications();
    });
  }

  // Titles và descriptions cho từng tab
  final List<Map<String, String>> _pageInfo = [
    {
      'title': 'Home',
      'description':
          '"Discover, evaluate, and secure the ideal site for your business success.',
    },
    // {'title': 'Statistics', 'description': 'Overview of project activities'},
    {
      'title': 'Tasks',
      'description': 'Get updates on the latest announcements and tasks',
    },
    {'title': 'Sites', 'description': 'Manage site information and locations'},
    {
      'title': 'Deals',
      'description': 'Manage negotiations and site conditions',
    },
    {
      'title': 'Notifications',
      'description': 'View the latest alerts and updates',
    },
  ];

  List<Widget> _getPages() => [
    HomePage(
      onNavigateToTaskTab: navigateToTaskTabWithoutFilter,
      onNavigateToSiteTab: navigateToSiteTabWithoutFilter,
      onNavigateToTaskTabWithFilter: navigateToTaskTab,
      onNavigateToSiteTabWithFilter: navigateToSiteTab,
    ),
    // const StatisticsPage(),
    TasksPage(
      onNavigateToSiteTab: navigateToSiteTab,
      filterTaskId: _filterTaskId,
      filterTaskStatus: _filterTaskStatus,
      onResetTaskStatusFilter: resetTaskStatusFilter,
    ),
    SiteViewPage(
      onNavigateToTaskTab: navigateToTaskTab,
      filterSiteId: _filterSiteId,
    ),
    SiteDealViewPage(onNavigateToSiteTab: navigateToSiteTab),
    const NotificationPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        // Cập nhật số lượng thông báo chưa đọc từ provider
        _unreadNotifications = notificationProvider.unreadCount;

        return Scaffold(
          key: MainScaffold.scaffoldKey,
          appBar: CustomAppBar(
            title: _pageInfo[_selectedIndex]['title'] ?? 'SitePlus',
            description: _pageInfo[_selectedIndex]['description'],
            notificationCount: _unreadNotifications,
            onNavigateToNotificationsTab: navigateToNotificationsTab,
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
                _filterTaskStatus = null;
              });

              if (index == 4) {
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
              // const NavigationDestination(
              //   icon: Icon(Icons.analytics),
              //   selectedIcon: Icon(Icons.analytics, fill: 1),
              //   label: 'Statistics',
              // ),
              const NavigationDestination(
                icon: Icon(LucideIcons.clipboardList),
                selectedIcon: Icon(LucideIcons.clipboardList, fill: 1),
                label: 'Tasks',
              ),
              const NavigationDestination(
                icon: Icon(LucideIcons.landmark),
                selectedIcon: Icon(LucideIcons.landmark, fill: 1),
                label: 'Sites',
              ),
              const NavigationDestination(
                icon: Icon(LucideIcons.handshake),
                selectedIcon: Icon(LucideIcons.handshake, fill: 1),
                label: 'Deals',
              ),
              // Badge cho tab Notifications
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: _unreadNotifications > 0,
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
      },
    );
  }
}
