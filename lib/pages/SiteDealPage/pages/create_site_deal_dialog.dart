import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siteplus_mb/components/searchable_dropdown.dart';
import 'package:siteplus_mb/pages/ReportPage/pages/deal_section.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/AreaDistrict/locations_provider.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_view_model.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/sites_provider.dart';
import 'package:siteplus_mb/utils/string_utils.dart';

class CreateSiteDealDialog extends StatefulWidget {
  final int? siteId;
  final int? taskId;
  final int? siteStatus;
  const CreateSiteDealDialog({
    super.key,
    this.siteId,
    this.siteStatus,
    this.taskId,
  });

  @override
  State<CreateSiteDealDialog> createState() => _CreateSiteDealDialogState();
}

class _CreateSiteDealDialogState extends State<CreateSiteDealDialog> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  Map<String, dynamic> dealData = {
    'proposedPrice': '',
    'leaseTerm': '',
    'deposit': '',
    'depositMonth': '',
    'additionalTerms': '',
    'status': 0,
  };
  Site? _selectedSite;
  int? _selectedTaskId;
  String? _selectedSiteName;
  bool _isSubmitting = false;
  int _currentStep = 0;
  bool _isLoading = false;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Luôn fetch lại danh sách sites khi khởi tạo dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSitesAndSelect();
    });
  }

  // Hàm fetch lại API và chọn site
  Future<void> _fetchSitesAndSelect() async {
    setState(() => _isLoading = true);
    final sitesProvider = Provider.of<SitesProvider>(context, listen: false);
    final locationsProvider = Provider.of<LocationsProvider>(
      context,
      listen: false,
    );
    try {
      locationsProvider.reset();
      await locationsProvider.loadAllAreas(force: true);
      final areaMap = {
        for (var area in locationsProvider.allAreas) area.id: area.name,
      };
      // Gọi fetchSites từ SitesProvider
      await sitesProvider.fetchSites(areaMap: areaMap, force: true);
      debugPrint(
        'Sites fetched successfully: ${sitesProvider.sites.map((s) => s.areaName).toList()}',
      );

      // Sau khi fetch xong, chọn site dựa trên siteId
      final sites = sitesProvider.sites;
      if (widget.siteId != null) {
        try {
          final selectedSite = sites.firstWhere(
            (site) => site.id == widget.siteId!,
            orElse: () => throw Exception('Site not found'),
          );
          if (mounted) {
            setState(() {
              _selectedSite = selectedSite;
              _selectedSiteName =
                  'Site ID #${selectedSite.id} - ${selectedSite.areaName}';
            });
            debugPrint(
              'Site selected: ${_selectedSite?.id} - $_selectedSiteName',
            );
          }
        } catch (e) {
          debugPrint('No site found with siteId: ${widget.siteId} after fetch');
          if (mounted) {
            setState(() {
              _selectedSite = null;
              _selectedSiteName = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'No site found with siteId: ${widget.siteId}. Please choose the other one.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching sites: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching sites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sitesProvider = Provider.of<SitesProvider>(context);
    final sites = sitesProvider.sites;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(0),
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 8),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [_buildStep1(theme, sites), _buildStep2(theme)],
                  ),
                ),
                const SizedBox(height: 16),
                _buildNavigationButtons(theme),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Để căn nút close sang phải
            children: [
              Row(
                children: [
                  Icon(
                    Icons.real_estate_agent_rounded,
                    size: 28,
                    color: theme.colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Create Site Deal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
              // Thêm nút close
              IconButton(
                onPressed: () {
                  Navigator.pop(context); // Đóng dialog khi nhấn
                },
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onPrimary,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(), // Loại bỏ padding mặc định
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 8,
                width:
                    MediaQuery.of(context).size.width *
                    (_currentStep == 0 ? 0.4 : 0.85) *
                    0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Step ${_currentStep + 1}/2: ${_currentStep == 0 ? "Select Site" : "Deal Details"}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${(_currentStep + 1) * 50}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(ThemeData theme, List<Site> sites) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Site',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please select a site to create a new deal',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'List of Sites',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SearchableDropdown<Site>(
                        selectedItem: _selectedSite,
                        items:
                            sites
                                .where(
                                  (site) =>
                                      site.status != 3 &&
                                      site.status != 5 &&
                                      site.status != 6 &&
                                      site.status != 9 &&
                                      site.status != 8 &&
                                      site.status != 1,
                                )
                                .toList(),
                        selectedItemBuilder:
                            (site) =>
                                site != null
                                    ? Row(
                                      children: [
                                        Icon(
                                          Icons.business_rounded,
                                          size: 20,
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.7),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Site ID #${site.id}',
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    )
                                    : Text(
                                      'Select Site',
                                      style: TextStyle(
                                        color: theme.hintColor,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                        itemBuilder:
                            (site, isSelected) => Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 16.0,
                              ),
                              color:
                                  isSelected
                                      ? theme.colorScheme.primary.withOpacity(
                                        0.1,
                                      )
                                      : null,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.business_rounded,
                                    size: 20,
                                    color:
                                        isSelected
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurface
                                                .withOpacity(0.7),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Site ID #${site.id}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                            color:
                                                isSelected
                                                    ? theme.colorScheme.primary
                                                    : null,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          site.areaName,
                                          style: theme.textTheme.bodyMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check,
                                      color: theme.colorScheme.primary,
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                        filter: (site, query) {
                          final normalizedQuery = StringUtils.normalizeString(
                            query,
                          );
                          final idString = site.id.toString();
                          final normalizedAreaName =
                              StringUtils.normalizeString(site.areaName);
                          return idString.contains(query) ||
                              normalizedAreaName.contains(normalizedQuery);
                        },
                        onChanged: (site) {
                          setState(() {
                            _selectedSite = site;
                            if (site != null) {
                              _selectedSiteName =
                                  'Site ID #${site.id} - ${site.areaName}';
                              _selectedTaskId = site.task?.id;
                              debugPrint(
                                'Selected site task ID: $_selectedTaskId',
                              );
                            } else {
                              _selectedSiteName = null;
                              _selectedTaskId = null;
                            }
                          });
                        },
                        icon: Icons.location_on_rounded,
                        isLoading: false,
                        isEnabled: true,
                      ),
                      if (_selectedSite != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_circle_rounded,
                                    color: theme.colorScheme.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Selected',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.primary,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedSiteName ?? '',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
  }

  Widget _buildStep2(ThemeData theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deal Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please enter the deal details for the site',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            if (_selectedSite != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _selectedSiteName ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: DealSection(
                dealData: dealData,
                setState: setState,
                theme: theme,
                useSmallText: true,
                useNewUI: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(ThemeData theme) {
    // Thay đổi thanh điều hướng để chỉ hiển thị nút Back và Create Deal
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút Back
          if (_currentStep > 0)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: IconButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() => _currentStep--);
                },
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),

          // Nút Continue/Create Deal
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: _currentStep > 0 ? 16 : 0),
              child: ElevatedButton(
                onPressed:
                    _isSubmitting
                        ? null
                        : () {
                          if (_currentStep == 0) {
                            if (_selectedSite != null) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                              setState(() => _currentStep++);
                            } else {
                              showDialog(
                                context: context,
                                builder:
                                    (ctx) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      title: const Text('Error'),
                                      content: const Text(
                                        'Please select a site',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(ctx).pop(),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                              );
                            }
                          } else {
                            _submitForm();
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _currentStep == 0 ? 'Continue' : 'Create Deal',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isSubmitting = true);
      try {
        // Lấy thông tin site được chọn từ danh sách sites
        final sitesProvider = Provider.of<SitesProvider>(
          context,
          listen: false,
        );
        final selectedSite = sitesProvider.sites.firstWhereOrNull(
          (site) => site.id == _selectedSite,
        );
        final taskIdToUpdate = widget.taskId ?? _selectedTaskId;
        final siteIdToUpdate = widget.siteId ?? _selectedSite?.id;

        // Check for existing site deals with status 0
        if (siteIdToUpdate != null) {
          final existingSiteDeals = await _apiService.getSiteDealBySiteId(
            siteIdToUpdate,
          );
          final pendingSiteDeals =
              existingSiteDeals.where((deal) => deal['status'] == 0).toList();

          // If there are any pending site deals, update them to status 2 (invalid)
          for (var pendingDeal in pendingSiteDeals) {
            final siteDealId = pendingDeal['id'];
            debugPrint(
              'Found existing site deal with status 0, ID: $siteDealId. Updating to status 2.',
            );
            final updated = await _apiService.updateSiteDealStatus(
              siteDealId,
              2,
            );
            if (!updated) {
              debugPrint('Failed to update site deal $siteDealId to status 2');
              // Consider showing an error message but continue with the process
            } else {
              debugPrint(
                'Successfully updated site deal $siteDealId to status 2',
              );
            }
          }
        }

        // Kiểm tra cả widget.siteStatus và status của site được chọn
        final requiresConfirmation =
            widget.siteStatus == 7 || (selectedSite?.status == 7);
        if (requiresConfirmation) {
          final confirm = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Confirmation'),
                  content: const Text(
                    'If you create a site deal for this site, it will directly send the report to the Area-Manager. Are you sure?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Send to Area Manager'),
                    ),
                  ],
                ),
          );
          if (confirm != true) {
            setState(() => _isSubmitting = false);
            return;
          }
        }
        dealData['siteId'] = _selectedSite?.id;
        dealData['status'] = 0;
        debugPrint("site to update is $siteIdToUpdate");
        debugPrint("task to update is $taskIdToUpdate");
        debugPrint('Submitting dealData: $dealData');
        final success = await _apiService.createSiteDeal(dealData);
        if (success) {
          if (requiresConfirmation && siteIdToUpdate != null) {
            final apiService = ApiService();
            final siteStatusUpdated = await apiService.updateSiteStatus(
              siteIdToUpdate,
              3,
            );
            bool taskStatusUpdated = true;
            if (taskIdToUpdate != null) {
              taskStatusUpdated = await apiService.updateTaskStatus(
                taskIdToUpdate,
                3,
              );
              if (!taskStatusUpdated) {
                debugPrint('Failed to update task status to 3');
              } else {
                debugPrint(
                  'Task status updated to 3 for taskId: $taskIdToUpdate',
                );
              }
            } else {
              debugPrint('No task ID available to update');
            }

            if (!siteStatusUpdated) {
              debugPrint('Failed to update site status to 3');
            } else {
              debugPrint(
                'Site status updated to 3 for siteId: $siteIdToUpdate',
              );
            }
          }
          if (context.mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text('Success'),
                      ],
                    ),
                    content: const Text('Site deal created successfully'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.pop(context, true);
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
            );
          }
        } else {
          showDialog(
            context: context,
            builder:
                (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  title: const Text('Error'),
                  content: const Text('Failed to create site deal'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: const Text('Error'),
                content: Text('Error: $e'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
