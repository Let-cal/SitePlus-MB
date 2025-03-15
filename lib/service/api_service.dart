import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siteplus_mb/utils/AreaDistrict/locations_provider.dart';
import 'package:siteplus_mb/utils/HomePage/site_report_statistics.dart';
import 'package:siteplus_mb/utils/HomePage/task_statistics.dart';
import 'package:siteplus_mb/utils/NotificationModel/notification_model.dart';
import 'package:siteplus_mb/utils/Site/site_api_create_model.dart';
import 'package:siteplus_mb/utils/Site/site_category.dart';
import 'package:siteplus_mb/utils/Site/site_model.dart';

import 'api_endpoints.dart';
import 'api_link.dart';

class ApiService {
  // Lấy token từ secure storage
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<List<Site>> getSites({
    required int pageNumber,
    required int pageSize,
    String? search,
    int? status,
  }) async {
    final token = await getToken();

    Uri uri = Uri.parse('${ApiLink.baseUrl}${ApiEndpoints.getAllSites}');
    Map<String, String> params = {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
    };

    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }

    if (status != null) {
      params['status'] = status.toString();
    }

    try {
      final response = await http.get(
        uri.replace(queryParameters: params),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('API Response: ${jsonEncode(jsonData)}');

        if (jsonData['listData'] != null && jsonData['listData'].isNotEmpty) {
          return List<Site>.from(
            jsonData['listData'].map((item) => Site.fromJson(item)),
          );
        } else {
          return [];
        }
      } else {
        throw Exception('Lỗi khi tải dữ liệu: ${response.statusCode}');
      }
    } catch (e) {
      print('Error details: $e');
      rethrow;
    }
  }

  Future<List<District>> getDistricts({
    required int page,
    required int pageSize,
  }) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(
        '${ApiLink.baseUrl}${ApiEndpoints.getAllDistricts}?page=$page&pageSize=$pageSize',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print('Districts Response Structure: ${jsonResponse.keys}');

      // Check if the data structure matches your expectations
      if (jsonResponse.containsKey('data') &&
          jsonResponse['data'] is Map &&
          (jsonResponse['data'] as Map).containsKey('listData') &&
          jsonResponse['data']['listData'] is List) {
        final List<dynamic> listData = jsonResponse['data']['listData'];
        return listData.map((json) => District.fromJson(json)).toList();
      } else if (jsonResponse.containsKey('data') &&
          jsonResponse['data'] is List) {
        // Alternative structure
        final List<dynamic> listData = jsonResponse['data'];
        return listData.map((json) => District.fromJson(json)).toList();
      } else {
        // Print the actual structure to debug
        print('Unexpected response structure: $jsonResponse');
        throw Exception('Unexpected API response format');
      }
    } else {
      throw Exception('Failed to load districts: ${response.statusCode}');
    }
  }

  // Get areas by district ID
  Future<List<Area>> getAreas({
    required int districtId,
    required int page,
    required int pageSize,
  }) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(
        '${ApiLink.baseUrl}${ApiEndpoints.getAllAreaByDistrict}/$districtId?page=$page&pageSize=$pageSize',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print('Areas Response Structure: ${jsonResponse.keys}');

      if (jsonResponse.containsKey('data') &&
          jsonResponse['data'] is Map &&
          (jsonResponse['data'] as Map).containsKey('listData') &&
          jsonResponse['data']['listData'] is List) {
        final List<dynamic> listData = jsonResponse['data']['listData'];
        return listData.map((json) => Area.fromJson(json)).toList();
      } else if (jsonResponse.containsKey('data') &&
          jsonResponse['data'] is List) {
        // Alternative structure
        final List<dynamic> listData = jsonResponse['data'];
        return listData.map((json) => Area.fromJson(json)).toList();
      } else {
        print('Unexpected response structure: $jsonResponse');
        throw Exception('Unexpected API response format');
      }
    } else {
      throw Exception('Failed to load areas: ${response.statusCode}');
    }
  }

  Future<List<Area>> getAllAreas({int page = 1, int pageSize = 100}) async {
    final token = await getToken();
    final uri = Uri.parse(
      '${ApiLink.baseUrl}${ApiEndpoints.getAllAreas}?page=$page&pageSize=$pageSize',
    );
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      debugPrint('API Response: ${jsonEncode(jsonData)}');

      // Kiểm tra cấu trúc dữ liệu
      if (jsonData['data'] == null || jsonData['data']['listData'] == null) {
        debugPrint('WARNING: Dữ liệu không đúng cấu trúc');
        return [];
      }

      final list = jsonData['data']['listData'] as List;
      final areas = list.map((item) => Area.fromJson(item)).toList();

      // Kiểm tra dữ liệu sau khi convert
      if (areas.any((area) => area == null)) {
        debugPrint('WARNING: Có area null sau khi convert');
      }

      return areas;
    } else {
      throw Exception('Lỗi khi tải dữ liệu Area: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> createSite(SiteCreateRequest request) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse(ApiLink.baseUrl + ApiEndpoints.createSite),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to create site: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Thêm hàm chuyển đổi dữ liệu cho báo cáo site
  Map<String, List<double>> convertToSiteReportData(
    SiteReportStatistics statistics,
  ) {
    // Khởi tạo danh sách dữ liệu
    List<double> totalData = [];
    List<double> availableData = [];
    List<double> pendingApprovalData = [];
    List<double> refuseData = [];
    List<double> closedData = [];

    // Duyệt qua báo cáo hàng ngày và thêm vào danh sách tương ứng
    for (var dailyReport in statistics.dailyReports) {
      totalData.add(dailyReport.total.toDouble());
      availableData.add(
        (dailyReport.statusTotals['Available'] ?? 0).toDouble(),
      );
      pendingApprovalData.add(
        (dailyReport.statusTotals['PendingApproval'] ?? 0).toDouble(),
      );
      refuseData.add((dailyReport.statusTotals['Refuse'] ?? 0).toDouble());
      closedData.add((dailyReport.statusTotals['Closed'] ?? 0).toDouble());
    }

    // Trả về map dữ liệu
    return {
      'total': totalData,
      'available': availableData,
      'pendingApproval': pendingApprovalData,
      'refuse': refuseData,
      'closed': closedData,
    };
  }

  Map<String, List<double>> convertToWeeklyData(TaskStatistics statistics) {
    // Khởi tạo các danh sách dữ liệu
    List<double> totalData = [];
    List<double> assignedData = [];
    List<double> inProgressData = [];
    List<double> completedData = [];

    // Duyệt qua báo cáo hàng ngày và thêm vào danh sách tương ứng
    for (var dailyReport in statistics.dailyReports) {
      totalData.add(dailyReport.total.toDouble());
      assignedData.add(dailyReport.statusTotals.assigned.toDouble());
      inProgressData.add(dailyReport.statusTotals.inProgress.toDouble());
      completedData.add(dailyReport.statusTotals.completed.toDouble());
    }

    // Trả về map dữ liệu
    return {
      'total': totalData,
      'assigned': assignedData,
      'inProgress': inProgressData,
      'completed': completedData,
    };
  }

  Future<SiteReportStatistics> getWeeklySiteReportStatistics(
    String token,
  ) async {
    final url = Uri.parse(ApiLink.baseUrl + ApiEndpoints.taskStatistics);

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return SiteReportStatistics.fromJson(data);
      } else {
        throw Exception(
          'Failed to load site report statistics: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error getting site report statistics: $e');
    }
  }

  Future<TaskStatistics> getWeeklyTaskStatistics(String token) async {
    final url = Uri.parse(ApiLink.baseUrl + ApiEndpoints.taskStatistics);

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return TaskStatistics.fromJson(data);
      } else {
        throw Exception(
          'Failed to load task statistics: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error getting task statistics: $e');
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiLink.baseUrl + ApiEndpoints.login),
        headers: {'Content-Type': 'application/json', 'accept': '*/*'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã xảy ra lỗi kết nối',
        'error': e.toString(),
      };
    }
  }

  Future<List<SiteCategory>> getSiteCategories(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiLink.baseUrl + ApiEndpoints.siteCate),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true && responseData['data'] != null) {
        print('API get all site category: ${jsonEncode(responseData)}');
        return (responseData['data'] as List)
            .map((item) => SiteCategory.fromJson(item))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching site categories: $e');
      return [];
    }
  }

  // Phương thức GET cho notification API
  Future<List<NotificationDto>> fetchNotifications() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token xác thực');
      }

      final response = await http.get(
        Uri.parse(ApiLink.baseUrl + ApiEndpoints.notification),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData is! Map<String, dynamic>) {
          throw Exception('Dữ liệu trả về không hợp lệ');
        }

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> notificationsJson = responseData['data'];

          // Chuyển đổi danh sách JSON thành List<NotificationDto>
          final List<NotificationDto> notifications =
              notificationsJson
                  .map(
                    (json) =>
                        NotificationDto.fromJson(json as Map<String, dynamic>),
                  )
                  .toList();

          return notifications;
        } else {
          throw Exception(responseData['message'] ?? 'Không thể tải thông báo');
        }
      } else {
        throw Exception(
          'Không thể kết nối đến máy chủ: Mã lỗi ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Lỗi khi tải thông báo: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getTasks({
    String? search,
    int? status,
    int? priority,
    int page = 1,
    int pageSize = 5,
  }) async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Không tìm thấy token xác thực'};
      }

      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (status != null) {
        queryParams['status'] = status.toString();
      }

      if (priority != null) {
        queryParams['priority'] = priority.toString();
      }

      final uri = Uri.parse(
        ApiLink.baseUrl + ApiEndpoints.task,
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Lỗi khi lấy danh sách task: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã xảy ra lỗi kết nối',
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getTaskStatuses() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Không tìm thấy token xác thực'};
      }

      final uri = Uri.parse(ApiLink.baseUrl + ApiEndpoints.taskStatuses);
      final response = await http.get(
        uri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'message': 'Lỗi khi lấy danh sách status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã xảy ra lỗi kết nối',
        'error': e.toString(),
      };
    }
  }
}
