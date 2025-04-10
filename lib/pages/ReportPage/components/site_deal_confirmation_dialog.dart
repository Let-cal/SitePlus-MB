import 'package:flutter/material.dart';
import 'package:siteplus_mb/components/generic_card.dart';
import 'package:siteplus_mb/utils/SiteDeal/site_deal_model.dart';
import 'package:siteplus_mb/utils/SiteDeal/site_deal_status.dart';

class SiteDealConfirmationDialog extends StatelessWidget {
  final Map<String, dynamic> siteDeal;
  final int siteId;
  final int siteCategoryId;

  const SiteDealConfirmationDialog({
    super.key,
    required this.siteDeal,
    required this.siteId,
    required this.siteCategoryId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final siteDealModel = SiteDeal.fromJson(siteDeal);

    return AlertDialog(
      title: const Text('Thông báo'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bạn đang có các site deal sau dành cho site này, bạn có chắc chắn là gửi báo cáo mà không qua bước kiểm tra lại site deal không?',
              ),
              const SizedBox(height: 16),
              _buildSiteDealCard(context, theme, siteDealModel),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Đóng'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Tạo báo cáo'),
        ),
      ],
    );
  }

  Widget _buildSiteDealCard(
    BuildContext context,
    ThemeData theme,
    SiteDeal deal,
  ) {
    final statusName = getSiteDealStatusName(deal.statusName);
    final statusColor = getSiteDealStatusColor(context, statusName);

    // Removed padding constraints to allow the card to expand to full width
    return GenericCard(
      id: deal.id.toString(),
      showSecondaryId: true,
      title: 'Deal',
      description: deal.leaseTerm,
      status: deal.status.toString(),
      statusName: statusName,
      statusColor: statusColor,
      icon: Icons.store,
      additionalInfo: [
        // Modified Row to prevent overflow
        LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First row - Date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        deal.createdAt.toString().substring(0, 10),
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
      onTap: () {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Chi tiết Deal #${deal.id}'),
                content: SingleChildScrollView(
                  child: _buildDealDetails(theme, deal),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
        );
      },
      colorScheme: theme.colorScheme,
    );
  }

  Widget _buildDealDetails(ThemeData theme, SiteDeal deal) {
    String dealType = '';
    String leaseTermInput = '';
    final leaseTerm = deal.leaseTerm;
    if (leaseTerm.contains('Mặt bằng chuyển nhượng')) {
      dealType = 'Mặt bằng chuyển nhượng';
      leaseTermInput = '';
    } else if (leaseTerm.contains('Mặt bằng cho thuê')) {
      dealType = 'Mặt bằng cho thuê';
      leaseTermInput = leaseTerm.replaceFirst(
        'Mặt bằng cho thuê - Thời hạn ',
        '',
      );
    } else {
      dealType = 'Không xác định';
      leaseTermInput = '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thông tin thương lượng',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        _buildDealInfoRow(theme, 'Loại mặt bằng', dealType, Icons.store),
        if (dealType == 'Mặt bằng cho thuê')
          _buildDealInfoRow(
            theme,
            'Thời hạn thuê',
            leaseTermInput,
            Icons.calendar_today,
          ),
        _buildDealInfoRow(
          theme,
          'Giá đề xuất',
          '${deal.proposedPrice.toInt()} VND',
          Icons.money,
        ),
        _buildDealInfoRow(
          theme,
          'Tiền đặt cọc',
          '${deal.deposit.toInt()} VND',
          Icons.account_balance_wallet,
        ),
        _buildDealInfoRow(
          theme,
          'Số tháng đặt cọc',
          deal.depositMonth,
          Icons.calendar_month,
        ),
        _buildDealInfoRow(
          theme,
          'Điều khoản bổ sung',
          deal.additionalTerms.isEmpty ? 'Không có' : deal.additionalTerms,
          Icons.notes,
        ),
      ],
    );
  }

  Widget _buildDealInfoRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
