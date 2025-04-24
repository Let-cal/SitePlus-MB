import 'package:flutter/material.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/animated_expansion_card.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/custom_chip_group.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/info_card.dart';
import 'package:siteplus_mb/components/custom_input_field.dart';

class ConvenienceSection extends StatefulWidget {
  final Map<String, dynamic> reportData;
  final Function(void Function()) setState;
  final ThemeData theme;

  const ConvenienceSection({
    super.key,
    required this.reportData,
    required this.setState,
    required this.theme,
  });

  @override
  ConvenienceSectionState createState() => ConvenienceSectionState();
}

class ConvenienceSectionState extends State<ConvenienceSection> {
  late Map<String, dynamic> localConvenienceData;
  int? siteCategoryId;
  bool isDataInitialized = false;
  List<Map<String, dynamic>> newAttributeValues = []; // Lưu giá trị mới
  List<Map<String, dynamic>> changedAttributeValues =
      []; // Lưu giá trị cập nhật
  late List<Map<String, dynamic>> originalAttributeValues; // Lưu giá trị gốc
  String _debugAttributeValues = '';

  final Map<String, int> attributeIds = {
    'terrain': 19,
    'accessibility': 20,
    'customerAccessibility': 29,
  };

  final List<String> terrainOptions = [
    'Bằng phẳng (<0.10 m; dốc <5 %)',
    'Cao hơn vỉa hè (>0.15 m)',
    'Thấp hơn vỉa hè (<–0.15 m)',
    'Dốc nhẹ (5–10 %)',
    'Dốc vừa (10–15 %)',
    'Dốc cao (>16 %)',
    'Khác',
  ];

  final Map<String, IconData> terrainIcons = {
    'Bằng phẳng (<0.10 m; dốc <5 %)': Icons.flatware,
    'Cao hơn vỉa hè (>0.15 m)': Icons.arrow_upward,
    'Thấp hơn vỉa hè (<–0.15 m)': Icons.arrow_downward,
    'Dốc nhẹ (5–10 %)': Icons.trending_flat,
    'Dốc vừa (10–15 %)': Icons.trending_up,
    'Dốc cao (>16 %)': Icons.show_chart,
    'Khác': Icons.edit,
  };

  final List<String> accessibilityOptions = [
    'Thuận tiện (≥80%)',
    'Khó khăn nhẹ (50–80%)',
    'Khó tiếp cận (<50%)',
    'Khác',
  ];
  final Map<String, IconData> accessibilityIcons = {
    'Thuận tiện (≥80%)': Icons.check_circle_outline,
    'Khó khăn nhẹ (50–80%)': Icons.warning_amber_outlined,
    'Khó tiếp cận (<50%)': Icons.not_interested,
    'Khác': Icons.help_outline,
  };

  final List<String> customerAccessibilityOptions = [
    'Cao (Đường trục chính; Độ rộng lòng đường: ≥12 m; vỉa hè 2 bên)',
    'Trung bình (Đường gom; Độ rộng lòng đường:8–12 m; vỉa hè 1 bên)',
    'Thấp (Đường nhánh, hẻm nhỏ; Độ rộng lòng đường:<8 m; không vỉa hè)',
    'Khác',
  ];
  final Map<String, IconData> customerAccessibilityIcons = {
    'Cao (Đường trục chính; Độ rộng lòng đường: ≥12 m; vỉa hè 2 bên)':
        Icons.people,
    'Trung bình (Đường gom; Độ rộng lòng đường:8–12 m; vỉa hè 1 bên)':
        Icons.people_outline,
    'Thấp (Đường nhánh, hẻm nhỏ; Độ rộng lòng đường:<8 m; không vỉa hè)':
        Icons.person_off,
    'Khác': Icons.help_outline,
  };

