import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siteplus_mb/main_scaffold.dart';
import 'package:siteplus_mb/utils/NotificationModel/notification_provider.dart';
import 'package:siteplus_mb/utils/Site/site_category_provider.dart';

// import 'pages/ReportPage/pages/ReportPage.dart';
import 'pages/LoginPage/pages/login_page.dart';
//  import 'pages/HomePage/pages/home_page.dart';
import 'theme.dart';
import 'util.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SiteCategoriesProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
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

class _MyAppState extends State<MyApp> {
  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();
    _loadLoginStatus();
  }

  Future<void> _loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    setState(() {
      isLoggedIn = token.isNotEmpty;
    });
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
