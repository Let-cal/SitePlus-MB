import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/components/SectionHeader.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/site_card.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/site_filter_chip.dart';
import 'package:siteplus_mb/pages/TaskPage/components/pagination_component.dart';
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

  // Mock site categories
  final List<SiteCategory> _siteCategories = [
    SiteCategory(
      id: 1,
      name: 'Mặt bằng trống',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    SiteCategory(
      id: 2,
      name: 'Mặt bằng nội khu',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    SiteCategory(
      id: 3,
      name: 'Mặt bằng ngoài trời',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  // Mock sites data
  List<Site> _generateMockSites() {
    return [
      Site(
        id: 1,
        siteCategoryId: 1,
        siteCategory: _siteCategories[0],
        address: '123 Đường Nguyễn Văn Cừ, Quận 5, TP.HCM',
        size: 120.5,
        status: 4,
        statusName: 'Sẵn sàng',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
        areaId: 1,
        matchingSites: [],
      ),
      Site(
        id: 2,
        siteCategoryId: 2,
        siteCategory: _siteCategories[1],
        address: 'Tòa nhà ABC, Tầng 3, 456 Cách Mạng Tháng 8, Quận 3, TP.HCM',
        size: 80.0,
        status: 2,
        statusName: 'Đang sử dụng',
        buildingId: 1,
        building: Building(
          id: 1,
          name: 'Tòa nhà ABC',
          areaId: 1,
          area: Area(
            id: 1,
            name: 'Quận 3',
            districtId: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          status: 1,
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
          updatedAt: DateTime.now(),
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
        areaId: 1,
        matchingSites: [],
      ),
      Site(
        id: 3,
        siteCategoryId: 3,
        siteCategory: _siteCategories[2],
        address: 'Sân vận động Quốc Gia, Quận Bình Thạnh, TP.HCM',
        size: 500.0,
        status: 4,
        statusName: 'Sẵn sàng',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
        areaId: 2,
        matchingSites: [],
      ),
      Site(
        id: 4,
        siteCategoryId: 2,
        siteCategory: _siteCategories[1],
        address:
            'Tòa nhà XYZ, Tầng 5, 789 Điện Biên Phủ, Quận Bình Thạnh, TP.HCM',
        size: 95.5,
        status: 3,
        statusName: 'Ngừng hoạt động',
        buildingId: 2,
        building: Building(
          id: 2,
          name: 'Tòa nhà XYZ',
          areaId: 2,
          area: Area(
            id: 2,
            name: 'Quận Bình Thạnh',
            districtId: 2,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          status: 2,
          createdAt: DateTime.now().subtract(const Duration(days: 500)),
          updatedAt: DateTime.now(),
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        areaId: 2,
        matchingSites: [],
      ),
    ];
  }

  void _onFilterChanged(int? categoryId, int? status) {
    setState(() {
      // Update filter states
      selectedCategoryId = categoryId ?? 0;
      selectedStatusId = status;
      currentPage = 1;
    });
    _loadSites();
  }

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  void _loadSites() {
    setState(() {
      isLoading = true;

      // Get all mock sites
      var filteredSites = _generateMockSites();

      // Filter by category if a category is selected
      if (selectedCategoryId != 0) {
        filteredSites =
            filteredSites
                .where((site) => site.siteCategoryId == selectedCategoryId)
                .toList();
      }

      // Filter by status if a status is selected
      if (selectedStatusId != null) {
        filteredSites =
            filteredSites
                .where((site) => site.status == selectedStatusId)
                .toList();
      }

      sites = filteredSites;

      // Update pagination
      totalRecords = sites.length;
      totalPages = (totalRecords / pageSize).ceil();

      isLoading = false;
    });
  }

  void _onCategorySelected(int categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      currentPage = 1;
    });
    _loadSites();
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
                            statuses: [1, 2, 3, 4], // All possible status codes
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
            onTap: () {
              // TODO: Implement site detail navigation
              print('Navigating to site details for site ${site.id}');
            },
          ),
        );
      }, childCount: sites.length),
    );
  }
}
