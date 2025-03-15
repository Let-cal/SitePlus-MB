import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/components/SectionHeader.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/site_card.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/site_filter_chip.dart';
import 'package:siteplus_mb/pages/TaskPage/components/pagination_component.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/AreaDistrict/locations_provider.dart';
import 'package:siteplus_mb/utils/Site/site_category.dart';
import 'package:siteplus_mb/utils/Site/site_model.dart';

class SiteViewPage extends StatefulWidget {
  const SiteViewPage({super.key});

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
        debugPrint('Category: ${cat?.id} - ${cat?.name}');
      }

      setState(() {
        _siteCategories = fetchedSiteCategories;
        _areas = fetchedAreas;

        // Make sure siteCategoryMap is created correctly
        debugPrint('Creating maps...');
        siteCategoryMap = Map.fromIterable(
          _siteCategories.where((cat) => cat != null),
          key: (cat) => cat!.id,
          value: (cat) => cat!.name,
        );
        debugPrint('siteCategoryMap size: ${siteCategoryMap.length}');

        areaMap = Map.fromIterable(
          _areas.where((area) => area != null),
          key: (area) => area!.id,
          value: (area) => area!.name,
        );
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
    });
    try {
      final fetchedSites = await ApiService().getSites(
        pageNumber: currentPage,
        pageSize: pageSize,
        search: null,
        status: selectedStatusId,
      );

      // Nếu có filter theo site category (id khác 0), lọc danh sách
      List<Site> filteredSites = fetchedSites;
      if (selectedCategoryId != 0) {
        filteredSites =
            fetchedSites
                .where((site) => site.siteCategoryId == selectedCategoryId)
                .toList();
      }

      setState(() {
        sites = filteredSites;
        totalRecords = sites.length;
        totalPages = (totalRecords / pageSize).ceil();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading sites: $e');
    }
  }

  void _onFilterChanged(int? categoryId, int? status) {
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
            onTap: () {
              print('Navigating to site details for site ${site.id}');
            },
          ),
        );
      }, childCount: sites.length),
    );
  }
}
