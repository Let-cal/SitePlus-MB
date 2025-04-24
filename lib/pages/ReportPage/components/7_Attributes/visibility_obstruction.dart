import 'package:flutter/material.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/animated_expansion_card.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/custom_chip_group.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/info_card.dart';
import 'package:siteplus_mb/components/custom_input_field.dart';

class VisibilityObstructionSection extends StatefulWidget {
  final Map<String, dynamic> reportData;
  final Function(void Function()) setState;
  final ThemeData theme;

  const VisibilityObstructionSection({
    super.key,
    required this.reportData,
    required this.setState,
    required this.theme,
  });

  @override
  VisibilityObstructionSectionState createState() =>
      VisibilityObstructionSectionState();
}

class VisibilityObstructionSectionState
    extends State<VisibilityObstructionSection> {
  Map<String, dynamic> localVisibilityObstructionData = {};
  late int? siteCategoryId;
  List<Map<String, dynamic>> newAttributeValues = []; // Lưu giá trị mới
  List<Map<String, dynamic>> changedAttributeValues =
      []; // Lưu giá trị cập nhật
  late List<Map<String, dynamic>> originalAttributeValues; // Lưu giá trị gốc
  String _debugAttributeValues = '';

  final Map<String, IconData> obstructionCategories = {
    'cây xanh': Icons.forest,
    'tòa nhà cao tầng': Icons.apartment,
    'cột điện': Icons.power,
    'biển quảng cáo': Icons.signpost,
    'khác': Icons.help_outline,
  };

  final Map<String, Map<String, IconData>> obstructionLevels = {
    'cây xanh': {
      'Ít (0–2 cây; <20%)': Icons.filter_1,
      'Trung bình (3–5 cây; 20–50%)': Icons.filter_2,
      'Nhiều (>5 cây; >50%)': Icons.filter_3,
    },
    'tòa nhà cao tầng': {
      'Gần (<50 m)': Icons.domain,
      'Trung bình (50–100 m)': Icons.apartment,
      'Xa (>100 m)': Icons.location_city,
    },
    'cột điện': {
      'Ít (0–1 cột)': Icons.bolt,
      'Nhiều (≥2 cột)': Icons.electrical_services,
    },
    'biển quảng cáo': {
      'Nhỏ (<10 m²)': Icons.crop_square,
      'Lớn (≥10 m²)': Icons.crop_din,
    },
    'khác': {'Không thể xác định': Icons.fiber_manual_record_outlined},
  };

  final generalObstructionLevels = {
    'cực thấp (~ 0-10%)': Icons.signal_cellular_0_bar,
    'thấp (~ 10-40%)': Icons.signal_cellular_alt_1_bar,
    'trung bình (~ 40-70%)': Icons.signal_cellular_alt_2_bar,
    'cao (~ 70-90%)': Icons.signal_cellular_alt,
    'rất cao (~ 90-100%)': Icons.signal_cellular_4_bar,
  };

  final visibilityOptions = {
    'có tầm nhìn ra biển': Icons.beach_access,
    'có tầm nhìn ra công viên': Icons.park,
    'có tầm nhìn ra đường phố chính': Icons.directions_car,
    'có tầm nhìn ra khu dân cư': Icons.home,
    'tầm nhìn hạn chế': Icons.visibility_off,
    'khác': Icons.help_outline,
  };

  String? hasObstruction;
  List<String> selectedObstructionCategories = [];
  Map<String, String> selectedObstructionDetails = {};
  String? selectedObstructionLevel;
  List<String> selectedVisibilityOptions = [];
  String obstructionAdditionalInfo = '';
  String obstructionLevelAdditionalInfo = '';
  String visibilityAdditionalInfo = '';

  List<String> customObstructionCategories = [];
  List<String> customObstructionDetails = [];
  List<String> customObstructionLevels = [];
  List<String> customVisibilityOptions = [];

  String get combinedObstructionType {
    if (hasObstruction == 'không') {
      return 'không có chướng ngại';
    }
    if (selectedObstructionCategories.isEmpty) {
      return '';
    }
    List<String> combinedObstructions = [];
    for (var category in selectedObstructionCategories) {
      String detail = selectedObstructionDetails[category] ?? '';
      if (detail.isNotEmpty) {
        combinedObstructions.add('$category - $detail');
      } else {
        combinedObstructions.add(category);
      }
    }
    return combinedObstructions.join(', ');
  }

  @override
  void initState() {
    super.initState();
    siteCategoryId = widget.reportData['siteCategoryId'] as int?;
    _initializeData();
    _updateDebugInfo();
  }

  void _initializeData() {
    localVisibilityObstructionData = Map<String, dynamic>.from(
      widget.reportData['visibilityAndObstruction'] ?? {},
    );
    originalAttributeValues = List<Map<String, dynamic>>.from(
      widget.reportData['attributeValues'] ?? [],
    );
    newAttributeValues = List<Map<String, dynamic>>.from(
      widget.reportData['newAttributeValues'] ?? [],
    );

    // Lấy attributeValues từ reportData
    List<Map<String, dynamic>> attributeValues = List.from(
      widget.reportData['attributeValues'] ?? [],
    );

    // Khởi tạo giá trị mặc định
    hasObstruction = localVisibilityObstructionData['hasObstruction'];
    selectedObstructionCategories = List<String>.from(
      localVisibilityObstructionData['selectedObstructionCategories'] ?? [],
    );
    selectedObstructionDetails = Map<String, String>.from(
      localVisibilityObstructionData['selectedObstructionDetails'] ?? {},
    );
    selectedObstructionLevel =
        localVisibilityObstructionData['obstructionLevel'];
    selectedVisibilityOptions = List<String>.from(
      localVisibilityObstructionData['selectedVisibilityOptions'] ?? [],
    );
    obstructionAdditionalInfo =
        localVisibilityObstructionData['obstructionAdditionalInfo'] ?? '';
    obstructionLevelAdditionalInfo =
        localVisibilityObstructionData['obstructionLevelAdditionalInfo'] ?? '';
    visibilityAdditionalInfo =
        localVisibilityObstructionData['visibilityAdditionalInfo'] ?? '';
    customObstructionCategories = List<String>.from(
      localVisibilityObstructionData['customObstructionCategories'] ?? [],
    );
    customObstructionDetails = List<String>.from(
      localVisibilityObstructionData['customObstructionDetails'] ?? [],
    );
    customObstructionLevels = List<String>.from(
      localVisibilityObstructionData['customObstructionLevels'] ?? [],
    );
    customVisibilityOptions = List<String>.from(
      localVisibilityObstructionData['customVisibilityOptions'] ?? [],
    );

    // Điền dữ liệu từ attributeValues (giữ nguyên phần còn lại)
    for (var attr in attributeValues) {
      final int attrId = attr['attributeId'];
      final String value = attr['value'] ?? '';
      final String additionalInfo = attr['additionalInfo'] ?? '';

      switch (attrId) {
        case 17: // obstructionType
          if (value == 'không có chướng ngại') {
            hasObstruction = 'không';
            selectedObstructionCategories.clear();
            selectedObstructionDetails.clear();
          } else {
            hasObstruction = 'có';
            final parts = value.split(', ');
            for (var part in parts) {
              final subParts = part.split(' - ');
              final category = subParts[0];
              final detail = subParts.length > 1 ? subParts[1] : '';
              if (!selectedObstructionCategories.contains(category)) {
                selectedObstructionCategories.add(category);
              }
              if (detail.isNotEmpty) {
                selectedObstructionDetails[category] = detail;
                if (!obstructionCategories.containsKey(category) &&
                    !customObstructionCategories.contains(category)) {
                  customObstructionCategories.add(category);
                }
                if (!obstructionLevels[category]!.containsKey(detail)) {
                  customObstructionDetails.add(detail);
                }
              }
            }
            obstructionAdditionalInfo = additionalInfo;
          }
          break;
        case 18: // obstructionLevel
          selectedObstructionLevel = value;
          if (!generalObstructionLevels.containsKey(value)) {
            customObstructionLevels.add(value);
          }
          obstructionLevelAdditionalInfo = additionalInfo;
          break;
        case 28: // visibility
          selectedVisibilityOptions = value.split(' và ');
          for (var option in selectedVisibilityOptions) {
            if (!visibilityOptions.containsKey(option)) {
              customVisibilityOptions.add(option);
            }
          }
          visibilityAdditionalInfo = additionalInfo;
          break;
      }
    }

    _updateAttributeValues();
  }

  void _updateDebugInfo() {
    final List<Map<String, dynamic>> attributeValues =
        List<Map<String, dynamic>>.from(
          widget.reportData['attributeValues'] ?? [],
        );

    final visibilityObstructionAttributes =
        attributeValues
            .where(
              (item) =>
                  item['attributeId'] == 17 ||
                  item['attributeId'] == 18 ||
                  item['attributeId'] == 28,
            )
            .toList();

    _debugAttributeValues =
        'attributeValues:\n${visibilityObstructionAttributes.map((item) => '  - attributeId: ${item['attributeId']}\n'
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

    // Update obstruction type (attributeId: 17)
    String obstructionValue =
        hasObstruction == 'không'
            ? 'không có chướng ngại'
            : combinedObstructionType;
    _updateSingleAttribute(
      attributeValues,
      17,
      obstructionValue,
      obstructionAdditionalInfo,
    );

    // Update obstruction level (attributeId: 18)
    _updateSingleAttribute(
      attributeValues,
      18,
      selectedObstructionLevel ?? '',
      obstructionLevelAdditionalInfo,
    );

    // Update visibility (attributeId: 28) for siteCategoryId == 1
    if (siteCategoryId == 1) {
      String visibilityValue =
          selectedVisibilityOptions.isEmpty
              ? ''
              : selectedVisibilityOptions.join(' và ');
      _updateSingleAttribute(
        attributeValues,
        28,
        visibilityValue,
        visibilityAdditionalInfo,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.setState(() {
        widget.reportData['attributeValues'] = attributeValues;
        widget.reportData['changedAttributeValues'] =
            List<Map<String, dynamic>>.from(changedAttributeValues);
        widget.reportData['newAttributeValues'] =
            List<Map<String, dynamic>>.from(newAttributeValues);
        widget.reportData['visibilityAndObstruction'] = {
          'hasObstruction': hasObstruction,
          'obstructionType': obstructionValue,
          'selectedObstructionCategories': selectedObstructionCategories,
          'selectedObstructionDetails': selectedObstructionDetails,
          'obstructionLevel': selectedObstructionLevel,
          'visibility':
              selectedVisibilityOptions.isEmpty
                  ? ''
                  : selectedVisibilityOptions.join(' và '),
          'selectedVisibilityOptions': selectedVisibilityOptions,
          'obstructionAdditionalInfo': obstructionAdditionalInfo,
          'obstructionLevelAdditionalInfo': obstructionLevelAdditionalInfo,
          'visibilityAdditionalInfo': visibilityAdditionalInfo,
          'customObstructionCategories': customObstructionCategories,
          'customObstructionDetails': customObstructionDetails,
          'customObstructionLevels': customObstructionLevels,
          'customVisibilityOptions': customVisibilityOptions,
        };
      });
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

  void _updateOrAddAttributeValue(
    List<Map<String, dynamic>> attributeValues,
    int attributeId,
    String value,
    String additionalInfo,
  ) {
    final int index = attributeValues.indexWhere(
      (element) => element['attributeId'] == attributeId,
    );

    if (index != -1) {
      attributeValues[index]['value'] = value;
      attributeValues[index]['additionalInfo'] = additionalInfo;
    } else if (value.isNotEmpty) {
      attributeValues.add({
        'attributeId': attributeId,
        'siteId': widget.reportData['siteId'] ?? 0,
        'value': value,
        'additionalInfo': additionalInfo,
      });
    }
  }

  void _handleObstructionCategorySelected(String option) {
    setState(() {
      if (selectedObstructionCategories.contains(option)) {
        selectedObstructionCategories.remove(option);
        selectedObstructionDetails.remove(option);
      } else {
        selectedObstructionCategories.add(option);
      }
      _updateAttributeValues();
    });
  }

  void _handleObstructionDetailSelected(String category, String detail) {
    setState(() {
      if (selectedObstructionDetails[category] == detail) {
        selectedObstructionDetails.remove(category);
      } else {
        selectedObstructionDetails[category] = detail;
      }
      _updateAttributeValues();
    });
  }

  void _handleObstructionLevelSelected(String option) {
    setState(() {
      selectedObstructionLevel =
          selectedObstructionLevel == option ? null : option;
      _updateAttributeValues();
    });
  }

  void _handleVisibilityOptionSelected(String option) {
    setState(() {
      if (selectedVisibilityOptions.contains(option)) {
        selectedVisibilityOptions.remove(option);
      } else {
        selectedVisibilityOptions.add(option);
      }
      _updateAttributeValues();
    });
  }

  void _handleCustomCategoryAdded(String option) {
    setState(() {
      customObstructionCategories.add(option);
      selectedObstructionCategories.add(option);
      obstructionLevels[option] = {
        'ít': Icons.filter_1,
        'trung bình': Icons.filter_2,
        'nhiều': Icons.filter_3,
      };
      _updateAttributeValues();
    });
  }

  void _handleCustomCategoryRemoved(String option) {
    setState(() {
      customObstructionCategories.remove(option);
      selectedObstructionCategories.remove(option);
      selectedObstructionDetails.remove(option);
      _updateAttributeValues();
    });
  }

  void _handleCustomDetailAdded(String category, String option) {
    setState(() {
      customObstructionDetails.add(option);
      selectedObstructionDetails[category] = option;
      _updateAttributeValues();
    });
  }

  void _handleCustomDetailRemoved(String category, String option) {
    setState(() {
      customObstructionDetails.remove(option);
      if (selectedObstructionDetails[category] == option) {
        selectedObstructionDetails.remove(category);
      }
      _updateAttributeValues();
    });
  }

  void _handleCustomLevelAdded(String option) {
    setState(() {
      customObstructionLevels.add(option);
      selectedObstructionLevel = option;
      _updateAttributeValues();
    });
  }

  void _handleCustomLevelRemoved(String option) {
    setState(() {
      customObstructionLevels.remove(option);
      if (selectedObstructionLevel == option) {
        selectedObstructionLevel = null;
      }
      _updateAttributeValues();
    });
  }

  void _handleCustomVisibilityAdded(String option) {
    setState(() {
      customVisibilityOptions.add(option);
      selectedVisibilityOptions.add(option);
      _updateAttributeValues();
    });
  }

  void _handleCustomVisibilityRemoved(String option) {
    setState(() {
      customVisibilityOptions.remove(option);
      selectedVisibilityOptions.remove(option);
      _updateAttributeValues();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String obstructionTitle =
        siteCategoryId == 1 ? 'Vật che chắn tòa nhà' : 'Vật che chắn mặt bằng';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VI. Tầm nhìn và Chướng ngại',
            style: widget.theme.textTheme.titleLarge?.copyWith(
              color: widget.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          InfoCard(
            icon: Icons.lightbulb_outline,
            content:
                'Kiểm tra các chướng ngại cản tầm nhìn và mức độ thoáng đãng của không gian.',
            backgroundColor: widget.theme.colorScheme.tertiaryFixed,
            iconColor: widget.theme.colorScheme.secondary,
            borderRadius: 20.0,
            padding: const EdgeInsets.all(20.0),
          ),
          const SizedBox(height: 16),
          AnimatedExpansionCard(
            icon: Icons.block,
            title: obstructionTitle,
            subtitle:
                hasObstruction == 'có'
                    ? (combinedObstructionType.isNotEmpty
                        ? combinedObstructionType
                        : 'Chưa chọn loại')
                    : hasObstruction == 'không'
                    ? 'Không có chướng ngại'
                    : 'Chưa chọn',
            theme: widget.theme,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Có vật che chắn không?',
                        style: widget.theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 16),
                      Radio<String>(
                        value: 'có',
                        groupValue: hasObstruction,
                        onChanged: (value) {
                          setState(() {
                            hasObstruction = value;
                            if (value == 'không') {
                              selectedObstructionCategories.clear();
                              selectedObstructionDetails.clear();
                            }
                            _updateAttributeValues();
                          });
                        },
                      ),
                      const Text('Có'),
                      const SizedBox(width: 16),
                      Radio<String>(
                        value: 'không',
                        groupValue: hasObstruction,
                        onChanged: (value) {
                          setState(() {
                            hasObstruction = value;
                            selectedObstructionCategories.clear();
                            selectedObstructionDetails.clear();
                            _updateAttributeValues();
                          });
                        },
                      ),
                      const Text('Không'),
                    ],
                  ),
                  if (hasObstruction == 'có') ...[
                    const SizedBox(height: 16),
                    Text(
                      'Loại vật che chắn:',
                      style: widget.theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    CustomChipGroup(
                      options: obstructionCategories.keys.toList(),
                      selectedOptions: selectedObstructionCategories,
                      customOptions: customObstructionCategories,
                      optionIcons: obstructionCategories,
                      onOptionSelected: _handleObstructionCategorySelected,
                      onCustomOptionAdded: _handleCustomCategoryAdded,
                      onCustomOptionRemoved: _handleCustomCategoryRemoved,
                      showOtherInputOnlyWhenSelected: true,
                      otherOptionKey: 'khác',
                    ),
                    ...selectedObstructionCategories.map((category) {
                      final detailOptions =
                          obstructionLevels[category]?.keys.toList() ?? [];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: widget.theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      obstructionCategories[category] ??
                                          Icons.help_outline,
                                      color: widget.theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Chi tiết cho: $category',
                                      style: widget.theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Builder(
                                  builder: (context) {
                                    final List<String> selectedForCategory = [];
                                    if (selectedObstructionDetails.containsKey(
                                      category,
                                    )) {
                                      selectedForCategory.add(
                                        selectedObstructionDetails[category]!,
                                      );
                                    }
                                    return CustomChipGroup(
                                      options: detailOptions,
                                      selectedOptions: selectedForCategory,
                                      customOptions:
                                          customObstructionDetails
                                              .where(
                                                (detail) =>
                                                    selectedObstructionDetails[category] ==
                                                    detail,
                                              )
                                              .toList(),
                                      optionIcons:
                                          obstructionLevels[category] ?? {},
                                      onOptionSelected:
                                          (detail) =>
                                              _handleObstructionDetailSelected(
                                                category,
                                                detail,
                                              ),
                                      onCustomOptionAdded:
                                          (detail) => _handleCustomDetailAdded(
                                            category,
                                            detail,
                                          ),
                                      onCustomOptionRemoved:
                                          (detail) =>
                                              _handleCustomDetailRemoved(
                                                category,
                                                detail,
                                              ),
                                      showOtherInputOnlyWhenSelected: true,
                                      otherOptionKey: 'khác',
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),
                    CustomInputField(
                      label: 'Thông tin bổ sung',
                      hintText: 'Mô tả thêm về vật che chắn',
                      icon: Icons.info_outline,
                      initialValue: obstructionAdditionalInfo,
                      onSaved: (value) {
                        setState(() {
                          obstructionAdditionalInfo = value;
                          _updateAttributeValues();
                        });
                      },
                      theme: widget.theme,
                      isDescription: true,
                    ),
                  ],
                ],
              ),
            ],
          ),
          AnimatedExpansionCard(
            icon: Icons.bar_chart,
            title: 'Mức độ che chắn tổng thể',
            subtitle: selectedObstructionLevel ?? 'Chưa chọn',
            theme: widget.theme,
            children: [
              CustomChipGroup(
                options: generalObstructionLevels.keys.toList(),
                selectedOptions:
                    selectedObstructionLevel != null
                        ? [selectedObstructionLevel!]
                        : [],
                customOptions: customObstructionLevels,
                optionIcons: generalObstructionLevels,
                onOptionSelected: _handleObstructionLevelSelected,
                onCustomOptionAdded: _handleCustomLevelAdded,
                onCustomOptionRemoved: _handleCustomLevelRemoved,
                showOtherInputOnlyWhenSelected: true,
                otherOptionKey: 'khác',
              ),
              const SizedBox(height: 8),
              CustomInputField(
                label: 'Thông tin bổ sung',
                hintText: 'Mô tả thêm về mức độ che chắn',
                icon: Icons.info_outline,
                initialValue: obstructionLevelAdditionalInfo,
                onSaved: (value) {
                  setState(() {
                    obstructionLevelAdditionalInfo = value;
                    _updateAttributeValues();
                  });
                },
                theme: widget.theme,
                isDescription: true,
              ),
            ],
          ),
          if (siteCategoryId == 1)
            AnimatedExpansionCard(
              icon: Icons.remove_red_eye,
              title: 'Tầm nhìn từ mặt bằng',
              subtitle:
                  selectedVisibilityOptions.isEmpty
                      ? 'Chưa chọn'
                      : selectedVisibilityOptions.join(' và '),
              theme: widget.theme,
              children: [
                CustomChipGroup(
                  options: visibilityOptions.keys.toList(),
                  selectedOptions: selectedVisibilityOptions,
                  customOptions: customVisibilityOptions,
                  optionIcons: visibilityOptions,
                  onOptionSelected: _handleVisibilityOptionSelected,
                  onCustomOptionAdded: _handleCustomVisibilityAdded,
                  onCustomOptionRemoved: _handleCustomVisibilityRemoved,
                  showOtherInputOnlyWhenSelected: true,
                  otherOptionKey: 'khác',
                ),
                const SizedBox(height: 8),
                CustomInputField(
                  label: 'Thông tin bổ sung',
                  hintText: 'Mô tả thêm về tầm nhìn từ mặt bằng',
                  icon: Icons.info_outline,
                  initialValue: visibilityAdditionalInfo,
                  onSaved: (value) {
                    setState(() {
                      visibilityAdditionalInfo = value;
                      _updateAttributeValues();
                    });
                  },
                  theme: widget.theme,
                  isDescription: true,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
