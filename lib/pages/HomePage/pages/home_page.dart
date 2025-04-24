import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:siteplus_mb/components/SectionHeader.dart';
import 'package:siteplus_mb/pages/HomePage/components/horizontal_site_list.dart';
import 'package:siteplus_mb/pages/HomePage/components/vertical_task_list.dart';
import 'package:siteplus_mb/pages/StatisticsPage/pages/statistics_sumary.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/AreaDistrict/locations_provider.dart';
import 'package:siteplus_mb/utils/HomePage/site_report_provider.dart';
import 'package:siteplus_mb/utils/HomePage/task_statistics_provider.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_category.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/sites_provider.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onNavigateToTaskTab;
  final VoidCallback? onNavigateToSiteTab;
  final void Function(int? filterTaskId)? onNavigateToTaskTabWithFilter;
  final void Function(int? FilterSiteId)? onNavigateToSiteTabWithFilter;

  const HomePage({
    Key? key,
    this.onNavigateToTaskTab,
    this.onNavigateToTaskTabWithFilter,
    this.onNavigateToSiteTabWithFilter,
    this.onNavigateToSiteTab,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final PageController _statsPageController = PageController();
  late AnimationController _animationController;
  List<SiteCategory> _siteCategories = [];
  Map<int, String> siteCategoryMap = {};
  bool isLoading = true;

  Future<void> _loadData() async {
    try {
      final token = await ApiService().getToken();

      if (token == null || token.isEmpty) {
        throw Exception("No authentication token");
      }

      final fetchedSiteCategories = await ApiService().getSiteCategories(token);

      // Debug prints
      debugPrint('Fetched categories: ${fetchedSiteCategories.length}');
      for (var cat in fetchedSiteCategories) {
        debugPrint('Category: ${cat.id} - ${cat.name}');
      }

      setState(() {
        _siteCategories = fetchedSiteCategories;

        // Create maps from category and area data
        debugPrint('Creating maps...');
        siteCategoryMap = {
          // ignore: unnecessary_null_comparison
          for (var cat in _siteCategories.where((cat) => cat != null))
            cat.id: cat.englishName,
        };
        debugPrint('siteCategoryMap size: ${siteCategoryMap.length}');
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading data: $e');
      if (e is Exception) {
        debugPrint('Exception: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    final sitesProvider = Provider.of<SitesProvider>(context, listen: false);
    final locationsProvider = Provider.of<LocationsProvider>(
      context,
      listen: false,
    );
    final taskStatsProvider = Provider.of<TaskStatisticsProvider>(
      context,
      listen: false,
    );
    final siteReportProvider = Provider.of<SiteReportProvider>(
      context,
      listen: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!sitesProvider.hasLoadedOnce) {
        sitesProvider.fetchSites(areaMap: {});
      }
      if (!locationsProvider.hasLoadedOnce) {
        locationsProvider.initialize();
      }
      if (!taskStatsProvider.hasLoadedOnce) {
        taskStatsProvider.fetchTaskStatistics();
      }
      if (!siteReportProvider.hasLoadedOnce) {
        siteReportProvider.fetchSiteReportStatistics();
      }

      // Khởi động animation khi màn hình được load
      _animationController.forward();
    });
    _loadData();
  }

  @override
  void dispose() {
    _statsPageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startEntranceAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Gọi khi route thay đổi hoặc page được push vào stack
    _startEntranceAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          final sitesProvider = Provider.of<SitesProvider>(
            context,
            listen: false,
          );
          final locationsProvider = Provider.of<LocationsProvider>(
            context,
            listen: false,
          );
          final taskStatsProvider = Provider.of<TaskStatisticsProvider>(
            context,
            listen: false,
          );
          final siteReportProvider = Provider.of<SiteReportProvider>(
            context,
            listen: false,
          );

          await Future.wait([
            sitesProvider.fetchSites(areaMap: {}),
            locationsProvider.initialize(),
            taskStatsProvider.refreshTaskStatistics(),
            siteReportProvider.refreshSiteReportStatistics(),
          ]);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(
              child: StatisticsSummary().animate().fadeIn(
                delay: 200.ms,
                duration: 400.ms,
              ),
            ),

            SliverToBoxAdapter(
              child: HorizontalSiteList(
                siteCategoryMap: siteCategoryMap,
                onNavigateToSiteTab: widget.onNavigateToSiteTab,
                onNavigateToSiteTabWithFilter:
                    widget.onNavigateToSiteTabWithFilter,
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Tasks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        if (widget.onNavigateToTaskTab != null) {
                          widget.onNavigateToTaskTab!();
                        }
                      },
                      icon: Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      label: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverToBoxAdapter(
                child: VerticalTaskList(
                      onNavigateToTaskTabWithFilter:
                          widget
                              .onNavigateToTaskTabWithFilter, // Truyền callback
                    )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Home Page',
            subtitle:
                'Welcome! Your impact helps many find the right site — Thank You!',
            icon: LucideIcons.handshake,
          ),
        ],
      ),
    );
  }
}
