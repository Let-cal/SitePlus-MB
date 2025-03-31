import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siteplus_mb/pages/ReportPage/pages/report_create_dialog.dart';
import 'package:siteplus_mb/pages/ReportPage/pages/site_building_dialog.dart';
import 'package:siteplus_mb/utils/AreaDistrict/locations_provider.dart';

class NavigationComponent {
  static Future<dynamic> navigateToSiteReport(
    BuildContext context,
    String reportType,
    int categoryId,
    String categoryName,
    int taskId,
    int? areaId,
    String taskStatus,
    int? siteId,
    LocationsProvider locationsProvider, {
    VoidCallback? onUpdateSuccess,
  }) async {
    String reportTypeValue;
    if (categoryId == 2) {
      // Mặt bằng độc lập (ID = 2 dựa vào API response)
      reportTypeValue = "Commercial";
    } else {
      // Mặt bằng nội khu (ID = 1)
      reportTypeValue = "Building";
    }

    // Wrap the SiteBuildingDialog with ChangeNotifierProvider
    final page = ChangeNotifierProvider<LocationsProvider>.value(
      value: locationsProvider,
      child: SiteBuildingDialog(
        reportType: reportTypeValue,
        siteCategory: categoryName,
        siteCategoryId: categoryId,
        taskId: taskId,
        areaId: areaId,
        taskStatus: taskStatus,
        siteId: siteId,
        onUpdateSuccess: onUpdateSuccess,
      ),
    );

    // Trả về kết quả từ Navigator.push
    return await Navigator.push(
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

  static void navigateToReport(
    BuildContext context,
    String reportType,
    int categoryId,
    String categoryName,
    int siteId,
    int? taskId,
  ) async {
    String reportTypeValue;
    if (categoryId == 2) {
      reportTypeValue = "Commercial";
    } else {
      reportTypeValue = "Building";
    }

    final page = ReportCreateDialog(
      reportType: reportTypeValue,
      siteCategory: categoryName,
      siteCategoryId: categoryId,
      taskId: taskId,
      siteId: siteId,
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
