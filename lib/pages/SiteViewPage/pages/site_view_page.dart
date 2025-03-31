import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/components/SectionHeader.dart';
import 'package:siteplus_mb/components/pagination_component.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/site_card.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/site_detail_popup.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/site_filter_chip.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/AreaDistrict/locations_provider.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_category.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_view_model.dart';

class SiteViewPage extends StatefulWidget {
  final int? filterSiteId;
  final void Function(int? filterTaskId)? onNavigateToTaskTab;
  const SiteViewPage({super.key, this.filterSiteId, this.onNavigateToTaskTab});
  @override
  State<SiteViewPage> createState() => _SiteViewPageState();
}

class _SiteViewPageState extends State<SiteViewPage>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Site filter state
  int selectedCategoryId = 0; // 0 means "All Categories"
  int? selectedStatusId; // 0 means "All Categories"

  // Pagination state
  int currentPage = 1;
  int totalPages = 1;
  int pageSize = 5;
  int totalRecords = 0;

  // Site data
  List<Site> sites = [];
  bool isLoading = true;

  List<SiteCategory> _siteCategories = [];
  List<Area> _areas = [];
  Map<int, String> siteCategoryMap = {};
  Map<int, String> areaMap = {};
  // Danh sách tất cả site khi cần duyệt qua các trang
  List<Site> allSites = [];
  // In _SiteViewPageState._loadData() add these debug prints:

  Future<void> _loadData() async {
    try {
      final token = await ApiService().getToken();
      debugPrint('Token: $token');

      if (token == null || token.isEmpty) {
        throw Exception("Không có token xác thực");
      }

      final fetchedSiteCategories = await ApiService().getSiteCategories(token);
      final fetchedAreas = await ApiService().getAllAreas();

      // Debug prints
      debugPrint('Fetched categories: ${fetchedSiteCategories.length}');
      for (var cat in fetchedSiteCategories) {
        debugPrint('Category: ${cat.id} - ${cat.name}');
      }

      setState(() {
        _siteCategories = fetchedSiteCategories;
        _areas = fetchedAreas;

        // Make sure siteCategoryMap is created correctly
        debugPrint('Creating maps...');
        siteCategoryMap = {
          for (var cat in _siteCategories.where((cat) => cat != null))
            cat!.id: cat!.name,
        };
        debugPrint('siteCategoryMap size: ${siteCategoryMap.length}');

        areaMap = {
          for (var area in _areas.where((area) => area != null))
            area!.id: area!.name,
        };
      });
      debugPrint('areaMap size: ${areaMap.length}');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Lỗi khi load data: $e');
      // Thêm xử lý lỗi cụ thể
      if (e is Exception) {
        debugPrint('Exception: $e');
      }
    }
  }

  /// Gọi API lấy danh sách Site, áp dụng filter nếu có
  Future<void> _loadSites() async {
    setState(() {
      isLoading = true;
      sites = [];
    });

    try {
      if (widget.filterSiteId != null) {
        // Nếu có filterSiteId, tìm site theo site id bằng tham số search
        final response = await ApiService().getSites(
          pageNumber: 1, // Chỉ cần trang 1 vì tìm theo id
          pageSize: 1, // Chỉ cần 1 kết quả
          search: widget.filterSiteId.toString(), // Tìm theo site id
          status: selectedStatusId,
        );

        final fetchedSites = List<Site>.from(
          response['listData'].map((item) => Site.fromJson(item)),
        );

        setState(() {
          sites = fetchedSites;
          totalRecords = fetchedSites.length; // Số lượng site tìm được
          totalPages = 1; // Chỉ hiển thị 1 trang khi lọc
        });
      } else {
        // Nếu không có filterSiteId, hiển thị bình thường với phân trang
        final response = await ApiService().getSites(
          pageNumber: currentPage,
          pageSize: pageSize,
          search: null,
          status: selectedStatusId,
        );

        final fetchedSites = List<Site>.from(
          response['listData'].map((item) => Site.fromJson(item)),
        );

        List<Site> filteredSites = fetchedSites;
        if (selectedCategoryId != 0) {
          filteredSites =
              fetchedSites
                  .where((site) => site.siteCategoryId == selectedCategoryId)
                  .toList();
        }

        setState(() {
          sites = filteredSites;
          totalRecords = response['totalRecords']; // Lấy từ API
          totalPages = response['totalPage']; // Lấy từ API
        });
      }
    } catch (e) {
      print('Error loading sites: $e');
      setState(() {
        sites = [];
        totalRecords = 0;
        totalPages = 1;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onFilterChanged(int? categoryId, int? status) {
    debugPrint('Filter changed - Category: $categoryId, Status: $status');
    setState(() {
      selectedCategoryId = categoryId ?? 0;
      selectedStatusId = status;
      currentPage = 1;
    });
    _loadSites();
  }

  @override
  void initState() {
    super.initState();
    _loadData().then((_) {
      _loadSites();
    });
  }

  void _changePage(int page) {
    if (page < 1 || page > totalPages || page == currentPage) return;
    setState(() {
      currentPage = page;
      _loadSites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              currentPage = 1;
              selectedCategoryId = 0;
            });
            _loadSites();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Danh sách mặt bằng',
                        subtitle: 'Quản lý và theo dõi các mặt bằng',
                        icon: LucideIcons.building,
                      ),
                      const SizedBox(height: 24),
                      // Site Category Filter
                      SiteFilterChipPanel(
                            categories: [
                              SiteCategory(
                                id: 0,
                                name: 'Tất cả',
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              ),
                              ..._siteCategories,
                            ],
                            statuses: [1, 2, 3, 4, 5],
                            onFilterChanged: _onFilterChanged,
                            initialSelectedCategoryId: selectedCategoryId,
                            initialSelectedStatus: selectedStatusId,
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
                              'Đang tải mặt bằng...',
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

              // Pagination
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
                "Không có mặt bằng nào phù hợp với bộ lọc",
                style: Theme.of(context).textTheme.titleMedium,
              ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final site = sites[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SiteCard(
            site: site,
            siteCategoryMap: siteCategoryMap,
            areaMap: areaMap,
            onNavigateToTaskTab: widget.onNavigateToTaskTab,
            onTap: () async {
              print('Navigating to site details for site ${site.id}');
              final result = await ViewDetailSite.show(
                context,
                site,
                siteCategoryMap,
                areaMap,
                onNavigateToTaskTab: widget.onNavigateToTaskTab,
              );
              if (result == true) {
                await _loadSites();
              }
            },
          ),
        );
      }, childCount: sites.length),
    );
  }
}
