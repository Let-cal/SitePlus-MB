// lib/components/generic_card.dart
import 'package:flutter/material.dart';

class GenericCard extends StatelessWidget {
  final String id;
  final String? secondaryId; // Thêm secondaryId (có thể null)
  final bool showSecondaryId; // Điều khiển hiển thị secondaryId
  final String title;
  final String description;
  final String status;
  final String statusName;
  final Color statusColor;
  final IconData icon;
  final List<Widget> additionalInfo;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const GenericCard({
    super.key,
    required this.id,
    this.secondaryId, // Không bắt buộc
    this.showSecondaryId = false, // Mặc định là false
    required this.title,
    required this.description,
    required this.status,
    required this.statusName,
    required this.statusColor,
    required this.icon,
    required this.additionalInfo,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 100,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(icon, color: colorScheme.primary),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$title #$id',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (showSecondaryId && secondaryId != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '(Site #$secondaryId)',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(
                                    0.6,
                                  ), // Ít nổi bật
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description.isNotEmpty
                              ? description
                              : 'Không có thông tin',
                          style: theme.textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        ...additionalInfo,
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusName,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
