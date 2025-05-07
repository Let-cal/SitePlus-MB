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
  String _ageGroupValidationMessage = '';
  String _genderValidationMessage = '';

  int getTotalAgeGroups() {
    Map<String, int> ageGroups = Map<String, int>.from(
      localCustomerModelData['ageGroups'],
    );
    return ageGroups.values.fold(0, (sum, value) => sum + value);
  }

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
      _updateGenderValidation();
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
      'incomePopulation': '',
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
      controller.text = value > 0 ? _formatNumber(value.toString()) : '';
      controller.addListener(() {
        _updateAgeGroup(key, controller.text);
      });
    });
  }

  String _formatNumber(String value) {
    if (value.isEmpty) return '';
    final number = int.tryParse(value.replaceAll(',', '')) ?? 0;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
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
      String genderSelection =
          genderValue.contains('nam')
              ? 'Nam'
              : genderValue.contains('nữ')
              ? 'Nữ'
              : 'Khác';
      localCustomerModelData['gender'] = genderSelection;
      String additionalInfo = genderAttribute['additionalInfo'] ?? '';
      RegExp regex = RegExp(
        r'(\d+)\s*người/ngày\s*chiếm\s*(\d+)%\s*trên\s*tổng\s*số\s*dân\s*trong\s*khu\s*vực\s*là\s*(\d+)\s*người/ngày',
      );
      Match? match = regex.firstMatch(additionalInfo);
      localCustomerModelData['genderInfo'] =
          match != null && match.groupCount >= 1
              ? match.group(1) ?? ''
              : additionalInfo.split(' người/ngày')[0].trim();
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
        RegExp regex = RegExp(
          r'(\d+)\s*người/ngày\s*nhóm khách hàng có độ tuổi (.+?)(?:,|\s+và|\s+chiếm|$)',
        );
        var match = regex.firstMatch(additionalInfo);
        if (match != null) {
          String countStr = match.group(1) ?? '0';
          String ageRange = match.group(2) ?? '';
          int count = int.tryParse(countStr) ?? 0;
          if (ageRange.contains('dưới 18'))
            ageGroups['under18'] = count;
          else if (ageRange.contains('18-30'))
            ageGroups['18to30'] = count;
          else if (ageRange.contains('31-45'))
            ageGroups['31to45'] = count;
          else if (ageRange.contains('trên 45'))
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
      String incomeSelection =
          additionalInfo.contains('<5 triệu/tháng')
              ? '<5 triệu/tháng'
              : additionalInfo.contains('5-10 triệu/tháng')
              ? '5-10 triệu/tháng'
              : additionalInfo.contains('10-20 triệu/tháng')
              ? '10-20 triệu/tháng'
              : additionalInfo.contains('>20 triệu/tháng')
              ? '>20 triệu/tháng'
              : '';
      localCustomerModelData['income'] = incomeSelection;
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
    String cleanedValue = value.replaceAll(',', '');
    int? intValue = int.tryParse(cleanedValue);
    setState(() {
      localCustomerModelData['ageGroups'][key] = intValue ?? 0;
      _calculateHighestAgeGroup();
      _updateAttributeValues();
      _updateGenderValidation();
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

    String highestKey =
        ageGroups.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    int highestValue = ageGroups[highestKey]!;
    int percentage = ((highestValue / total) * 100).round();
    String ageRangeName =
        highestKey == 'under18'
            ? 'dưới 18 tuổi'
            : highestKey == '18to30'
            ? '18-30 tuổi'
            : highestKey == '31to45'
            ? '31-45 tuổi'
            : 'trên 45 tuổi';
    _highestAgeGroupInfo =
        'Khách hàng nằm trong độ tuổi $ageRangeName chiếm tỉ lệ cao nhất: $percentage%';
  }

  int _calculateTotalAgeGroup() => getTotalAgeGroups();
  int _calculateTotalPopulation() =>
      widget.reportData['totalPopulationPerDay'] ?? 0;

  int? _getGenderValue() => int.tryParse(
    localCustomerModelData['genderInfo']?.replaceAll(',', '') ?? '',
  );

  void _updateGenderValidation() {
    int? genderValue = _getGenderValue();
    int totalPopulation = widget.reportData['totalPopulationPerDay'] ?? 0;
    setState(() {
      _genderValidationMessage =
          (genderValue != null &&
                  totalPopulation > 0 &&
                  genderValue > totalPopulation)
              ? 'Số lượng khách hàng giới tính chính ($genderValue) vượt quá tổng số dân ($totalPopulation).'
              : '';
    });
  }

  double? _calculateMarginOfError() {
    String incomePopulationStr =
        localCustomerModelData['incomePopulation']?.replaceAll(',', '') ?? '';
    int? incomePopulation = int.tryParse(incomePopulationStr);
    int totalPopulation = widget.reportData['totalPopulationPerDay'] ?? 0;
    if (incomePopulation == null || totalPopulation == 0) return null;
    double p = incomePopulation / totalPopulation;
    double z = 1.96;
    double marginOfError = z * sqrt(p * (1 - p) / totalPopulation);
    return marginOfError * 100;
  }

  void _updateAttributeValues() {
    final List<Map<String, dynamic>> attributeValues =
        List<Map<String, dynamic>>.from(
          widget.reportData['attributeValues'] ?? [],
        );

    // Gender
    if (localCustomerModelData['gender'] != null) {
      String genderValue =
          localCustomerModelData['gender'] == 'Nam'
              ? 'khách hàng chiếm đa số là nam'
              : localCustomerModelData['gender'] == 'Nữ'
              ? 'khách hàng chiếm đa số là nữ'
              : 'khách hàng có giới tính đa dạng';
      String rawGenderInfo =
          localCustomerModelData['genderInfo']?.replaceAll(',', '') ?? '';
      int totalPopulation = widget.reportData['totalPopulationPerDay'] ?? 0;
      String additionalInfo =
          rawGenderInfo.isNotEmpty ? '$rawGenderInfo người/ngày' : '';
      if (totalPopulation > 0 && rawGenderInfo.isNotEmpty) {
        int? genderValueInt = int.tryParse(rawGenderInfo);
        if (genderValueInt != null && genderValueInt > 0) {
          int percentage = ((genderValueInt / totalPopulation) * 100).round();
          additionalInfo +=
              ' chiếm ${percentage}% trên tổng số dân trong khu vực là ${totalPopulation} người/ngày';
        }
      }

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
        if (changeIndex != -1)
          changedAttributeValues[changeIndex] = updatedValue;
        else
          changedAttributeValues.add(updatedValue);
      } else if (genderValue.isNotEmpty) {
        final newIndex = newAttributeValues.indexWhere(
          (attr) => attr['attributeId'] == attributeIds['gender'],
        );
        if (newIndex != -1)
          newAttributeValues[newIndex] = newValue;
        else
          newAttributeValues.add(newValue);
      }

      final index = attributeValues.indexWhere(
        (attr) => attr['id'] == existingAttr['id'],
      );
      if (index != -1)
        attributeValues[index] = newValue;
      else if (genderValue.isNotEmpty)
        attributeValues.add(newValue);
    }

    // Age Groups
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
          String ageName =
              key == 'under18'
                  ? 'dưới 18 tuổi'
                  : key == '18to30'
                  ? '18-30 tuổi'
                  : key == '31to45'
                  ? '31-45 tuổi'
                  : 'trên 45 tuổi';
          String highestAgeAddition =
              _highestAgeGroupInfo.isNotEmpty &&
                      _highestAgeGroupInfo.contains(ageName)
                  ? ' và $_highestAgeGroupInfo'
                  : '';
          final existingAttr = existingAgeAttrs.firstWhere(
            (attr) => attr['value'] == ageName,
            orElse: () => {},
          );
          ageGroupAttrs.add({
            'attributeId': attributeIds['ageGroups'],
            'siteId': widget.reportData['siteId'] ?? 0,
            'value': ageName,
            'additionalInfo':
                '$value người/ngày nhóm khách hàng có độ tuổi $ageName$highestAgeAddition',
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
        if (changeIndex != -1)
          changedAttributeValues[changeIndex] = updatedValue;
        else
          changedAttributeValues.add(updatedValue);
      }
    }

    newAttributeValues.removeWhere(
      (attr) => attr['attributeId'] == attributeIds['ageGroups'],
    );
    newAttributeValues.addAll(
      ageGroupAttrs.where((attr) => attr['id'] == null),
    );
    attributeValues.removeWhere(
      (attr) => attr['attributeId'] == attributeIds['ageGroups'],
    );
    attributeValues.addAll(ageGroupAttrs);

    // Income
    if (localCustomerModelData['income'] != null &&
        localCustomerModelData['income'].isNotEmpty) {
      String incomeValue =
          localCustomerModelData['income'] == '<5 triệu/tháng'
              ? 'thấp'
              : localCustomerModelData['income'] == '5-10 triệu/tháng' ||
                  localCustomerModelData['income'] == '10-20 triệu/tháng'
              ? 'trung bình'
              : 'cao';
      String incomeDescription = 'Thu nhập ${localCustomerModelData['income']}';
      String additionalInfo = incomeDescription;
      String incomePopulation =
          localCustomerModelData['incomePopulation']?.replaceAll(',', '') ?? '';

      int totalPopulation = widget.reportData['totalPopulationPerDay'] ?? 0;
      if (incomePopulation.isNotEmpty && totalPopulation > 0) {
        int? incomePop = int.tryParse(incomePopulation);
        if (incomePop != null) {
          double p = incomePop / totalPopulation;
          double z = 1.96;
          double marginOfError = z * sqrt(p * (1 - p) / totalPopulation) * 100;
          additionalInfo +=
              ', tổng số dân có thu nhập này là $incomePop người/ngày so với tổng số dân trong khu vực là $totalPopulation người/ngày, với độ tin cậy 95% và biên độ sai số ${marginOfError.toStringAsFixed(2)}%';
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
        if (changeIndex != -1)
          changedAttributeValues[changeIndex] = updatedValue;
        else
          changedAttributeValues.add(updatedValue);
      } else if (incomeValue.isNotEmpty) {
        final newIndex = newAttributeValues.indexWhere(
          (attr) => attr['attributeId'] == attributeIds['income'],
        );
        if (newIndex != -1)
          newAttributeValues[newIndex] = newValue;
        else
          newAttributeValues.add(newValue);
      }

      final index = attributeValues.indexWhere(
        (attr) => attr['id'] == existingAttr['id'],
      );
      if (index != -1)
        attributeValues[index] = newValue;
      else if (incomeValue.isNotEmpty)
        attributeValues.add(newValue);
    }

    int totalAgeGroups = getTotalAgeGroups();
    int totalPopulation = widget.reportData['totalPopulationPerDay'] ?? 0;
    if (totalAgeGroups != 0 && totalPopulation != 0) {
      int difference = totalPopulation - totalAgeGroups;
      bool allInputsFilled = _ageGroupControllers.values.every(
        (controller) => controller.text.isNotEmpty,
      );
      if (allInputsFilled) {
        setState(() {
          _ageGroupValidationMessage =
              difference < 0
                  ? 'Tổng số người của 4 nhóm độ tuổi ($totalAgeGroups) vượt quá tổng số dân ($totalPopulation), dư ${-difference} người/ngày.'
                  : difference > 0
                  ? 'Tổng số người của 4 nhóm độ tuổi ($totalAgeGroups) thấp hơn tổng số dân ($totalPopulation), thiếu $difference người/ngày.'
                  : '';
        });
      } else {
        setState(() {
          _ageGroupValidationMessage = '';
        });
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
    if (ageGroups['under18']! > 0)
      filledGroups.add(
        'Dưới 18: ${_formatNumber(ageGroups['under18'].toString())} người/ngày',
      );
    if (ageGroups['18to30']! > 0)
      filledGroups.add(
        '18-30: ${_formatNumber(ageGroups['18to30'].toString())} người/ngày',
      );
    if (ageGroups['31to45']! > 0)
      filledGroups.add(
        '31-45: ${_formatNumber(ageGroups['31to45'].toString())} người/ngày',
      );
    if (ageGroups['over45']! > 0)
      filledGroups.add(
        'Trên 45: ${_formatNumber(ageGroups['over45'].toString())} người/ngày',
      );
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
              showInfo: true,
              infoTitle: 'Hướng dẫn nhập giới tính khách hàng chính',
              useBulletPoints: true,
              bulletPoints: [
                'Chọn giới tính chiếm đa số trong số khách hàng (Nam, Nữ, hoặc Khác).',
                'Nhập số lượng khách hàng theo giới tính đã chọn (người/ngày).',
                'Số lượng không được vượt quá tổng số dân trong khu vực.',
                'Kiểm tra thông báo nếu số liệu vượt quá giới hạn.',
              ],
              children: [_buildGenderSelectionWidget()],
            ),
            AnimatedExpansionCard(
              icon: Icons.group,
              title: 'Nhóm độ tuổi',
              subtitle: _getAgeGroupsSubtitle(),
              theme: widget.theme,
              showInfo: true,
              infoTitle: 'Hướng dẫn nhập nhóm độ tuổi',
              useBulletPoints: true,
              bulletPoints: [
                'Nhập số lượng khách hàng cho từng nhóm độ tuổi (người/ngày).',
                'Tổng số lượng của các nhóm phải khớp với tổng số dân trong khu vực.',
                'Hệ thống tự động tính nhóm tuổi chiếm tỉ lệ cao nhất.',
                'Sử dụng dấu phẩy để định dạng số lớn (ví dụ: 1,000).',
              ],
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
              showInfo: true,
              infoTitle: 'Hướng dẫn nhập thu nhập trung bình',
              useBulletPoints: true,
              bulletPoints: [
                'Chọn mức thu nhập phổ biến nhất của khách hàng.',
                'Nhập số lượng dân số có mức thu nhập này (người/ngày).',
                'Số lượng không được vượt quá tổng số dân trong khu vực.',
                'Xem biên độ sai số để đánh giá độ tin cậy.',
              ],
              children: [_buildIncomeSelectionWidget()],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelectionWidget() {
    int totalPopulation = widget.reportData['totalPopulationPerDay'] ?? 0;
    int? genderValue = _getGenderValue();
    String percentageInfo =
        totalPopulation > 0 && genderValue != null && genderValue > 0
            ? ' ${((genderValue / totalPopulation) * 100).round()}% trên tổng số dân trong khu vực là ${totalPopulation} người/ngày'
            : '';

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInputField(
                label: 'Số lượng khách hàng',
                hintText: 'Ví dụ: 1,000',
                icon: Icons.info_outline,
                theme: widget.theme,
                initialValue:
                    localCustomerModelData['genderInfo'] != null &&
                            localCustomerModelData['genderInfo'].isNotEmpty
                        ? _formatNumber(localCustomerModelData['genderInfo'])
                        : '',
                keyboardType: TextInputType.number,
                numbersOnly: true,
                formatThousands: true,
                suffixText: 'người/ngày',
                onSaved: (value) {
                  setState(() {
                    localCustomerModelData['genderInfo'] = value.replaceAll(
                      ',',
                      '',
                    );
                    _updateAttributeValues();
                    _updateGenderValidation();
                  });
                },
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    int? inputValue = int.tryParse(value.replaceAll(',', ''));
                    if (inputValue != null &&
                        totalPopulation > 0 &&
                        inputValue > totalPopulation) {
                      return 'Số lượng vượt quá tổng số dân ($totalPopulation)';
                    }
                  }
                  return null;
                },
              ),
              if (genderValue != null && totalPopulation > 0 && genderValue > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Chiếm $percentageInfo',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: widget.theme.colorScheme.onSurface.withOpacity(
                        0.7,
                      ),
                    ),
                  ),
                ),
            ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tổng số dân ở khu vực xung quanh mặt bằng ở các khung giờ cao điểm là ${_formatNumber((widget.reportData['totalPopulationPerDay'] ?? 0).toString())} người/ngày',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: widget.theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        ..._ageGroupControllers.entries.map((entry) {
          String key = entry.key;
          TextEditingController controller = entry.value;
          String label =
              key == 'under18'
                  ? 'Dưới 18 tuổi'
                  : key == '18to30'
                  ? '18-30 tuổi'
                  : key == '31to45'
                  ? '31-45 tuổi'
                  : 'Trên 45 tuổi';
          IconData icon =
              key == 'under18'
                  ? Icons.child_care
                  : key == 'over45'
                  ? Icons.elderly
                  : Icons.person;
          return CustomInputField(
            label: label,
            hintText: 'Nhập số lượng khách hàng',
            icon: icon,
            theme: widget.theme,
            controller: controller,
            keyboardType: TextInputType.number,
            numbersOnly: true,
            formatThousands: true,
            suffixText: 'người/ngày',
            onSaved: (value) => _updateAgeGroup(key, value),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                int? inputValue = int.tryParse(value.replaceAll(',', ''));
                int totalPopulation =
                    widget.reportData['totalPopulationPerDay'] ?? 0;
                if (inputValue != null &&
                    totalPopulation > 0 &&
                    getTotalAgeGroups() > totalPopulation) {
                  return 'Tổng vượt quá số dân ($totalPopulation)';
                }
              }
              return null;
            },
          );
        }).toList(),
        if (_ageGroupValidationMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _ageGroupValidationMessage,
              style: TextStyle(
                color: widget.theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
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
                hintText: 'Ví dụ: 1,000',
                icon: Icons.info_outline,
                theme: widget.theme,
                initialValue:
                    localCustomerModelData['incomePopulation'] != null &&
                            localCustomerModelData['incomePopulation']
                                .isNotEmpty
                        ? _formatNumber(
                          localCustomerModelData['incomePopulation'],
                        )
                        : '',
                keyboardType: TextInputType.number,
                numbersOnly: true,
                formatThousands: true,
                suffixText: 'người/ngày',
                onSaved: (value) {
                  setState(() {
                    localCustomerModelData['incomePopulation'] = value
                        .replaceAll(',', '');
                    _updateAttributeValues();
                  });
                },
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    int? inputValue = int.tryParse(value.replaceAll(',', ''));
                    int totalPopulation =
                        widget.reportData['totalPopulationPerDay'] ?? 0;
                    if (inputValue != null &&
                        totalPopulation > 0 &&
                        inputValue > totalPopulation) {
                      return 'Số lượng vượt quá tổng số dân ($totalPopulation)';
                    }
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'trên tổng số dân ${_formatNumber(_calculateTotalPopulation().toString())} người/ngày',
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
