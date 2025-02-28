import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siteplus_mb/utils/NotificationModel/notification_model.dart';
import 'package:siteplus_mb/utils/Site/site_category.dart';

import 'api_endpoints.dart';
import 'api_link.dart';

class ApiService {
  // Lấy token từ secure storage
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
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
  Future<NotificationResponse> getNotifications() async {
    final token = await _getToken();

    if (token == null) {
      throw Exception('Không tìm thấy token xác thực');
    }

    final response = await http.get(
      Uri.parse(ApiLink.baseUrl + ApiEndpoints.notification),
      headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return NotificationResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Không thể lấy danh sách thông báo: ${response.statusCode}',
      );
    }
  }
}

// Model để parse response từ API
class NotificationResponse {
  final List<NotificationDto> data;
  final bool success;
  final String message;

  NotificationResponse({
    required this.data,
    required this.success,
    required this.message,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      data:
          (json['data'] as List)
              .map((item) => NotificationDto.fromJson(item))
              .toList(),
      success: json['success'],
      message: json['message'],
    );
  }
}
