// sites_provider.dart
import 'package:flutter/material.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_view_model.dart';

class SitesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Site> _sites = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Site> get sites => _sites;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSites({
    int? pageNumber,
    int? pageSize,
    String? search,
    int? status,
    required Map<int, String> areaMap,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getSites(
        pageNumber: pageNumber,
        pageSize: pageSize,
        search: search,
        status: status,
      );
      print('fetchSites response: $response');

      // Kiểm tra cấu trúc response
      if (response['data'] == null) {
        throw Exception('Response không chứa "data": $response');
      }
      final listData = response['data']['listData'];
      if (listData == null) {
        print('listData is null, setting empty list');
        _sites = [];
      } else {
        _sites = List<Site>.from(
          listData.map((item) => Site.fromJson(item, areaMap: areaMap)),
        );
        print('fetchSites parsed sites: ${_sites.map((s) => s.id).toList()}');
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      print('fetchSites error: $e');
      _sites = []; // Đặt danh sách rỗng nếu có lỗi
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
