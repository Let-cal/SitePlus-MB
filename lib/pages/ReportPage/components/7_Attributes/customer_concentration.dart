import 'dart:math';

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
  List<Map<String, dynamic>> changedAttributeValues = [];
  final Map<String, TextEditingController> customerCalculationControllers = {};
  late List<Map<String, dynamic>> originalAttributeValues;
  String _debugAttributeValues = '';

  final Map<String, int> attributeIds = {
    'customerType': 4,
    'customerCount': 5,
    'totalPopulation': 41,
  };

  final List<String> customerCategoryOptions = [
    'Khách vãng lai',
    'Khách bản địa',
  ];
  final Map<String, IconData> customerCategoryIcons = {
    'Khách vãng lai': Icons.directions_walk,
    'Khách bản địa': Icons.home,
  };

  final List<String> calculationOptions = ['theo giờ', 'theo ngày'];
  final Map<String, IconData> calculationIcons = {
    'theo giờ': Icons.access_time,
    'theo ngày': Icons.calendar_today,
  };

  bool _dataInitialized = false;

  final TextEditingController totalPopulationPerHourController =
      TextEditingController();
  final TextEditingController totalPopulationPerDayController =
      TextEditingController();
  String estimatedPerDay = '';

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
    // Initialize controllers from reportData
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
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

    totalPopulationPerHourController.addListener(() {
      setState(() {
        String hourStr = totalPopulationPerHourController.text.replaceAll(
          ',',
          '',
        );
        int? hour = int.tryParse(hourStr);
        estimatedPerDay =
            hour != null ? _formatNumber((hour * 24).toString()) : '';
      });
    });
    customerCalculationAmounts.forEach((key, value) {
      if (key.endsWith('_theo ngày')) {
        customerCalculationControllers[key] = TextEditingController(
          text: _formatNumber(value),
        );
      }
    });
  }

  String _formatNumber(String value) {
    if (value.isEmpty) return '';
    final number = int.tryParse(value.replaceAll(',', ''));
    if (number == null) return value;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // Thêm helper function để lấy giá trị số từ chuỗi đã được format
  int? _getNumberValue(String formattedValue) {
    if (formattedValue.isEmpty) return null;
    return int.tryParse(formattedValue.replaceAll(',', ''));
  }

  void _initializeControllers() {
    // Check for saved values in reportData and set the controllers
    if (widget.reportData.containsKey('totalPopulationPerHour')) {
      String hourValue =
          widget.reportData['totalPopulationPerHour']?.toString() ?? '';
      if (hourValue.isNotEmpty &&
          totalPopulationPerHourController.text != hourValue) {
        totalPopulationPerHourController.text = _formatNumber(hourValue);
      }
    }

    if (widget.reportData.containsKey('totalPopulationPerDay')) {
      String dayValue =
          widget.reportData['totalPopulationPerDay']?.toString() ?? '';
      if (dayValue.isNotEmpty &&
          totalPopulationPerDayController.text != dayValue) {
        totalPopulationPerDayController.text = _formatNumber(dayValue);
      }
    }
  }

  @override
  void didUpdateWidget(CustomerConcentrationSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If returning to this section, make sure controllers are updated
    if (widget.reportData != oldWidget.reportData) {
      _initializeControllers();
    }
  }

  @override
  void dispose() {
    totalPopulationPerHourController.dispose();
    totalPopulationPerDayController.dispose();
    customerCalculationControllers.forEach(
      (key, controller) => controller.dispose(),
    );
    customerCalculationControllers.clear();
    super.dispose();
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
    final totalPopulationAttribute = attributeValues.firstWhere(
      (attr) => attr['attributeId'] == 41,
      orElse: () => {},
    );

    // Populate total population with suggestion from CustomerFlowSection
    if (widget.reportData.containsKey('totalVehiclesPerHour')) {
      int? suggestedHour = widget.reportData['totalVehiclesPerHour'] as int?;
      if (suggestedHour != null &&
          totalPopulationPerHourController.text.isEmpty) {
        totalPopulationPerHourController.text = _formatNumber(
          suggestedHour.toString(),
        );
        widget.reportData['totalPopulationPerHour'] = suggestedHour;
      }
    }
    if (widget.reportData.containsKey('totalVehiclesPerDay')) {
      int? suggestedDay = widget.reportData['totalVehiclesPerDay'] as int?;
      if (suggestedDay != null &&
          totalPopulationPerDayController.text.isEmpty) {
        totalPopulationPerDayController.text = _formatNumber(
          suggestedDay.toString(),
        );
        widget.reportData['totalPopulationPerDay'] = suggestedDay;
      }
    }

    // Populate customer types
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
        RegExp regExp = RegExp(r'(\d+)');
        Match? match = regExp.firstMatch(additionalInfo);
        if (match != null) {
          customerTypeAdditionalInfos[type] = match.group(1) ?? '';
        }
      }
    }

    // Populate customer counts
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
          RegExp regExp = RegExp(r'(\d+)');
          Match? match = regExp.firstMatch(additionalInfo);
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

    // Handle total population (attributeId: 41)
    String hourStr = totalPopulationPerHourController.text.trim().replaceAll(
      ',',
      '',
    );
    String dayStr = totalPopulationPerDayController.text.trim().replaceAll(
      ',',
      '',
    );
    if (hourStr.isNotEmpty || dayStr.isNotEmpty) {
      String value =
          hourStr.isNotEmpty ? 'tổng số dân là $hourStr người/giờ' : '';
      String additionalInfo =
          dayStr.isNotEmpty
              ? 'tổng số dân ước tính trong ngày dự đoán là $dayStr người/ngày'
              : '';
      final existingAttr = originalAttributeValues.firstWhere(
        (attr) => attr['attributeId'] == 41,
        orElse: () => {},
      );
      final newValue = {
        'attributeId': 41,
        'siteId': widget.siteId,
        'value': value,
        'additionalInfo': additionalInfo,
        if (existingAttr['id'] != null) 'id': existingAttr['id'],
      };
      if (existingAttr['id'] != null) {
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
      } else {
        final newIndex = newAttributeValues.indexWhere(
          (attr) => attr['attributeId'] == 41,
        );
        if (newIndex != -1) {
          newAttributeValues[newIndex] = newValue;
        } else {
          newAttributeValues.add(newValue);
        }
      }
      final index = attributeValues.indexWhere(
        (attr) => attr['id'] == existingAttr['id'],
      );
      if (index != -1) {
        attributeValues[index] = newValue;
      } else {
        attributeValues.add(newValue);
      }
    }

    // Store raw number values without formatting
    widget.reportData['totalPopulationPerHour'] =
        hourStr.isEmpty ? null : int.tryParse(hourStr);
    widget.reportData['totalPopulationPerDay'] =
        dayStr.isEmpty ? null : int.tryParse(dayStr);

    // Handle customer types (attributeId: 4)
    for (String type in selectedCustomerTypes) {
      String additionalInfo = customerTypeAdditionalInfos[type] ?? '';
      if (additionalInfo.isNotEmpty) {
        // Remove formatting before storing
        additionalInfo = additionalInfo.replaceAll(',', '');
        additionalInfo = '$additionalInfo người/ngày';
      }
      final existingAttr = originalAttributeValues.firstWhere(
        (attr) =>
            attr['attributeId'] == attributeIds['customerType'] &&
            attr['value'] == type,
        orElse: () => {},
      );
      final newValue = {
        'attributeId': attributeIds['customerType'],
        'siteId': widget.siteId,
        'value': type,
        'additionalInfo': additionalInfo,
        if (existingAttr['id'] != null) 'id': existingAttr['id'],
      };
      if (existingAttr['id'] != null) {
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
      } else if (additionalInfo.isNotEmpty) {
        final newIndex = newAttributeValues.indexWhere(
          (attr) =>
              attr['attributeId'] == attributeIds['customerType'] &&
              attr['value'] == type,
        );
        if (newIndex != -1) {
          newAttributeValues[newIndex] = newValue;
        } else {
          newAttributeValues.add(newValue);
        }
      }
      final index = attributeValues.indexWhere(
        (attr) => attr['id'] == existingAttr['id'],
      );
      if (index != -1) {
        attributeValues[index] = newValue;
      } else if (additionalInfo.isNotEmpty) {
        attributeValues.add(newValue);
      }
    }

    // Handle customer counts (attributeId: 5)
    selectedCustomerCalculations.forEach((category, calculations) {
      for (var calc in calculations) {
        String key = '${category}_$calc';
        String amount = customerCalculationAmounts[key] ?? '';
        if (amount.isNotEmpty) {
          // Remove formatting before storing
          amount = amount.replaceAll(',', '');
          String unit =
              calc == 'theo giờ'
                  ? 'người/giờ'
                  : calc == 'theo ngày'
                  ? 'người/ngày'
                  : 'người/tuần';
          String additionalInfo = '$amount $unit';
          final existingAttr = originalAttributeValues.firstWhere(
            (attr) =>
                attr['attributeId'] == attributeIds['customerCount'] &&
                attr['value'] == category &&
                attr['additionalInfo'].endsWith(unit),
            orElse: () => {},
          );
          final newValue = {
            'attributeId': attributeIds['customerCount'],
            'siteId': widget.siteId,
            'value': category,
            'additionalInfo': additionalInfo,
            if (existingAttr['id'] != null) 'id': existingAttr['id'],
          };
          if (existingAttr['id'] != null) {
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
            final newIndex = newAttributeValues.indexWhere(
              (attr) =>
                  attr['attributeId'] == attributeIds['customerCount'] &&
                  attr['value'] == category &&
                  attr['additionalInfo'].endsWith(unit),
            );
            if (newIndex != -1) {
              newAttributeValues[newIndex] = newValue;
            } else {
              newAttributeValues.add(newValue);
            }
          }
          final index = attributeValues.indexWhere(
            (attr) => attr['id'] == existingAttr['id'],
          );
          if (index != -1) {
            attributeValues[index] = newValue;
          } else {
            attributeValues.add(newValue);
          }
        }
      }
    });

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
              (item) =>
                  item['attributeId'] == 4 ||
                  item['attributeId'] == 5 ||
                  item['attributeId'] == 41,
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
        customerCalculationControllers
            .remove('${category}_$calculation')
            ?.dispose();
      } else {
        selectedCustomerCalculations[category]!.add(calculation);
        customerCalculationAmounts['${category}_$calculation'] = '';
        if (calculation == 'theo ngày') {
          customerCalculationControllers['${category}_$calculation'] =
              TextEditingController(text: '');
        }
      }
      _updateAttributeValues();
    });
  }

  int? getTotalPopulationPerDay() {
    if (totalPopulationPerDayController.text.isNotEmpty) {
      return _getNumberValue(totalPopulationPerDayController.text);
    }

    final attributeValues =
        widget.reportData['attributeValues'] as List<Map<String, dynamic>>? ??
        [];
    final totalPopulationAttr = attributeValues.firstWhere(
      (attr) => attr['attributeId'] == 41,
      orElse: () => {},
    );
    if (totalPopulationAttr.isNotEmpty) {
      String additionalInfo = totalPopulationAttr['additionalInfo'] ?? '';
      RegExp dayRegExp = RegExp(r'(\d+)\s*người/ngày');
      Match? dayMatch = dayRegExp.firstMatch(additionalInfo);
      if (dayMatch != null) {
        return int.tryParse(dayMatch.group(1) ?? '');
      }
    }
    return null;
  }

  bool checkExceedsTotalPopulation(String value, String currentCategory) {
    if (value.isEmpty) return false;
    int? totalPop = getTotalPopulationPerDay();
    if (totalPop == null) return false;

    int? inputValue = _getNumberValue(value);
    if (inputValue == null) return false;

    // Nếu chỉ chọn một danh mục, so sánh trực tiếp
    if (selectedCustomerCategories.length == 1) {
      return inputValue > totalPop;
    }

    // Nếu chọn cả hai danh mục, tính tổng giá trị người/ngày
    int totalCustomerCount = 0;
    for (String category in selectedCustomerCategories) {
      String key = '${category}_theo ngày';
      String? amount = customerCalculationAmounts[key];
      // Nếu là danh mục hiện tại, sử dụng giá trị đầu vào mới
      if (category == currentCategory) {
        totalCustomerCount += inputValue;
      } else if (amount != null && amount.isNotEmpty) {
        int? categoryValue = _getNumberValue(amount);
        if (categoryValue != null) {
          totalCustomerCount += categoryValue;
        }
      }
    }

    return totalCustomerCount > totalPop;
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
            icon: Icons.apartment,
            title: 'Tổng số dân trong khu vực',
            subtitle:
                totalPopulationPerHourController.text.isNotEmpty &&
                        totalPopulationPerDayController.text.isNotEmpty
                    ? '${totalPopulationPerHourController.text} người/giờ, ${totalPopulationPerDayController.text} người/ngày'
                    : 'Chưa nhập',
            theme: widget.theme,
            showInfo: true,
            infoTitle: 'Hướng dẫn nhập tổng số dân trong khu vực',
            useBulletPoints: true,
            bulletPoints: [
              'Nhập số lượng dân trung bình trong khu vực xung quanh mặt bằng trong các khung giờ cao điểm.',
              'Tùy theo giờ cao điểm bạn đã chọn ở phần trước, thì phần này là tổng số dân trung bình trong những khung giờ đó',
              'Số liệu "người/giờ" phản ánh mật độ dân cư tại thời điểm đông nhất trong ngày.',
              'Số liệu "người/ngày" là tổng số dân ước tính trong cả ngày, dựa trên các khung giờ cao điểm (có thể sử dụng nút gợi ý từ dữ liệu phương tiện).',
              'Không nhập số liệu cho toàn bộ 24 giờ, chỉ tập trung vào các khung giờ cao điểm.',
              'Đảm bảo số liệu chính xác vì sẽ được sử dụng để so sánh với số lượng khách hàng.',
            ],
            children: [
              CustomInputField(
                controller: totalPopulationPerHourController,
                label: 'Tổng số dân trong khu vực (người/giờ)',
                hintText: 'Nhập số lượng',
                icon: Icons.timer,
                theme: widget.theme,
                keyboardType: TextInputType.number,
                numbersOnly: true,
                formatThousands: true,
                suffixText: 'người/giờ',
                onSaved: (value) {
                  _updateAttributeValues();
                },
              ),
              if (estimatedPerDay.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Tổng số dân dự đoán trong ngày ở khu vực bạn đang khảo sát trong các khung giờ cao điểm nhất định được đoán là: $estimatedPerDay người/ngày',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: widget.theme.colorScheme.onSurface.withOpacity(
                        0.7,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomInputField(
                      controller: totalPopulationPerDayController,
                      label: 'Tổng số dân trong khu vực (người/ngày)',
                      hintText: 'Nhập số lượng',
                      icon: Icons.calendar_today,
                      theme: widget.theme,
                      keyboardType: TextInputType.number,
                      numbersOnly: true,
                      formatThousands: true,
                      suffixText: 'người/ngày',
                      onSaved: (value) {
                        _updateAttributeValues();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.lightbulb),
                    onPressed: () {
                      if (widget.reportData.containsKey(
                        'totalVehiclesPerDay',
                      )) {
                        int? suggestedDay =
                            widget.reportData['totalVehiclesPerDay'] as int?;
                        if (suggestedDay != null) {
                          totalPopulationPerDayController.text = _formatNumber(
                            suggestedDay.toString(),
                          );
                          _updateAttributeValues();
                        }
                      }
                      if (widget.reportData.containsKey(
                        'totalVehiclesPerHour',
                      )) {
                        int? suggestedHour =
                            widget.reportData['totalVehiclesPerHour'] as int?;
                        if (suggestedHour != null) {
                          totalPopulationPerHourController.text = _formatNumber(
                            suggestedHour.toString(),
                          );
                          _updateAttributeValues();
                        }
                      }
                    },
                    tooltip: 'Sử dụng gợi ý từ dữ liệu phương tiện',
                  ),
                ],
              ),
            ],
          ),

          AnimatedExpansionCard(
            icon: Icons.group,
            title: 'Loại khách hàng chính',
            subtitle:
                selectedCustomerTypes.isEmpty
                    ? 'Chưa chọn'
                    : selectedCustomerTypes.join(', '),
            theme: widget.theme,
            showInfo: true,
            infoTitle: 'Hướng dẫn nhập loại khách hàng chính',
            useBulletPoints: true,
            bulletPoints: [
              'Chọn các loại khách hàng chính (ví dụ: nhân viên văn phòng, học sinh, cư dân) xuất hiện thường xuyên tại khu vực.',
              'Nhập số lượng trung bình của từng loại khách hàng mỗi ngày (người/ngày).',
              'Số liệu phải nhỏ hơn hoặc bằng tổng số dân trong khu vực (đã nhập ở mục trên).',
              'Phối hợp kiểm tra biên độ sai số hiển thị để đánh giá độ tin cậy của số liệu.',
            ],
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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomInputField(
                      label: 'Số lượng khách hàng $type (người/ngày)',
                      hintText: 'Nhập số lượng',
                      icon: customerIcons[type] ?? Icons.people,
                      initialValue: _formatNumber(
                        customerTypeAdditionalInfos[type] ?? '',
                      ),
                      theme: widget.theme,
                      keyboardType: TextInputType.number,
                      formatThousands: true,
                      numbersOnly: true,
                      suffixText: 'người/ngày',
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (checkExceedsTotalPopulation(value, type)) {
                            return 'Bạn đã nhập quá số lượng dân số trong khu vực này mà bạn vừa khảo sát được ở trên';
                          }
                        }
                        return null;
                      },
                      onSaved: (value) {
                        customerTypeAdditionalInfos[type] = value.replaceAll(
                          ',',
                          '',
                        );
                        _updateAttributeValues();
                      },
                    ),

                    if (customerTypeAdditionalInfos[type]?.isNotEmpty == true &&
                        totalPopulationPerDayController.text.isNotEmpty)
                      Builder(
                        builder: (context) {
                          int? n = int.tryParse(
                            customerTypeAdditionalInfos[type]!.replaceAll(
                              ',',
                              '',
                            ),
                          );
                          int? N = int.tryParse(
                            totalPopulationPerDayController.text.replaceAll(
                              ',',
                              '',
                            ),
                          );
                          if (n != null && N != null && N > 0) {
                            double p = n / N;
                            double z = 1.96;
                            double marginOfError =
                                z * sqrt(p * (1 - p) / N) * 100;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Biên độ sai số: ${marginOfError.toStringAsFixed(2)}% (với độ tin cậy 95%)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: widget.theme.colorScheme.primary,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    const SizedBox(height: 10),
                  ],
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
            showInfo: true,
            infoTitle: 'Hướng dẫn nhập số lượng khách trung bình',
            useBulletPoints: true,
            bulletPoints: [
              'Chọn danh mục khách hàng (Khách vãng lai hoặc Khách bản địa) để đánh giá lưu lượng.',
              'Chọn cách tính (theo giờ hoặc theo ngày) để nhập số liệu phù hợp.',
              'Đối với "người/giờ", nhập số lượng khách trung bình trong khung giờ cao điểm.',
              'Đối với "người/ngày", nhập tổng số khách trong cả ngày hoặc sử dụng nút tính toán để chuyển từ "người/giờ".',
              'Tổng số lượng khách của tất cả danh mục không được vượt quá tổng số dân trong khu vực.',
              'Kiểm tra cảnh báo nếu số liệu vượt quá giới hạn.',
            ],
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
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (calc == 'theo ngày')
                            Row(
                              children: [
                                Expanded(
                                  child: CustomInputField(
                                    key: ValueKey(key),
                                    label: 'Số lượng $category $calc',
                                    hintText: 'Nhập số lượng',
                                    icon:
                                        customerCategoryIcons[category] ??
                                        Icons.people,
                                    controller:
                                        customerCalculationControllers[key], // Gán controller
                                    theme: widget.theme,
                                    keyboardType: TextInputType.number,
                                    numbersOnly: true,
                                    formatThousands:
                                        true, // Đảm bảo định dạng phần nghìn
                                    suffixText: unit,
                                    validator: (value) {
                                      if (value != null && value.isNotEmpty) {
                                        int? inputValue = int.tryParse(
                                          value.replaceAll(',', ''),
                                        );
                                        int? totalPop =
                                            getTotalPopulationPerDay();
                                        if (inputValue != null &&
                                            totalPop != null &&
                                            inputValue > totalPop) {
                                          return 'Bạn đã nhập quá số lượng dân số trong khu vực này mà bạn vừa khảo sát được ở trên';
                                        }
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      setState(() {
                                        customerCalculationAmounts[key] = value
                                            .replaceAll(',', '');
                                        _updateAttributeValues();
                                      });
                                    },
                                  ),
                                ),
                                if (selectedCustomerCalculations[category]!
                                        .contains('theo giờ') &&
                                    customerCalculationAmounts['${category}_theo giờ']
                                            ?.isNotEmpty ==
                                        true)
                                  IconButton(
                                    icon: const Icon(Icons.lightbulb),
                                    onPressed: () {
                                      String? hourStr =
                                          customerCalculationAmounts['${category}_theo giờ']
                                              ?.replaceAll(',', '');
                                      int? hour = int.tryParse(hourStr ?? '');
                                      if (hour != null) {
                                        setState(() {
                                          String calculatedValue =
                                              (hour * 24).toString();
                                          customerCalculationAmounts['${category}_theo ngày'] =
                                              calculatedValue;
                                          customerCalculationControllers['${category}_theo ngày']
                                              ?.text = _formatNumber(
                                            calculatedValue,
                                          ); // Cập nhật controller
                                          _updateAttributeValues();
                                        });
                                      }
                                    },
                                  ),
                              ],
                            )
                          else
                            CustomInputField(
                              key: ValueKey(key),
                              label: 'Số lượng $category $calc',
                              hintText: 'Nhập số lượng',
                              icon:
                                  customerCategoryIcons[category] ??
                                  Icons.people,
                              initialValue:
                                  customerCalculationAmounts[key] ?? '',
                              theme: widget.theme,
                              keyboardType: TextInputType.number,
                              numbersOnly: true,
                              formatThousands: true,
                              suffixText: unit,
                              onSaved: (value) {
                                setState(() {
                                  customerCalculationAmounts[key] = value
                                      .replaceAll(',', '');
                                  _updateAttributeValues();
                                });
                              },
                            ),
                          if (calc == 'theo giờ' &&
                              customerCalculationAmounts[key]?.isNotEmpty ==
                                  true)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8.0,
                                bottom: 8.0,
                              ),
                              child: Text(
                                'Ước tính theo ngày: ${_formatNumber(((int.tryParse(customerCalculationAmounts[key]?.replaceAll(',', '') ?? '0') ?? 0) * 24).toString())} người/ngày',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: widget.theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ),

                          if (calc == 'theo ngày' &&
                              customerCalculationAmounts[key]?.isNotEmpty ==
                                  true &&
                              checkExceedsTotalPopulation(
                                customerCalculationAmounts[key] ?? '',
                                category,
                              ))
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Cảnh báo: Tổng số lượng khách hàng (${selectedCustomerCategories.length > 1 ? 'cả hai danh mục' : category}) vượt quá tổng dân số trong khu vực!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: widget.theme.colorScheme.error,
                                ),
                              ),
                            ),

                          if (calc == 'theo ngày' &&
                              customerCalculationAmounts[key]?.isNotEmpty ==
                                  true &&
                              totalPopulationPerDayController.text.isNotEmpty)
                            Builder(
                              builder: (context) {
                                int? n = int.tryParse(
                                  (customerCalculationAmounts[key] ?? '0')
                                      .replaceAll(',', ''),
                                );
                                int? N = int.tryParse(
                                  totalPopulationPerDayController.text
                                      .replaceAll(',', ''),
                                );
                                if (n != null && N != null && N > 0) {
                                  double p = n / N;
                                  double z = 1.96;
                                  double marginOfError =
                                      z * sqrt(p * (1 - p) / N) * 100;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'Biên độ sai số: ${marginOfError.toStringAsFixed(2)}% (với độ tin cậy 95%)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: widget.theme.colorScheme.primary,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                        ],
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
