import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siteplus_mb/main_scaffold.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/AreaDistrict/locations_provider.dart';
import 'package:siteplus_mb/utils/HomePage/site_report_provider.dart';
import 'package:siteplus_mb/utils/HomePage/task_statistics_provider.dart';
import 'package:siteplus_mb/utils/NotificationModel/notification_provider.dart';
import 'package:siteplus_mb/utils/SiteDeal/site_deal_provider.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_category_provider.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/sites_provider.dart';

import 'pages/LoginPage/pages/login_page.dart';
import 'theme.dart';
import 'util.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SiteCategoriesProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => TaskStatisticsProvider()),
        ChangeNotifierProvider(create: (_) => SiteReportProvider()),
        ChangeNotifierProvider(create: (_) => LocationsProvider()),
        ChangeNotifierProvider(create: (_) => SitesProvider()),
        ChangeNotifierProvider(create: (_) => SiteDealProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLoginStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Gỡ observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Ứng dụng được mở lại từ background
      _refreshData();
    }
  }

  Future<void> _loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final hintId = prefs.getString('hintId');
    setState(() {
      isLoggedIn = token.isNotEmpty;
    });

    if (token.isNotEmpty && hintId != null) {
      final userId = int.tryParse(hintId);
      if (userId != null) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          // Các khởi tạo hiện có
          Provider.of<TaskStatisticsProvider>(
            context,
            listen: false,
          ).fetchTaskStatistics();
          Provider.of<SiteReportProvider>(
            context,
            listen: false,
          ).fetchSiteReportStatistics();
          final apiService = ApiService();
          final categories = await apiService.getSiteCategories(token);
          Provider.of<SiteCategoriesProvider>(
            context,
            listen: false,
          ).setCategories(categories);
          Provider.of<SiteDealProvider>(
            context,
            listen: false,
          ).fetchAllSiteDeals(userId);

          // Thêm khởi tạo SignalR cho NotificationProvider
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<NotificationProvider>(
              context,
              listen: false,
            ).initSignalR();
          });
        }
      }
    }
  }

  Future<void> _refreshData() async {
    if (mounted) {
      Provider.of<TaskStatisticsProvider>(
        context,
        listen: false,
      ).refreshTaskStatistics();
      Provider.of<SiteReportProvider>(
        context,
        listen: false,
      ).refreshSiteReportStatistics();
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).initSignalR(); // Kết nối lại SignalR khi ứng dụng vào foreground
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme = createTextTheme(context, "Roboto", "Open Sans");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      home:
          isLoggedIn == null
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : isLoggedIn == true
              ? const MainScaffold()
              : const LoginPage(),
    );
  }
}
