import 'package:flutter/material.dart';

class RatingSelection extends StatelessWidget {
  final String selectedRating;
  final Function(String?) onChanged;
  final ThemeData theme;

  const RatingSelection({
    Key? key,
    required this.selectedRating,
    required this.onChanged,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overall Rating:', style: theme.textTheme.titleMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: ['Good', 'Average', 'Poor'].map((rating) {
            return Row(
              children: [
                Radio<String>(
                  value: rating,
                  groupValue: selectedRating,
                  onChanged: onChanged,
                ),
                Text(rating, style: theme.textTheme.bodyLarge),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
