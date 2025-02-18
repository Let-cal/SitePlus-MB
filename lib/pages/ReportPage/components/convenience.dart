import 'package:flutter/material.dart';
import 'package:siteplus_mb/utils/ReportPage/animated_expansion_card.dart';
import 'package:siteplus_mb/utils/ReportPage/info_card.dart';
import 'package:siteplus_mb/utils/ReportPage/rating_buttons.dart';

class ConvenienceSection extends StatefulWidget {
  final Map<String, dynamic> reportData;
  final Function(void Function()) setState;
  final ThemeData theme;
  const ConvenienceSection({
    Key? key,
    required this.reportData,
    required this.setState,
    required this.theme,
  }) : super(key: key);

  @override
  ConvenienceSectionState createState() => ConvenienceSectionState();
}

class ConvenienceSectionState extends State<ConvenienceSection> {
  late Map<String, dynamic> localConvenienceData;
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    localConvenienceData = Map<String, dynamic>.from(
      widget.reportData['convenience'] ?? {},
    );

    final defaultValues = {
      'terrain': '',
      'accessibility': '',
      'overallRating': '',
    };

    defaultValues.forEach((key, value) {
      localConvenienceData.putIfAbsent(key, () => value);
    });
  }

  void _handleRatingSelection(String rating) {
    setState(() {
      localConvenienceData['overallRating'] = rating;
      widget.setState(() {
        widget.reportData['convenience'] = Map<String, dynamic>.from(
          localConvenienceData,
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
            'VII. Convenience',
            style: widget.theme.textTheme.headlineLarge?.copyWith(
              color: widget.theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 16),
          InfoCard(
            icon: Icons.lightbulb_outline,
            content: 'Evaluate terrain and ease of entry.',
            backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
            iconColor: Theme.of(context).colorScheme.secondary,
            borderRadius: 20.0,
            padding: EdgeInsets.all(20.0),
          ),
          SizedBox(height: 12.0),
          Text('Site terrain:', style: widget.theme.textTheme.titleMedium),
          DropdownButtonFormField<String>(
            value: localConvenienceData['terrain'],
            hint: Text('Select site terrain range'),
            items:
                [
                  'Flat',
                  'Higher than sidewalk',
                  'Lower than sidewalk',
                  'Sloped',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                localConvenienceData['terrain'] = value;
              });
            },
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.landscape,
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
          Text('Accessibility:', style: widget.theme.textTheme.titleMedium),
          DropdownButtonFormField<String>(
            value: localConvenienceData['accessibility'],
            hint: Text('Select accessibility range'),
            items:
                ['Convenient', 'Slightly difficult', 'Hard to access'].map((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                localConvenienceData['accessibility'] = value;
              });
            },
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.route,
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
            subtitle: localConvenienceData['overallRating'] ?? 'Not rated',
            theme: widget.theme,
            children: [
              RatingButtons(
                currentRating: localConvenienceData['overallRating'] ?? '',
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
