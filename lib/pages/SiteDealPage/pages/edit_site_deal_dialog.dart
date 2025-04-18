import 'package:flutter/material.dart';
import 'package:siteplus_mb/pages/ReportPage/components/site_deal_confirmation_dialog.dart';
import 'package:siteplus_mb/pages/ReportPage/pages/deal_section.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/SiteDeal/site_deal_model.dart';

class EditSiteDealDialog extends StatefulWidget {
  final SiteDeal siteDeal;

  const EditSiteDealDialog({super.key, required this.siteDeal});

  static Future<bool?> show(BuildContext context, int siteDealId) async {
    print('siteDealId in EditSiteDealDialog.show: $siteDealId');
    final apiService = ApiService();
    final siteDealData = await apiService.getSiteDealById(siteDealId);
    print('siteDealData from API: $siteDealData'); // Thêm log để kiểm tra
    if (siteDealData['success']) {
      final siteDeal = SiteDeal.fromJson(siteDealData['data']);
      print('Parsed siteDeal: ${siteDeal.toJson()}'); // Thêm log để kiểm tra
      return showDialog<bool>(
        context: context,
        builder: (context) => EditSiteDealDialog(siteDeal: siteDeal),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            siteDealData['message'] ?? 'Không thể tải thông tin Site Deal',
          ),
        ),
      );
      return null;
    }
  }

  @override
  State<EditSiteDealDialog> createState() => _EditSiteDealDialogState();
}

class _EditSiteDealDialogState extends State<EditSiteDealDialog> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  Map<String, dynamic> dealData = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Điền dữ liệu ban đầu từ siteDeal vào dealData
    dealData = {
      'proposedPrice': widget.siteDeal.proposedPrice.toString(),
      'leaseTerm': widget.siteDeal.leaseTerm,
      'deposit': widget.siteDeal.deposit.toString(),
      'depositMonth': widget.siteDeal.depositMonth,
      'additionalTerms': widget.siteDeal.additionalTerms,
      'status': widget.siteDeal.status,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    print('dealData in EditSiteDealDialog: $dealData');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 4,
      backgroundColor: theme.colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.all(0),
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(theme),
                const Divider(height: 1, thickness: 1),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: DealSection(
                    dealData: dealData,
                    setState: setState,
                    theme: theme,
                    useSmallText: true,
                    useNewUI: true,
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionButtons(theme),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_rounded,
                size: 28,
                color: theme.colorScheme.onPrimary,
              ),
              const SizedBox(width: 12),
              Text(
                'Edit Site Deal',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                foregroundColor:
                    theme.colorScheme.primary, // Màu khi hover/click
              ),
              child: const Text('Close'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2, // Thêm bóng đổ nhẹ
              ),
              child: const Text('Update'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isSubmitting = true);

      try {
        // Gọi API để lấy danh sách Site Deal của site
        final siteDeals = await _apiService.getSiteDealBySiteId(
          widget.siteDeal.siteId,
        );

        // Lọc các Site Deal có status == 0, ngoại trừ Site Deal đang được chỉnh sửa
        final pendingDeals =
            siteDeals
                .where(
                  (deal) =>
                      deal['status'] == 0 && deal['id'] != widget.siteDeal.id,
                )
                .toList();

        if (pendingDeals.isNotEmpty) {
          // Hiển thị SiteDealConfirmationDialog nếu có Site Deal chờ phê duyệt khác
          await showDialog<bool>(
            context: context,
            builder:
                (context) => SiteDealConfirmationDialog(
                  siteDeal:
                      pendingDeals
                          .first, // Hiển thị một trong các Site Deal chờ phê duyệt
                  siteId: widget.siteDeal.siteId,
                  siteCategoryId: 0, // Có thể cần điều chỉnh nếu có thông tin
                  fromEdit: true, // Đánh dấu dialog mở từ EditSiteDealDialog
                ),
          );
          setState(() => _isSubmitting = false);
          return; // Không tiếp tục cập nhật nếu có Site Deal chờ phê duyệt
        } else {
          // Hiển thị popup xác nhận nếu không có Site Deal chờ phê duyệt
          final confirmUpdate = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Confirmation'),
                  content: const Text(
                    'You are about to set this site deal to pending approval status. Are you sure?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
          );

          if (confirmUpdate != true) {
            setState(() => _isSubmitting = false);
            return; // Thoát nếu người dùng không đồng ý
          }
        }

        // Cập nhật Site Deal với status == 0
        dealData['status'] = 0;
        final success = await _apiService.updateSiteDeal(
          widget.siteDeal.id,
          dealData,
        );

        if (success) {
          Navigator.pop(
            context,
            true,
          ); // Đóng dialog và trả về kết quả thành công
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update Site Deal')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
