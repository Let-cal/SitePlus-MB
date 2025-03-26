import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/utils/constants.dart';

String getVietnameseStatus(String status) {
  switch (status) {
    case STATUS_CHUA_NHAN:
      return 'Chưa nhận';
    case STATUS_DA_NHAN:
      return 'Đã nhận';
    case STATUS_CHO_PHE_DUYET:
      return 'Đợi duyệt';
    case STATUS_HOAN_THANH:
      return 'Hoàn thành';
    default:
      return 'Không xác định';
  }
}

IconData getStatusIcon(String status) {
  switch (status) {
    case STATUS_CHUA_NHAN:
      return Icons.radio_button_checked;
    case STATUS_DA_NHAN:
      return LucideIcons.clock;
    case STATUS_CHO_PHE_DUYET:
      return Icons.access_time;
    case STATUS_HOAN_THANH:
      return Icons.check_circle;
    default:
      return LucideIcons.circle;
  }
}

Color getStatusColor(BuildContext context, String status) {
  final theme = Theme.of(context);
  switch (status) {
    case STATUS_CHUA_NHAN:
      return theme.colorScheme.primary;
    case STATUS_DA_NHAN:
      return Colors.orange;
    case STATUS_CHO_PHE_DUYET:
      return Colors.teal;
    case STATUS_HOAN_THANH:
      return Colors.green;
    default:
      return theme.colorScheme.secondary;
  }
}
