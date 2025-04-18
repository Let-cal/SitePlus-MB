import 'package:flutter/material.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/site_filter_chip.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_category.dart';

class SiteFilterPopup extends StatefulWidget {
  final int? initialCategoryId;
  final int? initialStatus;
  final int? initialSiteId; // Thêm tham số cho Site ID
  final List<SiteCategory> categories;
  final List<int> statuses;
  final Function(int? categoryId, int? status, int? siteId)
  onApply; // Cập nhật callback
  final Map<int, String> areaMap;

  const SiteFilterPopup({
    super.key,
    this.initialCategoryId,
    this.initialStatus,
    this.initialSiteId,
    required this.categories,
    required this.statuses,
    required this.onApply,
    required this.areaMap,
  });

  @override
  State<SiteFilterPopup> createState() => _SiteFilterPopupState();
}

class _SiteFilterPopupState extends State<SiteFilterPopup> {
  final _filterKey = GlobalKey<SiteFilterChipPanelState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SiteFilterChipPanel(
            key: _filterKey,
            categories: widget.categories,
            statuses: widget.statuses,
            initialSelectedCategoryId: widget.initialCategoryId,
            initialSelectedStatus: widget.initialStatus,
            areaMap: widget.areaMap,
            initialSelectedSiteId:
                widget.initialSiteId, // Truyền Site ID ban đầu
            showDecoration: false,
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
                  final (categoryId, status, siteId) =
                      _filterKey.currentState?.getCurrentSelections() ??
                      (null, null, null);
                  widget.onApply(categoryId, status, siteId); // Truyền Site ID
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
