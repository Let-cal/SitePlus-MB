// site_deal_card.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/components/generic_card.dart';
import 'package:siteplus_mb/utils/SiteDeal/site_deal_model.dart';
import 'package:siteplus_mb/utils/SiteDeal/site_deal_status.dart';

class SiteDealCard extends StatelessWidget {
  final SiteDeal deal;
  final VoidCallback onTap;
  final VoidCallback? onEditDeal;
  final VoidCallback? onViewSite;

  const SiteDealCard({
    super.key,
    required this.deal,
    required this.onTap,
    this.onEditDeal,
    this.onViewSite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GenericCard(
      id: deal.id.toString(), // Truy cập trực tiếp deal.id
      secondaryId: deal.siteId.toString(),
      showSecondaryId: true,
      title: 'Deal',
      description: deal.leaseTerm, // Truy cập deal.leaseTerm
      status: deal.status.toString(), // Truy cập deal.status
      statusName: getSiteDealStatusName(
        deal.statusName,
      ), // Truy cập deal.statusName
      statusColor: getSiteDealStatusColor(
        context,
        getSiteDealStatusName(deal.statusName),
      ),
      icon: LucideIcons.handshake,
      additionalInfo: [
        Row(
          children: [
            Icon(LucideIcons.calendar, size: 16, color: colorScheme.onSurface),
            const SizedBox(width: 4),
            Text(
              deal.createdAt.toString().substring(0, 10),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(width: 16),
            Icon(
              LucideIcons.dollarSign,
              size: 16,
              color: colorScheme.onSurface,
            ),
            const SizedBox(width: 4),
            Text('${deal.proposedPrice} VNĐ', style: theme.textTheme.bodySmall),
          ],
        ),
      ],
      onTap: onTap,
      colorScheme: colorScheme,
    );
  }
}
