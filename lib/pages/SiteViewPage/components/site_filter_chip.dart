import 'package:flutter/material.dart';
import 'package:siteplus_mb/components/filter_chip.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_category.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_status.dart';

/// Mở rộng FilterChipPanel để hỗ trợ filter động
class SiteFilterChipPanel extends StatefulWidget {
  final List<SiteCategory> categories;
  final List<int> statuses;
  final Function(int? categoryId, int? status) onFilterChanged;
  final int? initialSelectedCategoryId;
  final int? initialSelectedStatus;

  const SiteFilterChipPanel({
    super.key,
    required this.categories,
    required this.statuses,
    required this.onFilterChanged,
    this.initialSelectedCategoryId,
    this.initialSelectedStatus,
  });

  @override
  State<SiteFilterChipPanel> createState() => _SiteFilterChipPanelState();
}

class _SiteFilterChipPanelState extends State<SiteFilterChipPanel> {
  late List<FilterSection> _filterSections;
  final List<ActiveFilter> _activeFilters = [];
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeFilterSections(); // Move it here
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
            icon: getSiteCategoryIcon(category.id),
            color: getCategoryColor(category.id),
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
        label: getStatusText(8),
        icon: getStatusIcon(8),
        color: getStatusColor(context, 8),
        isSelected: 8 == widget.initialSelectedStatus,
        onTap: () => _handleStatusSelection(8),
      ),
      FilterOption(
        label: getStatusText(1),
        color: getStatusColor(context, 1),
        icon: getStatusIcon(1),
        isSelected: 1 == widget.initialSelectedStatus,
        onTap: () => _handleStatusSelection(1),
      ),
      FilterOption(
        label: getStatusText(2),
        color: getStatusColor(context, 2),
        icon: getStatusIcon(2),
        isSelected: 2 == widget.initialSelectedStatus,
        onTap: () => _handleStatusSelection(2),
      ),
      FilterOption(
        label: getStatusText(7),
        icon: getStatusIcon(7),
        color: getStatusColor(context, 7),
        isSelected: 7 == widget.initialSelectedStatus,
        onTap: () => _handleStatusSelection(7),
      ),
      FilterOption(
        label: getStatusText(3),
        color: getStatusColor(context, 3),
        icon: getStatusIcon(3),
        isSelected: 3 == widget.initialSelectedStatus,
        onTap: () => _handleStatusSelection(3),
      ),
      FilterOption(
        label: getStatusText(4),
        color: getStatusColor(context, 4),
        icon: getStatusIcon(4),
        isSelected: 4 == widget.initialSelectedStatus,
        onTap: () => _handleStatusSelection(4),
      ),
      FilterOption(
        label: getStatusText(6),
        icon: getStatusIcon(6),
        color: getStatusColor(context, 6),
        isSelected: 6 == widget.initialSelectedStatus,
        onTap: () => _handleStatusSelection(6),
      ),
      FilterOption(
        label: getStatusText(5),
        color: getStatusColor(context, 5),
        icon: getStatusIcon(5),
        isSelected: 5 == widget.initialSelectedStatus,
        onTap: () => _handleStatusSelection(5),
      ),
      FilterOption(
        label: getStatusText(9),
        color: getStatusColor(context, 9),
        icon: getStatusIcon(9),
        isSelected: 9 == widget.initialSelectedStatus,
        onTap: () => _handleStatusSelection(9),
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
            option.isSelected = option.label == getStatusText(status);
          }
        }
      }
      _updateActiveFilters();
    });
    widget.onFilterChanged(_getCurrentCategory(), status);
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
          case 'Đã kết nối':
            return 6;
          case 'Đang thương lượng':
            return 7;
          case 'Đã hoàn thành':
            return 8;
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
