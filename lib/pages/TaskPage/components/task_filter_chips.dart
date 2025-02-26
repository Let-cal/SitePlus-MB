import 'package:flutter/material.dart';
import 'package:siteplus_mb/utils/constants.dart';

class TaskFilterChips extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusSelected;
  final String selectedPriority;
  final Function(String) onPrioritySelected;

  const TaskFilterChips({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
    required this.selectedPriority,
    required this.onPrioritySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status filter
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Lọc Theo Trạng Thái',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context: context,
                  label: STATUS_CHUA_NHAN,
                  isSelected: selectedStatus == STATUS_CHUA_NHAN,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context: context,
                  label: STATUS_DA_NHAN,
                  isSelected: selectedStatus == STATUS_DA_NHAN,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context: context,
                  label: STATUS_HOAN_THANH,
                  isSelected: selectedStatus == STATUS_HOAN_THANH,
                  color: Colors.green,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Priority filter
          Row(
            children: [
              Icon(
                Icons.priority_high,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Lọc Theo Độ Ưu Tiên',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPriorityDropdown(context),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        color:
            isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: color,
      checkmarkColor: theme.colorScheme.onPrimary,
      elevation: 0,
      pressElevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? color : theme.dividerColor),
      ),
      onSelected: (bool selected) {
        onStatusSelected(label);
      },
    );
  }

  Widget _buildPriorityDropdown(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPriority,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          style: theme.textTheme.bodyLarge,
          onChanged: (String? newValue) {
            if (newValue != null) {
              onPrioritySelected(newValue);
            }
          },
          items: [
            const DropdownMenuItem<String>(
              value: 'Tất Cả',
              child: Text('Tất Cả'),
            ),
            DropdownMenuItem<String>(
              value: PRIORITY_CAO,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(PRIORITY_CAO),
                ],
              ),
            ),
            DropdownMenuItem<String>(
              value: PRIORITY_TRUNG_BINH,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(PRIORITY_TRUNG_BINH),
                ],
              ),
            ),
            DropdownMenuItem<String>(
              value: PRIORITY_THAP,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(PRIORITY_THAP),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
