import 'package:flutter/material.dart';

/// Model cho từng option của bộ lọc
class FilterOption {
  final String label;
  final IconData? icon;
  final Color color;
  bool isSelected;
  final VoidCallback onTap;
  final bool isSwitch;

  FilterOption({
    required this.label,
    this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.isSwitch = false, // Mặc định là false (không phải switch)
  });
}

/// Model cho từng section của bộ lọc (ví dụ: Trạng thái, Mức độ ưu tiên)
class FilterSection {
  final String title;

  /// Nếu true sẽ render theo dạng chip (cuộn ngang)
  /// Nếu false thì render theo dạng list style (vertical)
  final bool isChipStyle;
  final List<FilterOption> options;

  const FilterSection({
    required this.title,
    this.isChipStyle = true,
    required this.options,
  });
}

/// Model cho bộ lọc đang được active (đã chọn) hiển thị bên dưới
class ActiveFilter {
  final String label;
  final Color color;
  final VoidCallback onRemove;

  const ActiveFilter({
    required this.label,
    required this.color,
    required this.onRemove,
  });
}

/// Component FilterChipPanel: hiển thị header, danh sách các section filter (mỗi section có nhiều options)
/// và hiển thị danh sách active filters (nếu có)
class FilterChipPanel extends StatefulWidget {
  final String headerTitle;
  final List<FilterSection> sections;
  final List<ActiveFilter>? activeFilters;

  const FilterChipPanel({
    super.key,
    this.headerTitle = 'Bộ Lọc',
    required this.sections,
    this.activeFilters,
  });

  @override
  State<FilterChipPanel> createState() => _FilterChipPanelState();
}

class _FilterChipPanelState extends State<FilterChipPanel>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;

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
          // Header với icon filter và nút mở/đóng
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
                    widget.headerTitle,
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
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              height: _isExpanded ? null : 0,
              clipBehavior: Clip.none,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  ...widget.sections.map((section) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10, left: 8),
                          child: Text(
                            section.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                        section.isChipStyle
                            ? SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: section.options.map((option) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: _buildFilterChip(option, theme),
                                    );
                                  }).toList(),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.dividerColor.withOpacity(0.5),
                                  ),
                                ),
                                child: Column(
                                  children: section.options.map((option) {
                                    if (option.isSwitch) {
                                      // Render switch cho FilterOption có isSwitch = true
                                      return ListTile(
                                        title: Text(
                                          option.label,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                        trailing: Switch(
                                          value: option.isSelected,
                                          activeColor: option.color,
                                          onChanged: (value) {
                                            setState(() {
                                              option.isSelected = value;
                                            });
                                            option.onTap();
                                          },
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 4),
                                      );
                                    } else {
                                      // Render list item thông thường
                                      return Column(
                                        children: [
                                          InkWell(
                                            onTap: option.onTap,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                              color: option.isSelected
                                                  ? option.color.withOpacity(0.1)
                                                  : Colors.transparent,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 12,
                                                    height: 12,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: option.color,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    option.label,
                                                    style: theme.textTheme
                                                        .bodyMedium?.copyWith(
                                                      fontWeight:
                                                          option.isSelected
                                                              ? FontWeight.w600
                                                              : FontWeight.normal,
                                                      color: option.isSelected
                                                          ? option.color
                                                          : theme.colorScheme
                                                              .onSurface,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  if (option.isSelected)
                                                    Icon(
                                                      Icons.check,
                                                      size: 18,
                                                      color: option.color,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: theme.dividerColor
                                                .withOpacity(0.3),
                                          ),
                                        ],
                                      );
                                    }
                                  }).toList(),
                                ),
                              ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          // Active filters (giữ nguyên)
          if (widget.activeFilters != null && widget.activeFilters!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.activeFilters!.map((activeFilter) {
                  return _buildActiveFilterChip(activeFilter, theme);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(FilterOption option, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      transform:
          option.isSelected
              ? (Matrix4.identity()..scale(1.01))
              : Matrix4.identity(),
      decoration: BoxDecoration(
        color:
            option.isSelected
                ? option.color.withOpacity(0.15)
                : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              option.isSelected
                  ? option.color
                  : theme.dividerColor.withOpacity(0.5),
          width: option.isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: option.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (option.icon != null)
                  Icon(
                    option.icon,
                    size: 16,
                    color:
                        option.isSelected
                            ? option.color
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                if (option.icon != null) const SizedBox(width: 6),
                Text(
                  option.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        option.isSelected
                            ? option.color
                            : theme.colorScheme.onSurface,
                    fontWeight:
                        option.isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip(ActiveFilter activeFilter, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: activeFilter.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: activeFilter.color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            activeFilter.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: activeFilter.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: activeFilter.onRemove,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.close, size: 14, color: activeFilter.color),
            ),
          ),
        ],
      ),
    );
  }
}
