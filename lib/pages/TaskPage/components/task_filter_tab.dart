import 'package:flutter/material.dart';
import 'package:siteplus_mb/components/multi_tab_filter_panel.dart';
import 'package:siteplus_mb/utils/constants.dart';

class TaskFilterTab extends StatelessWidget {
  final Map<int, String> availableStatuses;
  final int? selectedStatusId;
  final int? selectedPriorityId;
  final Function(Map<String, dynamic>) onFilterChanged;

  const TaskFilterTab({
    super.key,
    required this.availableStatuses,
    required this.selectedStatusId,
    required this.selectedPriorityId,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MultiTabFilterPanel(
      groups: [
        FilterGroup(
          key: 'status',
          options: [
            FilterOption(id: null, label: 'Tất Cả'),
            ...availableStatuses.entries.map(
              (e) => FilterOption(id: e.key, label: e.value),
            ),
          ],
        ),
        FilterGroup(
          key: 'priority',
          options: [
            FilterOption(id: null, label: 'Tất Cả'),
            ...PRIORITY_API_MAP.entries.map(
              (e) => FilterOption(id: e.value, label: e.key),
            ),
          ],
        ),
      ],
      onFilterChanged: onFilterChanged,
      initialSelections: {
        'status': selectedStatusId,
        'priority': selectedPriorityId,
      },
    );
  }
}
