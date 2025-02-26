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
            'III. Mô Hình Khách Hàng',
            style: widget.theme.textTheme.headlineLarge?.copyWith(
              color: widget.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          InfoCard(
            icon: Icons.lightbulb_outline,
            content:
                'Ghi chú giới tính, độ tuổi và mức thu nhập của khách hàng.',
            backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
            iconColor: Theme.of(context).colorScheme.secondary,
            borderRadius: 20.0,
            padding: EdgeInsets.all(20.0),
          ),
          SizedBox(height: 12.0),
          Text(
            'Giới tính khách hàng chính:',
            style: widget.theme.textTheme.titleMedium,
          ),
          Row(
            children: [
              Radio(
                value: 'Nam',
                groupValue: localCustomerModelData['gender'],
                onChanged: (value) {
                  setState(() {
                    localCustomerModelData['gender'] = value;
                  });
                },
              ),
              Text('Nam'),
              SizedBox(width: 5),
              Icon(Icons.male, color: widget.theme.colorScheme.primary),

              Radio(
                value: 'Nữ',
                groupValue: localCustomerModelData['gender'],
                onChanged: (value) {
                  setState(() {
                    localCustomerModelData['gender'] = value;
                  });
                },
              ),
              Text('Nữ'),
              SizedBox(width: 5),
              Icon(Icons.female, color: widget.theme.colorScheme.primary),

              Radio(
                value: 'Khác',
                groupValue: localCustomerModelData['gender'],
                onChanged: (value) {
                  setState(() {
                    localCustomerModelData['gender'] = value;
                  });
                },
              ),
              Text('Khác'),
              SizedBox(width: 5),
              Icon(Icons.people_alt, color: widget.theme.colorScheme.primary),
            ],
          ),

          SizedBox(height: 16),
          Text('Nhóm độ tuổi:', style: widget.theme.textTheme.titleMedium),
          BuildAgeGroupInput(
            label: 'Dưới 18',
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
            label: 'Trên 45',
            keyName: 'over45',
            reportData: widget.reportData,
            theme: widget.theme,
          ),
          SizedBox(height: 16),
          Text(
            'Thu nhập trung bình của khách hàng:',
            style: widget.theme.textTheme.titleMedium,
          ),
          DropdownButtonFormField<String>(
            value: widget.reportData['customerModel']['income'],
            hint: Text('Chọn mức thu nhập'),
            items:
                [
                  '<5 triệu/tháng',
                  '5-10 triệu/tháng',
                  '10-20 triệu/tháng',
                  '>20 triệu/tháng',
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
              ),
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
            title: 'Đánh Giá Tổng Quan',
            subtitle:
                localCustomerModelData['overallRating'] ?? 'Chưa đánh giá',
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
