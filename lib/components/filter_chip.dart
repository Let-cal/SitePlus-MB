import 'package:flutter/material.dart';

class FilterChipPanel extends StatefulWidget {
  final String headerTitle;
  final List<FilterSection> sections;
  final List<ActiveFilter>? activeFilters;
  final bool showDecoration;
  final Widget Function(FilterSection)?
  sectionContentBuilder; // Callback for custom content

  const FilterChipPanel({
    super.key,
    this.headerTitle = 'Filter',
    required this.sections,
    this.activeFilters,
    this.showDecoration = true,
    this.sectionContentBuilder,
  });

  @override
  State<FilterChipPanel> createState() => _FilterChipPanelState();
}

class _FilterChipPanelState extends State<FilterChipPanel>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    if (_isExpanded) _animationController.forward();
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
      decoration:
          widget.showDecoration
              ? BoxDecoration(
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
              )
              : BoxDecoration(color: colorScheme.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                                children:
                                    section.options.map((option) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                        child: _buildFilterChip(option, theme),
                                      );
                                    }).toList(),
                              ),
                            )
                            : widget.sectionContentBuilder != null
                            ? widget.sectionContentBuilder!(
                              section,
                            ) // Use callback
                            : Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.dividerColor.withOpacity(0.5),
                                ),
                              ),
                              child: Column(
                                children:
                                    section.options.map((option) {
                                      if (option.isSwitch) {
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
                                                horizontal: 16,
                                                vertical: 4,
                                              ),
                                        );
                                      } else {
                                        return Column(
                                          children: [
                                            InkWell(
                                              onTap: option.onTap,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12,
                                                    ),
                                                color:
                                                    option.isSelected
                                                        ? option.color
                                                            .withOpacity(0.1)
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
                                                      style: theme
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            fontWeight:
                                                                option.isSelected
                                                                    ? FontWeight
                                                                        .w600
                                                                    : FontWeight
                                                                        .normal,
                                                            color:
                                                                option.isSelected
                                                                    ? option
                                                                        .color
                                                                    : theme
                                                                        .colorScheme
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
          if (widget.activeFilters != null && widget.activeFilters!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    widget.activeFilters!.map((activeFilter) {
                      return _buildActiveFilterChip(activeFilter, theme);
                    }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(FilterOption option, ThemeData theme) {
    return FilterChip(
      label: Text(option.label),
      selected: option.isSelected,
      onSelected: (bool selected) {
        setState(() {
          option.isSelected = selected;
        });
        option.onTap();
      },
      avatar:
          option.icon != null
              ? Icon(
                option.icon,
                size: 18,
                color:
                    option.isSelected
                        ? option.color
                        : theme.colorScheme.onSurface,
              )
              : null,
      selectedColor: option.color.withOpacity(0.1),
      checkmarkColor: option.color,
      labelStyle: TextStyle(
        color: option.isSelected ? option.color : theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildActiveFilterChip(ActiveFilter activeFilter, ThemeData theme) {
    return Chip(
      label: Text(activeFilter.label),
      backgroundColor: activeFilter.color.withOpacity(0.1),
      labelStyle: TextStyle(color: activeFilter.color),
      deleteIcon: Icon(Icons.close, size: 18, color: activeFilter.color),
      onDeleted: activeFilter.onRemove,
    );
  }
}

class FilterSection {
  final String title;
  final bool isChipStyle;
  final List<FilterOption> options;

  FilterSection({
    required this.title,
    this.isChipStyle = true,
    required this.options,
  });
}

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
    this.isSelected = false,
    required this.onTap,
    this.isSwitch = false,
  });
}

class ActiveFilter {
  final String label;
  final Color color;
  final VoidCallback onRemove;

  ActiveFilter({
    required this.label,
    required this.color,
    required this.onRemove,
  });
}
