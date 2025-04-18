import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:siteplus_mb/utils/AreaDistrict/locations_provider.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_status.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/sites_provider.dart';

class HorizontalSiteList extends StatelessWidget {
  final Map<int, String> siteCategoryMap;
  final VoidCallback? onNavigateToSiteTab;
  final void Function(int? FilterSiteId)? onNavigateToSiteTabWithFilter;

  const HorizontalSiteList({
    super.key,
    required this.siteCategoryMap,
    this.onNavigateToSiteTab,
    this.onNavigateToSiteTabWithFilter,
  });

  @override
  Widget build(BuildContext context) {
    final locationsProvider = Provider.of<LocationsProvider>(
      context,
      listen: false,
    );

    return FutureBuilder(
      future: locationsProvider.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading areas: ${snapshot.error}'));
        }

        return Consumer2<SitesProvider, LocationsProvider>(
          builder: (context, sitesProvider, locationsProvider, child) {
            if (sitesProvider.isLoading ||
                locationsProvider.isLoadingAllAreas) {
              return Center(child: CircularProgressIndicator());
            }
            if (sitesProvider.errorMessage != null) {
              return Center(
                child: Text('Error: ${sitesProvider.errorMessage}'),
              );
            }

            final sites =
                sitesProvider.sites
                    .where((site) => site.images!.isNotEmpty)
                    .toList();
            final areaMap = {
              for (var area in locationsProvider.allAreas) area.id: area.name,
            };

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Featured Sites',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          if (onNavigateToSiteTab != null) {
                            onNavigateToSiteTab!(); // Điều hướng tới SiteViewPage mà không có bộ lọc
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
                ),
                SizedBox(
                  height: 330,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: sites.length,
                    itemBuilder: (context, index) {
                      final site = sites[index];
                      final imageUrl = site.images?.first.url;
                      final areaName = areaMap[site.areaId] ?? 'Unknown';

                      final statusColor = getStatusColor(context, site.status);

                      return GestureDetector(
                        onTap: () {
                          if (onNavigateToSiteTabWithFilter != null) {
                            onNavigateToSiteTabWithFilter!(
                              site.id,
                            ); // Truyền site.id để lọc
                          }
                        },

                        child: Container(
                          width: 300,
                          margin: EdgeInsets.only(right: 16, bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                                children: [
                                  // Background Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      imageUrl ??
                                          'https://via.placeholder.com/300x330',
                                      height: 330,
                                      width: 300,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  // Status Tag
                                  Positioned(
                                    top: 16,
                                    left: 16,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        getStatusText(site.status),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Content Overlay
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(16),
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                            Colors.black.withOpacity(0.9),
                                          ],
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Site Category and ID
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text:
                                                      siteCategoryMap[site
                                                          .siteCategoryId] ??
                                                      'N/A',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: ' MB#${site.id}',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                          SizedBox(height: 8),

                                          // Area Name (Description)
                                          Text(
                                            areaName,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                          SizedBox(height: 16),

                                          // Size
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.straighten,
                                                    size: 18,
                                                    color: Colors.white
                                                        .withOpacity(0.7),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '${site.size.toInt()} m²',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white
                                                          .withOpacity(0.7),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                'Task #${site.task?.id}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                              .animate(delay: (100 * index).ms)
                              .fadeIn(duration: 400.ms)
                              .slideX(begin: 0.2, end: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
