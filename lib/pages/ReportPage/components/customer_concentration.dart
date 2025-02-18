import 'package:flutter/material.dart';
import 'package:siteplus_mb/utils/ReportPage/animated_expansion_card.dart';
import 'package:siteplus_mb/utils/ReportPage/custom_chip_group.dart';
import 'package:siteplus_mb/utils/ReportPage/info_card.dart';
import 'package:siteplus_mb/utils/ReportPage/rating_buttons.dart';
import 'package:siteplus_mb/utils/ReportPage/selectable_option_button.dart';

class CustomerConcentrationSection extends StatefulWidget {
  final Map<String, dynamic> reportData;
  final Function(void Function()) setState;
  final ThemeData theme;

  const CustomerConcentrationSection({
    Key? key,
    required this.reportData,
    required this.setState,
    required this.theme,
  }) : super(key: key);

  @override
  CustomerConcentrationSectionState createState() =>
      CustomerConcentrationSectionState();
}

class CustomerConcentrationSectionState
    extends State<CustomerConcentrationSection> {
  late Map<String, dynamic> localCustomerData;

  final Map<String, IconData> customerIcons = {
    'Domestic': Icons.home,
    'Tourists': Icons.airplanemode_active,
    'Students': Icons.school,
    'Office workers': Icons.business,
    'Workers/Engineers': Icons.engineering,
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    localCustomerData = Map<String, dynamic>.from(
      widget.reportData['customerConcentration'] ?? {},
    );

    final defaultValues = {
      'customerTypes': <String>[],
      'customCustomerTypes': <String>[], // Add field for custom customer types
      'averageCustomers': '',
      'overallRating': '',
    };

    defaultValues.forEach((key, value) {
      localCustomerData.putIfAbsent(key, () => value);
    });
  }

  void _handleCustomerTypeSelection(String customerType) {
    setState(() {
      List<String> types = List<String>.from(
        localCustomerData['customerTypes'] ?? [],
      );

      if (types.contains(customerType)) {
        types.remove(customerType);
      } else {
        types.add(customerType);
      }

      localCustomerData['customerTypes'] = types;
      widget.setState(() {
        widget.reportData['customerConcentration'] = Map<String, dynamic>.from(
          localCustomerData,
        );
      });
    });
  }

  void _handleCustomCustomerTypeAdded(String customerType) {
    setState(() {
      List<String> customTypes = List<String>.from(
        localCustomerData['customCustomerTypes'] ?? [],
      );

      if (!customTypes.contains(customerType)) {
        customTypes.add(customerType);
        localCustomerData['customCustomerTypes'] = customTypes;

        widget.setState(() {
          widget.reportData['customerConcentration'] =
              Map<String, dynamic>.from(localCustomerData);
        });
      }
    });
  }

  void _handleCustomCustomerTypeRemoved(String customerType) {
    setState(() {
      List<String> customTypes = List<String>.from(
        localCustomerData['customCustomerTypes'] ?? [],
      );

      customTypes.remove(customerType);
      localCustomerData['customCustomerTypes'] = customTypes;

      widget.setState(() {
        widget.reportData['customerConcentration'] = Map<String, dynamic>.from(
          localCustomerData,
        );
      });
    });
  }

  String get _totalSelectedCustomerTypes {
    final selectedPresetTypes =
        (localCustomerData['customerTypes'] as List<dynamic>? ?? []).length;
    final customTypes =
        (localCustomerData['customCustomerTypes'] as List<dynamic>? ?? [])
            .length;
    final total = selectedPresetTypes + customTypes;
    return '$total selected';
  }

  void _handleRatingSelection(String rating) {
    setState(() {
      localCustomerData['overallRating'] = rating;
      widget.setState(() {
        widget.reportData['customerConcentration'] = Map<String, dynamic>.from(
          localCustomerData,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'II. Customer Concentration',
            style: widget.theme.textTheme.headlineLarge?.copyWith(
              color: widget.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          InfoCard(
            icon: Icons.lightbulb_outline,
            content: 'Identify customer types and average foot traffic.',
            backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
            iconColor: Theme.of(context).colorScheme.secondary,
            borderRadius: 20.0,
            padding: EdgeInsets.all(20.0),
          ),
          SizedBox(height: 12.0),
          AnimatedExpansionCard(
            icon: Icons.group,
            title: 'Customer Types',
            subtitle: _totalSelectedCustomerTypes,
            theme: widget.theme,
            children: [
              CustomChipGroup(
                options: customerIcons.keys.toList(),
                selectedOptions: List<String>.from(
                  localCustomerData['customerTypes'] ?? [],
                ),
                customOptions: List<String>.from(
                  localCustomerData['customCustomerTypes'] ?? [],
                ),
                optionIcons: customerIcons,
                onOptionSelected: _handleCustomerTypeSelection,
                onCustomOptionAdded: _handleCustomCustomerTypeAdded,
                onCustomOptionRemoved: _handleCustomCustomerTypeRemoved,
              ),
            ],
          ),

          AnimatedExpansionCard(
            icon: Icons.bar_chart,
            title: 'Average Customers per Hour',
            subtitle: localCustomerData['averageCustomers'] ?? 'Not selected',
            theme: widget.theme,
            children: [
              Column(
                children:
                    ['<10', '10-30', '30-50', '>50'].map((value) {
                      return SelectableOptionButton(
                        value: value,
                        icon: Icons.people_outline,
                        isSelected:
                            localCustomerData['averageCustomers'] == value,
                        onTap: () {
                          setState(() {
                            localCustomerData['averageCustomers'] = value;
                            widget.setState(() {
                              widget.reportData['customerConcentration'] =
                                  Map<String, dynamic>.from(localCustomerData);
                            });
                          });
                        },
                        theme: widget.theme,
                      );
                    }).toList(),
              ),
            ],
          ),

          AnimatedExpansionCard(
            icon: Icons.star_outline,
            title: 'Overall Rating',
            subtitle: localCustomerData['overallRating'] ?? 'Not rated',
            theme: widget.theme,
            children: [
              RatingButtons(
                currentRating: localCustomerData['overallRating'] ?? '',
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
