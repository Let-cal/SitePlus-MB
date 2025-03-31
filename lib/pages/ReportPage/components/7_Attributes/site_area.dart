import 'package:flutter/material.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/animated_expansion_card.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/custom_chip_group.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/info_card.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/selectable_option_button.dart';
import 'package:siteplus_mb/components/custom_input_field.dart';

class SiteAreaSection extends StatefulWidget {
  final Map<String, dynamic> reportData;
  final Function(void Function()) setState;
  final ThemeData theme;

  const SiteAreaSection({
    super.key,
    required this.reportData,
    required this.setState,
    required this.theme,
  });

  @override
  SiteAreaSectionState createState() => SiteAreaSectionState();
}

class SiteAreaSectionState extends State<SiteAreaSection> {
  late Map<String, dynamic> localSiteData;
  List<Map<String, dynamic>> newAttributeValues = []; // Lưu giá trị mới
  List<Map<String, dynamic>> changedAttributeValues =
      []; // Lưu giá trị cập nhật
  late List<Map<String, dynamic>> originalAttributeValues; // Lưu giá trị gốc
  String _debugAttributeValues = '';

  final Map<String, int> attributeIds = {
    'totalArea': 9, // Diện tích tổng
    'shapes': 10, // Hình dạng mặt bằng
    'condition': 11, // Tình trạng mặt bằng
    'roadDistance': 34, // Khoảng cách so với mặt đường
    'frontageWidth': 35, // Bề ngang mặt tiền
  };

  final List<Map<String, dynamic>> areaStandards = [
    {
      "industryId": 2,
      "industryName": "F&B",
      "categories": [
        {
          "categoryId": 1,
          "categoryName": "Nhà hàng bình dân",
          "minArea": 20,
          "avgArea": 50,
          "goodArea": 100,
        },
        {
          "categoryId": 2,
          "categoryName": "Nhà hàng sang trọng",
          "minArea": 120,
          "avgArea": 200,
          "goodArea": 300,
        },
      ],
    },
    {
      "industryId": 3,
      "industryName": "Bán lẻ",
      "categories": [
        {
          "categoryId": 3,
          "categoryName": "Siêu thị",
          "minArea": 200,
          "avgArea": 500,
          "goodArea": 1000,
        },
        {
          "categoryId": 4,
          "categoryName": "Cửa hàng tiện lợi",
          "minArea": 20,
          "avgArea": 50,
          "goodArea": 80,
        },
      ],
    },
    {
      "industryId": 4,
      "industryName": "Ngân hàng",
      "categories": [
        {
          "categoryId": 5,
          "categoryName": "Ngân hàng thương mại",
          "minArea": 100,
          "avgArea": 200,
          "goodArea": 300,
        },
        {
          "categoryId": 6,
          "categoryName": "Ngân hàng đầu tư",
          "minArea": 150,
          "avgArea": 250,
          "goodArea": 400,
        },
      ],
    },
    {
      "industryId": 5,
      "industryName": "Thời trang",
      "categories": [
        {
          "categoryId": 5,
          "categoryName": "Cửa hàng thời trang bình dân",
          "minArea": 20,
          "avgArea": 50,
          "goodArea": 100,
        },
        {
          "categoryId": 6,
          "categoryName": "Cửa hàng thời trang cao cấp",
          "minArea": 50,
          "avgArea": 100,
          "goodArea": 150,
        },
      ],
    },
  ];

  final Map<String, IconData> shapeIcons = {
    'Hình vuông': Icons.square,
    'Dài hẹp': Icons.rectangle,
    'Hình chữ L': Icons.signpost,
    'Khác': Icons.extension,
  };

  final Map<String, IconData> conditionIcons = {
    'Hoàn thành': Icons.check_circle,
    'Đang thi công': Icons.construction,
    'Cần sửa chữa nhỏ': Icons.handyman,
    'Cần sửa chữa lớn': Icons.warning,
  };

  final Map<String, String> conditionDescriptions = {
    'Hoàn thành': 'Mặt bằng đã sẵn sàng sử dụng',
    'Đang thi công': 'Mặt bằng đang trong quá trình xây dựng, cần chờ đợi',
    'Cần sửa chữa nhỏ': 'Bị hư hại không nhiều',
    'Cần sửa chữa lớn': 'Có nhiều hư hại lớn, cần sửa chữa đáng kể',
  };

