import 'package:flutter/material.dart';
import 'package:siteplus_mb/utils/ReportPage/info_card.dart';

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
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          InfoCard(
            icon: Icons.lightbulb_outline,
            content: 'Include any other relevant details.',
            backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
            iconColor: Theme.of(context).colorScheme.secondary,
            borderRadius: 20.0,
            padding: EdgeInsets.all(20.0),
          ),
          SizedBox(height: 12.0),
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
