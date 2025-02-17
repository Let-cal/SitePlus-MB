import 'package:flutter/material.dart';

class AdditionalNotesSection extends StatelessWidget {
  final Map<String, dynamic> reportData;
  final Function(void Function()) setState;
  final ThemeData theme;
  const AdditionalNotesSection({
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
            'VIII. Additional Notes',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Additional Notes',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            onSaved: (value) => reportData['additionalNotes'] = value,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: reportData['hasImages'],
                onChanged: (value) {
                  setState(() {
                    reportData['hasImages'] = value;
                  });
                },
              ),
              Text('Images attached'),
            ],
          ),
        ],
      ),
    );
  }
}
