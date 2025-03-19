import 'package:flutter/material.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_category.dart';

class SiteCategoriesProvider extends ChangeNotifier {
  List<SiteCategory> _categories = [];
  bool _isLoaded = false;

  List<SiteCategory> get categories => _categories;
  bool get isLoaded => _isLoaded;

  void setCategories(List<SiteCategory> categories) {
    _categories = categories;
    _isLoaded = true;
    notifyListeners();
  }

  void reset() {
    _categories = [];
    _isLoaded = false;
    notifyListeners();
  }
}
