import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/utils/Site/site_model.dart';

class SiteCard extends StatelessWidget {
  final Site site;
  final VoidCallback? onTap;
  final VoidCallback? onCreateReport;

  const SiteCard({
    Key? key,
    required this.site,
    this.onTap,
    this.onCreateReport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Site Header
              _buildSiteHeader(context),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  color: colorScheme.onSurface.withOpacity(0.12),
                  thickness: 1,
                ),
              ),

              // Main Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Site Details
                    _buildSiteDetails(context),

                    // Conditional Building Details
                    if (site.siteCategoryId == 2 && site.building != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            'Thông tin tòa nhà',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildBuildingDetails(context),
                        ],
                      ),

                    // Footer
                    const SizedBox(height: 16),
                    _buildCardFooter(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSiteHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Mặt bằng #${site.id}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _getStatusColor(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getVietnameseStatus(site.status),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getStatusColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteDetails(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                context,
                icon: LucideIcons.ruler,
                label: 'Diện tích',
                value: '${site.size} m²',
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                context,
                icon: LucideIcons.layers,
                label: 'Loại',
                value: site.siteCategory.name,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDetailItem(
          context,
          icon: LucideIcons.mapPin,
          label: 'Địa chỉ',
          value: site.address,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildBuildingDetails(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                context,
                icon: LucideIcons.building,
                label: 'Tòa nhà',
                value: site.building!.name,
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                context,
                icon: LucideIcons.mapPin,
                label: 'Khu vực',
                value: site.building!.area.name,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool fullWidth = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.secondary.withOpacity(0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardFooter(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Ngày tạo: ${_formatDate(site.createdAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        // Nếu status là "Đang tiến hành" thì hiển thị nút Tạo báo cáo
        if (site.status == 4)
          ElevatedButton.icon(
            onPressed: onCreateReport,
            icon: const Icon(LucideIcons.file, size: 16),
            label: const Text('Tạo báo cáo'),
            style: ElevatedButton.styleFrom(
              foregroundColor: theme.colorScheme.onPrimary,
              backgroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          )
        else
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
            child: const Text('Chi tiết'),
          ),
      ],
    );
  }

  // Existing helper methods remain the same
  String _getVietnameseStatus(int status) {
    switch (status) {
      case 1:
        return 'Đã chấp nhận';
      case 2:
        return 'Bị từ chối';
      case 3:
        return 'Đã bán';
      case 4:
        return 'Đang tiến hành';
      default:
        return 'Không xác định';
    }
  }

  Color _getStatusColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (site.status) {
      case 1:
        return Colors.green;
      case 2:
        return theme.colorScheme.error;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.orange;
      default:
        return theme.colorScheme.secondary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
