// lib/services/customer_segment_service.dart
import 'package:flutter/material.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/ReportPage/CustomerSegmentModel/customer_segment.dart';

class CustomerSegmentProvider {
  static final CustomerSegmentProvider _instance =
      CustomerSegmentProvider._internal();
  final ApiService _apiService = ApiService();

  // Cache for customer segments
  List<CustomerSegment>? _customerSegments;

  // Singleton constructor
  factory CustomerSegmentProvider() {
    return _instance;
  }

  CustomerSegmentProvider._internal();

  Future<List<CustomerSegment>> getCustomerSegments() async {
    // Return cached data if available
    if (_customerSegments != null && _customerSegments!.isNotEmpty) {
      return _customerSegments!;
    }

    // Fetch data from API
    _customerSegments = await _apiService.getCustomerSegments();
    return _customerSegments ?? [];
  }

  // Convert customer segments to a map format for the CustomChipGroup
  Map<String, String> getCustomerSegmentMap() {
    if (_customerSegments == null || _customerSegments!.isEmpty) {
      return {}; // Return empty map if no data
    }

    Map<String, String> segmentMap = {};
    for (var segment in _customerSegments!) {
      segmentMap[segment.id.toString()] = segment.name;
    }

    return segmentMap;
  }

  // Get customer segment name by id
  String getCustomerSegmentName(String id) {
    if (_customerSegments == null) return '';

    try {
      final int segmentId = int.parse(id);
      final segment = _customerSegments!.firstWhere(
        (segment) => segment.id == segmentId,
        orElse:
            () => CustomerSegment(
              id: 0,
              name: '',
              industryId: 0,
              description: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
      );

      return segment.name;
    } catch (e) {
      debugPrint('Error getting segment name: $e');
      return '';
    }
  }

  // Clear cache
  void clearCache() {
    _customerSegments = null;
  }
}
