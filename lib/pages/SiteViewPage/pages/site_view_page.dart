import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:siteplus_mb/components/SectionHeader.dart';
import 'package:siteplus_mb/components/multi_tab_filter_panel.dart';
import 'package:siteplus_mb/components/pagination_component.dart';
import 'package:siteplus_mb/components/report_selection_dialog.dart';
import 'package:siteplus_mb/main_scaffold.dart';
import 'package:siteplus_mb/pages/ReportPage/pages/site_building_dialog.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/floating_button_site.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/site_card.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/site_detail_popup.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/site_filter_popup.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/AreaDistrict/locations_provider.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_category.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_status.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_view_model.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/sites_provider.dart';

enum FilterUIType { chip, tab }

class SiteViewPage extends StatefulWidget {
  final int? filterSiteId;
  final void Function(int? filterTaskId, {int? filterTaskStatus})?
  onNavigateToTaskTab;
  const SiteViewPage({super.key, this.filterSiteId, this.onNavigateToTaskTab});

  @override
  State<SiteViewPage> createState() => _SiteViewPageState();
}

class _SiteViewPageState extends State<SiteViewPage>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Site filter state
  int? selectedSiteId;
  int? selectedCategoryId; // null means "All"
  int? selectedStatusId; // null means "All"
  int? currentFilterSiteId;
  FilterUIType currentFilterUI = FilterUIType.tab;
  // Pagination state
  int currentPage = 1;
  int totalPages = 1;
  int pageSize = 6;
  int defaultPageSize = 6;
  int totalRecords = 0;

  // Site data
  List<Site> sites = [];
  bool isLoading = true;

  List<SiteCategory> _siteCategories = [];
  List<Area> _areas = [];
  Map<int, String> siteCategoryMap = {};
  Map<int, String> areaMap = {};
  final List<int> statuses = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  // All sites list for iterating through pages if needed
  List<Site> allSites = [];
  // In _SiteViewPageState._loadData() add these debug prints:

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final token = await ApiService().getToken();

      if (token == null || token.isEmpty) {
        throw Exception('No authentication token');
      }

      final fetchedSiteCategories = await ApiService().getSiteCategories(token);
      final fetchedAreas = await ApiService().getAllAreas();

      print(
        'SiteViewPage: Fetched categories: ${fetchedSiteCategories.length}',
      );
      for (var cat in fetchedSiteCategories) {
        print('SiteViewPage: Category: ${cat.id} - ${cat.name}');
      }

      setState(() {
        _siteCategories = fetchedSiteCategories;
        _areas = fetchedAreas;

        siteCategoryMap = {
          for (var cat in _siteCategories.where((cat) => cat != null))
            cat.id: cat.englishName,
        };
        print('SiteViewPage: siteCategoryMap size: ${siteCategoryMap.length}');

        areaMap = {
          for (var area in _areas.where((area) => area != null))
            area.id: area.name,
        };
        print('SiteViewPage: areaMap size: ${areaMap.length}');
      });

      if (areaMap.isEmpty) {
        print('SiteViewPage: Warning: areaMap is empty');
        setState(() {
          isLoading = false;
        });
        return;
      }

      final sitesProvider = Provider.of<SitesProvider>(context, listen: false);
      print('SiteViewPage: Calling fetchSites with force=true');
      await sitesProvider.fetchSites(areaMap: areaMap, force: true);
      print('SiteViewPage: fetchSites completed');

      await _loadSites();
    } catch (e) {
      print('SiteViewPage: Error loading data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Call API to get the list of Sites, applying filters if any
  Future<void> _loadSites() async {
    setState(() {
      isLoading = true;
      sites = [];
    });

    try {
      String? searchValue;
      int effectivePageSize = defaultPageSize; // Default page size

      // Prioritize selectedSiteId (from filter popup)
      if (selectedSiteId != null) {
        searchValue = selectedSiteId.toString();
        effectivePageSize = 1; // Limit to 1 result when filtering by siteId
      } else if (currentFilterSiteId != null) {
        searchValue = currentFilterSiteId.toString();
        effectivePageSize = 1; // Limit to 1 result when using initial filter
      }

      print(
        'SiteViewPage: _loadSites with searchValue=$searchValue, pageSize=$effectivePageSize',
      );

      if (searchValue != null) {
        // If filterSiteId exists, search by site id with page 1 and one result only.
        final response = await ApiService().getSites(
          pageNumber: 1,
          pageSize: effectivePageSize,
          search: searchValue,
          status: selectedStatusId,
          siteCategoryId: selectedCategoryId,
        );

        final fetchedSites = List<Site>.from(
          response['data']['listData'].map(
            (item) => Site.fromJson(item, areaMap: areaMap),
          ),
        );

        setState(() {
          sites = fetchedSites;
          totalRecords = fetchedSites.length;
          totalPages = 1;
          pageSize = effectivePageSize;
        });
      } else {
        // Normal display with pagination
        final response = await ApiService().getSites(
          pageNumber: currentPage,
          pageSize: pageSize,
          search: null,
          status: selectedStatusId,
          siteCategoryId: selectedCategoryId,
        );

        final fetchedSites = List<Site>.from(
          response['data']['listData'].map(
            (item) => Site.fromJson(item, areaMap: areaMap),
          ),
        );

        List<Site> filteredSites = fetchedSites;
        if (selectedCategoryId != null) {
          filteredSites =
              fetchedSites
                  .where((site) => site.siteCategoryId == selectedCategoryId)
                  .toList();
        }

        setState(() {
          sites = filteredSites;
          totalRecords = response['data']['totalRecords'];
          totalPages = response['data']['totalPage'];
          pageSize = defaultPageSize;
        });
      }
    } catch (e) {
      print('SiteViewPage: Error loading sites: $e');
      setState(() {
        sites = [];
        totalRecords = 0;
        totalPages = 1;
        pageSize = defaultPageSize;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedCategoryId = null;
    selectedStatusId = null;
    selectedSiteId = null;
    currentFilterSiteId = widget.filterSiteId;
    pageSize = currentFilterSiteId != null ? 1 : defaultPageSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didUpdateWidget(SiteViewPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filterSiteId != oldWidget.filterSiteId) {
      setState(() {
        currentFilterSiteId = widget.filterSiteId;
        pageSize = currentFilterSiteId != null ? 1 : defaultPageSize;
      });
      _loadSites();
    }
  }

  void _changePage(int page) {
    if (page < 1 || page > totalPages || page == currentPage) return;
    setState(() {
      currentPage = page;
      currentFilterSiteId = null;
      pageSize = defaultPageSize;
    });
    _loadSites();
  }

  Future<void> _refreshSites() async {
    setState(() {
      currentPage = 1;
      currentFilterSiteId = null;
      selectedSiteId = null;
      pageSize = defaultPageSize;
    });
    await _loadSites();
  }

  void _navigateToTaskPage() {
    if (widget.onNavigateToTaskTab != null) {
      widget.onNavigateToTaskTab!(null, filterTaskStatus: 1);
    }

    // Show a SnackBar after switching tabs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (MainScaffold.scaffoldKey.currentContext != null) {
        ScaffoldMessenger.of(
          MainScaffold.scaffoldKey.currentContext!,
        ).showSnackBar(
          SnackBar(
            content: Text('Please select a task to create a site.'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    });
  }

  void _showReportSelectionForPropose() async {
    final token = await ApiService().getToken();
    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please log in again')));
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (dialogContext) => ReportSelectionDialog(
            token: token,
            onReportSelected: (
              String reportType,
              int categoryId,
              String categoryName,
            ) {
              Navigator.of(dialogContext).pop({
                'reportType': reportType,
                'categoryId': categoryId,
                'categoryName': categoryName,
              });
            },
          ),
    );

    if (result != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SiteBuildingDialog(
                reportType: result['reportType'],
                siteCategoryId: result['categoryId'],
                siteCategory: result['categoryName'],
                taskId: 0, // Default value
                taskStatus: '',
                isProposeMode: true,
              ),
        ),
      );
      _loadSites(); // Reload the site list after proposing a site
    }
  }

  void _showFilterPopup() {
    final sitesProvider = Provider.of<SitesProvider>(context, listen: false);
    print('SiteViewPage: Refreshing sites before showing filter popup');
    sitesProvider.refreshSites(areaMap: areaMap).then((_) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder:
            (context) => SiteFilterPopup(
              initialCategoryId: selectedCategoryId,
              initialStatus: selectedStatusId,
              initialSiteId: selectedSiteId,
              categories: _siteCategories,
              statuses: statuses,
              areaMap: areaMap,
              onApply: (categoryId, status, siteId) {
                setState(() {
                  selectedCategoryId = categoryId;
                  selectedStatusId = status;
                  selectedSiteId = siteId;
                  currentPage = 1;
                  if (siteId == null && currentFilterSiteId == null) {
                    pageSize = defaultPageSize;
                  } else {
                    pageSize = 1;
                  }
                  currentFilterSiteId = siteId ?? currentFilterSiteId;
                });
                _loadSites();
              },
            ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingButtonSite(
        onProposeSite: _showReportSelectionForPropose,
        onCreateSiteByTask: _navigateToTaskPage,
        onShowFilter: _showFilterPopup,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshSites,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Sites List',
                        subtitle: 'Manage and track sites',
                        icon: LucideIcons.fileCheck,
                      ),
                      const SizedBox(height: 24),
                      MultiTabFilterPanel(
                            groups: [
                              FilterGroup(
                                key: 'category',
                                options: [
                                  FilterOption(id: null, label: 'All'),
                                  ..._siteCategories.map(
                                    (cat) => FilterOption(
                                      id: cat.id,
                                      label: cat.englishName,
                                    ),
                                  ),
                                ],
                              ),
                              FilterGroup(
                                key: 'status',
                                options: [
                                  FilterOption(id: null, label: 'All'),
                                  ...statuses.map(
                                    (status) => FilterOption(
                                      id: status,
                                      label: getStatusText(status),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            onFilterChanged: (selections) {
                              setState(() {
                                selectedCategoryId = selections['category'];
                                selectedStatusId = selections['status'];
                                currentPage = 1;
                                currentFilterSiteId = null;
                                pageSize = defaultPageSize;
                              });
                              _loadSites();
                            },
                            initialSelections: {
                              'category': selectedCategoryId,
                              'status': selectedStatusId,
                            },
                          )
                          .animate()
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            curve: Curves.easeOutQuart,
                            duration: 600.ms,
                            delay: 300.ms,
                          )
                          .fadeIn(delay: 300.ms, duration: 500.ms),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator()
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .scaleXY(
                              begin: 0.8,
                              end: 1.2,
                              duration: 1000.ms,
                              curve: Curves.easeInOut,
                            )
                            .then()
                            .scaleXY(
                              begin: 1.2,
                              end: 0.8,
                              duration: 1000.ms,
                              curve: Curves.easeInOut,
                            ),
                        const SizedBox(height: 16),
                        Text(
                              'Loading properties...',
                              style: Theme.of(context).textTheme.bodyLarge,
                            )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .fadeIn(duration: 1000.ms)
                            .then()
                            .fadeOut(duration: 1000.ms),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: _buildSiteList(),
                ),
              if (!isLoading && sites.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: PaginationComponent(
                          currentPage: currentPage,
                          totalPages: totalPages,
                          onPageChanged: _changePage,
                        )
                        .animate()
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          curve: Curves.easeOutQuart,
                          duration: 600.ms,
                          delay: 200.ms,
                        )
                        .fadeIn(delay: 200.ms, duration: 500.ms),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSiteList() {
    if (isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator()
              .animate(onPlay: (controller) => controller.repeat())
              .scaleXY(
                begin: 0.8,
                end: 1.2,
                duration: 1000.ms,
                curve: Curves.easeInOut,
              )
              .then()
              .scaleXY(
                begin: 1.2,
                end: 0.8,
                duration: 1000.ms,
                curve: Curves.easeInOut,
              ),
        ),
      );
    }
    if (sites.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.5),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text(
                "No properties match the selected filters",
                style: Theme.of(context).textTheme.titleMedium,
              ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final site = sites[index];
          return SiteCard(
            site: site,
            siteCategoryMap: siteCategoryMap,
            areaMap: areaMap,
            onNavigateToTaskTab: widget.onNavigateToTaskTab,
            onTap: () async {
              final result = await ViewDetailSite.show(
                context,
                site,
                siteCategoryMap,
                areaMap,
                onNavigateToTaskTab: widget.onNavigateToTaskTab,
              );
              if (result == true) await _loadSites();
            },
          );
        }, childCount: sites.length),
      ),
    );
  }
}
