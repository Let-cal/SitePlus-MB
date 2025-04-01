import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siteplus_mb/utils/AreaDistrict/locations_provider.dart';
import 'package:siteplus_mb/utils/HomePage/site_report_statistics.dart';
import 'package:siteplus_mb/utils/HomePage/task_statistics.dart';
import 'package:siteplus_mb/utils/NotificationModel/notification_model.dart';
import 'package:siteplus_mb/utils/ReportPage/CustomerSegmentModel/customer_segment.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_api_create_model.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_category.dart';

import 'api_endpoints.dart';
import 'api_link.dart';

class ApiService {
  // Lấy token từ secure storage
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<bool> createSiteDeal(Map<String, dynamic> dealData) async {
    final token = await getToken();
    const url =
        '${ApiLink.baseUrl}${ApiEndpoints.createSiteDeal}'; // "api/SiteDeal"

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json-patch+json',
          'Accept': '*/*',
        },
        body: jsonEncode(dealData),
      );

      debugPrint('Create Site Deal URL: $url');
      debugPrint('Request Body: ${jsonEncode(dealData)}');
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Site deal created successfully');
        return true;
      } else {
        debugPrint('Failed to create site deal: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Exception when creating site deal: $e');
      return false;
    }
  }

  // Lấy Site Deal theo Site ID
  Future<Map<String, dynamic>?> getSiteDealBySiteId(int siteId) async {
    final token = await getToken();
    final url =
        '${ApiLink.baseUrl}${ApiEndpoints.getSiteDealBySiteId}/$siteId'; // "api/SiteDeal/site/{siteId}"

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
      );

      debugPrint('Get Site Deal URL: $url');
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
          return jsonResponse['data'][0]; // Lấy deal đầu tiên (giả sử chỉ có 1 deal mỗi site)
        }
        return null;
      } else {
        debugPrint('Failed to fetch site deal: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception when fetching site deal: $e');
      return null;
    }
  }

  // Cập nhật Site Deal (chưa có API, để trống)
  Future<bool> updateSiteDeal(int dealId, Map<String, dynamic> dealData) async {
    final token = await getToken();
    final url =
        '${ApiLink.baseUrl}${ApiEndpoints.updateSiteDeal}/$dealId'; // "api/SiteDeal/{id}"

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json-patch+json',
          'Accept': '*/*',
        },
        body: jsonEncode(dealData),
      );

      debugPrint('Update Site Deal URL: $url');
      debugPrint('Request Body: ${jsonEncode(dealData)}');
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('Site deal updated successfully');
        return true;
      } else {
        debugPrint('Failed to update site deal: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Exception when updating site deal: $e');
      return false;
    }
  }

  Future<bool> updateSiteStatus(int siteId, int status) async {
    final token = await getToken();
    final url = '${ApiLink.baseUrl}${ApiEndpoints.updateSiteStatus}';

    final body = {'siteId': siteId, 'status': status};

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json-patch+json',
          'Accept': '*/*',
        },
        body: jsonEncode(body),
      );

      debugPrint('Update Site Status URL: $url');
      debugPrint('Request Body: ${jsonEncode(body)}');
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('Site status updated successfully to $status');
        return true;
      } else {
        debugPrint('Failed to update site status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Exception when updating site status: $e');
      return false;
    }
  }

  Future<bool> updateTaskStatus(int taskId, int status) async {
    final token = await getToken();
    final url = '${ApiLink.baseUrl}${ApiEndpoints.updateTaskStatus}';

    final body = {'taskId': taskId, 'status': status};

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json-patch+json',
          'Accept': '*/*',
        },
        body: jsonEncode(body),
      );

      debugPrint('Update Task Status URL: $url');
      debugPrint('Request Body: ${jsonEncode(body)}');
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('Task status updated successfully to $status');
        return true;
      } else {
        debugPrint('Failed to update site status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Exception when updating Task status: $e');
      return false;
    }
  }

  Future<bool> updateReport(
    int siteId,
    List<Map<String, dynamic>> reportData,
  ) async {
    final token = await getToken();
    final url = '${ApiLink.baseUrl}${ApiEndpoints.updateReport}/$siteId';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json-patch+json',
          'Accept': '*/*',
        },
        body: jsonEncode(reportData),
      );
      debugPrint('Update report URL: $url');
      debugPrint('Request body: ${jsonEncode(reportData)}');
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('Update report successful');
        return true;
      } else {
        debugPrint('Failed to update report: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Exception when updating report: $e');
      return false;
    }
  }

  // API lấy tất cả attributes
  Future<List<Map<String, dynamic>>> getAllAttributes() async {
    final token = await getToken();
    final url =
        '${ApiLink.baseUrl}${ApiEndpoints.getAttributes}?page=0&pageSize=0';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> attributesData = jsonResponse['data'];
        final attributes =
            attributesData.map((attr) => attr as Map<String, dynamic>).toList();
        debugPrint('Attributes data: $attributes'); // Debug logging
        return attributes;
      } else {
        debugPrint('Lỗi lấy attributes: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('Lỗi lấy attributes: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception when fetching attributes: $e');
      throw Exception('Lỗi khi lấy attributes: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAttributeValuesBySiteId(
    int siteId,
  ) async {
    final token = await getToken();
    final url = '${ApiLink.baseUrl}${ApiEndpoints.getAttributeValues}/$siteId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print('response của Attribute values từ api service: $jsonResponse');
        if (jsonResponse['data'] != null) {
          return List<Map<String, dynamic>>.from(jsonResponse['data']);
        } else {
          debugPrint('No attribute values found for site ID: $siteId');
          return [];
        }
      } else {
        debugPrint('Error fetching attribute values: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Exception when fetching attribute values: $e');
      return [];
    }
  }

  Future<List<CustomerSegment>> getCustomerSegments() async {
    final token = await getToken();
    final url = '${ApiLink.baseUrl}${ApiEndpoints.getCustomerSegments}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((item) => CustomerSegment.fromJson(item)).toList();
        } else {
          debugPrint(
            'No customer segments data found or request not successful',
          );
          return [];
        }
      } else {
        debugPrint('Error fetching customer segments: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Exception when fetching customer segments: $e');
      return [];
    }
  }

  Future<bool> createReport(List<Map<String, dynamic>> reportData) async {
    final token = await getToken();
    final url = '${ApiLink.baseUrl}${ApiEndpoints.createReport}';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(reportData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Report created successfully!');
        return true;
      } else {
        debugPrint('Error creating report: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Exception when creating report: $e');
      return false;
    }
  }

  Future<void> deleteImage(int imageId) async {
    final token = await getToken();
    final url = '${ApiLink.baseUrl}${ApiEndpoints.deleteImage}/$imageId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
      );

      if (response.statusCode != 200) {
        throw Exception('Lỗi xóa ảnh: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi xóa ảnh: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSiteImages(int siteId) async {
    final token = await getToken();
    final url = '${ApiLink.baseUrl}${ApiEndpoints.getImageSite}/$siteId/images';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> imagesData = jsonResponse['images']['data'];
        // Trả về danh sách các map chứa id và url
        return imagesData
            .map(
              (image) => {
                'id': image['id'], // Giữ nguyên id từ API
                'url': image['url'].toString(), // Chuyển url thành chuỗi
              },
            )
            .toList();
      } else {
        debugPrint('Lỗi lấy ảnh site: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('Lỗi lấy ảnh site: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception when fetching site images: $e');
      throw Exception('Lỗi khi lấy ảnh site: $e');
    }
  }

  Future<List<String>> uploadImages(
    List<XFile> images,
    int siteId, {
    int? buildingId,
  }) async {
    final token = await getToken();
    String url = '${ApiLink.baseUrl}${ApiEndpoints.imageUpload}?siteId=$siteId';

    // Add buildingId to query parameters if it exists
    if (buildingId != null) {
      url += '&buildingId=$buildingId';
    }

    // Create multipart request
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $token';

    // Add image files to the request
    for (var image in images) {
      final file = await http.MultipartFile.fromPath('files', image.path);
      request.files.add(file);
    }

    try {
      // Send the request
      var response = await request.send();

      // Read response
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // Parse the response
        final Map<String, dynamic> jsonResponse = jsonDecode(responseString);
        final List<dynamic> imageUrls = jsonResponse['imageUrls'];

        // Convert dynamic list to String list
        return imageUrls.map((url) => url.toString()).toList();
      } else {
        debugPrint('Lỗi upload ảnh: ${response.statusCode}');
        debugPrint('Response body: $responseString');
        throw Exception('Lỗi upload ảnh: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception during upload: $e');
      throw Exception('Lỗi khi upload ảnh: $e');
    }
  }

  Future<List<BuildingCreateRequest>> getBuildingsByAreaId(int areaId) async {
    final token = await getToken();
    final uri = Uri.parse(
      '${ApiLink.baseUrl}${ApiEndpoints.getAllBuilding}/$areaId',
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      debugPrint('Buildings API Response: ${jsonEncode(jsonData)}');

      final buildings =
          jsonData.map((item) => BuildingCreateRequest.fromJson(item)).toList();
      return buildings;
    } else {
      debugPrint('Lỗi khi lấy danh sách tòa nhà: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      throw Exception('Lỗi khi lấy danh sách tòa nhà: ${response.statusCode}');
    }
  }

  Future<BuildingCreateRequest> createBuilding(String name, int areaId) async {
    final token = await getToken();
    final uri = Uri.parse('${ApiLink.baseUrl}${ApiEndpoints.createBuilding}');

    final Map<String, dynamic> requestBody = {'name': name, 'areaId': areaId};

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);

      if (jsonData['success'] == true && jsonData['data'] != null) {
        // Lấy id của building vừa tạo
        final int buildingId = jsonData['data'];
        return BuildingCreateRequest(
          id: buildingId,
          name: name,
          areaId: areaId,
          areaName: '',
          status: 1,
          statusName: 'Available',
        );
      } else {
        throw Exception('Lỗi khi tạo Building: ${jsonData['message']}');
      }
    } else {
      debugPrint('Lỗi khi tạo Building: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      throw Exception('Lỗi khi tạo Building: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getSites({
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
        print('API get all site Response: ${jsonEncode(jsonData)}');
        return jsonData; // Trả về toàn bộ response
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

  // Lấy thông tin Site theo ID
  Future<Map<String, dynamic>> getSiteById(int siteId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('${ApiLink.baseUrl}${ApiEndpoints.getSiteById}/$siteId'),
      headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print('API get all site by id Response: $jsonResponse');
      return jsonResponse;
    } else {
      throw Exception('Failed to load site: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateSite(
    int siteId,
    Map<String, dynamic> siteData,
  ) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse('${ApiLink.baseUrl}${ApiEndpoints.updateSite}/$siteId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': '*/*',
        'Content-Type': 'application/json-patch+json',
      },
      body: json.encode(siteData),
    );

    final jsonResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      print("api update site response: ${jsonResponse}");
      return jsonResponse;
    } else {
      throw Exception(
        'Failed to update site: ${response.statusCode} - ${jsonResponse['message']}',
      );
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
      final responseBody = jsonDecode(response.body);
      print("response api create site: $responseBody");
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
      print('API Response: ${response.body}');
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
    bool? isCompanyTaskOnly,
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
      if (isCompanyTaskOnly != null) {
        queryParams['isCompanyTaskOnly'] = isCompanyTaskOnly.toString();
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