  final Map<String, String> shapeDescriptions = {
    'Hình vuông': 'Mặt bằng vuông',
    'Dài hẹp': 'Mặt bằng hình chữ nhật dài',
    'Hình chữ L': 'Mặt bằng hình chữ L',
    'Khác': 'Mặt bằng có hình dạng đặc biệt',
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAttributeValues();
      _updateDebugInfo();
    });
  }

  void _initializeData() {
    localSiteData = Map<String, dynamic>.from(
      widget.reportData['siteArea'] ?? {},
    );
    originalAttributeValues = List<Map<String, dynamic>>.from(
      widget.reportData['attributeValues'] ?? [],
    );
    newAttributeValues = List<Map<String, dynamic>>.from(
      widget.reportData['newAttributeValues'] ?? [],
    );

    localSiteData['totalArea'] = (localSiteData['totalArea'] ?? '').toString();
    localSiteData['frontageWidth'] =
        (localSiteData['frontageWidth'] ?? '').toString();
    localSiteData['roadDistance'] =
        (localSiteData['roadDistance'] ?? '').toString();
    localSiteData['condition'] = (localSiteData['condition'] ?? '').toString();
    localSiteData['shapes'] = localSiteData['shapes'] ?? <String>[];
    localSiteData['customShapes'] = localSiteData['customShapes'] ?? <String>[];

    _populateFromAttributeValues();
  }

  void _populateFromAttributeValues() {
    if (widget.reportData['attributeValues'] == null) return;

    List<dynamic> attributeValues = widget.reportData['attributeValues'];

    // Total Area (attributeId: 9)
    final areaAttribute = attributeValues.firstWhere(
      (attr) => attr['attributeId'] == attributeIds['totalArea'],
      orElse: () => <String, dynamic>{},
    );
    if (areaAttribute.isNotEmpty) {
      localSiteData['totalArea'] = (areaAttribute['value'] ?? '').toString();
    }

    // Frontage Width (attributeId: 35)
    final frontageAttribute = attributeValues.firstWhere(
      (attr) => attr['attributeId'] == attributeIds['frontageWidth'],
      orElse: () => <String, dynamic>{},
    );
    if (frontageAttribute.isNotEmpty) {
      localSiteData['frontageWidth'] =
          (frontageAttribute['value'] ?? '').toString();
    }

    // Road Distance (attributeId: 34)
    final roadDistanceAttribute = attributeValues.firstWhere(
      (attr) => attr['attributeId'] == attributeIds['roadDistance'],
      orElse: () => <String, dynamic>{},
    );
    if (roadDistanceAttribute.isNotEmpty) {
      localSiteData['roadDistance'] =
          (roadDistanceAttribute['value'] ?? '').toString();
    }

    // Condition (attributeId: 11)
    final conditionAttribute = attributeValues.firstWhere(
      (attr) => attr['attributeId'] == attributeIds['condition'],
      orElse: () => <String, dynamic>{},
    );
    if (conditionAttribute.isNotEmpty) {
      localSiteData['condition'] =
          (conditionAttribute['value'] ?? '').toString();
    }

    // Shapes (attributeId: 10)
    final shapeAttribute = attributeValues.firstWhere(
      (attr) => attr['attributeId'] == attributeIds['shapes'],
      orElse: () => <String, dynamic>{},
    );
    if (shapeAttribute.isNotEmpty) {
      String shapeValue = shapeAttribute['value'] ?? '';
      if (shapeIcons.containsKey(shapeValue)) {
        localSiteData['shapes'] = [shapeValue];
      } else {
        localSiteData['customShapes'] = [shapeValue];
      }
    }
  }

  void _updateDebugInfo() {
    final List<Map<String, dynamic>> attributeValues =
        List<Map<String, dynamic>>.from(
          widget.reportData['attributeValues'] ?? [],
        );
    final siteAreaAttributes =
        attributeValues
            .where((item) => attributeIds.values.contains(item['attributeId']))
            .toList();

    _debugAttributeValues =
        'attributeValues:\n${siteAreaAttributes.map((item) => '  - attributeId: ${item['attributeId']}\n'
        '    id: ${item['id']}\n'
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

    // Xử lý Total Area (attributeId: 9)
    if (localSiteData['totalArea'].isNotEmpty) {
      final formattedValue =
          localSiteData['totalArea'].contains('m²')
              ? localSiteData['totalArea']
              : '${localSiteData['totalArea']} m²';
      final additionalInfo = _getAreaAdditionalInfo(localSiteData['totalArea']);
      _updateSingleAttribute(
        attributeValues,
        attributeIds['totalArea']!,
        formattedValue,
        additionalInfo,
      );
    }

    // Xử lý Frontage Width (attributeId: 35)
    if (localSiteData['frontageWidth'].isNotEmpty) {
      final formattedValue =
          localSiteData['frontageWidth'].contains('m')
              ? localSiteData['frontageWidth']
              : '${localSiteData['frontageWidth']} m';
      final additionalInfo = _getFrontageAdditionalInfo(
        localSiteData['frontageWidth'],
      );
      _updateSingleAttribute(
        attributeValues,
        attributeIds['frontageWidth']!,
        formattedValue,
        additionalInfo,
      );
    }

    // Xử lý Road Distance (attributeId: 34)
    if (localSiteData['roadDistance'].isNotEmpty) {
      final formattedValue =
          localSiteData['roadDistance'].contains('m')
              ? localSiteData['roadDistance']
              : '${localSiteData['roadDistance']} m';
      final additionalInfo = _getRoadDistanceAdditionalInfo(
        localSiteData['roadDistance'],
      );
      _updateSingleAttribute(
        attributeValues,
        attributeIds['roadDistance']!,
        formattedValue,
        additionalInfo,
      );
    }

    // Xử lý Condition (attributeId: 11)
    if (localSiteData['condition'].isNotEmpty) {
      final conditionValue = localSiteData['condition'];
      final additionalInfo =
          conditionDescriptions[conditionValue] ??
          'Tình trạng mặt bằng: $conditionValue';
      _updateSingleAttribute(
        attributeValues,
        attributeIds['condition']!,
        conditionValue,
        additionalInfo,
      );
    }

    // Xử lý Shapes (attributeId: 10)
    List<String> shapes = List<String>.from(localSiteData['shapes'] ?? []);
    List<String> customShapes = List<String>.from(
      localSiteData['customShapes'] ?? [],
    );
    if (shapes.isNotEmpty || customShapes.isNotEmpty) {
      final selectedShape =
          shapes.isNotEmpty ? shapes.first : customShapes.first;
      final additionalInfo =
          shapes.isNotEmpty
              ? (shapeDescriptions[selectedShape] ??
                  'Hình dạng mặt bằng: $selectedShape')
              : 'Mặt bằng hình dạng đặc biệt: $selectedShape';
      _updateSingleAttribute(
        attributeValues,
        attributeIds['shapes']!,
        selectedShape,
        additionalInfo,
      );
    }

    widget.setState(() {
      widget.reportData['siteArea'] = localSiteData;
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

  String _getAreaAdditionalInfo(String areaText) {
    if (areaText.isEmpty) return '';
    double? area;
    try {
      final numericText = areaText.replaceAll(RegExp(r'[^0-9.]'), '');
      area = double.tryParse(numericText);
    } catch (e) {
      return 'Không thể xác định diện tích';
    }
    if (area == null) return 'Không thể xác định diện tích';

    List<String> suitableCategories = [];
    List<String> minimumCategories = [];
    List<String> goodCategories = [];

    for (var industry in areaStandards) {
      for (var category in industry['categories']) {
        final categoryName = category['categoryName'];
        final minArea = category['minArea'];
        final avgArea = category['avgArea'];
        final goodArea = category['goodArea'];
        if (area >= goodArea) {
          goodCategories.add(categoryName);
        } else if (area >= avgArea) {
          suitableCategories.add(categoryName);
        } else if (area >= minArea) {
          minimumCategories.add(categoryName);
        }
      }
    }

    String feedback = '';
    if (goodCategories.isNotEmpty) {
      feedback += 'Diện tích lý tưởng cho: ${goodCategories.join(", ")}. ';
    }
    if (suitableCategories.isNotEmpty) {
      feedback += 'Diện tích phù hợp với: ${suitableCategories.join(", ")}. ';
    }
    if (minimumCategories.isNotEmpty) {
      feedback +=
          'Đạt mức diện tích tối thiểu cho: ${minimumCategories.join(", ")}. ';
    }
    if (feedback.isEmpty) {
      feedback =
          'Diện tích không đạt yêu cầu tối thiểu cho bất kỳ loại hình kinh doanh nào.';
    }
    return feedback;
  }

  String _getFrontageAdditionalInfo(String widthText) {
    if (widthText.isEmpty) return '';
    double? width;
    try {
      final numericText = widthText.replaceAll(RegExp(r'[^0-9.]'), '');
      width = double.tryParse(numericText);
    } catch (e) {
      return 'Không thể xác định bề ngang mặt tiền';
    }
    if (width == null) return 'Không thể xác định bề ngang mặt tiền';
    return width < 6
        ? 'Mặt tiền < 6m, không gian sẽ bị chật và hạn chế'
        : 'Bề ngang mặt tiền ổn định, phù hợp với một số ngành hàng';
  }

  String _getRoadDistanceAdditionalInfo(String distanceText) {
    if (distanceText.isEmpty) return '';
    double? distance;
    try {
      final numericText = distanceText.replaceAll(RegExp(r'[^0-9.]'), '');
      distance = double.tryParse(numericText);
    } catch (e) {
      return 'Không thể xác định khoảng cách so với mặt đường';
    }
    if (distance == null) {
      return 'Không thể xác định khoảng cách so với mặt đường';
    }
    if (distance < 2) {
      return 'Khoảng cách < 2m, quá gần mặt đường, hạn chế không gian.';
    } else if (distance >= 2 && distance <= 4) {
      return 'Khoảng cách 2-4m, lý tưởng cho nhiều loại hình kinh doanh.';
    } else if (distance > 4 && distance <= 5) {
      return 'Khoảng cách 4-5m, có thêm không gian cho tiện ích.';
    } else {
      return 'Khoảng cách > 5m, khá xa, cần chỉ dẫn rõ ràng.';
    }
  }

  void _handleShapeSelection(String shape) {
    setState(() {
      List<String> shapes = List<String>.from(localSiteData['shapes'] ?? []);
      if (shapes.contains(shape)) {
        shapes.remove(shape);
      } else {
        shapes = [shape]; // Chỉ cho phép chọn 1 giá trị
      }
      localSiteData['shapes'] = shapes;
      localSiteData['customShapes'] =
          []; // Reset custom shapes khi chọn shape chuẩn
      _updateAttributeValues();
    });
  }

  void _handleCustomShapeAdded(String shape) {
    setState(() {
      List<String> customShapes = List<String>.from(
        localSiteData['customShapes'] ?? [],
      );
      if (!customShapes.contains(shape)) {
        customShapes.add(shape);
        localSiteData['customShapes'] = customShapes;
        localSiteData['shapes'] = []; // Reset shapes khi thêm custom shape
        _updateAttributeValues();
      }
    });
  }

  void _handleCustomShapeRemoved(String shape) {
    setState(() {
      List<String> customShapes = List<String>.from(
        localSiteData['customShapes'] ?? [],
      );
      customShapes.remove(shape);
      localSiteData['customShapes'] = customShapes;
      _updateAttributeValues();
    });
  }

  void _handleConditionSelection(String condition) {
    setState(() {
      localSiteData['condition'] = condition;
      _updateAttributeValues();
    });
  }

  String get _totalSelectedShapes {
    final selectedShapes =
        (localSiteData['shapes'] as List<dynamic>? ?? []).length;
    final customShapes =
        (localSiteData['customShapes'] as List<dynamic>? ?? []).length;
    final total = selectedShapes + customShapes;
    if (total == 0) return 'Chưa chọn';
    return selectedShapes > 0
        ? (localSiteData['shapes'] as List<dynamic>).first.toString()
        : '${localSiteData['customShapes'].first}';
  }

  @override
  Widget build(BuildContext context) {
    String getInitialValue(String? value) {
      return (value == null || value == "0" || value.isEmpty) ? '' : value;
    }

    final bool showFrontageWidth = widget.reportData['siteCategoryId'] == 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IV. Mặt Bằng',
            style: widget.theme.textTheme.titleLarge?.copyWith(
              color: widget.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          InfoCard(
            icon: Icons.lightbulb_outline,
            content:
                'Cung cấp kích thước, hình dạng và tình trạng của mặt bằng.',
            backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
            iconColor: Theme.of(context).colorScheme.secondary,
            borderRadius: 20.0,
            padding: const EdgeInsets.all(20.0),
          ),
          const SizedBox(height: 12),

          // Diện tích tổng
          AnimatedExpansionCard(
            icon: Icons.area_chart,
            title: 'Diện tích tổng',
            subtitle:
                localSiteData['totalArea'].isNotEmpty
                    ? '${localSiteData['totalArea']}'
                    : 'Chưa chỉ định',
            theme: widget.theme,
            children: [
              CustomInputField(
                label: 'Diện tích tổng (m²)',
                hintText: 'Ví dụ 120(m²)',
                suffixText: 'm2',
                icon: Icons.edit,
                theme: widget.theme,
                initialValue: getInitialValue(localSiteData['totalArea']),
                keyboardType: TextInputType.number,
                numbersOnly: true,
                onSaved: (value) {
                  setState(() {
                    localSiteData['totalArea'] = value;
                    _updateAttributeValues();
                  });
                },
              ),
            ],
          ),

          // Bề ngang mặt tiền
          if (showFrontageWidth)
            AnimatedExpansionCard(
              icon: Icons.straighten,
              title: 'Bề ngang mặt tiền',
              subtitle:
                  localSiteData['frontageWidth'].isNotEmpty
                      ? '${localSiteData['frontageWidth']}'
                      : 'Chưa chỉ định',
              theme: widget.theme,
              children: [
                CustomInputField(
                  label: 'Bề ngang mặt tiền (m)',
                  hintText: 'Ví dụ 6(m)',
                  suffixText: 'm',
                  icon: Icons.edit,
                  theme: widget.theme,
                  initialValue: getInitialValue(localSiteData['frontageWidth']),
                  keyboardType: TextInputType.number,
                  numbersOnly: true,
                  onSaved: (value) {
                    setState(() {
                      localSiteData['frontageWidth'] = value;
                      _updateAttributeValues();
                    });
                  },
                ),
              ],
            ),

          // Khoảng cách so với mặt đường
          if (showFrontageWidth)
            AnimatedExpansionCard(
              icon: Icons.space_bar,
              title: 'Khoảng cách so với mặt đường',
              subtitle:
                  localSiteData['roadDistance'].isNotEmpty
                      ? '${localSiteData['roadDistance']}'
                      : 'Chưa chỉ định',
              theme: widget.theme,
              children: [
                CustomInputField(
                  label: 'Khoảng cách so với mặt đường (m)',
                  hintText: 'Ví dụ 3(m)',
                  suffixText: 'm',
                  icon: Icons.edit,
                  theme: widget.theme,
                  initialValue: getInitialValue(localSiteData['roadDistance']),
                  keyboardType: TextInputType.number,
                  numbersOnly: true,
                  onSaved: (value) {
                    setState(() {
                      localSiteData['roadDistance'] = value;
                      _updateAttributeValues();
                    });
                  },
                ),
              ],
            ),

          // Hình dạng mặt bằng
          AnimatedExpansionCard(
            icon: Icons.crop_square,
            title: 'Hình dạng Mặt Bằng',
            subtitle: _totalSelectedShapes,
            theme: widget.theme,
            children: [
              CustomChipGroup(
                options: shapeIcons.keys.toList(),
                selectedOptions: List<String>.from(
                  localSiteData['shapes'] ?? [],
                ),
                customOptions: List<String>.from(
                  localSiteData['customShapes'] ?? [],
                ),
                optionIcons: shapeIcons,
                onOptionSelected: _handleShapeSelection,
                onCustomOptionAdded: _handleCustomShapeAdded,
                onCustomOptionRemoved: _handleCustomShapeRemoved,
                showOtherInputOnlyWhenSelected: true,
                otherOptionKey: 'Khác',
              ),
            ],
          ),

          // Tình trạng mặt bằng
          AnimatedExpansionCard(
            icon: Icons.construction,
            title: 'Tình trạng Mặt Bằng',
            subtitle:
                localSiteData['condition'].isNotEmpty
                    ? localSiteData['condition']
                    : 'Chưa chọn',
            theme: widget.theme,
            children: [
              Column(
                children:
                    conditionIcons.keys.map((String value) {
                      return SelectableOptionButton(
                        value: value,
                        icon: conditionIcons[value] ?? Icons.help_outline,
                        isSelected: localSiteData['condition'] == value,
                        onTap: () => _handleConditionSelection(value),
                        theme: widget.theme,
                      );
                    }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
