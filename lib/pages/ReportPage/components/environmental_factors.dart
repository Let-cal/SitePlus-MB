import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:siteplus_mb/utils/ReportPage/animated_expansion_card.dart';
import 'package:siteplus_mb/utils/ReportPage/custom_chip_group.dart';
import 'package:siteplus_mb/utils/ReportPage/info_card.dart';
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

  final Map<String, Map<String, dynamic>> factorConfigs = {
    'airQuality': {
      'title': 'Chất lượng không khí',
      'icon': Icons.air,
      'options': [
        {'label': 'Sạch', 'icon': Icons.check_circle_outline},
        {'label': 'Trung bình', 'icon': Icons.remove_circle_outline},
        {'label': 'Ô nhiễm', 'icon': Icons.cancel_outlined},
      ],
    },
    'naturalLight': {
      'title': 'Ánh sáng tự nhiên',
      'icon': Icons.wb_sunny,
      'options': [
        {'label': 'Tốt', 'icon': Icons.brightness_high},
        {'label': 'Trung bình', 'icon': Icons.brightness_medium},
        {'label': 'Kém', 'icon': Icons.brightness_low},
      ],
    },
    'greenery': {
      'title': 'Không gian xanh',
      'icon': Icons.park,
      'options': [
        {'label': 'Phong phú', 'icon': Icons.forest},
        {'label': 'Hiếm', 'icon': Icons.grass},
        {'label': 'Không có', 'icon': Icons.crop_square},
      ],
    },
    'waste': {
      'title': 'Quản lý rác thải',
      'icon': Icons.delete_outline,
      'options': [
        {'label': 'Không có', 'icon': Icons.check_circle_outline},
        {'label': 'Ít', 'icon': Icons.remove_circle_outline},
        {'label': 'Nhiều', 'icon': Icons.cancel_outlined},
      ],
    },
  };

  final Map<String, IconData> surroundingStoresIcons = {
    'Siêu thị': Icons.store_mall_directory,
    'Nhà hàng': Icons.restaurant,
    'Trường học': Icons.school,
    'Văn phòng': Icons.business,
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
      'customStores': <String>[],
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
    return '$total đã chọn';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'V. Yếu Tố Môi Trường',
            style: widget.theme.textTheme.headlineLarge?.copyWith(
              color: widget.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          InfoCard(
            icon: Icons.lightbulb_outline,
            content:
                'Đánh giá chất lượng không khí, ánh sáng và không gian xanh.',
            backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
            iconColor: Theme.of(context).colorScheme.secondary,
            borderRadius: 20.0,
            padding: const EdgeInsets.all(20.0),
          ),
          const SizedBox(height: 12),
          ...factorConfigs.keys.map((key) {
            final config = factorConfigs[key]!;
            return AnimatedExpansionCard(
              icon: config['icon'] as IconData,
              title: config['title'] as String,
              subtitle: localEnvironmentalFactors[key] ?? 'Chưa chọn',
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
            title: 'Cửa hàng xung quanh',
            subtitle: _totalSelectedStores,
            theme: widget.theme,
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
            title: 'Đánh giá tổng quan',
            subtitle:
                localEnvironmentalFactors['overallRating'] ?? 'Chưa đánh giá',
            theme: widget.theme,
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
