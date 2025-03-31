import 'package:flutter/material.dart';
import 'package:siteplus_mb/service/api_service.dart';

class LocationsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isBusy = false;

  @override
  void notifyListeners() {
    if (!_isBusy) {
      super.notifyListeners();
    }
  }

  Future<void> initialize() async {
    if (_districts.isEmpty) {
      _isBusy = true;
      try {
        await loadDistricts();
      } finally {
        _isBusy = false;
        notifyListeners();
      }
    }
  }

  // Data storage
  List<District> _districts = [];
  final Map<int, List<Area>> _areasByDistrict = {};

  // Loading states
  bool _isLoadingDistricts = false;
  final Map<int, bool> _isLoadingAreas = {};

  // Getters
  List<District> get districts => _districts;
  Map<int, List<Area>> get areasByDistrict => _areasByDistrict;
  bool get isLoadingDistricts => _isLoadingDistricts;
  bool isLoadingAreasForDistrict(int districtId) =>
      _isLoadingAreas[districtId] ?? false;

  // Load all districts
  Future<void> loadDistricts() async {
    if (_isLoadingDistricts) return;

    _isLoadingDistricts = true;
    notifyListeners();

    try {
      final districtsResponse = await _apiService.getDistricts(
        page: 1,
        pageSize: 50,
      );
      _districts = districtsResponse;
      _isLoadingDistricts = false;
      notifyListeners();
    } catch (e) {
      _isLoadingDistricts = false;
      notifyListeners();
      rethrow;
    }
  }

  // Load areas for a specific district
  Future<List<Area>> getAreasForDistrict(int districtId) async {
    // Return cached areas if available
    if (_areasByDistrict.containsKey(districtId)) {
      return _areasByDistrict[districtId]!;
    }

    // Prevent multiple simultaneous requests for the same district
    if (_isLoadingAreas[districtId] == true) {
      // Wait until loading is complete
      await Future.doWhile(() async {
        await Future.delayed(Duration(milliseconds: 100));
        return _isLoadingAreas[districtId] == true;
      });
      return _areasByDistrict[districtId] ?? [];
    }

    // Start loading
    _isLoadingAreas[districtId] = true;
    notifyListeners();

    try {
      final areas = await _apiService.getAreas(
        districtId: districtId,
        page: 1,
        pageSize: 50,
      );
      _areasByDistrict[districtId] = areas;
      _isLoadingAreas[districtId] = false;
      notifyListeners();
      return areas;
    } catch (e) {
      _isLoadingAreas[districtId] = false;
      notifyListeners();
      rethrow;
    }
  }
}

// Model classes
class District {
  final int id;
  final String name;
  final int cityId;

  District({required this.id, required this.name, required this.cityId});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(id: json['id'], name: json['name'], cityId: json['cityId']);
  }
}

class Area {
  final int id;
  final String name;
  final int districtId;

  Area({required this.id, required this.name, required this.districtId});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'],
      name: json['name'],
      districtId: json['districtId'],
    );
  }

  toJson() {}
}
