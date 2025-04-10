import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siteplus_mb/components/SectionHeader.dart';
import 'package:siteplus_mb/components/pagination_component.dart';
import 'package:siteplus_mb/pages/SiteDealPage/components/floating_action_site_deal.dart';
import 'package:siteplus_mb/pages/SiteDealPage/components/site_deal_card.dart';
import 'package:siteplus_mb/pages/SiteDealPage/components/site_deal_filter.dart';
import 'package:siteplus_mb/pages/SiteDealPage/components/view_detail_site_deal.dart';
import 'package:siteplus_mb/pages/SiteDealPage/pages/create_site_deal_dialog.dart';
import 'package:siteplus_mb/pages/SiteDealPage/pages/edit_site_deal_dialog.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/AreaDistrict/locations_provider.dart';
import 'package:siteplus_mb/utils/SiteDeal/site_deal_model.dart';
import 'package:siteplus_mb/utils/SiteDeal/site_deal_provider.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/sites_provider.dart';

class SiteDealViewPage extends StatefulWidget {
  final void Function(int? filterSiteId)? onNavigateToSiteTab;
  const SiteDealViewPage({super.key, this.onNavigateToSiteTab});

  @override
  State<SiteDealViewPage> createState() => _SiteDealViewPageState();
}

class _SiteDealViewPageState extends State<SiteDealViewPage>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<SiteDeal> deals = [];
  List<Area> _areas = [];
  Map<int, String> areaMap = {};
  bool isLoading = true;
  int currentPage = 1;
  int totalPages = 1;
  int pageSize = 5;
  int? userId;
  late AnimationController _animationController;

  String? search;
  int? siteId;
  String? startDate;
  String? endDate;
  String? status;

  List<int> _siteIdsWithDeals = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _loadUserIdAndData();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserIdAndData() async {
    final prefs = await SharedPreferences.getInstance();
    final hintId = prefs.getString('hintId');
    if (hintId != null) {
      setState(() {
        userId = int.tryParse(hintId);
      });
      print('User ID from hint: $userId');
      await _loadData();
    } else {
      setState(() => isLoading = false);
      print('Error: hintId not found in SharedPreferences');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User ID not found')));
    }
  }

  Future<void> _loadData() async {
    try {
      final sitesProvider = Provider.of<SitesProvider>(context, listen: false);
      final siteDealProvider = Provider.of<SiteDealProvider>(
        context,
        listen: false,
      );
      final fetchedAreas = await _apiService.getAllAreas();
      setState(() {
        _areas = fetchedAreas;
        areaMap = {for (var area in _areas) area.id: area.name};
      });
      print('areaMap: $areaMap');
      await sitesProvider.fetchSites(
        pageNumber: 0,
        pageSize: 0,
        areaMap: areaMap,
      );
      print('Sites loaded: ${sitesProvider.sites.map((s) => s.id).toList()}');
      // Load all site deals for the current user
      if (userId != null) {
        await siteDealProvider.fetchAllSiteDeals(userId!);
        print(
          'All site deals loaded: ${siteDealProvider.allSiteDeals.map((d) => d.siteId).toList()}',
        );
      }

      // Load paginated site deals
      await _loadSiteDeals();

      // Update the site IDs with deals
      _updateSiteIdsWithDeals();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading data: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
    }
  }

  Future<void> _loadSiteDeals() async {
    if (userId == null) return;

    setState(() => isLoading = true);
    final result = await _apiService.getSiteDealsByUserId(
      userId: userId!,
      search: search,
      siteId: siteId,
      startDate: startDate,
      endDate: endDate,
      status: status,
      pageNumber: currentPage,
      pageSize: pageSize,
    );

    if (result['success']) {
      setState(() {
        deals =
            (result['data']['data'] as List<dynamic>?)
                ?.map((item) => SiteDeal.fromJson(item))
                .toList() ??
            [];
        final totalRecords =
            result['data']['totalRecords'] as int? ?? deals.length;
        totalPages = (totalRecords / pageSize).ceil();
        isLoading = false;
        print(
          'Total Records: $totalRecords, Total Pages: $totalPages, Deals: ${deals.length}',
        );
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to load deals')),
      );
    }
  }

  void _updateSiteIdsWithDeals() {
    final siteDealProvider = Provider.of<SiteDealProvider>(
      context,
      listen: false,
    );
    final sitesProvider = Provider.of<SitesProvider>(context, listen: false);
    final siteIdsFromDeals =
        siteDealProvider.allSiteDeals.map((deal) => deal.siteId).toSet();
    print(
      'siteDeal ID from allSiteDeals: ${siteDealProvider.allSiteDeals.map((deal) => deal.id).toList()}',
    );
    print(
      'siteIds from allSiteDeals: ${siteDealProvider.allSiteDeals.map((deal) => deal.siteId).toList()}',
    );
    print(
      'siteIds from sitesProvider: ${sitesProvider.sites.map((site) => site.id).toList()}',
    );
    setState(() {
      _siteIdsWithDeals =
          sitesProvider.sites
              .where((site) => siteIdsFromDeals.contains(site.id))
              .map((site) => site.id)
              .toList();
    });
  }

  void _showFilterPopup() {
    final siteDealProvider = Provider.of<SiteDealProvider>(
      context,
      listen: false,
    );
    if (siteDealProvider.isLoadingAll) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang tải dữ liệu site deals...')),
      );
      return;
    }
    if (siteDealProvider.allSiteDeals.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không có site deals nào')));
      return;
    }
    if (areaMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dữ liệu khu vực chưa sẵn sàng')),
      );
      return;
    }
    print('Opening filter with siteId: $siteId, status: $status');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SiteDealFilter(
            areaMap: areaMap,
            siteIdsWithDeals: _siteIdsWithDeals,
            search: search,
            siteId: siteId,
            startDate: startDate,
            endDate: endDate,
            status: status,
            onApply: (filters) {
              setState(() {
                search = filters['search'];
                siteId = filters['siteId'];
                startDate = filters['startDate'];
                endDate = filters['endDate'];
                status = filters['status'];
                currentPage = 1;
              });
              _loadSiteDeals();
            },
          ),
    );
  }

  VoidCallback? onEditDeal(int siteDealId) {
    return () async {
      Navigator.pop(context);
      final result = await EditSiteDealDialog.show(context, siteDealId);
      if (result == true) {
        await _loadSiteDeals(); // Làm mới danh sách
      }
    };
  }

  void _changePage(int page) {
    if (page < 1 || page > totalPages || page == currentPage) return;
    setState(() => currentPage = page);
    _loadSiteDeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: _buildMainContent().animate().fadeIn(
          duration: 800.ms,
          curve: Curves.easeOut,
        ),
      ),
      floatingActionButton: FloatingActionSiteDeal(
        onCreateSiteDeal: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => const CreateSiteDealDialog(),
          );
          if (result == true) {
            setState(() => currentPage = 1);
            await _loadSiteDeals();
            _updateSiteIdsWithDeals(); // Cập nhật lại sau khi tạo mới
          }
        },
        onShowFilter: _showFilterPopup,
      ),
    );
  }

  Widget _buildMainContent() {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => currentPage = 1);
        await _loadSiteDeals();
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Site Deals List',
                    subtitle: 'Manage and track your site deals',
                    icon: LucideIcons.handshake,
                  ),
                  const SizedBox(height: 24),
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
                    const SizedBox(height: 16),
                    Text('Loading deals...', style: theme.textTheme.bodyLarge)
                        .animate(onPlay: (controller) => controller.repeat())
                        .fadeIn(duration: 1000.ms)
                        .then()
                        .fadeOut(duration: 1000.ms),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              sliver: _buildDealList(),
            ),
          if (!isLoading && deals.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
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
    );
  }

  Widget _buildDealList() {
    if (deals.isEmpty) {
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
                'No deals found',
                style: Theme.of(context).textTheme.titleMedium,
              ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
            ],
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final deal = deals[index];
        final delayMs = 100 + (index * 100);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SiteDealCard(
                deal: deal,
                onTap: () async {
                  await ViewDetailSiteDeal.show(
                    context,
                    deal,
                    onViewSite: () {
                      if (widget.onNavigateToSiteTab != null) {
                        widget.onNavigateToSiteTab!(deal.siteId);
                      }
                      Navigator.of(context).pop();
                    },
                    onEditDeal: onEditDeal(deal.id),
                  );
                },
              )
              .animate()
              .fadeIn(
                duration: 600.ms,
                delay: Duration(milliseconds: delayMs),
                curve: Curves.easeOutQuad,
              )
              .slideY(
                begin: 0.2,
                end: 0,
                duration: 600.ms,
                delay: Duration(milliseconds: delayMs),
                curve: Curves.easeOutQuad,
              )
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1, 1),
                duration: 600.ms,
                delay: Duration(milliseconds: delayMs),
                curve: Curves.easeOutQuad,
              ),
        );
      }, childCount: deals.length),
    );
  }
}
