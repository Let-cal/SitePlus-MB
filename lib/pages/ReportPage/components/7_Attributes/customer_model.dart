import 'dart:math';

import 'package:flutter/material.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/animated_expansion_card.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/info_card.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/selectable_option_button.dart';
import 'package:siteplus_mb/components/custom_input_field.dart';

class CustomerModelSection extends StatefulWidget {
  final Map<String, dynamic> reportData;
  final Function(void Function()) setState;
  final ThemeData theme;

  const CustomerModelSection({
    super.key,
    required this.reportData,
    required this.setState,
    required this.theme,
  });

  @override
  CustomerModelSectionState createState() => CustomerModelSectionState();
}

class CustomerModelSectionState extends State<CustomerModelSection>
    with SingleTickerProviderStateMixin {
  late Map<String, dynamic> localCustomerModelData;
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<Map<String, dynamic>> newAttributeValues = [];
  List<Map<String, dynamic>> changedAttributeValues = [];
  late List<Map<String, dynamic>> originalAttributeValues;
  String _debugAttributeValues = '';
  final Map<String, int> attributeIds = {
    'gender': 6,
    'ageGroups': 7,
    'income': 8,
  };

  final Map<String, IconData> genderIcons = {
    'Nam': Icons.male,
    'Nữ': Icons.female,
    'Khác': Icons.people_alt,
  };

  final Map<String, TextEditingController> _ageGroupControllers = {
    'under18': TextEditingController(),
    '18to30': TextEditingController(),
    '31to45': TextEditingController(),
    'over45': TextEditingController(),
  };

  final Map<String, IconData> incomeIcons = {
    '<5 triệu/tháng': Icons.money_off,
    '5-10 triệu/tháng': Icons.monetization_on,
    '10-20 triệu/tháng': Icons.account_balance_wallet,
    '>20 triệu/tháng': Icons.attach_money,
  };

  String _highestAgeGroupInfo = '';
  String _genderValidationMessage = ''; // Added for gender validation

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    _initializeData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(
        'Initial reportData[attributeValues] in CustomerModelSection: ${widget.reportData['attributeValues']}',
      );
      _updateAttributeValues();
      _updateGenderValidation(); // Validate gender initially
      _updateDebugInfo();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _ageGroupControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _initializeData() {
    localCustomerModelData = Map<String, dynamic>.from(
      widget.reportData['customerModel'] ?? {},
    );
    originalAttributeValues = List<Map<String, dynamic>>.from(
      widget.reportData['attributeValues'] ?? [],
    );
    newAttributeValues = List<Map<String, dynamic>>.from(
      widget.reportData['newAttributeValues'] ?? [],
    );

    final defaultValues = {
      'gender': null,
      'genderInfo': '',
      'ageGroups': {'under18': 0, '18to30': 0, '31to45': 0, 'over45': 0},
      'income': '',
      'incomePopulation': '', // Added for income population
    };

    defaultValues.forEach((key, value) {
      localCustomerModelData.putIfAbsent(key, () => value);
    });

    _populateFromAttributeValues();
    _initializeAgeGroupControllers();
    _calculateHighestAgeGroup();
  }

  void _initializeAgeGroupControllers() {
    _ageGroupControllers.forEach((key, controller) {
      int value = localCustomerModelData['ageGroups'][key] ?? 0;
      controller.text = value > 0 ? value.toString() : '';
      controller.addListener(() {
        _updateAgeGroup(key, controller.text);
      });
    });
  }

  void _updateDebugInfo() {
    final List<Map<String, dynamic>> attributeValues =
        List<Map<String, dynamic>>.from(
          widget.reportData['attributeValues'] ?? [],
        );
    final customerModelAttributes =
        attributeValues
            .where((item) => attributeIds.values.contains(item['attributeId']))
            .toList();

    _debugAttributeValues =
        'attributeValues:\n${customerModelAttributes.map((item) => '  - attributeId: ${item['attributeId']}\n'
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

  void _populateFromAttributeValues() {
    if (widget.reportData['attributeValues'] == null ||
        widget.reportData['attributeValues'].isEmpty)
      return;

    List<dynamic> attributeValues = widget.reportData['attributeValues'];

    final genderAttribute = attributeValues.firstWhere(
      (attr) => attr['attributeId'] == 6,
      orElse: () => <String, dynamic>{},
    );
    if (genderAttribute.isNotEmpty && genderAttribute['value'] != null) {
      String genderValue = genderAttribute['value'];
      String genderSelection = 'Nam';
      if (genderValue.contains('nam')) {
        genderSelection = 'Nam';
      } else if (genderValue.contains('nữ')) {
        genderSelection = 'Nữ';
      } else if (genderValue.contains('đa dạng')) {
        genderSelection = 'Khác';
      }
      localCustomerModelData['gender'] = genderSelection;
      String additionalInfo = genderAttribute['additionalInfo'] ?? '';
      if (additionalInfo.contains('%')) {
        String numberPart =
            additionalInfo.replaceAll(RegExp(r'\s*%'), '').trim();
        int? personCount = int.tryParse(numberPart);
        localCustomerModelData['genderInfo'] =
            personCount != null ? personCount.toString() : '';
      } else if (additionalInfo.contains('người/ngày')) {
        RegExp regex = RegExp(r'(\d+)\s*người/ngày');
        Match? match = regex.firstMatch(additionalInfo);
        localCustomerModelData['genderInfo'] =
            match != null && match.groupCount >= 1 ? match.group(1) ?? '' : '';
      } else {
        localCustomerModelData['genderInfo'] = additionalInfo;
      }
    }

    final ageAttributes =
        attributeValues.where((attr) => attr['attributeId'] == 7).toList();
    if (ageAttributes.isNotEmpty) {
      Map<String, int> ageGroups = {
        'under18': 0,
        '18to30': 0,
        '31to45': 0,
        'over45': 0,
      };
      for (var attr in ageAttributes) {
        String additionalInfo = attr['additionalInfo'] ?? '';
        RegExp peoplePerDayRegex = RegExp(
          r'(\d+)\s*người/ngày\s*nhóm khách hàng có độ tuổi (.+?)(?:,|\s+và|\s+chiếm|$)',
        );
        var peopleMatches = peoplePerDayRegex.firstMatch(additionalInfo);
        RegExp percentRegex = RegExp(
          r'(\d+)%\s*nhóm khách hàng có độ tuổi (.+?)(?:,|\s+và|\s+chiếm|$)',
        );
        var percentMatches = percentRegex.firstMatch(additionalInfo);

        String ageRange = '';
        int count = 0;
        if (peopleMatches != null) {
          String countStr = peopleMatches.group(1) ?? '0';
          ageRange = peopleMatches.group(2) ?? '';
          count = int.tryParse(countStr) ?? 0;
        } else if (percentMatches != null) {
          String percentage = percentMatches.group(1) ?? '0';
          ageRange = percentMatches.group(2) ?? '';
          count = int.tryParse(percentage) ?? 0;
        }

        if (ageRange.contains('dưới 18')) {
          ageGroups['under18'] = count;
        } else if (ageRange.contains('18-30')) {
          ageGroups['18to30'] = count;
        } else if (ageRange.contains('31-45')) {
          ageGroups['31to45'] = count;
        } else if (ageRange.contains('trên 45')) {
          ageGroups['over45'] = count;
        }
      }
      localCustomerModelData['ageGroups'] = ageGroups;
      _calculateHighestAgeGroup();
    }

    final incomeAttribute = attributeValues.firstWhere(
      (attr) => attr['attributeId'] == 8,
      orElse: () => <String, dynamic>{},
    );
    if (incomeAttribute.isNotEmpty) {
      String additionalInfo = incomeAttribute['additionalInfo'] ?? '';
      String incomeSelection = '';
      if (additionalInfo.contains('<5 triệu/tháng')) {
        incomeSelection = '<5 triệu/tháng';
      } else if (additionalInfo.contains('5-10 triệu/tháng')) {
        incomeSelection = '5-10 triệu/tháng';
      } else if (additionalInfo.contains('10-20 triệu/tháng')) {
        incomeSelection = '10-20 triệu/tháng';
      } else if (additionalInfo.contains('>20 triệu/tháng')) {
        incomeSelection = '>20 triệu/tháng';
      }
      localCustomerModelData['income'] = incomeSelection;

      // Extract incomePopulation from additionalInfo
      RegExp regex = RegExp(
        r'tổng số dân có thu nhập này là (\d+) người/ngày',
      );
      Match? match = regex.firstMatch(additionalInfo);
      if (match != null && match.groupCount >= 1) {
        localCustomerModelData['incomePopulation'] = match.group(1) ?? '';
      }
    }
  }

  void _updateAgeGroup(String key, String value) {
    int? intValue = int.tryParse(value);
    setState(() {
      localCustomerModelData['ageGroups'][key] = intValue ?? 0;
      _calculateHighestAgeGroup();
      _updateAttributeValues();
      _updateGenderValidation(); // Validate gender when age changes
    });
  }

  void _calculateHighestAgeGroup() {
    Map<String, int> ageGroups = Map<String, int>.from(
      localCustomerModelData['ageGroups'],
    );
    int total = ageGroups.values.fold(0, (sum, value) => sum + value);
    if (total == 0) {
      _highestAgeGroupInfo = '';
      return;
    }

    String highestKey = '';
    int highestValue = 0;
    ageGroups.forEach((key, value) {
      if (value > highestValue) {
        highestValue = value;
        highestKey = key;
      }
    });

    if (highestValue > 0) {
      int percentage = ((highestValue / total) * 100).round();
      String ageRangeName = '';
      switch (highestKey) {
        case 'under18':
          ageRangeName = 'dưới 18 tuổi';
          break;
        case '18to30':
          ageRangeName = '18-30 tuổi';
          break;
        case '31to45':
          ageRangeName = '31-45 tuổi';
          break;
        case 'over45':
          ageRangeName = 'trên 45 tuổi';
          break;
      }
      _highestAgeGroupInfo =
          'Khách hàng nằm trong độ tuổi $ageRangeName chiếm tỉ lệ cao nhất: $percentage%';
    } else {
      _highestAgeGroupInfo = '';
    }
  }

  // Added methods
  int _calculateTotalAgeGroup() {
    Map<String, int> ageGroups = Map<String, int>.from(
      localCustomerModelData['ageGroups'],
    );
    return ageGroups.values.fold(0, (sum, value) => sum + value);
  }

  int? _getGenderValue() {
    String genderInfo = localCustomerModelData['genderInfo'] ?? '';
    return int.tryParse(genderInfo);
  }

  void _updateGenderValidation() {
    int? genderValue = _getGenderValue();
    int totalAgeGroup = _calculateTotalAgeGroup();
    String message = '';
    if (genderValue != null &&
        totalAgeGroup > 0 &&
        genderValue > totalAgeGroup) {
      message =
          'Số lượng dân số trong phần giới tính chính mà bạn đang nhập đang lớn hơn tổng số dân số bạn khảo sát được ở phần nhóm độ tuổi đang có là $totalAgeGroup người/ngày';
    }
    if (message != _genderValidationMessage) {
      setState(() {
        _genderValidationMessage = message;
      });
    }
  }

  double? _calculateMarginOfError() {
    String incomePopulationStr =
        localCustomerModelData['incomePopulation'] ?? '';
    int? incomePopulation = int.tryParse(incomePopulationStr);
    int totalAgeGroup = _calculateTotalAgeGroup();
    if (incomePopulation == null || totalAgeGroup == 0) return null;
    double p = incomePopulation / totalAgeGroup;
    double z = 1.96; // 95% confidence
    double marginOfError = z * sqrt(p * (1 - p) / totalAgeGroup);
    return marginOfError * 100; // Percentage
  }

  void _updateAttributeValues() {
    final List<Map<String, dynamic>> attributeValues =
        List<Map<String, dynamic>>.from(
          widget.reportData['attributeValues'] ?? [],
        );

    if (localCustomerModelData['gender'] != null) {
      String genderValue = "";
      switch (localCustomerModelData['gender']) {
        case 'Nam':
          genderValue = "khách hàng chiếm đa số là nam";
          break;
        case 'Nữ':
          genderValue = "khách hàng chiếm đa số là nữ";
          break;
        case 'Khác':
          genderValue = "khách hàng có giới tính đa dạng";
          break;
      }
      String rawGenderInfo = localCustomerModelData['genderInfo'] ?? '';
      String additionalInfo =
          rawGenderInfo.isNotEmpty ? "$rawGenderInfo người/ngày" : "";

      final existingAttr = originalAttributeValues.firstWhere(
        (attr) => attr['attributeId'] == attributeIds['gender'],
        orElse: () => {},
      );
      final newValue = {
        'attributeId': attributeIds['gender'],
        'siteId': widget.reportData['siteId'] ?? 0,
        'value': genderValue,
        'additionalInfo': additionalInfo,
        if (existingAttr['id'] != null) 'id': existingAttr['id'],
      };

      if (existingAttr['id'] != null) {
        final changeIndex = changedAttributeValues.indexWhere(
          (attr) => attr['id'] == existingAttr['id'],
        );
        final updatedValue = {
          'id': existingAttr['id'],
          'value': genderValue,
          'additionalInfo': additionalInfo,
        };
        if (changeIndex != -1) {
          changedAttributeValues[changeIndex] = updatedValue;
        } else {
          changedAttributeValues.add(updatedValue);
        }
      } else if (genderValue.isNotEmpty) {
        final newIndex = newAttributeValues.indexWhere(
          (attr) => attr['attributeId'] == attributeIds['gender'],
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
      } else if (genderValue.isNotEmpty) {
        attributeValues.add(newValue);
      }
    }

    Map<String, int> ageGroups = Map<String, int>.from(
      localCustomerModelData['ageGroups'],
    );
    final existingAgeAttrs =
        originalAttributeValues
            .where((attr) => attr['attributeId'] == attributeIds['ageGroups'])
            .toList();
    List<Map<String, dynamic>> ageGroupAttrs = [];
    if (ageGroups.values.every((value) => value == 0) &&
        existingAgeAttrs.isNotEmpty) {
      ageGroupAttrs.addAll(existingAgeAttrs);
    } else {
      ageGroups.forEach((key, value) {
        if (value > 0) {
          String ageName = "";
          switch (key) {
            case 'under18':
              ageName = "dưới 18 tuổi";
              break;
            case '18to30':
              ageName = "18-30 tuổi";
              break;
            case '31to45':
              ageName = "31-45 tuổi";
              break;
            case 'over45':
              ageName = "trên 45 tuổi";
              break;
          }
          String highestAgeAddition =
              _highestAgeGroupInfo.isNotEmpty &&
                      _highestAgeGroupInfo.contains(ageName)
                  ? " và " + _highestAgeGroupInfo
                  : "";
          final existingAttr = existingAgeAttrs.firstWhere(
            (attr) => attr['value'] == ageName,
            orElse: () => {},
          );
          ageGroupAttrs.add({
            'attributeId': attributeIds['ageGroups'],
            'siteId': widget.reportData['siteId'] ?? 0,
            'value': ageName,
            'additionalInfo':
                "$value người/ngày nhóm khách hàng có độ tuổi $ageName$highestAgeAddition",
            if (existingAttr['id'] != null) 'id': existingAttr['id'],
          });
        }
      });
    }

    for (var attr in ageGroupAttrs) {
      if (attr['id'] != null) {
        final changeIndex = changedAttributeValues.indexWhere(
          (item) => item['id'] == attr['id'],
        );
        final updatedValue = {
          'id': attr['id'],
          'value': attr['value'],
          'additionalInfo': attr['additionalInfo'],
        };
        if (changeIndex != -1) {
          changedAttributeValues[changeIndex] = updatedValue;
        } else {
          changedAttributeValues.add(updatedValue);
        }
      }
    }

    newAttributeValues.removeWhere(
      (attr) => attr['attributeId'] == attributeIds['ageGroups'],
    );
    newAttributeValues.addAll(
      ageGroupAttrs.where((attr) => attr['id'] == null).toList(),
    );
    attributeValues.removeWhere(
      (attr) => attr['attributeId'] == attributeIds['ageGroups'],
    );
    attributeValues.addAll(ageGroupAttrs);

    if (localCustomerModelData['income'] != null &&
        localCustomerModelData['income'].isNotEmpty) {
      String incomeValue = "";
      switch (localCustomerModelData['income']) {
        case '<5 triệu/tháng':
          incomeValue = "thấp";
          break;
        case '5-10 triệu/tháng':
        case '10-20 triệu/tháng':
          incomeValue = "trung bình";
          break;
        case '>20 triệu/tháng':
          incomeValue = "cao";
          break;
      }
      String incomeDescription = "Thu nhập ${localCustomerModelData['income']}";
      String additionalInfo = incomeDescription;
      String incomePopulation =
          localCustomerModelData['incomePopulation'] ?? '';
      int totalAgeGroup = _calculateTotalAgeGroup();
      if (incomePopulation.isNotEmpty && totalAgeGroup > 0) {
        int? incomePop = int.tryParse(incomePopulation);
        if (incomePop != null) {
          double p = incomePop / totalAgeGroup;
          double z = 1.96;
          double marginOfError = z * sqrt(p * (1 - p) / totalAgeGroup) * 100;
          additionalInfo +=
              ", tổng số dân có thu nhập này là $incomePop người/ngày so với tổng số dân là $totalAgeGroup người/ngày, với độ tin cậy 95% và biên độ sai số ${marginOfError.toStringAsFixed(2)}%";
        }
      }

      final existingAttr = originalAttributeValues.firstWhere(
        (attr) => attr['attributeId'] == attributeIds['income'],
        orElse: () => {},
      );
      final newValue = {
        'attributeId': attributeIds['income'],
        'siteId': widget.reportData['siteId'] ?? 0,
        'value': incomeValue,
        'additionalInfo': additionalInfo,
        if (existingAttr['id'] != null) 'id': existingAttr['id'],
      };

      if (existingAttr['id'] != null) {
        final changeIndex = changedAttributeValues.indexWhere(
          (attr) => attr['id'] == existingAttr['id'],
        );
        final updatedValue = {
          'id': existingAttr['id'],
          'value': incomeValue,
          'additionalInfo': additionalInfo,
        };
        if (changeIndex != -1) {
          changedAttributeValues[changeIndex] = updatedValue;
        } else {
          changedAttributeValues.add(updatedValue);
        }
      } else if (incomeValue.isNotEmpty) {
        final newIndex = newAttributeValues.indexWhere(
          (attr) => attr['attributeId'] == attributeIds['income'],
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
      } else if (incomeValue.isNotEmpty) {
        attributeValues.add(newValue);
      }
    }

    widget.setState(() {
      widget.reportData['customerModel'] = localCustomerModelData;
      widget.reportData['attributeValues'] = attributeValues;
      widget.reportData['changedAttributeValues'] =
          List<Map<String, dynamic>>.from(changedAttributeValues);
      widget.reportData['newAttributeValues'] = List<Map<String, dynamic>>.from(
        newAttributeValues,
      );
    });

    _updateDebugInfo();
  }

  String _getGenderSubtitle() =>
      localCustomerModelData['gender'] ?? 'Chưa chọn';

  String _getAgeGroupsSubtitle() {
    Map<String, int> ageGroups = Map<String, int>.from(
      localCustomerModelData['ageGroups'],
    );
    List<String> filledGroups = [];
    if ((ageGroups['under18'] ?? 0) > 0)
      filledGroups.add("Dưới 18: ${ageGroups['under18']} người/ngày");
    if ((ageGroups['18to30'] ?? 0) > 0)
      filledGroups.add("18-30: ${ageGroups['18to30']} người/ngày");
    if ((ageGroups['31to45'] ?? 0) > 0)
      filledGroups.add("31-45: ${ageGroups['31to45']} người/ngày");
    if ((ageGroups['over45'] ?? 0) > 0)
      filledGroups.add("Trên 45: ${ageGroups['over45']} người/ngày");
    return filledGroups.isEmpty
        ? 'Chưa điền thông tin'
        : filledGroups.join(', ');
  }

  String _getIncomeSubtitle() =>
      (localCustomerModelData['income'] == null ||
              localCustomerModelData['income'].isEmpty)
          ? 'Chưa chọn'
          : localCustomerModelData['income'];

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'III. Mô Hình Khách Hàng',
              style: widget.theme.textTheme.titleLarge?.copyWith(
                color: widget.theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            InfoCard(
              icon: Icons.lightbulb_outline,
              content:
                  'Ghi chú giới tính, độ tuổi và mức thu nhập của khách hàng.',
              backgroundColor: widget.theme.colorScheme.tertiaryFixed,
              iconColor: widget.theme.colorScheme.secondary,
              borderRadius: 20.0,
              padding: const EdgeInsets.all(20.0),
            ),
            const SizedBox(height: 20.0),
            AnimatedExpansionCard(
              icon: Icons.people,
              title: 'Giới tính khách hàng chính',
              subtitle: _getGenderSubtitle(),
              theme: widget.theme,
              children: [_buildGenderSelectionWidget()],
            ),
            AnimatedExpansionCard(
              icon: Icons.group,
              title: 'Nhóm độ tuổi',
              subtitle: _getAgeGroupsSubtitle(),
              theme: widget.theme,
              children: [
                _buildAgeGroupSelectionWidget(),
                if (_highestAgeGroupInfo.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.theme.colorScheme.primaryContainer
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: widget.theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _highestAgeGroupInfo,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: widget.theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            AnimatedExpansionCard(
              icon: Icons.monetization_on,
              title: 'Thu nhập trung bình của khách hàng',
              subtitle: _getIncomeSubtitle(),
              theme: widget.theme,
              children: [_buildIncomeSelectionWidget()],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelectionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children:
              genderIcons.entries.map((entry) {
                String gender = entry.key;
                IconData icon = entry.value;
                return SelectableOptionButton(
                  value: gender,
                  icon: icon,
                  isSelected: localCustomerModelData['gender'] == gender,
                  onTap: () {
                    setState(() {
                      localCustomerModelData['gender'] = gender;
                      _updateAttributeValues();
                      _updateGenderValidation();
                    });
                  },
                  theme: widget.theme,
                );
              }).toList(),
        ),
        if (localCustomerModelData['gender'] != null)
          CustomInputField(
            label: 'Số lượng khách hàng',
            hintText: 'Ví dụ: 1000',
            icon: Icons.info_outline,
            theme: widget.theme,
            initialValue: localCustomerModelData['genderInfo'] ?? '',
            keyboardType: TextInputType.number,
            numbersOnly: true,
            suffixText: 'người/ngày',
            onSaved: (value) {
              setState(() {
                localCustomerModelData['genderInfo'] = value;
                _updateAttributeValues();
                _updateGenderValidation();
              });
            },
          ),
        if (_genderValidationMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.theme.colorScheme.errorContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: widget.theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _genderValidationMessage,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: widget.theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAgeGroupSelectionWidget() {
    return Column(
      children:
          _ageGroupControllers.entries.map((entry) {
            String key = entry.key;
            TextEditingController controller = entry.value;
            String label;
            IconData icon;
            switch (key) {
              case 'under18':
                label = 'Dưới 18 tuổi';
                icon = Icons.child_care;
                break;
              case '18to30':
                label = '18-30 tuổi';
                icon = Icons.person;
                break;
              case '31to45':
                label = '31-45 tuổi';
                icon = Icons.person;
                break;
              case 'over45':
                label = 'Trên 45 tuổi';
                icon = Icons.elderly;
                break;
              default:
                label = '';
                icon = Icons.person;
            }
            return CustomInputField(
              label: label,
              hintText: 'Nhập phần trăm khách hàng',
              icon: icon,
              theme: widget.theme,
              controller: controller,
              keyboardType: TextInputType.number,
              numbersOnly: true,
              suffixText: 'người/ngày',
              onSaved: (value) => _updateAgeGroup(key, value ?? ''),
            );
          }).toList(),
    );
  }

  Widget _buildIncomeSelectionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children:
              incomeIcons.entries.map((entry) {
                String income = entry.key;
                IconData icon = entry.value;
                return SelectableOptionButton(
                  value: income,
                  icon: icon,
                  isSelected: localCustomerModelData['income'] == income,
                  onTap: () {
                    setState(() {
                      localCustomerModelData['income'] = income;
                      _updateAttributeValues();
                    });
                  },
                  theme: widget.theme,
                );
              }).toList(),
        ),
        if (localCustomerModelData['income'] != null &&
            localCustomerModelData['income'].isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInputField(
                label: 'Số lượng dân số có thu nhập này',
                hintText: 'Ví dụ: 1000',
                icon: Icons.info_outline,
                theme: widget.theme,
                initialValue: localCustomerModelData['incomePopulation'] ?? '',
                keyboardType: TextInputType.number,
                numbersOnly: true,
                suffixText: 'người/ngày',
                onSaved: (value) {
                  setState(() {
                    localCustomerModelData['incomePopulation'] = value;
                    _updateAttributeValues();
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'trên tổng số dân ${_calculateTotalAgeGroup()} người/ngày',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: widget.theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Builder(
                  builder: (context) {
                    double? marginOfError = _calculateMarginOfError();
                    return marginOfError != null
                        ? Text(
                          'Biên độ sai số: ${marginOfError.toStringAsFixed(2)}% (với độ tin cậy 95%)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: widget.theme.colorScheme.primary,
                          ),
                        )
                        : const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }
}
