import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siteplus_mb/components/detail_popup.dart';
import 'package:siteplus_mb/utils/SiteDeal/site_deal_model.dart';

class ViewDetailSiteDeal extends StatelessWidget {
  final SiteDeal siteDeal;
  final BuildContext parentContext;
  final VoidCallback? onEditDeal;
  final VoidCallback? onViewSite;

  const ViewDetailSiteDeal({
    super.key,
    required this.siteDeal,
    required this.parentContext,
    this.onEditDeal,
    this.onViewSite,
  });

  static Future<bool?> show(
    BuildContext context,
    SiteDeal siteDeal, {
    VoidCallback? onEditDeal,
    VoidCallback? onViewSite,
  }) {
    return DetailPopup.show(
      context: context,
      title: 'Site Deal Details',
      infoSections: ViewDetailSiteDeal(
        siteDeal: siteDeal,
        parentContext: context,
        onEditDeal: onEditDeal,
        onViewSite: onViewSite,
      )._buildInfoSections(context),
      actionButtons: ViewDetailSiteDeal(
        siteDeal: siteDeal,
        parentContext: context,
        onEditDeal: onEditDeal,
        onViewSite: onViewSite,
      )._buildActionButtons(context),
      onClose: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DetailPopup(
      title: 'Site Deal Details',
      infoSections: _buildInfoSections(context),
      actionButtons: _buildActionButtons(context),
      onClose: () => Navigator.of(parentContext).pop(),
    );
  }

  static Widget buildInfoCard({
    required BuildContext context,
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

  static Widget buildInfoRow({
    required BuildContext context,
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

  List<Widget> _buildInfoSections(BuildContext context) {
    return [
      buildInfoCard(
        context: context,
        title: 'Site Deal Information',
        icon: Icons.handshake,
        child: _buildSiteDealInfo(context),
      ),
    ];
  }

  Widget _buildSiteDealInfo(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildInfoRow(
          context: context,
          label: 'ID#',
          value: siteDeal.id.toString(),
          icon: Icons.numbers,
        ),
        const SizedBox(height: 12),
        buildInfoRow(
          context: context,
          label: 'Site ID',
          value: siteDeal.siteId.toString(),
          icon: Icons.location_on,
        ),
        const SizedBox(height: 12),
        buildInfoRow(
          context: context,
          label: 'Proposed Price',
          value: currencyFormat.format(siteDeal.proposedPrice),
          icon: Icons.money,
        ),
        const SizedBox(height: 12),
        buildInfoRow(
          context: context,
          label: 'Lease Term',
          value: siteDeal.leaseTerm,
          icon: Icons.calendar_today,
        ),
        const SizedBox(height: 12),
        buildInfoRow(
          context: context,
          label: 'Deposit',
          value: currencyFormat.format(siteDeal.deposit),
          icon: Icons.account_balance_wallet,
        ),
        const SizedBox(height: 12),
        buildInfoRow(
          context: context,
          label: 'Deposit Month',
          value: siteDeal.depositMonth,
          icon: Icons.calendar_month,
        ),
        const SizedBox(height: 12),
        buildInfoRow(
          context: context,
          label: 'Additional Terms',
          value:
              siteDeal.additionalTerms.isEmpty
                  ? 'N/A'
                  : siteDeal.additionalTerms,
          icon: Icons.notes,
        ),
        const SizedBox(height: 12),
        buildInfoRow(
          context: context,
          label: 'Status',
          value: siteDeal.statusName,
          icon: siteDeal.status == 1 ? Icons.check_circle : Icons.cancel,
          valueColor:
              siteDeal.status == 1
                  ? Colors.green
                  : siteDeal.status == 2
                  ? Colors.red
                  : Colors.grey,
        ),
        const SizedBox(height: 12),
        buildInfoRow(
          context: context,
          label: 'Created At',
          value: DateFormat('dd/MM/yyyy HH:mm').format(siteDeal.createdAt),
          icon: Icons.date_range,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);

    if (siteDeal.status == 0) {
      return Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed:
                  onViewSite != null
                      ? () {
                        print('View Site button pressed');
                        onViewSite!();
                      }
                      : null,
              icon: const Icon(Icons.visibility),
              label: const Text('View Site'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onEditDeal,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Deal'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: theme.colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (siteDeal.status == 1 || siteDeal.status == 2) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
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
              onPressed:
                  onViewSite != null
                      ? () {
                        print('View Site button pressed'); // Thêm log
                        onViewSite!();
                      }
                      : null,
              icon: const Icon(Icons.visibility),
              label: const Text('View Site'),
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
      );
    }
    return const SizedBox.shrink(); // Default case
  }
}
