import 'package:flutter/material.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/animated_expansion_card.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/custom_chip_group.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/info_card.dart';
import 'package:siteplus_mb/components/custom_input_field.dart';
import 'package:siteplus_mb/utils/ReportPage/CustomerSegmentModel/customer_segment.dart';
import 'package:siteplus_mb/utils/constants.dart';

class CustomerConcentrationSection extends StatefulWidget {
  final Map<String, dynamic> reportData;
  final Function(void Function()) setState;
  final ThemeData theme;
  final int siteId;
  final List<CustomerSegment> customerSegments;

  const CustomerConcentrationSection({
    super.key,
    required this.reportData,
    required this.setState,
    required this.theme,
    required this.siteId,
    required this.customerSegments,
  });

  @override
  _CustomerConcentrationSectionState createState() =>
      _CustomerConcentrationSectionState();
}

class _CustomerConcentrationSectionState
    extends State<CustomerConcentrationSection> {
  late Map<String, dynamic> localCustomerData;
  List<String> selectedCustomerTypes = [];
  List<String> customCustomerTypes = [];
  Map<String, String> customerTypeAdditionalInfos = {};
  List<String> selectedCustomerCategories = [];
  Map<String, List<String>> selectedCustomerCalculations = {};
  Map<String, String> customerCalculationAmounts = {};
  List<Map<String, dynamic>> newAttributeValues = [];
  // Danh sách lưu các attributeValues đã thay đổi (bao gồm id)
  List<Map<String, dynamic>> changedAttributeValues = [];
  // Lưu trữ attributeValues gốc để so sánh thay đổi
  late List<Map<String, dynamic>> originalAttributeValues;

  String _debugAttributeValues = '';

  final Map<String, int> attributeIds = {
    'customerType': 4, // attributeId cho loại khách hàng
    'customerCount': 5, // attributeId cho số lượng khách trung bình
  };

  final List<String> customerCategoryOptions = [
    'Khách vãng lai',
    'Khách bản địa',
  ];
  final Map<String, IconData> customerCategoryIcons = {
    'Khách vãng lai': Icons.directions_walk,
    'Khách bản địa': Icons.home,
  };

  final List<String> calculationOptions = [
    'theo giờ',
    'theo ngày',
    'theo tuần',
  ];
  final Map<String, IconData> calculationIcons = {
    'theo giờ': Icons.access_time,
    'theo ngày': Icons.calendar_today,
    'theo tuần': Icons.calendar_view_week,
  };

  bool _dataInitialized = false;

  Map<String, IconData> getCustomerSegmentIcons() {
    Map<String, IconData> nameBasedIcons = {};
    for (var segment in widget.customerSegments) {
      nameBasedIcons[segment.name] =
          CUSTOMER_SEGMENT_ICONS[segment.id.toString()] ?? Icons.people;
    }
    return nameBasedIcons;
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
    // Hoãn việc cập nhật sau khi build hoàn tất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_dataInitialized) {
        final attributeValues = List<Map<String, dynamic>>.from(
          widget.reportData['attributeValues'] ?? [],
        );
        if (attributeValues.isNotEmpty) {
          _populateFromAttributeValues(attributeValues);
          _dataInitialized = true;
        }
      }
      _updateAttributeValues();
      _updateDebugInfo();
    });
  }

  void _initializeData() {
    localCustomerData = Map<String, dynamic>.from(
      widget.reportData['customerConcentration'] ?? {},
    );
    originalAttributeValues = List<Map<String, dynamic>>.from(
      widget.reportData['attributeValues'] ?? [],
    );
    newAttributeValues = List<Map<String, dynamic>>.from(
      widget.reportData['newAttributeValues'] ?? [],
    );
    selectedCustomerTypes = List<String>.from(
      localCustomerData['customerTypes'] ?? [],
    );
    customCustomerTypes = List<String>.from(
      localCustomerData['customCustomerTypes'] ?? [],
    );
    customerTypeAdditionalInfos = Map<String, String>.from(
      localCustomerData['customerTypeAdditionalInfo'] ?? {},
    );
    selectedCustomerCategories = List<String>.from(
      localCustomerData['selectedCustomerCategories'] ?? [],
    );
    selectedCustomerCalculations = Map<String, List<String>>.from(
      localCustomerData['selectedCustomerCalculations'] ?? {},
    );
    customerCalculationAmounts = Map<String, String>.from(
      localCustomerData['customerCalculationAmounts'] ?? {},
    );

    for (var category in selectedCustomerCategories) {
      selectedCustomerCalculations.putIfAbsent(category, () => []);
    }
  }

  void _populateFromAttributeValues(
    List<Map<String, dynamic>> attributeValues,
  ) {
    final customerTypeAttributes =
        attributeValues.where((attr) => attr['attributeId'] == 4).toList();
    final customerCountAttributes =
        attributeValues.where((attr) => attr['attributeId'] == 5).toList();

    // Xử lý loại khách hàng (attributeId: 4)
    for (var attr in customerTypeAttributes) {
      final String type = attr['value'];
      final String additionalInfo = attr['additionalInfo'] ?? '';

      bool isCustomType = !CUSTOMER_SEGMENTS.values.contains(type);

      if (!selectedCustomerTypes.contains(type)) {
        selectedCustomerTypes.add(type);
        if (isCustomType && !customCustomerTypes.contains(type)) {
          customCustomerTypes.add(type);
        }
      }

      if (additionalInfo.isNotEmpty) {
        customerTypeAdditionalInfos[type] = additionalInfo.replaceAll('%', '');
      }
    }

    // Xử lý số lượng khách trung bình (attributeId: 5)
    for (var attr in customerCountAttributes) {
      final String category = attr['value'];
      final String additionalInfo = attr['additionalInfo'] ?? '';

      if (customerCategoryOptions.contains(category) &&
          !selectedCustomerCategories.contains(category)) {
        selectedCustomerCategories.add(category);
        selectedCustomerCalculations[category] = [];
      }

      if (additionalInfo.isNotEmpty) {
        String calculation = '';
        if (additionalInfo.contains('người/giờ')) {
          calculation = 'theo giờ';
        } else if (additionalInfo.contains('người/ngày')) {
          calculation = 'theo ngày';
        } else if (additionalInfo.contains('người/tuần')) {
          calculation = 'theo tuần';
        }

        if (calculation.isNotEmpty) {
          if (!selectedCustomerCalculations[category]!.contains(calculation)) {
            selectedCustomerCalculations[category]!.add(calculation);
          }

          final RegExp regExp = RegExp(r'(\d+)');
          final match = regExp.firstMatch(additionalInfo);
          if (match != null) {
            customerCalculationAmounts['${category}_$calculation'] =
                match.group(1) ?? '';
          }
        }
      }
    }
  }

  void _updateAttributeValues() {
    final List<Map<String, dynamic>> attributeValues =
        List<Map<String, dynamic>>.from(
          widget.reportData['attributeValues'] ?? [],
        );

    // Xử lý loại khách hàng (attributeId: 4)
    for (String type in selectedCustomerTypes) {
      String additionalInfo = customerTypeAdditionalInfos[type] ?? '';
      if (additionalInfo.isNotEmpty && !additionalInfo.endsWith('%')) {
        additionalInfo = '$additionalInfo%';
        customerTypeAdditionalInfos[type] = additionalInfo;
      }

      // Tìm attribute value đã tồn tại trong originalAttributeValues
      final existingAttr = originalAttributeValues.firstWhere(
        (attr) =>
            attr['attributeId'] == attributeIds['customerType'] &&
            attr['value'] == type,
        orElse: () => {},
      );

      if (existingAttr['id'] != null) {
        // Nếu đã tồn tại (có id), cập nhật changedAttributeValues
        final changeIndex = changedAttributeValues.indexWhere(
          (attr) => attr['id'] == existingAttr['id'],
        );
        final updatedValue = {
          'id': existingAttr['id'],
          'value': type,
          'additionalInfo': additionalInfo,
        };
        if (changeIndex != -1) {
          changedAttributeValues[changeIndex] = updatedValue;
        } else {
          changedAttributeValues.add(updatedValue);
        }
      } else {
        // Nếu là mới, tìm và thay thế trong newAttributeValues dựa trên value
        final newIndex = newAttributeValues.indexWhere(
          (attr) =>
              attr['attributeId'] == attributeIds['customerType'] &&
              attr['value'] == type,
        );
        final newValue = {
          'attributeId': attributeIds['customerType'],
          'siteId': widget.siteId,
          'value': type,
          'additionalInfo': additionalInfo,
        };
        if (newIndex != -1) {
          newAttributeValues[newIndex] = newValue; // Thay thế bản ghi cũ
        } else if (additionalInfo.isNotEmpty) {
          newAttributeValues.add(
            newValue,
          ); // Chỉ thêm mới nếu có additionalInfo
        }
      }

      // Cập nhật attributeValues để hiển thị UI
      final index = attributeValues.indexWhere(
        (attr) => attr['id'] == existingAttr['id'],
      );
      final newValue = {
        'attributeId': attributeIds['customerType'],
        'siteId': widget.siteId,
        'value': type,
        'additionalInfo': additionalInfo,
        if (existingAttr['id'] != null) 'id': existingAttr['id'],
      };
      if (index != -1) {
        attributeValues[index] = newValue;
      } else {
        attributeValues.add(newValue);
      }
    }

    // Xử lý số lượng khách trung bình (attributeId: 5)
    selectedCustomerCalculations.forEach((category, calculations) {
      for (var calc in calculations) {
        String key = '${category}_$calc';
        String amount = customerCalculationAmounts[key] ?? '';
        if (amount.isNotEmpty) {
          String unit =
              calc == 'theo giờ'
                  ? 'người/giờ'
                  : calc == 'theo ngày'
                  ? 'người/ngày'
                  : 'người/tuần';
          String additionalInfo = '$amount $unit';

          // Tìm attribute value đã tồn tại trong originalAttributeValues
          final existingAttr = originalAttributeValues.firstWhere(
            (attr) =>
                attr['attributeId'] == attributeIds['customerCount'] &&
                attr['value'] == category &&
                attr['additionalInfo'].endsWith(unit),
            orElse: () => {},
          );

          if (existingAttr['id'] != null) {
            // Nếu đã tồn tại (có id), cập nhật changedAttributeValues
            final changeIndex = changedAttributeValues.indexWhere(
              (attr) => attr['id'] == existingAttr['id'],
            );
            final updatedValue = {
              'id': existingAttr['id'],
              'value': category,
              'additionalInfo': additionalInfo,
            };
            if (changeIndex != -1) {
              changedAttributeValues[changeIndex] = updatedValue;
            } else {
              changedAttributeValues.add(updatedValue);
            }
          } else {
            // Nếu là mới, thay thế trong newAttributeValues dựa trên value và unit
            final newIndex = newAttributeValues.indexWhere(
              (attr) =>
                  attr['attributeId'] == attributeIds['customerCount'] &&
                  attr['value'] == category &&
                  attr['additionalInfo'].endsWith(unit),
            );
            final newValue = {
              'attributeId': attributeIds['customerCount'],
              'siteId': widget.siteId,
              'value': category,
              'additionalInfo': additionalInfo,
            };
            if (newIndex != -1) {
              newAttributeValues[newIndex] = newValue; // Thay thế bản ghi cũ
            } else {
              newAttributeValues.add(newValue); // Thêm mới nếu chưa tồn tại
            }
          }

          // Cập nhật attributeValues để hiển thị UI
          final index = attributeValues.indexWhere(
            (attr) => attr['id'] == existingAttr['id'],
          );
          final newValue = {
            'attributeId': attributeIds['customerCount'],
            'siteId': widget.siteId,
            'value': category,
            'additionalInfo': additionalInfo,
            if (existingAttr['id'] != null) 'id': existingAttr['id'],
          };
          if (index != -1) {
            attributeValues[index] = newValue;
          } else {
            attributeValues.add(newValue);
          }
        }
      }
    });

    // Cập nhật reportData
    widget.setState(() {
      widget.reportData['customerConcentration'] = {
        'customerTypes': selectedCustomerTypes,
        'customCustomerTypes': customCustomerTypes,
        'customerTypeAdditionalInfo': customerTypeAdditionalInfos,
        'selectedCustomerCategories': selectedCustomerCategories,
        'selectedCustomerCalculations': selectedCustomerCalculations,
        'customerCalculationAmounts': customerCalculationAmounts,
      };
      widget.reportData['attributeValues'] = attributeValues;
      widget.reportData['changedAttributeValues'] =
          List<Map<String, dynamic>>.from(changedAttributeValues);
      widget.reportData['newAttributeValues'] = List<Map<String, dynamic>>.from(
        newAttributeValues,
      );
    });

    _updateDebugInfo();
  }

  void _updateDebugInfo() {
    final List<Map<String, dynamic>> attributeValues =
        List<Map<String, dynamic>>.from(
          widget.reportData['attributeValues'] ?? [],
        );
    final customerAttributes =
        attributeValues
            .where(
              (item) => item['attributeId'] == 4 || item['attributeId'] == 5,
            )
            .toList();

    _debugAttributeValues =
        'attributeValues:\n${customerAttributes.map((item) => '  - attributeId: ${item['attributeId']}\n'
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

  void _handleCustomerTypeSelected(String type) {
    setState(() {
      if (selectedCustomerTypes.contains(type)) {
        selectedCustomerTypes.remove(type);
        customerTypeAdditionalInfos.remove(type);
      } else {
        selectedCustomerTypes.add(type);
      }
      _updateAttributeValues();
    });
  }

  void _handleCustomerCategorySelected(String category) {
    setState(() {
      if (selectedCustomerCategories.contains(category)) {
        selectedCustomerCategories.remove(category);
        selectedCustomerCalculations.remove(category);
        for (var calc in calculationOptions) {
          customerCalculationAmounts.remove('${category}_$calc');
        }
      } else {
        selectedCustomerCategories.add(category);
        selectedCustomerCalculations[category] = [];
      }
      _updateAttributeValues();
    });
  }

  void _handleCalculationSelected(String category, String calculation) {
    setState(() {
      if (selectedCustomerCalculations[category]!.contains(calculation)) {
        selectedCustomerCalculations[category]!.remove(calculation);
        customerCalculationAmounts.remove('${category}_$calculation');
      } else {
        selectedCustomerCalculations[category]!.add(calculation);
        customerCalculationAmounts['${category}_$calculation'] = '';
      }
      _updateAttributeValues();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> customerTypeOptions =
        widget.customerSegments.map((segment) => segment.name).toList();
    final Map<String, IconData> customerIcons = getCustomerSegmentIcons();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'II. Mật độ khách hàng',
            style: widget.theme.textTheme.titleLarge?.copyWith(
              color: widget.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          InfoCard(
            icon: Icons.lightbulb_outline,
            content: 'Xác định loại khách hàng và lưu lượng khách trung bình.',
            backgroundColor: widget.theme.colorScheme.tertiaryFixed,
            iconColor: widget.theme.colorScheme.secondary,
            borderRadius: 20.0,
            padding: const EdgeInsets.all(20.0),
          ),
          const SizedBox(height: 16),
          AnimatedExpansionCard(
            icon: Icons.group,
            title: 'Loại khách hàng',
            subtitle:
                selectedCustomerTypes.isEmpty
                    ? 'Chưa chọn'
                    : selectedCustomerTypes.join(', '),
            theme: widget.theme,
            children: [
              CustomChipGroup(
                options: customerTypeOptions,
                selectedOptions: selectedCustomerTypes,
                customOptions: customCustomerTypes,
                optionIcons: customerIcons,
                onOptionSelected: _handleCustomerTypeSelected,
                onCustomOptionAdded: (type) {
                  setState(() {
                    customCustomerTypes.add(type);
                    selectedCustomerTypes.add(type);
                    _updateAttributeValues();
                  });
                },
                onCustomOptionRemoved: (type) {
                  setState(() {
                    customCustomerTypes.remove(type);
                    selectedCustomerTypes.remove(type);
                    customerTypeAdditionalInfos.remove(type);
                    _updateAttributeValues();
                  });
                },
                showOtherInputOnlyWhenSelected: true,
                otherOptionKey: 'khác',
              ),
              const SizedBox(height: 12),
              ...selectedCustomerTypes.map((type) {
                return CustomInputField(
                  label: 'Thông tin bổ sung cho $type',
                  hintText: 'Ví dụ: 80%',
                  icon: customerIcons[type] ?? Icons.people,
                  initialValue:
                      customerTypeAdditionalInfos[type]?.replaceAll('%', '') ??
                      '',
                  theme: widget.theme,
                  suffixText: '%',
                  onSaved: (value) {
                    setState(() {
                      customerTypeAdditionalInfos[type] = value ?? '';
                      _updateAttributeValues();
                    });
                  },
                );
              }),
            ],
          ),
          AnimatedExpansionCard(
            icon: Icons.bar_chart,
            title: 'Số lượng khách trung bình',
            subtitle:
                selectedCustomerCategories.isEmpty
                    ? 'Chưa chọn'
                    : selectedCustomerCategories.join(', '),
            theme: widget.theme,
            children: [
              CustomChipGroup(
                options: customerCategoryOptions,
                selectedOptions: selectedCustomerCategories,
                customOptions: [],
                optionIcons: customerCategoryIcons,
                onOptionSelected: _handleCustomerCategorySelected,
                onCustomOptionAdded: null,
                onCustomOptionRemoved: null,
                showOtherInputOnlyWhenSelected: false,
              ),
              const SizedBox(height: 12),
              ...selectedCustomerCategories.map((category) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cách tính cho $category:',
                      style: widget.theme.textTheme.titleMedium,
                    ),
                    CustomChipGroup(
                      options: calculationOptions,
                      selectedOptions:
                          selectedCustomerCalculations[category] ?? [],
                      customOptions: [],
                      optionIcons: calculationIcons,
                      onOptionSelected:
                          (calc) => _handleCalculationSelected(category, calc),
                      onCustomOptionAdded: null,
                      onCustomOptionRemoved: null,
                      showOtherInputOnlyWhenSelected: false,
                    ),
                    const SizedBox(height: 8),
                    ...selectedCustomerCalculations[category]!.map((calc) {
                      String key = '${category}_$calc';
                      String unit =
                          calc == 'theo giờ'
                              ? 'người/giờ'
                              : calc == 'theo ngày'
                              ? 'người/ngày'
                              : 'người/tuần';
                      return CustomInputField(
                        key: ValueKey(key),
                        label: 'Số lượng $category $calc',
                        hintText: 'Nhập số lượng $category $calc',
                        icon: customerCategoryIcons[category] ?? Icons.people,
                        initialValue: customerCalculationAmounts[key] ?? '',
                        theme: widget.theme,
                        keyboardType: TextInputType.number,
                        numbersOnly: true,
                        suffixText: unit,
                        onSaved: (value) {
                          setState(() {
                            customerCalculationAmounts[key] = value ?? '';
                            _updateAttributeValues();
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 12),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
