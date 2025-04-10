import 'package:flutter/material.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_category.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_status.dart';

class FilterTabPanel extends StatefulWidget {
  final List<SiteCategory> categories;
  final List<int> statuses;
  final Function(int? categoryId, int? status) onFilterChanged;
  final int? initialSelectedCategoryId;
  final int? initialSelectedStatus;

  const FilterTabPanel({
    super.key,
    required this.categories,
    required this.statuses,
    required this.onFilterChanged,
    this.initialSelectedCategoryId,
    this.initialSelectedStatus,
  });

  @override
  State<FilterTabPanel> createState() => _FilterTabPanelState();
}

class _FilterTabPanelState extends State<FilterTabPanel> {
  int? selectedCategoryId;
  int? selectedStatus;

  @override
  void initState() {
    super.initState();
    // Mặc định chọn "Tất cả" (id = 0 cho category, null cho status)
    selectedCategoryId = widget.initialSelectedCategoryId ?? 0;
    selectedStatus = widget.initialSelectedStatus;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab cho loại mặt bằng
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.onPrimary, // Nền tối cho toàn bộ thanh
              border: Border.all(
                color: colorScheme.onSurface.withOpacity(0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(
                4,
              ), // Bo góc nhẹ cho toàn bộ thanh
            ),
            child: Row(
              children:
                  widget.categories.map((cat) {
                    final isSelected = cat.id == selectedCategoryId;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategoryId = cat.id;
                          widget.onFilterChanged(
                            selectedCategoryId,
                            selectedStatus,
                          );
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          border:
                              isSelected
                                  ? Border.all(
                                    color: colorScheme.primary,
                                    width: 1,
                                  ) // Viền màu primary khi active
                                  : Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(
                            4,
                          ), // Bo góc nhẹ cho từng tab
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: colorScheme.primary.withOpacity(
                                        0.2,
                                      ), // Bóng nhẹ với màu primary
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : [],
                        ),
                        child: Text(
                          cat.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                            color:
                                isSelected
                                    ? colorScheme
                                        .primary // Màu chữ primary khi active
                                    : colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Tab cho trạng thái
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.onPrimary,
              border: Border.all(
                color: colorScheme.onSurface.withOpacity(0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(
                4,
              ), // Bo góc nhẹ cho toàn bộ thanh
            ),
            child: Row(
              children:
                  widget.statuses.map((status) {
                    final isSelected = status == selectedStatus;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedStatus = status;
                          widget.onFilterChanged(
                            selectedCategoryId,
                            selectedStatus,
                          );
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          border:
                              isSelected
                                  ? Border.all(
                                    color: colorScheme.primary,
                                    width: 1,
                                  ) // Viền màu primary khi active
                                  : Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(
                            4,
                          ), // Bo góc nhẹ cho từng tab
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: colorScheme.primary.withOpacity(
                                        0.2,
                                      ), // Bóng nhẹ với màu primary
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : [],
                        ),
                        child: Text(
                          getStatusText(status),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                            color:
                                isSelected
                                    ? colorScheme
                                        .primary // Màu chữ primary khi active
                                    : colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
