import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siteplus_mb/components/custom_dropdown_field.dart';
import 'package:siteplus_mb/pages/ReportPage/pages/deal_section.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_view_model.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/sites_provider.dart';

class CreateSiteDealDialog extends StatefulWidget {
  final int? siteId;
  final int? siteStatus;
  const CreateSiteDealDialog({super.key, this.siteId, this.siteStatus});

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
  int? _selectedSiteId;
  String? _selectedSiteName;
  bool _isSubmitting = false;
  int _currentStep = 0;
  final PageController _pageController = PageController();
  @override
  void initState() {
    super.initState();
    // Nếu siteStatus == 7, fetch lại API trước khi chọn site
    if (widget.siteStatus == 7 && widget.siteId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchSitesAndSelect();
      });
    } else if (widget.siteId != null) {
      // Trường hợp không cần fetch lại, dùng dữ liệu hiện tại từ provider
      final sitesProvider = Provider.of<SitesProvider>(context, listen: false);
      final sites = sitesProvider.sites;
      try {
        final selectedSite = sites.firstWhere(
          (site) => site.id == widget.siteId!,
        );
        _selectedSiteId = selectedSite.id;
        _selectedSiteName =
            'Site ID #${selectedSite.id} - ${selectedSite.areaName}';
      } catch (e) {
        debugPrint('No site found with siteId: ${widget.siteId}');
      }
    }
  }

  // Hàm fetch lại API và chọn site
  Future<void> _fetchSitesAndSelect() async {
    final sitesProvider = Provider.of<SitesProvider>(context, listen: false);
    try {
      // Gọi fetchSites từ SitesProvider
      await sitesProvider.fetchSites(areaMap: {});

      // Sau khi fetch xong, chọn site dựa trên siteId
      final sites = sitesProvider.sites;
      try {
        final selectedSite = sites.firstWhere(
          (site) => site.id == widget.siteId!,
        );
        if (mounted) {
          setState(() {
            _selectedSiteId = selectedSite.id;
            _selectedSiteName =
                'Site ID #${selectedSite.id} - ${selectedSite.areaName}';
          });
        }
        debugPrint(
          'Site fetched and selected: $_selectedSiteId - $_selectedSiteName',
        );
      } catch (e) {
        debugPrint('No site found with siteId: ${widget.siteId} after fetch');
      }
    } catch (e) {
      debugPrint('Error fetching sites: $e');
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
    return Padding(
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
                CustomDropdownField<int>(
                  value: _selectedSiteId,
                  items:
                      sites
                          .where(
                            (site) =>
                                site.status != 3 ||
                                site.status != 5 ||
                                site.status != 6 ||
                                site.status != 9,
                          )
                          .map((site) => site.id)
                          .toList(),
                  labelText: 'Select Site',
                  hintText: 'Tap to select a site',
                  prefixIcon: Icons.location_on_rounded,
                  theme: theme,
                  onChanged: (value) {
                    setState(() {
                      _selectedSiteId = value;
                      if (value != null) {
                        final selectedSite = sites.firstWhere(
                          (site) => site.id == value,
                        );
                        _selectedSiteName =
                            'Site ID #${selectedSite.id} - ${selectedSite.areaName}';
                      } else {
                        _selectedSiteName = null;
                      }
                    });
                  },
                  validator:
                      (value) => value == null ? 'Please select a site' : null,
                  itemBuilder: (int siteId) {
                    final site = sites.firstWhere((s) => s.id == siteId);
                    return Row(
                      children: [
                        Icon(
                          Icons.business_rounded,
                          size: 20,
                          color: theme.colorScheme.primary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Site ID #${site.id}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
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
                      ],
                    );
                  },
                  selectedItemBuilder: (int siteId) {
                    final site = sites.firstWhere((s) => s.id == siteId);
                    return Row(
                      children: [
                        Icon(
                          Icons.business_rounded,
                          size: 20,
                          color: theme.colorScheme.primary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Site ID #${site.id}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                if (_selectedSiteId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.2),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selected',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedSiteName ?? '',
                                  style: theme.textTheme.bodyMedium?.copyWith(
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
            if (_selectedSiteId != null)
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
                            if (_selectedSiteId != null) {
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
          (site) => site.id == _selectedSiteId,
        );

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
        dealData['siteId'] = _selectedSiteId;
        dealData['status'] = 0;
        debugPrint('Submitting dealData: $dealData');
        final success = await _apiService.createSiteDeal(dealData);
        if (success) {
          if (requiresConfirmation && _selectedSiteId != null) {
            final apiService = ApiService();
            final statusUpdated = await apiService.updateSiteStatus(
              widget.siteId!,
              3,
            );
            if (!statusUpdated) {
              debugPrint('Failed to update site status to 3');
            } else {
              debugPrint(
                'Site status updated to 3 for siteId: $_selectedSiteId',
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
