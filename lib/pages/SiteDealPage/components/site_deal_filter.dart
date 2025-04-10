import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:siteplus_mb/components/custom_input_field.dart';
import 'package:siteplus_mb/utils/SiteDeal/site_deal_provider.dart';
import 'package:siteplus_mb/utils/SiteDeal/site_deal_status.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/sites_provider.dart';

class SiteDealFilter extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;
  final Map<int, String> areaMap;
  final List<int> siteIdsWithDeals;

  final String? search;
  final int? siteId;
  final String? startDate;
  final String? endDate;
  final String? status;

  const SiteDealFilter({
    super.key,
    required this.onApply,
    required this.areaMap,
    required this.siteIdsWithDeals,
    this.search,
    this.siteId,
    this.startDate,
    this.endDate,
    this.status,
  });

  @override
  State<SiteDealFilter> createState() => _SiteDealFilterState();
}

class _SiteDealFilterState extends State<SiteDealFilter> {
  late TextEditingController _searchController;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedStatus;
  int? _selectedSiteId;

  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.search ?? '');
    _selectedSiteId = widget.siteId;
    _selectedStatus = widget.status;

    if (widget.status != null) {
      _selectedStatus =
          SITE_DEAL_STATUS_API_MAP.entries
              .firstWhere(
                (entry) => entry.value.toString() == widget.status,
                orElse: () => MapEntry(STATUS_ACTIVE, 1),
              )
              .key;
    }
    if (widget.startDate != null && widget.startDate!.isNotEmpty) {
      _startDate = DateTime.tryParse(widget.startDate!);
    }
    if (widget.endDate != null && widget.endDate!.isNotEmpty) {
      _endDate = DateTime.tryParse(widget.endDate!);
    }
    _startDateController = TextEditingController(text: _formatDate(_startDate));
    _endDateController = TextEditingController(text: _formatDate(_endDate));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _searchController.text = '';
      _selectedSiteId = null;
      _startDate = null;
      _endDate = null;
      _selectedStatus = null;
      _startDateController.text = '';
      _endDateController.text = '';
    });
  }

  void _resetAndApply() {
    _resetFilters();
    widget.onApply({
      'search': '',
      'siteId': null,
      'startDate': null,
      'endDate': null,
      'status': null,
    });
    Navigator.pop(context);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sitesProvider = Provider.of<SitesProvider>(context);
    final siteDealProvider = Provider.of<SiteDealProvider>(context);

    // Lấy danh sách site id từ tất cả site deals
    final allSiteIdsWithDeals =
        siteDealProvider.allSiteDeals.map((deal) => deal.siteId).toSet();
    final filteredSites =
        sitesProvider.sites
            .where((site) => allSiteIdsWithDeals.contains(site.id))
            .toList();

    if (_selectedSiteId != null &&
        !filteredSites.any((site) => site.id == _selectedSiteId)) {
      _selectedSiteId = null;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Đường kéo ở trên cùng để UX tốt hơn
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onBackground.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Deals',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _resetAndApply,
                icon: const Icon(LucideIcons.refreshCcw, size: 18),
                label: const Text('Reset & Apply'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sử dụng CustomInputField cho search để đồng nhất UI
          CustomInputField(
            label: 'Search',
            hintText: 'Enter keywords',
            icon: LucideIcons.search,
            onSaved: (value) {},
            theme: theme,
            controller: _searchController,
            useNewUI: true, // Sử dụng UI mới với border radius lớn hơn
          ),
          const SizedBox(height: 16),
          // Dropdown được thiết kế lại với CustomInputField
          DropdownButtonFormField<int>(
            value: _selectedSiteId,
            decoration: InputDecoration(
              labelText: 'Site',
              labelStyle: TextStyle(color: theme.colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              prefixIcon: Icon(
                LucideIcons.mapPin,
                color: theme.colorScheme.primary,
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            items:
                filteredSites.map((site) {
                  return DropdownMenuItem<int>(
                    value: site.id,
                    child: Text(
                      'Site ID #${site.id} - ${widget.areaMap[site.areaId] ?? 'Unknown'}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }).toList(),
            onChanged: (value) => setState(() => _selectedSiteId = value),
            dropdownColor: theme.colorScheme.surface,
            isExpanded: true,
            style: theme.textTheme.bodyMedium,
            itemHeight: 48,
            menuMaxHeight: 240,
            icon: Icon(
              LucideIcons.chevronDown,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: theme.colorScheme.primary,
                              onPrimary: theme.colorScheme.onPrimary,
                              surface: theme.colorScheme.surface,
                              onSurface: theme.colorScheme.onSurface,
                            ),
                            dialogBackgroundColor: theme.colorScheme.background,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                        _startDateController.text = _formatDate(date);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: CustomInputField(
                      label: 'Start Date',
                      hintText: 'Select date',
                      icon: LucideIcons.calendar,
                      onSaved: (_) {},
                      theme: theme,
                      controller: _startDateController,
                      keyboardType: TextInputType.none,
                      useNewUI: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: theme.colorScheme.primary,
                              onPrimary: theme.colorScheme.onPrimary,
                              surface: theme.colorScheme.surface,
                              onSurface: theme.colorScheme.onSurface,
                            ),
                            dialogBackgroundColor: theme.colorScheme.background,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setState(() {
                        _endDate = date;
                        _endDateController.text = _formatDate(date);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: CustomInputField(
                      label: 'End Date',
                      hintText: 'Select date',
                      icon: LucideIcons.calendar,
                      onSaved: (_) {},
                      theme: theme,
                      controller: _endDateController,
                      keyboardType: TextInputType.none,
                      useNewUI: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Dropdown Status được thiết kế lại
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: InputDecoration(
              labelText: 'Status',
              labelStyle: TextStyle(color: theme.colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              prefixIcon: Icon(
                LucideIcons.tag,
                color: theme.colorScheme.primary,
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            items:
                [STATUS_ACTIVE, STATUS_EXPIRED, STATUS_IN_PROGRESS].map((
                  status,
                ) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status, style: theme.textTheme.bodyMedium),
                  );
                }).toList(),
            onChanged: (value) => setState(() => _selectedStatus = value),
            dropdownColor: theme.colorScheme.surface,
            isExpanded: true,
            style: theme.textTheme.bodyMedium,
            itemHeight: 48,
            menuMaxHeight: 200,
            icon: Icon(
              LucideIcons.chevronDown,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          // Các nút được cải tiến
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  int? statusNumber;
                  if (_selectedStatus != null) {
                    statusNumber = SITE_DEAL_STATUS_API_MAP[_selectedStatus!];
                  }
                  widget.onApply({
                    'search': _searchController.text,
                    'siteId': _selectedSiteId,
                    'startDate': _startDate?.toIso8601String(),
                    'endDate': _endDate?.toIso8601String(),
                    'status': statusNumber?.toString(),
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0, // Modern UI thường có elevation thấp
                ),
                child: Text(
                  'Apply',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
