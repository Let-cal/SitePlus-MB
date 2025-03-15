import 'package:flutter/material.dart';
import 'package:siteplus_mb/components/filter_chip.dart';
import 'package:siteplus_mb/utils/Site/site_category.dart';

/// Mở rộng FilterChipPanel để hỗ trợ filter động
class SiteFilterChipPanel extends StatefulWidget {
  final List<SiteCategory> categories;
  final List<int> statuses;
  final Function(int? categoryId, int? status) onFilterChanged;
  final int? initialSelectedCategoryId;
  final int? initialSelectedStatus;

  const SiteFilterChipPanel({
    Key? key,
    required this.categories,
    required this.statuses,
    required this.onFilterChanged,
    this.initialSelectedCategoryId,
    this.initialSelectedStatus,
  }) : super(key: key);

  @override
  State<SiteFilterChipPanel> createState() => _SiteFilterChipPanelState();
}

class _SiteFilterChipPanelState extends State<SiteFilterChipPanel> {
  late List<FilterSection> _filterSections;
  List<ActiveFilter> _activeFilters = [];
  @override
  void didUpdateWidget(SiteFilterChipPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categories != oldWidget.categories) {
      _initializeFilterSections();
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeFilterSections();
  }

  void _initializeFilterSections() {
    
    // Debug before initializing
    debugPrint(
      'Initializing filters with ${widget.categories.length} categories',
    );
    for (var cat in widget.categories) {
      debugPrint('Filter category: ${cat.id} - ${cat.name}');
    }

    // Prepare category filter options
    final categoryOptions =
        widget.categories.map((category) {
          bool isSelected = category.id == widget.initialSelectedCategoryId;
          debugPrint(
            'Creating option for ${category.name}, selected: $isSelected',
          );

          return FilterOption(
            label: category.name,
            color: _getCategoryColor(category.id),
            isSelected: isSelected,
            onTap: () {
              debugPrint('Selecting category: ${category.id}');
              _handleCategorySelection(category.id);
            },
          );
        }).toList();

    // Prepare status filter options với 5 trạng thái
    final statusOptions = [
      FilterOption(
        label: 'Có sẵn',
        color: Colors.green,
        isSelected: 1 == widget.initialSelectedStatus,
        onTap: () => _handleStatusSelection(1),
      ),
      FilterOption(
        label: 'Đang tiến hành',
        color: Colors.orange,
        isSelected: 2 == widget.initialSelectedStatus,
        onTap: () => _handleStatusSelection(2),
      ),
      FilterOption(
        label: 'Chờ phê duyệt',
        color: Colors.blue,
        isSelected: 3 == widget.initialSelectedStatus,
        onTap: () => _handleStatusSelection(3),
      ),
      FilterOption(
        label: 'Bị từ chối',
        color: Colors.red,
        isSelected: 4 == widget.initialSelectedStatus,
        onTap: () => _handleStatusSelection(4),
      ),
      FilterOption(
        label: 'Đã đóng',
        color: Colors.grey,
        isSelected: 5 == widget.initialSelectedStatus,
        onTap: () => _handleStatusSelection(5),
      ),
    ];

    _filterSections = [
      FilterSection(
        title: 'Loại mặt bằng',
        isChipStyle: true,
        options: categoryOptions,
      ),
      FilterSection(title: 'Trạng thái', options: statusOptions),
    ];

    // Initialize active filters if any
    _updateActiveFilters();
  }

  Color _getCategoryColor(int categoryId) {
    switch (categoryId) {
      case 1:
        return Colors.green.shade300;
      case 2:
        return Colors.blue.shade300;
      case 3:
        return Colors.purple.shade300;
      default:
        return Colors.grey;
    }
  }

  void _handleCategorySelection(int categoryId) {
    debugPrint('Handling category selection: $categoryId');

    setState(() {
      for (var section in _filterSections) {
        if (section.title == 'Loại mặt bằng') {
          for (var option in section.options) {
            // Find category by ID
            final selectedCategoryName =
                widget.categories
                    .firstWhere(
                      (cat) => cat.id == categoryId,
                      orElse: () => widget.categories.first,
                    )
                    .name;

            option.isSelected = option.label == selectedCategoryName;
            debugPrint('Option ${option.label} selected: ${option.isSelected}');
          }
        }
      }
      _updateActiveFilters();
    });

    widget.onFilterChanged(categoryId, _getCurrentStatus());
  }

  void _handleStatusSelection(int status) {
    setState(() {
      for (var section in _filterSections) {
        if (section.title == 'Trạng thái') {
          for (var option in section.options) {
            option.isSelected = option.label == _getStatusLabel(status);
          }
        }
      }
      _updateActiveFilters();
    });
    widget.onFilterChanged(_getCurrentCategory(), status);
  }

  String _getStatusLabel(int status) {
    switch (status) {
      case 1:
        return 'Có sẵn';
      case 2:
        return 'Đang tiến hành';
      case 3:
        return 'Chờ phê duyệt';
      case 4:
        return 'Bị từ chối';
      case 5:
        return 'Đã đóng';
      default:
        return 'Không xác định';
    }
  }

  int? _getCurrentCategory() {
    for (var section in _filterSections) {
      if (section.title == 'Loại mặt bằng') {
        final selectedOption = section.options.firstWhere(
          (option) => option.isSelected,
          orElse: () => section.options.first,
        );

        // Find matching category, with fallback
        final matchingCategory = widget.categories.firstWhere(
          (cat) => cat.name == selectedOption.label,
          orElse: () => widget.categories.first,
        );

        return matchingCategory.id;
      }
    }
    return null;
  }

  int? _getCurrentStatus() {
    for (var section in _filterSections) {
      if (section.title == 'Trạng thái') {
        final selectedOption = section.options.firstWhere(
          (option) => option.isSelected,
          orElse: () => section.options.first,
        );
        switch (selectedOption.label) {
          case 'Có sẵn':
            return 1;
          case 'Đang tiến hành':
            return 2;
          case 'Chờ phê duyệt':
            return 3;
          case 'Bị từ chối':
            return 4;
          case 'Đã đóng':
            return 5;
        }
      }
    }
    return null;
  }

  void _updateActiveFilters() {
    _activeFilters.clear();

    for (var section in _filterSections) {
      for (var option in section.options) {
        if (option.isSelected) {
          _activeFilters.add(
            ActiveFilter(
              label: option.label,
              color: option.color,
              onRemove: () {
                setState(() {
                  option.isSelected = false;
                  _updateActiveFilters();
                });
                widget.onFilterChanged(null, null);
              },
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilterChipPanel(
      headerTitle: 'Bộ lọc mặt bằng',
      sections: _filterSections,
      activeFilters: _activeFilters,
    );
  }
}
