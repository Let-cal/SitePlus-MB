import 'package:flutter/material.dart';
import 'package:siteplus_mb/utils/ReportPage/age_group_input.dart';
import 'package:siteplus_mb/utils/ReportPage/animated_expansion_card.dart';
import 'package:siteplus_mb/utils/ReportPage/info_card.dart';
import 'package:siteplus_mb/utils/ReportPage/rating_buttons.dart';

class CustomerModelSection extends StatefulWidget {
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
  CustomerModelSectionState createState() => CustomerModelSectionState();
}

class CustomerModelSectionState extends State<CustomerModelSection> {
  late Map<String, dynamic> localCustomerModelData;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    localCustomerModelData = Map<String, dynamic>.from(
      widget.reportData['customerModel'] ?? {},
    );

    final defaultValues = {
      'gender': <String>[],
      'ageGroups': {'under18': 0, '18to30': 0, '31to45': 0, 'over45': 0},
      'income': '',
      'overallRating': '',
    };

    defaultValues.forEach((key, value) {
      localCustomerModelData.putIfAbsent(key, () => value);
    });
  }

  void _handleRatingSelection(String rating) {
    setState(() {
      localCustomerModelData['overallRating'] = rating;
      widget.setState(() {
        widget.reportData['customerConcentration'] = Map<String, dynamic>.from(
          localCustomerModelData,
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
            'III. Customer Model',
            style: widget.theme.textTheme.headlineLarge?.copyWith(
              color: widget.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          InfoCard(
            icon: Icons.lightbulb_outline,
            content: 'Note gender, age, and income distribution.',
            backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
            iconColor: Theme.of(context).colorScheme.secondary,
            borderRadius: 20.0,
            padding: EdgeInsets.all(20.0),
          ),
          SizedBox(height: 12.0),
          Text(
            'Main customer gender:',
            style: widget.theme.textTheme.titleMedium,
          ),
          Row(
            children: [
              Radio(
                value: 'Male',
                groupValue: localCustomerModelData['gender'],
                onChanged: (value) {
                  setState(() {
                    localCustomerModelData['gender'] = value;
                  });
                },
              ),
              Text('Male'),
              SizedBox(width: 5),
              Icon(Icons.male, color: widget.theme.colorScheme.primary),

              Radio(
                value: 'Female',
                groupValue: localCustomerModelData['gender'],
                onChanged: (value) {
                  setState(() {
                    localCustomerModelData['gender'] = value;
                  });
                },
              ),
              Text('Female'),
              SizedBox(width: 5),
              Icon(Icons.female, color: widget.theme.colorScheme.primary),

              Radio(
                value: 'Balanced',
                groupValue: localCustomerModelData['gender'],
                onChanged: (value) {
                  setState(() {
                    localCustomerModelData['gender'] = value;
                  });
                },
              ),
              Text('Other'),
              SizedBox(width: 5),
              Icon(Icons.people_alt, color: widget.theme.colorScheme.primary),
            ],
          ),

          SizedBox(height: 16),
          Text('Age groups:', style: widget.theme.textTheme.titleMedium),
          BuildAgeGroupInput(
            label: 'Under 18',
            keyName: 'under18',
            reportData: widget.reportData,
            theme: widget.theme,
          ),
          BuildAgeGroupInput(
            label: '18-30',
            keyName: '18to30',
            reportData: widget.reportData,
            theme: widget.theme,
          ),
          BuildAgeGroupInput(
            label: '31-45',
            keyName: '31to45',
            reportData: widget.reportData,
            theme: widget.theme,
          ),
          BuildAgeGroupInput(
            label: 'Over 45',
            keyName: 'over45',
            reportData: widget.reportData,
            theme: widget.theme,
          ),
          SizedBox(height: 16),
          Text(
            'Average customer income:',
            style: widget.theme.textTheme.titleMedium,
          ),
          DropdownButtonFormField<String>(
            value: widget.reportData['customerModel']['income'],
            hint: Text('Select income range'),
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
                widget.reportData['customerModel']['income'] = value;
              });
            },
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.monetization_on,
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
            subtitle: localCustomerModelData['overallRating'] ?? 'Not rated',
            theme: widget.theme,
            children: [
              RatingButtons(
                currentRating: localCustomerModelData['overallRating'] ?? '',
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
