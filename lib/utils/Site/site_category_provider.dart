import 'package:flutter/material.dart';
import 'package:siteplus_mb/utils/Site/site_category.dart';

class SiteCategoriesProvider extends ChangeNotifier {
  static final SiteCategoriesProvider _instance = SiteCategoriesProvider._internal();
  
  factory SiteCategoriesProvider() {
    return _instance;
  }
  
  SiteCategoriesProvider._internal();
  
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