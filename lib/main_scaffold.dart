import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/custom_app_bar.dart';
import 'package:siteplus_mb/pages/HomePage/pages/home_page.dart';
import 'package:siteplus_mb/pages/NotificationPage/pages/notification_page.dart';
import 'package:siteplus_mb/pages/ReportViewPage/pages/report_view_page.dart';
import 'package:siteplus_mb/pages/TaskPage/pages/task_view_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // Titles và descriptions cho từng tab
  final List<Map<String, String>> _pageInfo = [
    {'title': 'Dashboard', 'description': 'Tổng quan hoạt động của dự án'},
    {'title': 'Tasks', 'description': 'Quản lý công việc của bạn'},
    {'title': 'Notifications', 'description': 'Thông báo và cập nhật mới nhất'},
    {'title': 'Reports', 'description': 'Báo cáo và thống kê'},
    {'title': 'Profile', 'description': 'Thông tin cá nhân của bạn'},
  ];

  final List<Widget> _pages = [
    const HomePageWidget(),
    const TasksPage(),
    const NotificationPage(),
    const ReportViewPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: _pageInfo[_selectedIndex]['title'] ?? 'SitePlus',
        description: _pageInfo[_selectedIndex]['description'],
        // Thêm các action buttons khác tùy theo màn hình
        additionalActions:
            _selectedIndex == 0
                ? [
                  IconButton(
                    icon: const Icon(LucideIcons.bell),
                    onPressed: () {},
                  ),
                ]
                : null,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: theme.colorScheme.surfaceContainerLow,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.house),
            selectedIcon: Icon(LucideIcons.house, fill: 1),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.clipboardList),
            selectedIcon: Icon(LucideIcons.clipboardList, fill: 1),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.bell),
            selectedIcon: Icon(LucideIcons.bell, fill: 1),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.chartBar),
            selectedIcon: Icon(LucideIcons.chartBar, fill: 1),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
