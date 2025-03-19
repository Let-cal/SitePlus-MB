import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siteplus_mb/pages/ReportPage/pages/site_building_page.dart';
import 'package:siteplus_mb/utils/AreaDistrict/locations_provider.dart';

class SiteNavigation {
  static void navigateToReport(
    BuildContext context,
    String reportType,
    int categoryId,
    String categoryName,
    String taskId,
    LocationsProvider locationsProvider,
  ) async {
    String reportTypeValue;
    if (categoryId == 2) {
      // Mặt bằng độc lập (ID = 2 dựa vào API response)
      reportTypeValue = "Commercial";
    } else {
      // Mặt bằng nội khu (ID = 1)
      reportTypeValue = "Building";
    }

    // Wrap the SiteBuildingPage with ChangeNotifierProvider
    final page = ChangeNotifierProvider<LocationsProvider>.value(
      value: locationsProvider,
      child: SiteBuildingPage(
        reportType: reportTypeValue,
        siteCategory: categoryName,
        siteCategoryId: categoryId,
        taskId: taskId,
      ),
    );

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var fadeTween = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeInOut));
          var slideTween = Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOut));

          return FadeTransition(
            opacity: animation.drive(fadeTween),
            child: SlideTransition(
              position: animation.drive(slideTween),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
