import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_status.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_view_model.dart'
    as SiteModels;

class SiteCard extends StatelessWidget {
  final SiteModels.Site site;
  final Map<int, String> siteCategoryMap;
  final Map<int, String> areaMap;
  final VoidCallback? onTap;
  final void Function(int? filterTaskId)? onNavigateToTaskTab;

  const SiteCard({
    super.key,
    required this.site,
    required this.siteCategoryMap,
    required this.areaMap,
    this.onTap,
    this.onNavigateToTaskTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get the area name from the areaMap
    final areaName =
        site.building != null
            ? areaMap[site.building!.areaId] ?? 'N/A'
            : areaMap[site.areaId] ?? 'N/A';

    // Get the first image URL from site images if available
    final imageUrl =
        site.images != null && site.images!.isNotEmpty
            ? site.images![0].url
            : null;

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize:
                MainAxisSize
                    .min, // Đảm bảo column chỉ chiếm không gian cần thiết
            children: [
              // Site Image
              AspectRatio(
                aspectRatio: 1.5,
                child: Stack(
                  children: [
                    imageUrl != null
                        ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: theme.colorScheme.surfaceVariant,
                              child: Center(
                                child: Icon(
                                  LucideIcons.image,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: theme.colorScheme.surfaceVariant,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              ),
                            );
                          },
                        )
                        : Container(
                          color: theme.colorScheme.surfaceVariant,
                          child: Center(
                            child: Icon(
                              LucideIcons.landmark,
                              size: 36,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.5),
                            ),
                          ),
                        ),
                    // Status Badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: getStatusColor(context, site.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              getStatusIcon(site.status),
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              getStatusText(site.status),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize:
                        MainAxisSize
                            .min, // Quan trọng: chỉ lấy không gian cần thiết
                    children: [
                      // Site ID and Category - Kết hợp thành một hàng
                      Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        siteCategoryMap[site.siteCategoryId] ??
                                        'N/A',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  TextSpan(
                                    text: ' MB#${site.id}',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.7),
                                        ),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (site.building != null)
                        // Area
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              LucideIcons.map,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                areaName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),

                      // Address
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            LucideIcons.mapPin,
                            size: 14,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              site.address,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.8,
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }
}
