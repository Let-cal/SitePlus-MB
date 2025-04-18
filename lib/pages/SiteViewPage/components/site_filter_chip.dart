import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siteplus_mb/components/custom_dropdown_field.dart';
import 'package:siteplus_mb/components/filter_chip.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_category.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_status.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_view_model.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/sites_provider.dart';

class SiteFilterChipPanel extends StatefulWidget {
  final List<SiteCategory> categories;
  final List<int> statuses;
  final int? initialSelectedCategoryId;
  final int? initialSelectedStatus;
  final int? initialSelectedSiteId;
  final bool showDecoration;
  final Map<int, String> areaMap;

  const SiteFilterChipPanel({
    super.key,
    required this.categories,
    required this.statuses,
    this.initialSelectedCategoryId,
    this.initialSelectedStatus,
    this.initialSelectedSiteId,
    this.showDecoration = true,
    required this.areaMap,
  });

  @override
  State<SiteFilterChipPanel> createState() => SiteFilterChipPanelState();
}

class SiteFilterChipPanelState extends State<SiteFilterChipPanel> {
  late List<FilterSection> _filterSections;
  final List<ActiveFilter> _activeFilters = [];
  int? _selectedSiteId;

  @override
  void initState() {
    super.initState();
    _selectedSiteId = widget.initialSelectedSiteId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeFilterSections();
  }

  void _initializeFilterSections() {
    final categoryOptions =
        widget.categories.map((category) {
          return FilterOption(
            label: category.name,
            icon: getSiteCategoryIcon(category.id),
            color: getCategoryColor(category.id),
            isSelected: category.id == widget.initialSelectedCategoryId,
            onTap: () => _handleCategorySelection(category.id),
          );
        }).toList();

    final statusOptions =
        widget.statuses.map((status) {
          return FilterOption(
            label: getStatusText(status),
            icon: getStatusIcon(status),
            color: getStatusColor(context, status),
            isSelected: status == widget.initialSelectedStatus,
            onTap: () => _handleStatusSelection(status),
          );
        }).toList();

    _filterSections = [
      FilterSection(title: 'Site ID', isChipStyle: false, options: []),
      FilterSection(
        title: 'Site Type',
        isChipStyle: true,
        options: categoryOptions,
      ),
      FilterSection(title: 'Status', options: statusOptions),
    ];

    _updateActiveFilters();
  }

  void _handleCategorySelection(int categoryId) {
    setState(() {
      for (var section in _filterSections) {
        if (section.title == 'Site Type') {
          for (var option in section.options) {
            final selectedCategoryName =
                widget.categories
                    .firstWhere((cat) => cat.id == categoryId)
                    .name;
            option.isSelected = option.label == selectedCategoryName;
          }
        }
      }
      _updateActiveFilters();
    });
  }

  void _handleStatusSelection(int status) {
    setState(() {
      for (var section in _filterSections) {
        if (section.title == 'Status') {
          for (var option in section.options) {
            option.isSelected = option.label == getStatusText(status);
          }
        }
      }
      _updateActiveFilters();
    });
  }

  int? _getCurrentCategory() {
    for (var section in _filterSections) {
      if (section.title == 'Site Type') {
        final selectedOption = section.options.firstWhere(
          (option) => option.isSelected,
          orElse:
              () => FilterOption(
                label: '',
                color: Colors.transparent,
                isSelected: false,
                onTap: () {},
              ),
        );
        if (selectedOption.isSelected) {
          return widget.categories
              .firstWhere((cat) => cat.name == selectedOption.label)
              .id;
        }
      }
    }
    return null;
  }

  int? _getCurrentStatus() {
    for (var section in _filterSections) {
      if (section.title == 'Status') {
        final selectedOption = section.options.firstWhere(
          (option) => option.isSelected,
          orElse:
              () => FilterOption(
                label: '',
                color: Colors.transparent,
                isSelected: false,
                onTap: () {},
              ),
        );
        if (selectedOption.isSelected) {
          return widget.statuses.firstWhere(
            (status) => getStatusText(status) == selectedOption.label,
          );
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
              },
            ),
          );
        }
      }
    }
    if (_selectedSiteId != null) {
      final sitesProvider = Provider.of<SitesProvider>(context, listen: false);
      final selectedSite = sitesProvider.sites.firstWhere(
        (site) => site.id == _selectedSiteId,
        orElse:
            () => Site(
              id: _selectedSiteId!,
              brandId: 0,
              floor: 0,
              siteCategoryId: 0,
              areaId: 0,
              areaName: 'Unknown',
              address: '',
              size: 0.0,
              status: 0,
              statusName: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
      );
      _activeFilters.add(
        ActiveFilter(
          label: 'Site ID: ${selectedSite.id}',
          color: Colors.blue,
          onRemove: () {
            setState(() {
              _selectedSiteId = null;
              _updateActiveFilters();
            });
          },
        ),
      );
    }
  }

  (int?, int?, int?) getCurrentSelections() {
    return (_getCurrentCategory(), _getCurrentStatus(), _selectedSiteId);
  }

  void resetSelections() {
    setState(() {
      for (var section in _filterSections) {
        for (var option in section.options) {
          option.isSelected = false;
        }
      }
      _selectedSiteId = null;
      _updateActiveFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FilterChipPanel(
      headerTitle: 'Filter Site',
      sections: _filterSections,
      activeFilters: _activeFilters,
      showDecoration: widget.showDecoration,
      sectionContentBuilder: _buildSectionContent, // Pass the callback
    );
  }

  Widget _buildSectionContent(FilterSection section) {
    if (section.title == 'Site ID') {
      final sitesProvider = Provider.of<SitesProvider>(context);
      final sites = sitesProvider.sites;

      if (sitesProvider.isLoading) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (sites.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              const Text(
                'No sites available',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  print('SiteFilterChipPanel: Manually refreshing sites');
                  Provider.of<SitesProvider>(
                    context,
                    listen: false,
                  ).refreshSites(areaMap: widget.areaMap);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      return CustomDropdownField<int>(
        value: _selectedSiteId,
        items: sites.map((site) => site.id).toList(),
        labelText: 'Select Site ID',
        hintText: 'Tap to select a site',
        prefixIcon: Icons.business_rounded,
        theme: Theme.of(context),
        onChanged: (value) {
          setState(() {
            _selectedSiteId = value;
            _updateActiveFilters();
          });
        },
        itemBuilder: (int siteId) {
          final site = sites.firstWhere(
            (s) => s.id == siteId,
            orElse:
                () => Site(
                  id: siteId,
                  brandId: 0,
                  floor: 0,
                  siteCategoryId: 0,
                  areaId: 0,
                  areaName: widget.areaMap[siteId] ?? 'Unknown', // Use areaMap
                  address: '',
                  size: 0.0,
                  status: 0,
                  statusName: '',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
          );
          return Row(
            children: [
              Icon(
                Icons.business_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text('Site ID: ${site.id} - ${site.areaName}')),
            ],
          );
        },
        selectedItemBuilder: (int siteId) {
          final site = sites.firstWhere(
            (s) => s.id == siteId,
            orElse:
                () => Site(
                  id: siteId,
                  brandId: 0,
                  floor: 0,
                  siteCategoryId: 0,
                  areaId: 0,
                  areaName: widget.areaMap[siteId] ?? 'Unknown', // Use areaMap
                  address: '',
                  size: 0.0,
                  status: 0,
                  statusName: '',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
          );
          return Text('Site ID: ${site.id} - ${site.areaName}');
        },
      );
    }
    return const SizedBox.shrink();
  }
}
