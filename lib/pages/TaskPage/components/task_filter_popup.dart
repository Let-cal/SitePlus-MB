import 'package:flutter/material.dart';
import 'package:siteplus_mb/pages/TaskPage/components/task_filter_chips.dart';

class TaskFilterPopup extends StatefulWidget {
  final List<Map<String, dynamic>> allTaskOptions;
  final String initialStatus;
  final String initialPriority;
  final int? initialTaskId;
  final Function(String, String, int?) onApply;

  const TaskFilterPopup({
    super.key,
    required this.allTaskOptions,
    required this.initialStatus,
    required this.initialPriority,
    required this.initialTaskId,
    required this.onApply,
  });

  @override
  State<TaskFilterPopup> createState() => _TaskFilterPopupState();
}

class _TaskFilterPopupState extends State<TaskFilterPopup> {
  final _filterKey = GlobalKey<TaskFilterChipPanelState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TaskFilterChipPanel(
            key: _filterKey,
            allTaskOptions: widget.allTaskOptions,
            initialStatus: widget.initialStatus,
            initialPriority: widget.initialPriority,
            initialTaskId: widget.initialTaskId,
            onApply: widget.onApply,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _filterKey.currentState?.resetSelections();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Reset',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final currentState = _filterKey.currentState;
                  if (currentState != null) {
                    final (status, priority, taskId) =
                        currentState.getCurrentSelections();
                    widget.onApply(status, priority, taskId);
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
