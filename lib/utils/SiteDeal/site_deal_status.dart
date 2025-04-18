// site_deal_status.dart
import 'package:flutter/material.dart';

// Định nghĩa các trạng thái của Site Deal
const String STATUS_ACTIVE = 'Active';
const String STATUS_EXPIRED = 'Inactive';
const String STATUS_IN_PROGRESS = 'In Progress';
// Map trạng thái từ API sang UI
Map<String, int> SITE_DEAL_STATUS_API_MAP = {
  STATUS_IN_PROGRESS: 0,
  STATUS_ACTIVE: 1,
  STATUS_EXPIRED: 2,
};

// Map trạng thái từ ID sang tên hiển thị
Map<int, String> SITE_DEAL_API_STATUS_MAP = {
  0: STATUS_IN_PROGRESS,
  1: STATUS_ACTIVE,
  2: STATUS_EXPIRED,
};

// Hàm lấy màu sắc dựa trên trạng thái
Color getSiteDealStatusColor(BuildContext context, String status) {
  final colorScheme = Theme.of(context).colorScheme;
  switch (status) {
    case STATUS_ACTIVE:
      return Colors.green;
    case STATUS_EXPIRED:
      return colorScheme.error;
    case STATUS_IN_PROGRESS:
      return Colors.teal;
    default:
      return colorScheme.onSurface;
  }
}

Color getSiteDealStatusColorByNumber(BuildContext context, int status) {
  final colorScheme = Theme.of(context).colorScheme;
  switch (status) {
    case 1:
      return Colors.green;
    case 2:
      return colorScheme.error;
    case 0:
      return Colors.blue;
    default:
      return colorScheme.onSurface;
  }
}

// Hàm chuyển đổi tên trạng thái từ API sang UI
String getSiteDealStatusName(String apiStatusName) {
  switch (apiStatusName) {
    case 'Hữu hiệu':
      return STATUS_ACTIVE;
    case 'Vô hiệu':
      return STATUS_EXPIRED;
    case 'Mới tạo':
      return STATUS_IN_PROGRESS;
    default:
      return apiStatusName;
  }
}
