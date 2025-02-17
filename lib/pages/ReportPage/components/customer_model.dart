import 'package:flutter/material.dart';
import 'package:siteplus_mb/utils/ReportPage/age_group_input.dart';

class CustomerModelSection extends StatelessWidget {
  final Map<String, dynamic> reportData;
  final Function(void Function()) setState;
  final ThemeData theme;
  const CustomerModelSection({
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
            'III. Customer Model',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 16),
          Text('Main customer gender:'),
          Row(
            children: [
              Radio(
                value: 'Male',
                groupValue: reportData['customerModel']['gender'],
                onChanged:
                    (value) => setState(
                      () => reportData['customerModel']['gender'] = value,
                    ),
              ),
              Text('Male'),
              Radio(
                value: 'Female',
                groupValue: reportData['customerModel']['gender'],
                onChanged:
                    (value) => setState(
                      () => reportData['customerModel']['gender'] = value,
                    ),
              ),
              Text('Female'),
              Radio(
                value: 'Balanced',
                groupValue: reportData['customerModel']['gender'],
                onChanged:
                    (value) => setState(
                      () => reportData['customerModel']['gender'] = value,
                    ),
              ),
              Text('Balanced'),
            ],
          ),
          SizedBox(height: 16),
          Text('Age groups:'),
          BuildAgeGroupInput(
            label: 'Under 18',
            keyName: 'under18',
            reportData: reportData,
            theme: theme,
          ),
          BuildAgeGroupInput(
            label: '18-30',
            keyName: '18to30',
            reportData: reportData,
            theme: theme,
          ),
          BuildAgeGroupInput(
            label: '31-45',
            keyName: '31to45',
            reportData: reportData,
            theme: theme,
          ),
          BuildAgeGroupInput(
            label: 'Over 45',
            keyName: 'over45',
            reportData: reportData,
            theme: theme,
          ),
          SizedBox(height: 16),
          Text('Average customer income:'),
          DropdownButtonFormField<String>(
            value: reportData['customerModel']['income'],
            items:
                [
                  '<5 million/month',
                  '5-10 million/month',
                  '10-20 million/month',
                  '>20 million/month',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                reportData['customerModel']['income'] = value;
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
                groupValue: reportData['customerModel']['overallRating'],
                onChanged:
                    (value) => setState(
                      () =>
                          reportData['customerModel']['overallRating'] = value,
                    ),
              ),
              Text('Good'),
              Radio(
                value: 'Poor',
                groupValue: reportData['customerModel']['overallRating'],
                onChanged:
                    (value) => setState(
                      () =>
                          reportData['customerModel']['overallRating'] = value,
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
