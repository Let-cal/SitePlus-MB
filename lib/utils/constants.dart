// lib/utils/constants.dart

// Task Status

import 'package:flutter/material.dart';
import 'package:siteplus_mb/utils/ReportPage/CustomerSegmentModel/customer_segment_provider.dart';

const String STATUS_CHUA_NHAN = 'Chưa Nhận';
const String STATUS_DA_NHAN = 'Đã Nhận';
const String STATUS_HOAN_THANH = 'Hoàn Thành';

// Task Priority
const String PRIORITY_CAO = 'Cao';
const String PRIORITY_TRUNG_BINH = 'Trung Bình';
const String PRIORITY_THAP = 'Thấp';

// Transportation
const String TRANSPORTATION_MOTORCYCLE = 'Xe Gắn Máy';
const String TRANSPORTATION_CAR = 'Ôtô';
const String TRANSPORTATION_BICYCLE = 'Xe Đạp';
const String TRANSPORTATION_PEDESTRIAN = 'Người Đi Bộ';

// Peak Hours
const String PEAK_HOUR_MORNING = 'Buổi Sáng (07:00 - 10:00)';
const String PEAK_HOUR_NOON = 'Buổi Trưa (11:00 - 14:00)';
const String PEAK_HOUR_AFTERNOON = 'Buổi Chiều (15:00 - 18:00)';
const String PEAK_HOUR_EVENING = 'Buổi Tối (19:00 - 22:00)';

// Customer Flow Ratings
const String RATING_EXCELLENT = 'Xuất Sắc';
const String RATING_GOOD = 'Tốt';
const String RATING_AVERAGE = 'Trung Bình';
const String RATING_POOR = 'Kém';
const String RATING_NOT_RATED = 'Chưa đánh giá';

// Section Titles
const String SECTION_CUSTOMER_TRAFFIC = 'I. Lưu Lượng Khách Hàng';
const String SECTION_OVERALL_RATING = 'Đánh Giá Tổng Quát';

// Instructions
const String INSTRUCTION_CUSTOMER_TRAFFIC =
    'Ghi lại phương tiện di chuyển chính và giờ cao điểm của khách hàng.';
const String LABEL_SELECT_TRANSPORTATION = 'Chọn Phương Tiện Di Chuyển:';
const String LABEL_SELECT_PEAK_HOURS = 'Chọn Giờ Cao Điểm:';

// Customer Type
const String DOMESTIC = 'Người dân địa phương';
const String TOURISTS = 'Khách du lịch';
const String STUDENTS = 'Sinh viên';
const String OFFICE_WORKERS = 'Nhân viên văn phòng';
const String WORKERS = 'Công nhân/Kỹ sư';
// Customer segment constants
Map<String, String> CUSTOMER_SEGMENTS = {};
Map<String, IconData> CUSTOMER_SEGMENT_ICONS = {};
Map<String, IconData> DEFAULT_CUSTOMER_SEGMENT_ICONS = {
  "1": Icons.school,
  "2": Icons.family_restroom,
  "3": Icons.business,
  "4": Icons.location_city,
  "5": Icons.engineering,
};

// Initialize method to be called at app startup, in ReportPage, or in the main.dart
Future<void> initCustomerSegments() async {
  final customerSegmentService = CustomerSegmentProvider();
  final segments = await customerSegmentService.getCustomerSegments();

  // Reset maps
  CUSTOMER_SEGMENTS = {};
  CUSTOMER_SEGMENT_ICONS = {};

  for (var segment in segments) {
    CUSTOMER_SEGMENTS[segment.id.toString()] = segment.name;

    // Sử dụng icon trong danh sách nếu có, nếu không dùng icon mặc định
    CUSTOMER_SEGMENT_ICONS[segment.id.toString()] =
        DEFAULT_CUSTOMER_SEGMENT_ICONS[segment.id.toString()] ?? Icons.people;
  }

  // Nếu API không trả về dữ liệu, giữ nguyên các giá trị mặc định
  if (CUSTOMER_SEGMENTS.isEmpty) {
    CUSTOMER_SEGMENTS = {
      "1": DOMESTIC,
      "2": TOURISTS,
      "3": STUDENTS,
      "4": OFFICE_WORKERS,
      "5": WORKERS,
    };

    CUSTOMER_SEGMENT_ICONS = DEFAULT_CUSTOMER_SEGMENT_ICONS;
  }
}

Map<String, int> STATUS_API_MAP = {
  STATUS_CHUA_NHAN: 1,
  STATUS_DA_NHAN: 2,
  STATUS_HOAN_THANH: 3,
};

// Priority mapping for API
const Map<String, int> PRIORITY_API_MAP = {
  PRIORITY_THAP: 1,
  PRIORITY_TRUNG_BINH: 2,
  PRIORITY_CAO: 3,
};

// Reverse mappings
Map<int, String> API_STATUS_MAP = {
  1: STATUS_CHUA_NHAN,
  2: STATUS_DA_NHAN,
  3: STATUS_HOAN_THANH,
};

const Map<int, String> API_PRIORITY_MAP = {
  1: PRIORITY_THAP,
  2: PRIORITY_TRUNG_BINH,
  3: PRIORITY_CAO,
};