  List<String> customTerrainOptions = [];
  List<String> customAccessibilityOptions = [];
  List<String> customCustomerAccessibilityOptions = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
    // Hoãn việc cập nhật trạng thái sau khi build hoàn tất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAttributeValues();
      _updateDebugInfo();
    });
  }

  void _initializeData() {
    siteCategoryId = widget.reportData['siteCategoryId'];
    localConvenienceData = Map<String, dynamic>.from(
      widget.reportData['convenience'] ?? {},
    );
    originalAttributeValues = List<Map<String, dynamic>>.from(
      widget.reportData['attributeValues'] ?? [],
    );
    newAttributeValues = List<Map<String, dynamic>>.from(
      widget.reportData['newAttributeValues'] ?? [],
    );

    List<Map<String, dynamic>> attributeValues = List.from(
      widget.reportData['attributeValues'] ?? [],
    );

    final defaultValues = {
      'terrain': {'value': '', 'additionalInfo': ''},
      'accessibility': {'value': '', 'additionalInfo': ''},
    };
    if (siteCategoryId == 1) {
      defaultValues['customerAccessibility'] = {
        'value': '',
        'additionalInfo': '',
      };
    }

    defaultValues.forEach((key, value) {
      localConvenienceData.putIfAbsent(key, () => value);
    });

    customTerrainOptions = List<String>.from(
      localConvenienceData['customTerrainOptions'] ?? [],
    );
    customAccessibilityOptions = List<String>.from(
      localConvenienceData['customAccessibilityOptions'] ?? [],
    );
    if (siteCategoryId == 1) {
      customCustomerAccessibilityOptions = List<String>.from(
        localConvenienceData['customCustomerAccessibilityOptions'] ?? [],
      );
    }

    for (var attr in attributeValues) {
      final int attrId = attr['attributeId'];
      final String value = attr['value'] ?? '';
      final String additionalInfo = attr['additionalInfo'] ?? '';

      switch (attrId) {
        case 19: // terrain
          localConvenienceData['terrain'] = {
            'value': value,
            'additionalInfo': additionalInfo,
          };
          if (!terrainOptions.contains(value) && value.isNotEmpty) {
            customTerrainOptions.add(value);
          }
          break;
        case 20: // accessibility
          localConvenienceData['accessibility'] = {
            'value': value,
            'additionalInfo': additionalInfo,
          };
          if (!accessibilityOptions.contains(value) && value.isNotEmpty) {
            customAccessibilityOptions.add(value);
          }
          break;
        case 29: // customerAccessibility
          if (siteCategoryId == 1) {
            localConvenienceData['customerAccessibility'] = {
              'value': value,
              'additionalInfo': additionalInfo,
            };
            if (!customerAccessibilityOptions.contains(value) &&
                value.isNotEmpty) {
              customCustomerAccessibilityOptions.add(value);
            }
          }
          break;
      }
    }

    isDataInitialized = true;
  }

  void _updateDebugInfo() {
    final List<Map<String, dynamic>> attributeValues =
        List<Map<String, dynamic>>.from(
          widget.reportData['attributeValues'] ?? [],
        );

    final convenienceAttributes =
        attributeValues
            .where(
              (item) =>
                  item['attributeId'] == 19 ||
                  item['attributeId'] == 20 ||
                  item['attributeId'] == 29,
            )
            .toList();

    _debugAttributeValues =
        'attributeValues:\n${convenienceAttributes.map((item) => '  - attributeId: ${item['attributeId']}\n'
        '    id: ${item['id'] ?? 'N/A'}\n'
        '    siteId: ${item['siteId']}\n'
        '    value: ${item['value']}\n'
        '    additionalInfo: ${item['additionalInfo']}').join('\n\n')}\n'
        'changedAttributeValues:\n${changedAttributeValues.map((item) => '  - id: ${item['id']}\n'
        '    value: ${item['value']}\n'
        '    additionalInfo: ${item['additionalInfo']}').join('\n\n')}\n'
        'newAttributeValues:\n${newAttributeValues.map((item) => '  - attributeId: ${item['attributeId']}\n'
        '    siteId: ${item['siteId']}\n'
        '    value: ${item['value']}\n'
        '    additionalInfo: ${item['additionalInfo']}').join('\n\n')}';
    debugPrint(_debugAttributeValues);
  }

  void _updateAttributeValues() {
    final List<Map<String, dynamic>> attributeValues =
        List<Map<String, dynamic>>.from(
          widget.reportData['attributeValues'] ?? [],
        );

    // Update terrain (attributeId: 19)
    if (localConvenienceData['terrain']['value'].isNotEmpty) {
      _updateSingleAttribute(
        attributeValues,
        attributeIds['terrain']!,
        localConvenienceData['terrain']['value'],
        localConvenienceData['terrain']['additionalInfo'] ?? '',
      );
    }

    // Update accessibility (attributeId: 20)
    if (localConvenienceData['accessibility']['value'].isNotEmpty) {
      _updateSingleAttribute(
        attributeValues,
        attributeIds['accessibility']!,
        localConvenienceData['accessibility']['value'],
        localConvenienceData['accessibility']['additionalInfo'] ?? '',
      );
    }

    // Update customerAccessibility (attributeId: 29) if siteCategoryId == 1
    if (siteCategoryId == 1 &&
        localConvenienceData['customerAccessibility']['value'].isNotEmpty) {
      _updateSingleAttribute(
        attributeValues,
        attributeIds['customerAccessibility']!,
        localConvenienceData['customerAccessibility']['value'],
        localConvenienceData['customerAccessibility']['additionalInfo'] ?? '',
      );
    }

    widget.setState(() {
      localConvenienceData['customTerrainOptions'] = customTerrainOptions;
      localConvenienceData['customAccessibilityOptions'] =
          customAccessibilityOptions;
      localConvenienceData['customCustomerAccessibilityOptions'] =
          customCustomerAccessibilityOptions;
      widget.reportData['convenience'] = localConvenienceData;
      widget.reportData['attributeValues'] = attributeValues;
      widget.reportData['changedAttributeValues'] =
          List<Map<String, dynamic>>.from(changedAttributeValues);
      widget.reportData['newAttributeValues'] = List<Map<String, dynamic>>.from(
        newAttributeValues,
      );
    });

    _updateDebugInfo();
  }

  void _updateSingleAttribute(
    List<Map<String, dynamic>> attributeValues,
    int attributeId,
    String value,
    String additionalInfo,
  ) {
    final existingAttr = originalAttributeValues.firstWhere(
      (attr) => attr['attributeId'] == attributeId,
      orElse: () => {},
    );

    final newValue = {
      'attributeId': attributeId,
      'siteId': widget.reportData['siteId'] ?? 0,
      'value': value,
      'additionalInfo': additionalInfo,
      if (existingAttr['id'] != null) 'id': existingAttr['id'],
    };

    if (existingAttr['id'] != null) {
      // Nếu đã tồn tại (có id), cập nhật changedAttributeValues
      final changeIndex = changedAttributeValues.indexWhere(
        (attr) => attr['id'] == existingAttr['id'],
      );
      final updatedValue = {
        'id': existingAttr['id'],
        'value': value,
        'additionalInfo': additionalInfo,
      };
      if (changeIndex != -1) {
        changedAttributeValues[changeIndex] = updatedValue;
      } else {
        changedAttributeValues.add(updatedValue);
      }
    } else if (value.isNotEmpty) {
      // Nếu là mới, thay thế hoặc thêm vào newAttributeValues
      final newIndex = newAttributeValues.indexWhere(
        (attr) => attr['attributeId'] == attributeId,
      );
      if (newIndex != -1) {
        newAttributeValues[newIndex] = newValue;
      } else {
        newAttributeValues.add(newValue);
      }
    }

    // Cập nhật attributeValues
    final index = attributeValues.indexWhere(
      (attr) => attr['id'] == existingAttr['id'],
    );
    if (index != -1) {
      attributeValues[index] = newValue;
    } else if (value.isNotEmpty) {
      attributeValues.add(newValue);
    }
  }

  String _getTerrainTitle() {
    return siteCategoryId == 1
        ? 'Địa hình xung quanh tòa nhà'
        : 'Địa hình xung quanh mặt bằng';
  }

  String _getAccessibilityTitle() {
    return siteCategoryId == 1
        ? 'Mức độ tiếp cận tòa nhà'
        : 'Mức độ tiếp cận mặt bằng';
  }

  String _getSubtitle(String type) {
    return localConvenienceData[type]['value'].isEmpty
        ? 'Chưa chọn'
        : localConvenienceData[type]['value'];
  }

  void _handleOptionSelected(String type, String option) {
    setState(() {
      localConvenienceData[type]['value'] =
          localConvenienceData[type]['value'] == option ? '' : option;
      _updateAttributeValues();
    });
  }

  void _handleCustomOptionAdded(String type, String option) {
    setState(() {
      if (type == 'terrain') {
        customTerrainOptions.add(option);
      } else if (type == 'accessibility') {
        customAccessibilityOptions.add(option);
      } else if (type == 'customerAccessibility') {
        customCustomerAccessibilityOptions.add(option);
      }
      localConvenienceData[type]['value'] = option;
      _updateAttributeValues();
    });
  }

  void _handleCustomOptionRemoved(String type, String option) {
    setState(() {
      if (type == 'terrain') {
        customTerrainOptions.remove(option);
      } else if (type == 'accessibility') {
        customAccessibilityOptions.remove(option);
      } else if (type == 'customerAccessibility') {
        customCustomerAccessibilityOptions.remove(option);
      }
      if (localConvenienceData[type]['value'] == option) {
        localConvenienceData[type]['value'] = '';
      }
      _updateAttributeValues();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isDataInitialized) {
      _initializeData();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VII. Tiện ích',
            style: widget.theme.textTheme.titleLarge?.copyWith(
              color: widget.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          InfoCard(
            icon: Icons.lightbulb_outline,
            content:
                siteCategoryId == 1
                    ? 'Đánh giá địa hình và khả năng tiếp cận của tòa nhà.'
                    : 'Đánh giá địa hình và khả năng tiếp cận của mặt bằng.',
            backgroundColor: widget.theme.colorScheme.tertiaryFixed,
            iconColor: widget.theme.colorScheme.secondary,
            borderRadius: 20.0,
            padding: const EdgeInsets.all(20.0),
          ),
          const SizedBox(height: 16),
          AnimatedExpansionCard(
            icon: Icons.landscape,
            title: _getTerrainTitle(),
            subtitle: _getSubtitle('terrain'),
            theme: widget.theme,
            children: [
              CustomChipGroup(
                options: terrainOptions,
                selectedOptions:
                    localConvenienceData['terrain']['value'].isEmpty
                        ? []
                        : [localConvenienceData['terrain']['value']],
                customOptions: customTerrainOptions,
                optionIcons: terrainIcons,
                onOptionSelected:
                    (option) => _handleOptionSelected('terrain', option),
                onCustomOptionAdded:
                    (option) => _handleCustomOptionAdded('terrain', option),
                onCustomOptionRemoved:
                    (option) => _handleCustomOptionRemoved('terrain', option),
                showOtherInputOnlyWhenSelected: true,
                otherOptionKey: 'khác',
              ),
              const SizedBox(height: 12.0),
              CustomInputField(
                label: 'Thông tin bổ sung về địa hình',
                hintText: 'Nhập thông tin chi tiết về địa hình',
                icon: Icons.info_outline,
                initialValue:
                    localConvenienceData['terrain']['additionalInfo'] ?? '',
                theme: widget.theme,
                isDescription: true,
                onSaved: (value) {
                  setState(() {
                    localConvenienceData['terrain']['additionalInfo'] = value;
                    _updateAttributeValues();
                  });
                },
              ),
            ],
          ),
          AnimatedExpansionCard(
            icon: Icons.route,
            title: _getAccessibilityTitle(),
            subtitle: _getSubtitle('accessibility'),
            theme: widget.theme,
            children: [
              CustomChipGroup(
                options: accessibilityOptions,
                selectedOptions:
                    localConvenienceData['accessibility']['value'].isEmpty
                        ? []
                        : [localConvenienceData['accessibility']['value']],
                customOptions: customAccessibilityOptions,
                optionIcons: accessibilityIcons,
                onOptionSelected:
                    (option) => _handleOptionSelected('accessibility', option),
                onCustomOptionAdded:
                    (option) =>
                        _handleCustomOptionAdded('accessibility', option),
                onCustomOptionRemoved:
                    (option) =>
                        _handleCustomOptionRemoved('accessibility', option),
                showOtherInputOnlyWhenSelected: true,
                otherOptionKey: 'khác',
              ),
              const SizedBox(height: 12.0),
              CustomInputField(
                label: 'Thông tin bổ sung về khả năng tiếp cận',
                hintText: 'Nhập thông tin chi tiết về khả năng tiếp cận',
                icon: Icons.info_outline,
                initialValue:
                    localConvenienceData['accessibility']['additionalInfo'] ??
                    '',
                theme: widget.theme,
                isDescription: true,
                onSaved: (value) {
                  setState(() {
                    localConvenienceData['accessibility']['additionalInfo'] =
                        value;
                    _updateAttributeValues();
                  });
                },
              ),
            ],
          ),
          if (siteCategoryId == 1)
            AnimatedExpansionCard(
              icon: Icons.people,
              title: 'Mức độ tiếp cận khách hàng',
              subtitle: _getSubtitle('customerAccessibility'),
              theme: widget.theme,
              children: [
                CustomChipGroup(
                  options: customerAccessibilityOptions,
                  selectedOptions:
                      localConvenienceData['customerAccessibility']['value']
                              .isEmpty
                          ? []
                          : [
                            localConvenienceData['customerAccessibility']['value'],
                          ],
                  customOptions: customCustomerAccessibilityOptions,
                  optionIcons: customerAccessibilityIcons,
                  onOptionSelected:
                      (option) => _handleOptionSelected(
                        'customerAccessibility',
                        option,
                      ),
                  onCustomOptionAdded:
                      (option) => _handleCustomOptionAdded(
                        'customerAccessibility',
                        option,
                      ),
                  onCustomOptionRemoved:
                      (option) => _handleCustomOptionRemoved(
                        'customerAccessibility',
                        option,
                      ),
                  showOtherInputOnlyWhenSelected: true,
                  otherOptionKey: 'khác',
                ),
                const SizedBox(height: 12.0),
                CustomInputField(
                  label: 'Thông tin bổ sung về mức độ tiếp cận khách hàng',
                  hintText:
                      'Nhập thông tin chi tiết về mức độ tiếp cận khách hàng',
                  icon: Icons.info_outline,
                  initialValue:
                      localConvenienceData['customerAccessibility']['additionalInfo'] ??
                      '',
                  theme: widget.theme,
                  isDescription: true,
                  onSaved: (value) {
                    setState(() {
                      localConvenienceData['customerAccessibility']['additionalInfo'] =
                          value;
                      _updateAttributeValues();
                    });
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}
