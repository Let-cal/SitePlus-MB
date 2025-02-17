import 'package:flutter/material.dart';
import 'package:siteplus_mb/utils/ReportPage/custom_input_field.dart';

class SiteAreaSection extends StatelessWidget {
  final Map<String, dynamic> reportData;
  final Function(void Function()) setState;
  final ThemeData theme;
  const SiteAreaSection({
    Key? key,
    required this.reportData,
    required this.setState,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IV. Site Area',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 16),
          CustomInputField(
            label: 'Total area (m²)',
            icon: Icons.area_chart,
            theme: theme,
            onSaved:
                (value) =>
                    reportData['siteArea']['totalArea'] = int.parse(value),
          ),
          SizedBox(height: 16),
          Text('Site shape:'),
          DropdownButtonFormField<String>(
            value: reportData['siteArea']['shape'],
            items:
                ['Square', 'Long and narrow', 'L-shaped', 'Other'].map((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                reportData['siteArea']['shape'] = value;
              });
            },
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 16),
          Text('Site condition:'),
          DropdownButtonFormField<String>(
            value: reportData['siteArea']['condition'],
            items:
                [
                  'Finished',
                  'Under construction',
                  'Needs minor repairs',
                  'Needs major repairs',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                reportData['siteArea']['condition'] = value;
              });
            },
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 16),
          Text('Overall rating:'),
          Row(
            children: [
              Radio(
                value: 'Good',
                groupValue: reportData['siteArea']['overallRating'],
                onChanged:
                    (value) => setState(
                      () => reportData['siteArea']['overallRating'] = value,
                    ),
              ),
              Text('Good'),
              Radio(
                value: 'Poor',
                groupValue: reportData['siteArea']['overallRating'],
                onChanged:
                    (value) => setState(
                      () => reportData['siteArea']['overallRating'] = value,
                    ),
              ),
              Text('Poor'),
            ],
          ),
        ],
      ),
    );
  }
}
