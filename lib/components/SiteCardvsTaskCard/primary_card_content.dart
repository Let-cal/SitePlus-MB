import 'package:flutter/material.dart';

class PrimaryCardContent extends StatelessWidget {
  final List<FeaturedItem> featuredItems;
  final String? description;
  final Widget? additionalInfo;
  final EdgeInsetsGeometry padding;

  const PrimaryCardContent({
    super.key,
    required this.featuredItems,
    this.description,
    this.additionalInfo,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured Items Row
          _buildFeaturedItemsRow(),

          // Description Text
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Additional Information
          if (additionalInfo != null) ...[
            const SizedBox(height: 16),
            additionalInfo!,
          ],
        ],
      ),
    );
  }

  Widget _buildFeaturedItemsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        featuredItems.length > 2 ? 2 : featuredItems.length,
        (index) {
          final item = featuredItems[index];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index > 0 ? 10 : 0,
                right: index < featuredItems.length - 1 ? 10 : 0,
              ),
              child: item,
            ),
          );
        },
      ),
    );
  }
}

class FeaturedItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final int? flex;
  final bool preventLineBreak;

  const FeaturedItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.flex,
    this.preventLineBreak = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: colorScheme.secondary),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
