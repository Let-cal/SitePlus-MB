import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siteplus_mb/utils/HomePage/site_report_statistics.dart';
import 'package:siteplus_mb/utils/HomePage/task_statistics.dart';
import 'package:siteplus_mb/utils/NotificationModel/notification_model.dart';
import 'package:siteplus_mb/utils/Site/site_category.dart';

import 'api_endpoints.dart';
import 'api_link.dart';

class ApiService {
  // Lấy token từ secure storage
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
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
