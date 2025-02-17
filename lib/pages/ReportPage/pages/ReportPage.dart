import 'package:flutter/material.dart';

import '../components/additional_notes.dart';
import '../components/convenience.dart';
import '../components/customer_concentration.dart';
import '../components/customer_flow.dart';
import '../components/customer_model.dart';
import '../components/environmental_factors.dart';
import '../components/site_area.dart';
import '../components/visibility_obstruction.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  Map<String, dynamic> reportData = {
    'customerFlow': {
      'vehicles': {
        'motorcycle': 0,
        'car': 0,
        'bicycle': 0,
        'pedestrian': 0,
        'other': null,
      },
      'peakHours': {'morning': 0, 'noon': 0, 'afternoon': 0, 'evening': 0},
      'overallRating': null,
    },
    'customerConcentration': {
      'customerTypes': [],
      'averageCustomers': null,
      'overallRating': null,
    },
    'customerModel': {
      'gender': null,
      'ageGroups': {'under18': 0, '18to30': 0, '31to45': 0, 'over45': 0},
      'income': null,
      'overallRating': null,
    },
    'siteArea': {
      'totalArea': 0,
      'shape': null,
      'condition': null,
      'overallRating': null,
    },
    'environmentalFactors': {
      'airQuality': null,
      'naturalLight': null,
      'greenery': null,
      'waste': null,
      'surroundingStores': [],
      'overallRating': null,
    },
    'visibilityAndObstruction': {
      'hasObstruction': false,
      'obstructionType': null,
      'obstructionLevel': null,
    },
    'convenience': {
      'terrain': null,
      'accessibility': null,
      'overallRating': null,
    },
    'additionalNotes': null,
    'hasImages': false,
  };

  int _currentPage = 0;
  final List<String> _pageNames = [
    'Customer Flow',
    'Customer Concentration',
    'Customer Model',
    'Site Area',
    'Environmental Factors',
    'Visibility & Obstruction',
    'Convenience',
    'Additional Notes',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      // Sử dụng theme hiện tại và có thể override một số thuộc tính nếu cần
      data: theme.copyWith(
        // Ví dụ nếu bạn muốn override một số thuộc tính cho riêng ReportPage
        // textTheme: theme.textTheme.copyWith(...),
        // colorScheme: theme.colorScheme.copyWith(...),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Site Report',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          actions: [IconButton(icon: Icon(Icons.save), onPressed: _submitForm)],
        ),
        body: Form(
          key: _formKey,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              CustomerFlowSection(
                reportData: reportData,
                setState: setState,
                theme: theme,
              ),
              CustomerConcentrationSection(
                reportData: reportData,
                setState: setState,
                theme: theme,
              ),
              CustomerModelSection(
                reportData: reportData,
                setState: setState,
                theme: theme,
              ),
              SiteAreaSection(
                reportData: reportData,
                setState: setState,
                theme: theme,
              ),
              EnvironmentalFactorsSection(
                reportData: reportData,
                setState: setState,
                theme: theme,
              ),
              VisibilityObstructionSection(
                reportData: reportData,
                setState: setState,
                theme: theme,
              ),
              ConvenienceSection(
                reportData: reportData,
                setState: setState,
                theme: theme,
              ),
              AdditionalNotesSection(
                reportData: reportData,
                setState: setState,
                theme: theme,
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed:
                      _currentPage > 0
                          ? () => _pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                          : null,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  child: Text('Previous'),
                ),
                Text(
                  '${_currentPage + 1}/${_pageNames.length}',
                  style: theme.textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed:
                      _currentPage < _pageNames.length - 1
                          ? () => _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                          : null,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  child: Text('Next'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Check if all required fields are filled
      bool isValid = true;
      String missingFields = '';

      void checkField(String fieldName, dynamic value) {
        if (value == null || (value is String && value.isEmpty)) {
          isValid = false;
          missingFields += '$fieldName, ';
        }
      }

      checkField(
        'Average customers',
        reportData['customerConcentration']['averageCustomers'],
      );
      checkField('Site shape', reportData['siteArea']['shape']);
      checkField('Site condition', reportData['siteArea']['condition']);
      checkField('Customer income', reportData['customerModel']['income']);
      checkField(
        'Obstruction level',
        reportData['visibilityAndObstruction']['obstructionLevel'],
      );
      checkField('Site terrain', reportData['convenience']['terrain']);
      checkField('Accessibility', reportData['convenience']['accessibility']);

      // Add more checks for other required fields

      if (!isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please fill in all required fields: ${missingFields.substring(0, missingFields.length - 2)}',
            ),
          ),
        );
        return;
      }

      // If all required fields are filled, proceed with form submission
      print(reportData);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Report submitted successfully')));
    }
  }
}
