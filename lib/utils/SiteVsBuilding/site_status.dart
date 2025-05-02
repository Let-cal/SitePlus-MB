import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Trả về trạng thái bằng tiếng Việt dựa vào giá trị [status]
String getStatusText(int status) {
  switch (status) {
    case 1:
      return 'Available';
    case 2:
      return 'In Progress';
    case 3:
      return 'Pending Approval';
    case 4:
      return 'Rejected';
    case 5:
      return 'Closed';
    case 6:
      return 'Connected';
    case 7:
      return 'Negotiating';
    case 8:
      return 'Draft';
    case 9:
      return 'Proposed';
    case 10:
      return 'Done';
    default:
      return 'Undefined';
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
      return Colors.teal;
    case 4:
      return theme.colorScheme.error;
    case 5:
      return Colors.grey;
    case 6:
      return Colors.cyan;
    case 7:
      return Colors.amber;
    case 8:
      return Colors.blueGrey;
    case 9:
      return Colors.blue;
    case 10:
      return Colors.indigo;
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
    case 7:
      return Icons.forum;
    case 8:
      return Icons.note;
    case 9:
      return LucideIcons.clipboardCheck;
    case 10:
      return LucideIcons.badgeCheck;
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
