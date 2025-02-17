import 'package:flutter/material.dart';

class ConvenienceSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VII. Convenience',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 16),
          Text('Site terrain:'),
          DropdownButtonFormField<String>(
            value: reportData['convenience']['terrain'],
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
                reportData['convenience']['terrain'] = value;
              });
            },
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 16),
          Text('Accessibility:'),
          DropdownButtonFormField<String>(
            value: reportData['convenience']['accessibility'],
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
                reportData['convenience']['accessibility'] = value;
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
                groupValue: reportData['convenience']['overallRating'],
                onChanged:
                    (value) => setState(
                      () => reportData['convenience']['overallRating'] = value,
                    ),
              ),
              Text('Good'),
              Radio(
                value: 'Poor',
                groupValue: reportData['convenience']['overallRating'],
                onChanged:
                    (value) => setState(
                      () => reportData['convenience']['overallRating'] = value,
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
