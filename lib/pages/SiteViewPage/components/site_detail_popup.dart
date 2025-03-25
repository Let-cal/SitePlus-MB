import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/pages/ReportPage/pages/report_create_dialog.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/ImageComponents/image_upload_dialog_ui.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_status.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_view_model.dart';

class ViewDetailSite extends StatelessWidget {
  final Site site;
  final Map<int, String> siteCategoryMap;
  final VoidCallback? onTap;
  final Map<int, String> areaMap;
  final BuildContext parentContext;
  const ViewDetailSite({
    super.key,
    this.onTap,
    required this.site,
    required this.siteCategoryMap,
    required this.areaMap,
    required this.parentContext,
  });

  static Future<void> show(
    BuildContext context,
    Site site,
    Map<int, String> siteCategoryMap,
    Map<int, String> areaMap,
  ) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ViewDetailSite(
            site: site,
            siteCategoryMap: siteCategoryMap,
            areaMap: areaMap,
            parentContext: context,
          ),
    );
  }

  Future<void> handleImageUpload(BuildContext) async {
    final siteId = site.id;
    final buildingId = site.building?.id;

    final selectedImages = await ImageUploadDialogUI.show(
      BuildContext,
      siteId: siteId,
      buildingId: buildingId,
      loadExistingImages: true,
    );

    if (selectedImages != null && selectedImages.isNotEmpty) {
      ScaffoldMessenger.of(BuildContext).showSnackBar(
        SnackBar(
          content: Text('Đã tải lên ${selectedImages.length} ảnh thành công!'),
          backgroundColor: Theme.of(BuildContext).colorScheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
          height: size.height * 0.85,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildSiteTitle(context),
                      const SizedBox(height: 24),
                      _buildInfoCard(
                        context,
                        title: 'Thông Tin Mặt Bằng',
                        icon: LucideIcons.landmark,
                        child: _buildSiteInfo(context),
                      ),
                      if (site.building != null) ...[
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          context,
                          title: 'Thông Tin Tòa Nhà',
                          icon: Icons.business,
                          child: _buildBuildingInfo(context),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        context,
                        title: 'Thông Tin Nhiệm Vụ',
                        icon: LucideIcons.clipboardList,
                        child: _buildTaskInfo(context),
                      ),
                      const SizedBox(height: 24),
                      _buildActionButtons(context),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slide(
          duration: 400.ms,
          begin: const Offset(0, 0.1),
          end: Offset.zero,
          curve: Curves.easeOutQuad,
        );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Chi Tiết Mặt Bằng',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSiteTitle(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ID#: ',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            Text(
              site.id.toString(),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            _buildStatusBadge(context),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          site.address ?? 'N/A',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildSiteInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context,
          label: 'Diện tích',
          value: '${site.size} m²',
          icon: LucideIcons.ruler,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          label: 'Tầng',
          value: site.floor.toString(),
          icon: Icons.layers,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          label: 'Loại Mặt Bằng',
          value: siteCategoryMap[site.siteCategoryId] ?? 'N/A',
          icon: Icons.category,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          label: 'Trạng Thái',
          value: getVietnameseStatus(site.status),
          icon: getStatusIcon(site.status),
          valueColor: getStatusColor(context, site.status),
        ),
      ],
    );
  }

  Widget _buildBuildingInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context,
          label: 'Tên Tòa Nhà',
          value: site.building?.name ?? 'N/A',
          icon: Icons.business,
        ),
        if (site.building?.areaId != null) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            label: 'Khu Vực',
            value: areaMap[site.building!.areaId] ?? 'N/A',
            icon: Icons.map,
          ),
        ],
      ],
    );
  }

  Widget _buildTaskInfo(BuildContext context) {
    Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context,
          label: 'Nhiệm Vụ',
          value: 'ID: #${site.task?.id}',
          icon: LucideIcons.file,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          label: 'Tên Nhiệm Vụ',
          value: site.task?.name ?? 'N/A',
          icon: Icons.file_copy_sharp,
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
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
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final theme = Theme.of(context);
    final status = getVietnameseStatus(site.status);
    final color = getStatusColor(context, site.status);
    final icon = getStatusIcon(site.status);
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              status,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);

    void _navigateToReportCreate({bool isEditMode = false}) {
      String reportTypeValue;
      if (site.siteCategoryId == 2) {
        reportTypeValue = "Commercial";
      } else {
        reportTypeValue = "Building";
      }

      // Sử dụng pushReplacement để thay thế bottom sheet bằng ReportCreateDialog
      Navigator.of(parentContext).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder:
              (context, animation, secondaryAnimation) => ReportCreateDialog(
                reportType: reportTypeValue,
                siteCategory: siteCategoryMap[site.siteCategoryId] ?? 'Unknown',
                siteCategoryId: site.siteCategoryId,
                siteId: site.id,
                taskId: site.task?.id,
                isEditMode: isEditMode,
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var fadeTween = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeInOut));
            var slideTween = Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeInOut));

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: SlideTransition(
                position: animation.drive(slideTween),
                child: child,
              ),
            );
          },
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  if (site.status == 2) {
                    // Create report mode
                    _navigateToReportCreate(isEditMode: false);
                  } else if (site.status == 5) {
                    _navigateToReportCreate(isEditMode: true);
                    // Navigator.of(context).pop();
                  } else {
                    // Edit report mode
                    _navigateToReportCreate(isEditMode: true);
                  }
                },
                icon: Icon(
                  site.status == 2
                      ? Icons.edit
                      : site.status == 5
                      ? Icons.check
                      : Icons.create,
                ),
                label: Text(
                  site.status == 2
                      ? 'Tạo báo cáo'
                      : site.status == 5
                      ? 'Xác nhận'
                      : 'Sửa báo cáo',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                label: const Text('Đóng'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: theme.colorScheme.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => handleImageUpload(context),
                icon: const Icon(Icons.image),
                label: const Text('Tải ảnh'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: theme.colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Hành động này là điền thông tin mặt bằng. Sau khi điền xong, bạn có thể tạo báo cáo và gửi lên quản lý.',
          textAlign: TextAlign.center,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
        ),
      ],
    );
  }
}
