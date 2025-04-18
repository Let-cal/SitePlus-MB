import 'package:flutter/material.dart';
import 'package:siteplus_mb/components/custom_dropdown_field.dart';
import 'package:siteplus_mb/components/filter_chip.dart';
import 'package:siteplus_mb/utils/TaskPage/task_status.dart';
import 'package:siteplus_mb/utils/constants.dart';

class TaskFilterChipPanel extends StatefulWidget {
  final List<Map<String, dynamic>> allTaskOptions;
  final String initialStatus;
  final String initialPriority;
  final int? initialTaskId;
  final Function(String, String, int?) onApply;

  const TaskFilterChipPanel({
    super.key,
    required this.allTaskOptions,
    required this.initialStatus,
    required this.initialPriority,
    required this.initialTaskId,
    required this.onApply,
  });

  @override
  State<TaskFilterChipPanel> createState() => TaskFilterChipPanelState();
}

class TaskFilterChipPanelState extends State<TaskFilterChipPanel> {
  late String _selectedStatus;
  late String _selectedPriority;
  late int? _selectedTaskId;
  final List<ActiveFilter> _activeFilters = [];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _selectedPriority = widget.initialPriority;
    _selectedTaskId = widget.initialTaskId;
    _updateActiveFilters();
  }

  (String, String, int?) getCurrentSelections() {
    return (_selectedStatus, _selectedPriority, _selectedTaskId);
  }

  void _updateActiveFilters() {
    _activeFilters.clear();
    if (_selectedStatus != 'Tất Cả') {
      _activeFilters.add(
        ActiveFilter(
          label: _selectedStatus,
          color: getStatusColor(context, _selectedStatus),
          onRemove: () {
            setState(() {
              _selectedStatus = 'Tất Cả';
              _updateActiveFilters();
            });
            widget.onApply(_selectedStatus, _selectedPriority, _selectedTaskId);
          },
        ),
      );
    }
    if (_selectedPriority != 'Tất Cả') {
      _activeFilters.add(
        ActiveFilter(
          label: _selectedPriority,
          color: getStatusPriorityColor(context, _selectedPriority),
          onRemove: () {
            setState(() {
              _selectedPriority = 'Tất Cả';
              _updateActiveFilters();
            });
            widget.onApply(_selectedStatus, _selectedPriority, _selectedTaskId);
          },
        ),
      );
    }
    if (_selectedTaskId != null) {
      final task = widget.allTaskOptions.firstWhere(
        (t) => t['id'] == _selectedTaskId,
        orElse:
            () => <String, Object>{
              'id': _selectedTaskId!,
              'areaName': 'Unknown',
            },
      );
      _activeFilters.add(
        ActiveFilter(
          label: 'Task ID: ${task['id']}',
          color: Colors.blue,
          onRemove: () {
            setState(() {
              _selectedTaskId = null;
              _updateActiveFilters();
            });
            widget.onApply(_selectedStatus, _selectedPriority, _selectedTaskId);
          },
        ),
      );
    }
  }

  void resetSelections() {
    setState(() {
      _selectedStatus = 'Tất Cả';
      _selectedPriority = 'Tất Cả';
      _selectedTaskId = null;
      _updateActiveFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<FilterSection> sections = [
      FilterSection(title: 'Task ID', isChipStyle: false, options: []),
      FilterSection(
        title: 'Status',
        isChipStyle: true,
        options: [
          FilterOption(
            label: 'Tất Cả',
            icon: Icons.all_inclusive,
            color: Colors.grey,
            isSelected: _selectedStatus == 'Tất Cả',
            onTap: () {
              setState(() {
                _selectedStatus = 'Tất Cả';
                _updateActiveFilters();
              });
            },
          ),
          FilterOption(
            label: STATUS_CHUA_NHAN,
            icon: Icons.pending_actions,
            color: Colors.blue,
            isSelected: _selectedStatus == STATUS_CHUA_NHAN,
            onTap: () {
              setState(() {
                _selectedStatus = STATUS_CHUA_NHAN;
                _updateActiveFilters();
              });
            },
          ),
          FilterOption(
            label: STATUS_DA_NHAN,
            icon: Icons.assignment_ind,
            color: Colors.orange,
            isSelected: _selectedStatus == STATUS_DA_NHAN,
            onTap: () {
              setState(() {
                _selectedStatus = STATUS_DA_NHAN;
                _updateActiveFilters();
              });
            },
          ),
          FilterOption(
            label: STATUS_CHO_PHE_DUYET,
            icon: Icons.access_time,
            color: Colors.teal,
            isSelected: _selectedStatus == STATUS_CHO_PHE_DUYET,
            onTap: () {
              setState(() {
                _selectedStatus = STATUS_CHO_PHE_DUYET;
                _updateActiveFilters();
              });
            },
          ),
          FilterOption(
            label: STATUS_HOAN_THANH,
            icon: Icons.task_alt,
            color: Colors.green,
            isSelected: _selectedStatus == STATUS_HOAN_THANH,
            onTap: () {
              setState(() {
                _selectedStatus = STATUS_HOAN_THANH;
                _updateActiveFilters();
              });
            },
          ),
        ],
      ),
      FilterSection(
        title: 'Priority',
        isChipStyle: true,
        options: [
          FilterOption(
            label: 'Tất Cả',
            icon: Icons.all_inclusive,
            color: Colors.grey,
            isSelected: _selectedPriority == 'Tất Cả',
            onTap: () {
              setState(() {
                _selectedPriority = 'Tất Cả';
                _updateActiveFilters();
              });
            },
          ),
          FilterOption(
            label: PRIORITY_CAO,
            color: Colors.red,
            isSelected: _selectedPriority == PRIORITY_CAO,
            onTap: () {
              setState(() {
                _selectedPriority = PRIORITY_CAO;
                _updateActiveFilters();
              });
            },
          ),
          FilterOption(
            label: PRIORITY_TRUNG_BINH,
            color: Colors.orange,
            isSelected: _selectedPriority == PRIORITY_TRUNG_BINH,
            onTap: () {
              setState(() {
                _selectedPriority = PRIORITY_TRUNG_BINH;
                _updateActiveFilters();
              });
            },
          ),
          FilterOption(
            label: PRIORITY_THAP,
            color: Colors.green,
            isSelected: _selectedPriority == PRIORITY_THAP,
            onTap: () {
              setState(() {
                _selectedPriority = PRIORITY_THAP;
                _updateActiveFilters();
              });
            },
          ),
        ],
      ),
    ];

    return FilterChipPanel(
      headerTitle: 'Filter Tasks',
      sections: sections,
      activeFilters: _activeFilters,
      sectionContentBuilder: (section) {
        if (section.title == 'Task ID') {
          return CustomDropdownField<int>(
            value: _selectedTaskId,
            items:
                widget.allTaskOptions.map((task) => task['id'] as int).toList(),
            labelText: 'Select Task ID',
            hintText: 'Tap to select a task',
            prefixIcon: Icons.task,
            theme: Theme.of(context),
            onChanged: (value) {
              setState(() {
                _selectedTaskId = value;
                _updateActiveFilters();
              });
            },
            itemBuilder: (int taskId) {
              final task = widget.allTaskOptions.firstWhere(
                (t) => t['id'] == taskId,
                orElse:
                    () => <String, Object>{'id': taskId, 'areaName': 'Unknown'},
              );
              return Row(
                children: [
                  Icon(
                    Icons.task,
                    size: 20,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Task ID: ${task['id']} - ${task['areaName']}'),
                  ),
                ],
              );
            },
            selectedItemBuilder: (int taskId) {
              final task = widget.allTaskOptions.firstWhere(
                (t) => t['id'] == taskId,
                orElse:
                    () => <String, Object>{'id': taskId, 'areaName': 'Unknown'},
              );
              return Text('Task ID: ${task['id']} - ${task['areaName']}');
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
