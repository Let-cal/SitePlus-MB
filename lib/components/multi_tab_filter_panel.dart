import 'package:flutter/material.dart';

class FilterOption {
  final dynamic id;
  final String label;

  FilterOption({required this.id, required this.label});
}

class FilterGroup {
  final String key;
  final String? title;
  final List<FilterOption> options;

  FilterGroup({required this.key, this.title, required this.options});
}

class MultiTabFilterPanel extends StatefulWidget {
  final List<FilterGroup> groups;
  final Function(Map<String, dynamic>) onFilterChanged;
  final Map<String, dynamic>? initialSelections;

  const MultiTabFilterPanel({
    super.key,
    required this.groups,
    required this.onFilterChanged,
    this.initialSelections,
  });

  @override
  State<MultiTabFilterPanel> createState() => _MultiTabFilterPanelState();
}

class _MultiTabFilterPanelState extends State<MultiTabFilterPanel> {
  late Map<String, dynamic> selections;

  @override
  void initState() {
    super.initState();
    selections = Map.from(widget.initialSelections ?? {});
    for (var group in widget.groups) {
      selections.putIfAbsent(group.key, () => null);
    }
  }

  void _onOptionSelected(String groupKey, dynamic optionId) {
    setState(() {
      selections[groupKey] = optionId;
    });
    widget.onFilterChanged(selections);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          widget.groups.map((group) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (group.title != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        group.title!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary,
                        border: Border.all(
                          color: colorScheme.onSurface.withOpacity(0.2),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children:
                            group.options.map((option) {
                              final isSelected =
                                  selections[group.key] == option.id;
                              return GestureDetector(
                                onTap:
                                    () =>
                                        _onOptionSelected(group.key, option.id),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? colorScheme.primary
                                            : Colors.transparent,
                                    border:
                                        isSelected
                                            ? Border.all(
                                              color: colorScheme.primary,
                                              width: 1,
                                            )
                                            : Border.all(
                                              color: Colors.transparent,
                                            ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow:
                                        isSelected
                                            ? [
                                              BoxShadow(
                                                color: colorScheme.primary
                                                    .withOpacity(0.2),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                            : [],
                                  ),
                                  child: Text(
                                    option.label,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                      color:
                                          isSelected
                                              ? colorScheme.onPrimary
                                              : colorScheme.onSurface
                                                  .withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
