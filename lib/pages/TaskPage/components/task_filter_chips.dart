import 'package:flutter/material.dart';
import 'package:siteplus_mb/components/filter_chip.dart';
import 'package:siteplus_mb/utils/constants.dart';

class TaskFilterChips extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusSelected;
  final String selectedPriority;
  final Function(String) onPrioritySelected;
  final String taskTypeFilter; // Thay bool bằng String
  final Function(String) onTaskTypeFilterChanged; // Callback mới
  final Map<int, String> availableStatuses;

  const TaskFilterChips({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
    required this.selectedPriority,
    required this.onPrioritySelected,
    required this.taskTypeFilter,
    required this.onTaskTypeFilterChanged,
    required this.availableStatuses,
  });

  @override
  Widget build(BuildContext context) {
    List<FilterOption> statusOptions = [
      FilterOption(
        label: 'Tất Cả',
        icon: Icons.all_inclusive,
        color: Colors.grey,
        isSelected: selectedStatus == 'Tất Cả',
        onTap: () => onStatusSelected('Tất Cả'),
      ),
      ...availableStatuses.entries.map((entry) {
        IconData icon;
        Color color;
        switch (entry.value) {
          case STATUS_CHUA_NHAN:
            icon = Icons.pending_actions;
            color = Colors.blue;
            break;
          case STATUS_DA_NHAN:
            icon = Icons.assignment_ind;
            color = Colors.orange;
            break;
          case STATUS_HOAN_THANH:
            icon = Icons.task_alt;
            color = Colors.green;
            break;
          case STATUS_CHO_PHE_DUYET:
            icon = Icons.access_time;
            color = Colors.teal;
            break;
          default:
            icon = Icons.circle;
            color = Colors.grey;
        }
        return FilterOption(
          label: entry.value,
          icon: icon,
          color: color,
          isSelected: selectedStatus == entry.value,
          onTap: () => onStatusSelected(entry.value),
        );
      }),
    ];

    return FilterChipPanel(
      headerTitle: 'Bộ Lọc',
      sections: [
        FilterSection(
          title: 'Trạng thái',
          isChipStyle: true,
          options: statusOptions,
        ),
        FilterSection(
          title: 'Loại nhiệm vụ',
          isChipStyle: true, // Sử dụng chip cho 3 tùy chọn
          options: [
            FilterOption(
              label: 'Tất cả',
              icon: Icons.all_inclusive,
              color: Colors.grey,
              isSelected: taskTypeFilter == 'Tất cả',
              onTap: () => onTaskTypeFilterChanged('Tất cả'),
            ),
            FilterOption(
              label: 'Chỉ công ty',
              icon: Icons.business,
              color: Colors.blue,
              isSelected: taskTypeFilter == 'Chỉ công ty',
              onTap: () => onTaskTypeFilterChanged('Chỉ công ty'),
            ),
            FilterOption(
              label: 'Từ yêu cầu',
              icon: Icons.request_page,
              color: Colors.purple,
              isSelected: taskTypeFilter == 'Từ yêu cầu',
              onTap: () => onTaskTypeFilterChanged('Từ yêu cầu'),
            ),
          ],
        ),
        FilterSection(
          title: 'Mức độ ưu tiên',
          isChipStyle: false,
          options: [
            FilterOption(
              label: 'Tất Cả',
              color: Colors.grey,
              isSelected: selectedPriority == 'Tất Cả',
              onTap: () => onPrioritySelected('Tất Cả'),
            ),
            FilterOption(
              label: PRIORITY_CAO,
              color: Colors.red,
              isSelected: selectedPriority == PRIORITY_CAO,
              onTap: () => onPrioritySelected(PRIORITY_CAO),
            ),
            FilterOption(
              label: PRIORITY_TRUNG_BINH,
              color: Colors.orange,
              isSelected: selectedPriority == PRIORITY_TRUNG_BINH,
              onTap: () => onPrioritySelected(PRIORITY_TRUNG_BINH),
            ),
            FilterOption(
              label: PRIORITY_THAP,
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
                    : Colors.green,
            onRemove: () => onPrioritySelected('Tất Cả'),
          ),
        if (taskTypeFilter != 'Tất cả')
          ActiveFilter(
            label: taskTypeFilter,
            color:
                taskTypeFilter == 'Chỉ công ty' ? Colors.blue : Colors.purple,
            onRemove: () => onTaskTypeFilterChanged('Tất cả'),
          ),
      ],
    );
  }
}
