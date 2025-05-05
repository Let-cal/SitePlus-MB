import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siteplus_mb/pages/ReportPage/pages/site_building_dialog.dart';
import 'package:siteplus_mb/pages/TaskPage/components/location_mapper_component.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/AreaDistrict/locations_provider.dart';
import 'package:siteplus_mb/utils/TaskPage/dead_line_utils.dart';
import 'package:siteplus_mb/utils/TaskPage/task_api_model.dart';
import 'package:siteplus_mb/utils/TaskPage/task_status.dart';
import 'package:siteplus_mb/utils/constants.dart';

import '../../../components/report_selection_dialog.dart';
import '../../../service/navigation_component.dart';

class ViewDetailTask extends StatelessWidget {
  final Task task;
  final BuildContext parentContext;
  final VoidCallback? onUpdateSuccess;
  final void Function(int? filterSiteId)? onNavigateToSiteTab;
  const ViewDetailTask({
    super.key,
    required this.task,
    required this.parentContext,
    this.onUpdateSuccess,
    this.onNavigateToSiteTab,
  });

  // Method to show the bottom sheet
  static Future<bool?> show(
    BuildContext context,
    Task task, {
    VoidCallback? onUpdateSuccess, // Thêm callback vào show
    void Function(int? filterSiteId)? onNavigateToSiteTab,
  }) async {
    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (bottomSheetContext) => ViewDetailTask(
            task: task,
            parentContext: context,
            onUpdateSuccess: onUpdateSuccess,
            onNavigateToSiteTab: onNavigateToSiteTab,
          ),
    );
  }

  void _showReportSelection(BuildContext context) async {
    final rootContext = Navigator.of(context).context;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    if (token.isEmpty) {
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
      final siteBuildingResult = await NavigationComponent.navigateToSiteReport(
        rootContext,
        result['reportType'],
        result['categoryId'],
        result['categoryName'],
        task.id,
        task.areaId,
        task.status,
        task.site?.id,
        Provider.of<LocationsProvider>(rootContext, listen: false),
        onUpdateSuccess: () {
          onUpdateSuccess?.call(); // Gọi callback để reload TasksPage
        },
      );

      if (siteBuildingResult == true) {
        Navigator.of(context).pop(true); // Chỉ pop bottom sheet
      }
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
                      _buildTaskTitle(context),
                      const SizedBox(height: 24),
                      _buildInfoCard(
                        context,
                        title: 'Task Information',
                        icon: Icons.assignment,
                        child: _buildTaskInfo(context),
                      ),
                      const SizedBox(height: 16),
                      if (task.request?.brand != null) ...[
                        _buildInfoCard(
                          context,
                          title: 'Brand Information',
                          icon: Icons.business,
                          child: _buildBrandInfo(context),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (task.site != null) ...[
                        _buildInfoCard(
                          context,
                          title: 'Site Information',
                          icon: Icons.location_on,
                          child: _buildSiteInfo(context),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildLocationMapCard(context),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        context,
                        title: 'Task Description',
                        icon: Icons.description,
                        child: _buildDescription(context),
                      ),
                      const SizedBox(height: 24),
                      _buildActionButtons(context),
                      const SizedBox(height: 32),
                    ],
                  )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slide(
                    duration: 400.ms,
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                    curve: Curves.easeOutQuad,
                  ),
            ),
          ),
        ],
      ),
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
          // Handle bar
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
                  Icon(
                    Icons.article_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Task Details',
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

  Widget _buildTaskTitle(BuildContext context) {
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
              task.id.toString(),
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
          task.name,
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

  Widget _buildTaskInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context,
          label: 'Priority',
          value: task.priority,
          valueColor:
              task.priority.toLowerCase() == PRIORITY_CAO
                  ? theme.colorScheme.error
                  : theme.colorScheme.tertiary,
          icon:
              task.priority.toLowerCase() == PRIORITY_CAO
                  ? Icons.priority_high
                  : Icons.low_priority,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          label: 'Deadline',
          value: _buildDeadlineText(),
          icon: Icons.calendar_today,
          valueColor: _getDeadlineColor(),
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          label: 'Status',
          value: getStatusText(task.status),
          icon: getStatusIcon(task.status),
          valueColor: getStatusColor(context, task.status),
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          label: 'Address',
          value: _getLocationText(),
          icon: Icons.location_on,
        ),
        if (task.request != null) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            label: 'Request ID',
            value: task.requestId ?? 'N/A',
            icon: Icons.numbers,
          ),
        ],
      ],
    );
  }

  String _buildDeadlineText() {
    String text = _formatDate(task.deadline);
    if (task.status != STATUS_HOAN_THANH && task.isDeadlineWarning) {
      String warning = DeadlineUtils.getDeadlineMessage(task.daysToDeadline);
      text += ' - $warning';
    }
    return text;
  }

  Color? _getDeadlineColor() {
    if (task.status != STATUS_HOAN_THANH && task.isDeadlineWarning) {
      return DeadlineUtils.getDeadlineColor(task.daysToDeadline);
    }
    return null;
  }

  Widget _buildBrandInfo(BuildContext context) {
    final brand = task.request?.brand;

    if (brand == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context,
          label: 'Brand Name',
          value: brand.name,
          icon: Icons.business,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSiteInfo(BuildContext context) {
    final site = task.site;
    Map<String, String> parseAddress(String fullAddress) {
      // Giả định địa chỉ có định dạng "[Địa chỉ chi tiết], [Quận], [Thành phố]"
      final parts = fullAddress.split(', ');

      String specificAddress = '';
      String district = '';
      String city = '';

      if (parts.length >= 3) {
        // Trường hợp đầy đủ: "2 Hải Triều, Quận 1, TP.HCM"
        specificAddress = parts[0];
        district = parts[1];
        city = parts[2];
      } else if (parts.length == 2) {
        // Trường hợp thiếu thành phố: "2 Hải Triều, Quận 1"
        specificAddress = parts[0];
        district = parts[1];
        city = "TP.HCM";
      } else if (parts.length == 1) {
        // Trường hợp chỉ có địa chỉ không đầy đủ
        specificAddress = parts[0];
        district = "Quận 1";
        city = "TP.HCM";
      }

      return {
        'specificAddress': specificAddress,
        'district': district,
        'city': city,
      };
    }

    if (site == null) return const SizedBox.shrink();

    // Phân tích địa chỉ để tách thành địa chỉ cụ thể, quận, thành phố
    final addressParts = parseAddress(site.address);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context,
          label: 'ID#:',
          value: site.id.toString(),
          icon: Icons.map,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          label: 'Detailed Address',
          value: addressParts['specificAddress']!,
          icon: Icons.map,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          label: 'District',
          value: addressParts['district']!,
          icon: Icons.location_city,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          label: 'City',
          value: addressParts['city']!,
          icon: Icons.location_on,
        ),
        if (site.building != null) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            label: 'Building',
            value: site.building!.name,
            icon: Icons.business,
          ),
        ],
      ],
    );
  }

  // Thêm phương thức mới để hiển thị card location riêng biệt
  Widget _buildLocationMapCard(BuildContext context) {
    final site = task.site;
    if (site == null) return const SizedBox.shrink();

    Map<String, String> parseAddress(String fullAddress) {
      final parts = fullAddress.split(', ');

      String specificAddress = '';
      String district = '';
      String city = '';

      if (parts.length >= 3) {
        specificAddress = parts[0];
        district = parts[1];
        city = parts[2];
      } else if (parts.length == 2) {
        specificAddress = parts[0];
        district = parts[1];
        city = "TP.HCM";
      } else if (parts.length == 1) {
        specificAddress = parts[0];
        district = "Quận 1";
        city = "TP.HCM";
      }

      return {
        'specificAddress': specificAddress,
        'district': district,
        'city': city,
      };
    }

    final addressParts = parseAddress(site.address);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: LocationMapperComponent(
        specificAddress: addressParts['specificAddress']!,
        district: addressParts['district']!,
        city: addressParts['city']!,
        buildingName: site.building?.name, // Thêm buildingName nếu có
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.description,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            height: 1.5,
          ),
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

  void _showEditReport(BuildContext context) async {
    try {
      if (task.site == null) {
        ScaffoldMessenger.of(
          parentContext,
        ).showSnackBar(SnackBar(content: Text('No site information to edit')));
        return;
      }

      final siteResponse = await ApiService().getSiteById(task.site!.id);
      final siteId = siteResponse['data']['id'];

      Navigator.of(context).pop(); // Đóng bottom sheet

      final result = await Navigator.push(
        parentContext, // Sử dụng parentContext để mở SiteBuildingDialog
        MaterialPageRoute(
          builder:
              (context) => SiteBuildingDialog(
                reportType:
                    siteResponse['data']['siteCategoryId'] == 1
                        ? 'Internal Site'
                        : 'Independent site',
                siteCategoryId: siteResponse['data']['siteCategoryId'],
                areaId: siteResponse['data']['areaId'],
                siteCategory:
                    siteResponse['data']['siteCategoryId'] == 1
                        ? 'Internal Site'
                        : 'Independent site',
                taskId: task.id,
                taskStatus: task.status,
                siteId: siteId,
                onUpdateSuccess: onUpdateSuccess,
              ),
        ),
      );

      print('Result from SiteBuildingDialog: $result');
    } catch (e) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(
          content: Text('Unable to load site information for editing: $e'),
        ),
      );
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    void navigateToSiteDetail() async {
      Navigator.of(context).pop(); // Đóng bottom sheet
      if (onNavigateToSiteTab != null) {
        onNavigateToSiteTab!(task.site?.id); // Gọi callback để chuyển tab
      } else {
        print('Callback onNavigateToSiteTab không được cung cấp');
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child:
                  task.status == STATUS_DA_NHAN
                      ? FilledButton.icon(
                        // Thay OutlinedButton bằng FilledButton cho View Site
                        onPressed: navigateToSiteDetail,
                        icon: const Icon(Icons.visibility),
                        label: const Text('View Site'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: theme.colorScheme.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                      : OutlinedButton.icon(
                        // Giữ nguyên cho các status khác
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        label: const Text('Close'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: theme.colorScheme.outline),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  if (task.status == STATUS_DA_NHAN) {
                    _showEditReport(context);
                  } else if (task.status == STATUS_CHUA_NHAN) {
                    _showReportSelection(context);
                  } else if (task.status == STATUS_CHO_PHE_DUYET ||
                      task.status == STATUS_HOAN_THANH) {
                    navigateToSiteDetail();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                icon: Icon(
                  task.status == STATUS_DA_NHAN ||
                          task.status == STATUS_CHUA_NHAN
                      ? Icons.edit
                      : Icons.visibility,
                ),
                label: Text(
                  task.status == STATUS_DA_NHAN
                      ? 'Edit Report'
                      : task.status == STATUS_CHUA_NHAN
                      ? 'Create Report'
                      : 'View Site',
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
          ],
        ),
        const SizedBox(height: 12),
        if (task.status != STATUS_HOAN_THANH)
          Text(
            'This action involves filling in site information. Once completed, you can create and submit a report to the manager.',
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final theme = Theme.of(context);
    final status = task.status;
    final color = getStatusColor(context, task.status);
    final icon = getStatusIcon(task.status);

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
              getStatusText(status),
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

  String _getLocationText() {
    return task.areaName.isNotEmpty ? task.areaName : 'Quận 1, TP. Hồ Chí Minh';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
