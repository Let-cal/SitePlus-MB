import 'package:flutter/material.dart';

class RatingButtons extends StatelessWidget {
  final String currentRating;
  final Function(String) onRatingSelected;
  final ThemeData theme;

  const RatingButtons({
    super.key,
    required this.currentRating,
    required this.onRatingSelected,
    required this.theme,
  });

  Widget _buildRatingButton(String rating, IconData icon, bool isSelected) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onRatingSelected(rating),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isSelected 
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? theme.colorScheme.primary
                    : theme.dividerColor,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected 
                      ? theme.colorScheme.primary
                      : theme.iconTheme.color,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  rating,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected 
                        ? theme.colorScheme.primary
                        : theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildRatingButton('Good', Icons.thumb_up_outlined, currentRating == 'Good'),
        const SizedBox(width: 16),
        _buildRatingButton('Poor', Icons.thumb_down_outlined, currentRating == 'Poor'),
      ],
    );
  }
}