import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Trả về trạng thái bằng tiếng Việt dựa vào giá trị [status]
String getVietnameseStatus(int status) {
  switch (status) {
    case 1:
      return 'Có sẵn';
    case 2:
      return 'Đang tiến hành';
    case 3:
      return 'Chờ phê duyệt';
    case 4:
      return 'Bị từ chối';
    case 5:
      return 'Đã đóng';
    case 6:
      return 'Đã kết nối';
    default:
      return 'Không xác định';
  }
}

/// Trả về Color dựa vào [status]
Color getStatusColor(BuildContext context, int status) {
  final theme = Theme.of(context);
  switch (status) {
    case 1:
      return Colors.green;
    case 2:
      return Colors.orange;
    case 3:
      return Colors.blue;
    case 4:
      return theme.colorScheme.error;
    case 5:
      return Colors.grey;
    case 6:
      return Colors.cyan;
    default:
      return theme.colorScheme.secondary;
  }
}

/// Trả về IconData tương ứng với [status]
IconData getStatusIcon(int status) {
  switch (status) {
    case 1:
      return Icons.check;
    case 2:
      return Icons.timer;
    case 3:
      return Icons.hourglass_full;
    case 4:
      return Icons.close;
    case 5:
      return Icons.archive;
    case 6:
      return Icons.map;
    default:
      return Icons.help;
  }
}

IconData getSiteCategoryIcon(int status) {
  switch (status) {
    case 1:
      return LucideIcons.building;
    case 2:
      return LucideIcons.landmark;
    default:
      return Icons.all_inclusive;
  }
}

Color getCategoryColor(int categoryId) {
  switch (categoryId) {
    case 1:
      return Colors.green.shade300;
    case 2:
      return Colors.blue.shade300;
    default:
      return Colors.grey;
  }
}
