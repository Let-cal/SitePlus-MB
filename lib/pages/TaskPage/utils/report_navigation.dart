import 'package:flutter/material.dart';
import 'package:siteplus_mb/pages/ReportPage/pages/ReportPage.dart';

class ReportNavigation {
  static void navigateToReport(BuildContext context, String reportType) {
    Widget page;
    String siteCategory;

    if (reportType == "Commercial") {
      siteCategory = 'Commercial';
    } else {
      siteCategory = 'Building';
    }

    // Pass the required parameters to ReportPage
    page = ReportPage(reportType: reportType, siteCategory: siteCategory);

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
