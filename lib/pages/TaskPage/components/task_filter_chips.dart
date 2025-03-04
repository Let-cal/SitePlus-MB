import 'package:flutter/material.dart';
import 'package:siteplus_mb/utils/constants.dart';

class TaskFilterChips extends StatefulWidget {
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
  State<TaskFilterChips> createState() => _TaskFilterChipsState();
}

class _TaskFilterChipsState extends State<TaskFilterChips>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with filter icon and expand/collapse button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.filter_alt_rounded,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Bộ Lọc',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: _toggleExpanded,
                icon: AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                splashRadius: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          // Animated expandable content
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              height: _isExpanded ? null : 0,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Status label
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, left: 8),
                    child: Text(
                      'Trạng thái',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),

                  // Status chips
                  SingleChildScrollView(
                    scrollDirection:
                        Axis.horizontal, // Cuộn ngang nếu không đủ chỗ
                    child: Row(
                      children: [
                        _buildFilterChip(
                          context: context,
                          label: STATUS_CHUA_NHAN,
                          isSelected: widget.selectedStatus == STATUS_CHUA_NHAN,
                          color: Colors.blue,
                          icon: Icons.pending_actions,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context: context,
                          label: STATUS_DA_NHAN,
                          isSelected: widget.selectedStatus == STATUS_DA_NHAN,
                          color: Colors.orange,
                          icon: Icons.assignment_ind,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context: context,
                          label: STATUS_HOAN_THANH,
                          isSelected:
                              widget.selectedStatus == STATUS_HOAN_THANH,
                          color: Colors.green,
                          icon: Icons.task_alt,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Priority label
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Mức độ ưu tiên',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),

                  // Priority selector
                  _buildPrioritySelector(context),
                ],
              ),
            ),
          ),

          // Active filters display (always visible)
          if (widget.selectedStatus != 'Tất Cả' ||
              widget.selectedPriority != 'Tất Cả')
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (widget.selectedStatus != 'Tất Cả')
                    _buildActiveFilterChip(
                      context: context,
                      label: widget.selectedStatus,
                      onRemove: () => widget.onStatusSelected('Tất Cả'),
                      color: _getStatusColor(widget.selectedStatus),
                    ),
                  if (widget.selectedPriority != 'Tất Cả')
                    _buildActiveFilterChip(
                      context: context,
                      label: widget.selectedPriority,
                      onRemove: () => widget.onPrioritySelected('Tất Cả'),
                      color: _getPriorityColor(widget.selectedPriority),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case STATUS_CHUA_NHAN:
        return Colors.blue;
      case STATUS_DA_NHAN:
        return Colors.orange;
      case STATUS_HOAN_THANH:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case PRIORITY_CAO:
        return Colors.red;
      case PRIORITY_TRUNG_BINH:
        return Colors.orange;
      case PRIORITY_THAP:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      transform:
          isSelected ? (Matrix4.identity()..scale(1.01)) : Matrix4.identity(),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.15) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onStatusSelected(label),
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 50,
            ), // Giới hạn độ nhỏ nhất
            child: Ink(
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? color.withOpacity(0.15)
                        : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected ? color : theme.dividerColor.withOpacity(0.5),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ), // Giảm padding ngang
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color:
                        isSelected
                            ? color
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(
                    width: 6,
                  ), // Giảm khoảng cách giữa icon và text
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected ? color : theme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip({
    required BuildContext context,
    required String label,
    required VoidCallback onRemove,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.close, size: 14, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySelector(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _buildPriorityOption(
            context: context,
            value: 'Tất Cả',
            label: 'Tất Cả',
            color: Colors.grey,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: theme.dividerColor.withOpacity(0.3),
          ),
          _buildPriorityOption(
            context: context,
            value: PRIORITY_CAO,
            label: PRIORITY_CAO,
            color: Colors.red,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: theme.dividerColor.withOpacity(0.3),
          ),
          _buildPriorityOption(
            context: context,
            value: PRIORITY_TRUNG_BINH,
            label: PRIORITY_TRUNG_BINH,
            color: Colors.orange,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: theme.dividerColor.withOpacity(0.3),
          ),
          _buildPriorityOption(
            context: context,
            value: PRIORITY_THAP,
            label: PRIORITY_THAP,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityOption({
    required BuildContext context,
    required String value,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isSelected = widget.selectedPriority == value;

    return InkWell(
      onTap: () => widget.onPrioritySelected(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            if (isSelected) Icon(Icons.check, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}
