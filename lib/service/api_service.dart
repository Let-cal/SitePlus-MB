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
  Future<List<NotificationDto>> fetchNotifications() async {
    try {
      final token = await _getToken();
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
      final token = await _getToken();

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
}
