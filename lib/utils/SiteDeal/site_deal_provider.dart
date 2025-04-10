import 'package:flutter/material.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/SiteDeal/site_deal_model.dart';

class SiteDealProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<SiteDeal> _allSiteDeals = [];
  bool _isLoadingAll = false;
  String? _errorMessage;

  List<SiteDeal> get allSiteDeals => _allSiteDeals;
  bool get isLoadingAll => _isLoadingAll;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAllSiteDeals(int userId) async {
    _isLoadingAll = true;
    _errorMessage = null;
    notifyListeners();
    debugPrint("Bắt đầu fetch site deals cho userId: $userId");

    try {
      final result = await _apiService.getSiteDealsByUserId(userId: userId);
      debugPrint("Kết quả API: $result");

      if (result['success']) {
        _allSiteDeals =
            (result['data']['data'] as List<dynamic>)
                .map((item) => SiteDeal.fromJson(item))
                .toList();
        debugPrint("Số site deals lấy được: ${_allSiteDeals.length}");
      } else {
        _errorMessage = result['message'] ?? 'Không thể tải site deals';
        debugPrint("Lỗi từ API: $_errorMessage");
      }
    } catch (e) {
      _errorMessage = 'Lỗi: $e';
      debugPrint("Ngoại lệ: $e");
    } finally {
      _isLoadingAll = false;
      notifyListeners();
    }
  }
}
