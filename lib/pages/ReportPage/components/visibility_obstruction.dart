import 'package:flutter/material.dart';
import 'package:siteplus_mb/utils/ReportPage/animated_expansion_card.dart';
import 'package:siteplus_mb/utils/ReportPage/info_card.dart';
import 'package:siteplus_mb/utils/ReportPage/rating_buttons.dart';

class VisibilityObstructionSection extends StatefulWidget {
  final Map<String, dynamic> reportData;
  final Function(void Function()) setState;
  final ThemeData theme;
  const VisibilityObstructionSection({
    super.key,
    required this.reportData,
    required this.setState,
    required this.theme,
  });
  @override
  VisibilityObstructionSectionState createState() =>
      VisibilityObstructionSectionState();
}

class VisibilityObstructionSectionState
    extends State<VisibilityObstructionSection> {
  Map<String, dynamic> localVisibilityObstructionData = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    localVisibilityObstructionData = Map<String, dynamic>.from(
      widget.reportData['visibilityAndObstruction'] ?? {},
    );

    final defaultValues = {
      'hasObstruction': false,
      'obstructionType': '',
      'obstructionLevel': '',
      'overallRating': '',
    };

    defaultValues.forEach((key, value) {
      localVisibilityObstructionData.putIfAbsent(key, () => value);
    });
  }

  void _handleRatingSelection(String rating) {
    setState(() {
      localVisibilityObstructionData['overallRating'] = rating;
      widget.setState(() {
        localVisibilityObstructionData = Map<String, dynamic>.from(
          localVisibilityObstructionData,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VI. Visibility and Obstruction',
            style: widget.theme.textTheme.headlineLarge?.copyWith(
              color: widget.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          InfoCard(
            icon: Icons.lightbulb_outline,
            content: 'Check for view obstructions and openness.',
            backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
            iconColor: Theme.of(context).colorScheme.secondary,
            borderRadius: 20.0,
            padding: EdgeInsets.all(20.0),
          ),
          SizedBox(height: 12.0),
          Text(
            'Is there any obstruction?',
            style: widget.theme.textTheme.titleMedium,
          ),
          Row(
            children: [
              Radio(
                value: true,
                groupValue: localVisibilityObstructionData['hasObstruction'],
                onChanged:
                    (value) => setState(
                      () =>
                          localVisibilityObstructionData['hasObstruction'] =
                              value,
                    ),
              ),
              Text('Yes'),
              Radio(
                value: false,
                groupValue: localVisibilityObstructionData['hasObstruction'],
                onChanged:
                    (value) => setState(
                      () =>
                          localVisibilityObstructionData['hasObstruction'] =
                              value,
                    ),
              ),
              Text('No'),
            ],
          ),
          if (localVisibilityObstructionData['hasObstruction'])
            TextFormField(
              decoration: InputDecoration(labelText: 'Type of obstruction'),
              onSaved:
                  (value) =>
                      localVisibilityObstructionData['obstructionType'] = value,
            ),
          SizedBox(height: 16),
          Text('Obstruction level:', style: widget.theme.textTheme.titleMedium),
          DropdownButtonFormField<String>(
            value: localVisibilityObstructionData['obstructionLevel'],
            hint: Text('Select obstruction level'),
            items:
                ['<20%', '20-50%', '50-80%', '>80%'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                localVisibilityObstructionData['obstructionLevel'] = value;
              });
            },
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.block,
                color: widget.theme.colorScheme.primary,
              ), // Icon đồng bộ
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: widget.theme.colorScheme.surfaceVariant,
            ),
          ),
          SizedBox(height: 16),
          AnimatedExpansionCard(
            icon: Icons.star_outline,
            title: 'Overall Rating',
            subtitle:
                localVisibilityObstructionData['overallRating'] ?? 'Not rated',
            theme: widget.theme,
            children: [
              RatingButtons(
                currentRating:
                    localVisibilityObstructionData['overallRating'] ?? '',
                onRatingSelected: _handleRatingSelection,
                theme: widget.theme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
