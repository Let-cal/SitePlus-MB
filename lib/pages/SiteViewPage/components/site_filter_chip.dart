import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/components/filter_chip.dart';
import 'package:siteplus_mb/utils/Site/site_model.dart';

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
  void initState() {
    super.initState();
    _initializeFilterSections();
  }

  void _initializeFilterSections() {
    // Prepare category filter options
    final categoryOptions = widget.categories.map((category) {
      return FilterOption(
        label: category.name,
        color: _getCategoryColor(category.id),
        isSelected: category.id == widget.initialSelectedCategoryId,
        onTap: () => _handleCategorySelection(category.id),
      );
    }).toList();

    // Prepare status filter options
    final statusOptions = [
      FilterOption(
        label: 'Đã chấp nhận',
        color: Colors.green,
        isSelected: 1 == widget.initialSelectedStatus,
        onTap: () => _handleStatusSelection(1),
      ),
      FilterOption(
        label: 'Bị từ chối',
        color: Colors.red,
        isSelected: 2 == widget.initialSelectedStatus,
        onTap: () => _handleStatusSelection(2),
      ),
      FilterOption(
        label: 'Đã bán',
        color: Colors.blue,
        isSelected: 3 == widget.initialSelectedStatus,
        onTap: () => _handleStatusSelection(3),
      ),
      FilterOption(
        label: 'Đang tiến hành',
        color: Colors.orange,
        isSelected: 4 == widget.initialSelectedStatus,
        onTap: () => _handleStatusSelection(4),
      ),
    ];

    _filterSections = [
      FilterSection(
        title: 'Loại mặt bằng',
        options: categoryOptions,
      ),
      FilterSection(
        title: 'Trạng thái',
        options: statusOptions,
      ),
    ];

    // Initialize active filters if any
    _updateActiveFilters();
  }

  Color _getCategoryColor(int categoryId) {
    switch (categoryId) {
      case 1: return Colors.green.shade300;
      case 2: return Colors.blue.shade300;
      case 3: return Colors.purple.shade300;
      default: return Colors.grey;
    }
  }

  void _handleCategorySelection(int categoryId) {
    setState(() {
      for (var section in _filterSections) {
        if (section.title == 'Loại mặt bằng') {
          for (var option in section.options) {
            option.isSelected = option.label == widget.categories.firstWhere((cat) => cat?.id == categoryId).name;
          }
        }
      }
      _updateActiveFilters();
    });
    widget.onFilterChanged(
      categoryId,
      _getCurrentStatus(),
    );
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
    widget.onFilterChanged(
      _getCurrentCategory(),
      status,
    );
  }

  String _getStatusLabel(int status) {
    switch (status) {
      case 1: return 'Đã chấp nhận';
      case 2: return 'Bị từ chối';
      case 3: return 'Đã bán';
      case 4: return 'Đang tiến hành';
      default: return 'Không xác định';
    }
  }

  int? _getCurrentCategory() {
    for (var section in _filterSections) {
      if (section.title == 'Loại mặt bằng') {
        final selectedOption = section.options.firstWhere(
          (option) => option.isSelected,
          orElse: () => section.options.first,
        );
        return widget.categories.firstWhere(
          (cat) => cat.name == selectedOption.label,
        ).id;
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
          case 'Đã chấp nhận': return 1;
          case 'Bị từ chối': return 2;
          case 'Đã bán': return 3;
          case 'Đang tiến hành': return 4;
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