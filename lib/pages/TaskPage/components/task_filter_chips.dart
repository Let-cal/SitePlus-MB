import 'package:flutter/material.dart';
import 'package:siteplus_mb/components/filter_chip.dart';
import 'package:siteplus_mb/utils/constants.dart';

class TaskFilterChips extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusSelected;
  final String selectedPriority;
  final Function(String) onPrioritySelected;

  const TaskFilterChips({
    Key? key,
    required this.selectedStatus,
    required this.onStatusSelected,
    required this.selectedPriority,
    required this.onPrioritySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilterChipPanel(
      headerTitle: 'Bộ Lọc',
      sections: [
        FilterSection(
          title: 'Trạng thái',
          isChipStyle: true,
          options: [
            FilterOption(
              label: STATUS_CHUA_NHAN,
              icon: Icons.pending_actions,
              color: Colors.blue,
              isSelected: selectedStatus == STATUS_CHUA_NHAN,
              onTap: () => onStatusSelected(STATUS_CHUA_NHAN),
            ),
            FilterOption(
              label: STATUS_DA_NHAN,
              icon: Icons.assignment_ind,
              color: Colors.orange,
              isSelected: selectedStatus == STATUS_DA_NHAN,
              onTap: () => onStatusSelected(STATUS_DA_NHAN),
            ),
            FilterOption(
              label: STATUS_HOAN_THANH,
              icon: Icons.task_alt,
              color: Colors.green,
              isSelected: selectedStatus == STATUS_HOAN_THANH,
              onTap: () => onStatusSelected(STATUS_HOAN_THANH),
            ),
          ],
        ),
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
        if (selectedStatus != 'Tất Cả')
          ActiveFilter(
            label: selectedStatus,
            color:
                selectedStatus == STATUS_CHUA_NHAN
                    ? Colors.blue
                    : selectedStatus == STATUS_DA_NHAN
                    ? Colors.orange
                    : selectedStatus == STATUS_HOAN_THANH
                    ? Colors.green
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
