import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:siteplus_mb/utils/NotificationModel/notification_model.dart';

class SignalRService {
  HubConnection? _hubConnection;
  // final String _hubUrl =
  //     '${ApiLink.baseUrl}/notificationHub'; // Sửa URL đúng với backend
  final String _hubUrl =
      'https://siteplus-eeb6evfwhhagfzdd.southeastasia-01.azurewebsites.net/notificationHub';
  // Khởi tạo và bắt đầu kết nối
  Future<void> startConnection() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    _hubConnection =
        HubConnectionBuilder()
            .withUrl(
              _hubUrl,
              options: HttpConnectionOptions(
                accessTokenFactory: () async => token,
              ),
            )
            .build();

    // Xử lý khi kết nối bị đóng và tự động kết nối lại
    _hubConnection!.onclose(({error}) {
      print('Kết nối SignalR bị đóng: $error');
      Future.delayed(Duration(seconds: 5), () {
        startConnection();
      });
    });

    try {
      await _hubConnection!.start();
      print('Kết nối SignalR đã được thiết lập thành công.');
    } catch (e) {
      print('Lỗi khi kết nối SignalR: $e');
    }
  }

  // Lắng nghe thông báo từ backend
  void onReceiveNotification(Function(NotificationDto) callback) {
    _hubConnection!.on('ReceiveNotification', (arguments) {
      print('Nhận được thông báo từ backend: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        final notificationJson = arguments[0] as Map<String, dynamic>;
        final notification = NotificationDto.fromJson(notificationJson);
        callback(notification);
      }
    });
  }

  // Ngắt kết nối
  Future<void> stopConnection() async {
    await _hubConnection!.stop();
    print('Kết nối SignalR đã dừng.');
  }
}
