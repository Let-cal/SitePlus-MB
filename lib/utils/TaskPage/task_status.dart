import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/utils/constants.dart';

/// Returns the status text in English based on the provided [status].
String getStatusText(String status) {
  switch (status) {
    case STATUS_CHUA_NHAN:
      return 'Not Received';
    case STATUS_DA_NHAN:
      return 'Received';
    case STATUS_CHO_PHE_DUYET:
      return 'Pending Approval';
    case STATUS_HOAN_THANH:
      return 'Completed';
    default:
      return 'Undefined';
  }
}

/// Returns an IconData corresponding to the provided [status].
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

/// Returns a Color based on the provided [status].
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

/// Returns a Color based on the provided priority value.
Color getStatusPriorityColor(BuildContext context, String priority) {
  final theme = Theme.of(context);
  switch (priority) {
    case PRIORITY_CAO:
      return theme.colorScheme.error;
    case PRIORITY_TRUNG_BINH:
      return theme.colorScheme.secondary;
    case PRIORITY_THAP:
      return theme.colorScheme.tertiary;
    default:
      return theme.colorScheme.secondary;
  }
}
