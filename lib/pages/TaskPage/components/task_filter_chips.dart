import 'package:flutter/material.dart';
import 'package:siteplus_mb/components/filter_chip.dart';
import 'package:siteplus_mb/utils/constants.dart';

class TaskFilterChips extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusSelected;
  final String selectedPriority;
  final Function(String) onPrioritySelected;
  final Map<int, String> availableStatuses; // Thêm tham số này

  const TaskFilterChips({
    Key? key,
    required this.selectedStatus,
    required this.onStatusSelected,
    required this.selectedPriority,
    required this.onPrioritySelected,
    required this.availableStatuses, // Yêu cầu danh sách trạng thái
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tạo các tùy chọn bộ lọc động dựa trên trạng thái có sẵn
    List<FilterOption> statusOptions = [
      FilterOption(
        label: 'Tất Cả',
        icon: Icons.all_inclusive,
        color: Colors.grey,
        isSelected: selectedStatus == 'Tất Cả',
        onTap: () => onStatusSelected('Tất Cả'),
      ),
    ];

    // Thêm các tùy chọn từ availableStatuses
    availableStatuses.forEach((id, label) {
      IconData icon;
      Color color;

      // Xác định icon và màu dựa trên label
      if (label == STATUS_CHUA_NHAN) {
        icon = Icons.pending_actions;
        color = Colors.blue;
      } else if (label == STATUS_DA_NHAN) {
        icon = Icons.assignment_ind;
        color = Colors.orange;
      } else if (label == STATUS_HOAN_THANH) {
        icon = Icons.task_alt;
        color = Colors.green;
      } else if (label == STATUS_CHO_PHE_DUYET) {
        icon = Icons.access_time;
        color = Colors.teal;
      } else {
        icon = Icons.circle;
        color = Colors.grey;
      }

      statusOptions.add(
        FilterOption(
          label: label,
          icon: icon,
          color: color,
          isSelected: selectedStatus == label,
          onTap: () => onStatusSelected(label),
        ),
      );
    });

    return FilterChipPanel(
      headerTitle: 'Bộ Lọc',
      sections: [
        FilterSection(
          title: 'Trạng thái',
          isChipStyle: true,
          options: statusOptions,
        ),
        // Phần mức độ ưu tiên giữ nguyên
        FilterSection(
          title: 'Mức độ ưu tiên',
          isChipStyle: false,
          options: [
            FilterOption(
              label: 'Tất Cả',
              icon: null,
              color: Colors.grey,
              isSelected: selectedPriority == 'Tất Cả',
              onTap: () => onPrioritySelected('Tất Cả'),
            ),
            FilterOption(
              label: PRIORITY_CAO,
              icon: null,
              color: Colors.red,
              isSelected: selectedPriority == PRIORITY_CAO,
              onTap: () => onPrioritySelected(PRIORITY_CAO),
            ),
            FilterOption(
              label: PRIORITY_TRUNG_BINH,
              icon: null,
              color: Colors.orange,
              isSelected: selectedPriority == PRIORITY_TRUNG_BINH,
              onTap: () => onPrioritySelected(PRIORITY_TRUNG_BINH),
            ),
            FilterOption(
              label: PRIORITY_THAP,
              icon: null,
              color: Colors.green,
              isSelected: selectedPriority == PRIORITY_THAP,
              onTap: () => onPrioritySelected(PRIORITY_THAP),
            ),
          ],
        ),
      ],
      activeFilters: [
        ActiveFilter(
          label: selectedStatus,
          color:
              selectedStatus == STATUS_CHUA_NHAN
                  ? Colors.blue
                  : selectedStatus == STATUS_DA_NHAN
                  ? Colors.orange
                  : selectedStatus == STATUS_HOAN_THANH
                  ? Colors.green
                  : selectedStatus == STATUS_CHO_PHE_DUYET
                  ? Colors.teal
                  : Colors.grey,
          onRemove: () => onStatusSelected('Tất Cả'),
        ),
        if (selectedPriority != 'Tất Cả')
          ActiveFilter(
            label: selectedPriority,
            color:
                selectedPriority == PRIORITY_CAO
                    ? Colors.red
                    : selectedPriority == PRIORITY_TRUNG_BINH
                    ? Colors.orange
                    : selectedPriority == PRIORITY_THAP
                    ? Colors.green
                    : Colors.grey,
            onRemove: () => onPrioritySelected('Tất Cả'),
          ),
      ],
    );
  }
}
