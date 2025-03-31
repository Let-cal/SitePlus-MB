import 'package:flutter/material.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_view_model.dart'; // Giả sử đây là model Site

class SitesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Site> _sites = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getter để truy cập từ các widget
  List<Site> get sites => _sites;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Hàm gọi API getSites và cập nhật trạng thái
  Future<void> fetchSites({
    required int pageNumber,
    required int pageSize,
    String? search,
    int? status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Thông báo giao diện rằng đang tải dữ liệu

    try {
      final response = await _apiService.getSites(
        pageNumber: pageNumber,
        pageSize: pageSize,
        search: search,
        status: status,
      );
      _sites = List<Site>.from(
        response['listData'].map((item) => Site.fromJson(item)),
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Thông báo giao diện khi hoàn tất
    }
  }
}
