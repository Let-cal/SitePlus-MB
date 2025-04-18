import 'package:flutter/material.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_view_model.dart';

class SitesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Site> _sites = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasLoadedOnce = false;

  List<Site> get sites => _sites;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasLoadedOnce => _hasLoadedOnce;

  SitesProvider() {
    print('SitesProvider: Initialized');
  }

  Future<void> fetchSites({
    int? pageNumber,
    int? pageSize,
    String? search,
    int? status,
    required Map<int, String> areaMap,
    bool force = false, // Add force parameter
  }) async {
    if (_isLoading || (!force && _hasLoadedOnce)) {
      print(
        'SitesProvider: fetchSites skipped (_isLoading: $_isLoading, _hasLoadedOnce: $_hasLoadedOnce, force: $force)',
      );
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    print('SitesProvider: Starting fetchSites');
    notifyListeners();

    try {
      final response = await _apiService.getSites(
        pageNumber: pageNumber,
        pageSize: pageSize,
        search: search,
        status: status,
      );
      print('SitesProvider: fetchSites response: $response');

      if (response['data'] == null) {
        throw Exception('Response không chứa "data": $response');
      }
      final listData = response['data']['listData'];
      if (listData == null) {
        print('SitesProvider: listData is null, setting empty list');
        _sites = [];
      } else {
        _sites = List<Site>.from(
          listData.map((item) => Site.fromJson(item, areaMap: areaMap)),
        );
        print(
          'SitesProvider: Parsed sites: ${_sites.map((s) => s.id).toList()}',
        );
      }
      _hasLoadedOnce = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      print('SitesProvider: fetchSites error: $e');
      _sites = [];
      notifyListeners();
    } finally {
      _isLoading = false;
      print('SitesProvider: fetchSites completed');
      notifyListeners();
    }
  }

  Future<void> refreshSites({required Map<int, String> areaMap}) async {
    print('SitesProvider: refreshSites called');
    _hasLoadedOnce = false;
    await fetchSites(areaMap: areaMap);
  }
}
