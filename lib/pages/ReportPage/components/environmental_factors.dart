import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:siteplus_mb/utils/ReportPage/animated_expansion_card.dart';
import 'package:siteplus_mb/utils/ReportPage/custom_chip_group.dart';
import 'package:siteplus_mb/utils/ReportPage/rating_buttons.dart';
import 'package:siteplus_mb/utils/ReportPage/selectable_option_button.dart';

class EnvironmentalFactorsSection extends StatefulWidget {
  final Map<String, dynamic> reportData;
  final Function(void Function()) setState;
  final ThemeData theme;

  const EnvironmentalFactorsSection({
    super.key,
    required this.reportData,
    required this.setState,
    required this.theme,
  });

  @override
  EnvironmentalFactorsSectionState createState() =>
      EnvironmentalFactorsSectionState();
}

class EnvironmentalFactorsSectionState
    extends State<EnvironmentalFactorsSection> {
  final Logger _logger = Logger('EnvironmentalFactorsSection');
  late Map<String, dynamic> localEnvironmentalFactors;
  final TextEditingController _otherStoreController = TextEditingController();
  bool _isExpanded = false;

  final Map<String, Map<String, dynamic>> factorConfigs = {
    'airQuality': {
      'title': 'Air Quality',
      'icon': Icons.air,
      'options': [
        {'label': 'Clean', 'icon': Icons.check_circle_outline},
        {'label': 'Average', 'icon': Icons.remove_circle_outline},
        {'label': 'Polluted', 'icon': Icons.cancel_outlined},
      ],
    },
    'naturalLight': {
      'title': 'Natural Light',
      'icon': Icons.wb_sunny,
      'options': [
        {'label': 'Good', 'icon': Icons.brightness_high},
        {'label': 'Average', 'icon': Icons.brightness_medium},
        {'label': 'Poor', 'icon': Icons.brightness_low},
      ],
    },
    'greenery': {
      'title': 'Greenery',
      'icon': Icons.park,
      'options': [
        {'label': 'Abundant', 'icon': Icons.forest},
        {'label': 'Scarce', 'icon': Icons.grass},
        {'label': 'None', 'icon': Icons.crop_square},
      ],
    },
    'waste': {
      'title': 'Waste Management',
      'icon': Icons.delete_outline,
      'options': [
        {'label': 'None', 'icon': Icons.check_circle_outline},
        {'label': 'Scarce', 'icon': Icons.remove_circle_outline},
        {'label': 'Abundant', 'icon': Icons.cancel_outlined},
      ],
    },
  };

  final Map<String, IconData> surroundingStoresIcons = {
    'Supermarket': Icons.store_mall_directory,
    'Restaurants': Icons.restaurant,
    'Schools': Icons.school,
    'Offices': Icons.business,
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    localEnvironmentalFactors = Map<String, dynamic>.from(
      widget.reportData['environmentalFactors'] ?? {},
    );

    final defaultValues = {
      'airQuality': '',
      'naturalLight': '',
      'greenery': '',
      'waste': '',
      'surroundingStores': <String>[],
      'customStores': <String>[], // Add this new field for custom stores
      'overallRating': '',
    };

    defaultValues.forEach((key, value) {
      localEnvironmentalFactors.putIfAbsent(key, () => value);
    });

    _logger.info("Initial environmentalFactors: $localEnvironmentalFactors");
  }

  void _handleFactorSelection(String key, String value) {
    setState(() {
      localEnvironmentalFactors[key] = value;
      widget.setState(() {
        widget.reportData['environmentalFactors'] = Map<String, dynamic>.from(
          localEnvironmentalFactors,
        );
      });
      _logger.info("Updated $key: $value");
    });
  }

  void _handleStoreSelection(String store) {
    setState(() {
      List<String> stores = List<String>.from(
        localEnvironmentalFactors['surroundingStores'] ?? [],
      );

      if (stores.contains(store)) {
        stores.remove(store);
      } else {
        stores.add(store);
      }

      localEnvironmentalFactors['surroundingStores'] = stores;
      widget.setState(() {
        widget.reportData['environmentalFactors'] = Map<String, dynamic>.from(
          localEnvironmentalFactors,
        );
      });
    });
  }

  void _handleCustomStoreAdded(String store) {
    setState(() {
      List<String> customStores = List<String>.from(
        localEnvironmentalFactors['customStores'] ?? [],
      );

      if (!customStores.contains(store)) {
        customStores.add(store);
        localEnvironmentalFactors['customStores'] = customStores;

        widget.setState(() {
          widget.reportData['environmentalFactors'] = Map<String, dynamic>.from(
            localEnvironmentalFactors,
          );
        });
      }
    });
  }

  void _handleCustomStoreRemoved(String store) {
    setState(() {
      List<String> customStores = List<String>.from(
        localEnvironmentalFactors['customStores'] ?? [],
      );

      customStores.remove(store);
      localEnvironmentalFactors['customStores'] = customStores;

      widget.setState(() {
        widget.reportData['environmentalFactors'] = Map<String, dynamic>.from(
          localEnvironmentalFactors,
        );
      });
    });
  }

  String get _totalSelectedStores {
    final selectedPresetStores =
        (localEnvironmentalFactors['surroundingStores'] as List<dynamic>? ?? [])
            .length;
    final customStores =
        (localEnvironmentalFactors['customStores'] as List<dynamic>? ?? [])
            .length;
    final total = selectedPresetStores + customStores;
    return '$total selected';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.eco,
                color: widget.theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Environmental Factors',
                style: widget.theme.textTheme.headlineSmall?.copyWith(
                  color: widget.theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          ...factorConfigs.keys.map((key) {
            final config = factorConfigs[key]!;
            return AnimatedExpansionCard(
              icon: config['icon'] as IconData,
              title: config['title'] as String,
              subtitle: localEnvironmentalFactors[key] ?? 'Not selected',
              theme: widget.theme,
              children: [
                Column(
                  children:
                      (config['options'] as List<Map<String, dynamic>>)
                          .map(
                            (option) => SelectableOptionButton(
                              value: option['label'] as String,
                              icon: option['icon'] as IconData,
                              isSelected:
                                  localEnvironmentalFactors[key] ==
                                  option['label'],
                              onTap:
                                  () => _handleFactorSelection(
                                    key,
                                    option['label'] as String,
                                  ),
                              theme: widget.theme,
                            ),
                          )
                          .toList(),
                ),
              ],
            );
          }),

          AnimatedExpansionCard(
            icon: Icons.store,
            title: 'Surrounding Stores',
            subtitle: _totalSelectedStores,
            theme: widget.theme,
            initiallyExpanded: true,
            children: [
              CustomChipGroup(
                options: surroundingStoresIcons.keys.toList(),
                selectedOptions: List<String>.from(
                  localEnvironmentalFactors['surroundingStores'] ?? [],
                ),
                customOptions: List<String>.from(
                  localEnvironmentalFactors['customStores'] ?? [],
                ),
                optionIcons: surroundingStoresIcons,
                onOptionSelected: _handleStoreSelection,
                onCustomOptionAdded: _handleCustomStoreAdded,
                onCustomOptionRemoved: _handleCustomStoreRemoved,
              ),
            ],
          ),

          AnimatedExpansionCard(
            icon: Icons.star_outline,
            title: 'Overall Rating',
            subtitle: localEnvironmentalFactors['overallRating'] ?? 'Not rated',
            theme: widget.theme,
            initiallyExpanded: true,
            children: [
              RatingButtons(
                currentRating: localEnvironmentalFactors['overallRating'] ?? '',
                onRatingSelected:
                    (rating) => _handleFactorSelection('overallRating', rating),
                theme: widget.theme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
