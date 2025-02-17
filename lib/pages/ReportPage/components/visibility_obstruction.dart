import 'package:flutter/material.dart';

class VisibilityObstructionSection extends StatelessWidget {
  final Map<String, dynamic> reportData;
  final Function(void Function()) setState;
  final ThemeData theme;
  const VisibilityObstructionSection({
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
            'VI. Visibility and Obstruction',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 16),
          Text('Is there any obstruction?'),
          Row(
            children: [
              Radio(
                value: true,
                groupValue:
                    reportData['visibilityAndObstruction']['hasObstruction'],
                onChanged:
                    (value) => setState(
                      () =>
                          reportData['visibilityAndObstruction']['hasObstruction'] =
                              value,
                    ),
              ),
              Text('Yes'),
              Radio(
                value: false,
                groupValue:
                    reportData['visibilityAndObstruction']['hasObstruction'],
                onChanged:
                    (value) => setState(
                      () =>
                          reportData['visibilityAndObstruction']['hasObstruction'] =
                              value,
                    ),
              ),
              Text('No'),
            ],
          ),
          if (reportData['visibilityAndObstruction']['hasObstruction'])
            TextFormField(
              decoration: InputDecoration(labelText: 'Type of obstruction'),
              onSaved:
                  (value) =>
                      reportData['visibilityAndObstruction']['obstructionType'] =
                          value,
            ),
          SizedBox(height: 16),
          Text('Obstruction level:'),
          DropdownButtonFormField<String>(
            value: reportData['visibilityAndObstruction']['obstructionLevel'],
            items:
                ['<20%', '20-50%', '50-80%', '>80%'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                reportData['visibilityAndObstruction']['obstructionLevel'] =
                    value;
              });
            },
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}
