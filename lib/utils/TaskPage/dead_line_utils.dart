import 'package:flutter/material.dart';

class DeadlineUtils {
  // Get color based on days to deadline
  static Color getDeadlineColor(int daysToDeadline) {
    if (daysToDeadline < 0) {
      return Colors.red; // Overdue
    } else if (daysToDeadline <= 3) {
      return Colors.orange; // Due soon
    } else if (daysToDeadline <= 7) {
      return Colors.blue; // Approaching
    } else {
      return Colors.green; // Plenty of time
    }
  }

  // Get a formatted text message based on days to deadline
  static String getDeadlineMessage(int daysToDeadline) {
    if (daysToDeadline < 0) {
      return '${daysToDeadline.abs()} days overdue';
    } else if (daysToDeadline == 0) {
      return 'Due today';
    } else if (daysToDeadline == 1) {
      return '1 day left';
    } else if (daysToDeadline == 2) {
      return '2 day left';
    } else if (daysToDeadline == 3) {
      return '3 day left';
    } else {
      return '$daysToDeadline days left';
    }
  }

  // Get icon based on days to deadline
  static IconData getDeadlineIcon(int daysToDeadline) {
    if (daysToDeadline < 0) {
      return Icons.warning_amber_rounded;
    } else if (daysToDeadline <= 3) {
      return Icons.access_time_filled;
    } else {
      return Icons.calendar_today;
    }
  }
}
