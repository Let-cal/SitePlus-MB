import 'package:flutter/material.dart';
import 'package:siteplus_mb/utils/ReportPage/animated_expansion_card.dart';
import 'package:siteplus_mb/utils/ReportPage/custom_input_field.dart';
import 'package:siteplus_mb/utils/ReportPage/info_card.dart';
import 'package:siteplus_mb/utils/ReportPage/selectable_option_button.dart';

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
  List<Map<String, dynamic>> newAttributeValues = []; // Thêm để lưu giá trị mới
  List<Map<String, dynamic>> changedAttributeValues =
      []; // Thêm để lưu giá trị cập nhật
  late List<Map<String, dynamic>> originalAttributeValues; // Lưu giá trị gốc
  String _debugAttributeValues = '';
  final Map<String, int> attributeIds = {
    'gender': 6,
    'ageGroups': 7,
    'income': 8,
  };
  // Gender icons
  final Map<String, IconData> genderIcons = {
    'Nam': Icons.male,
    'Nữ': Icons.female,
    'Khác': Icons.people_alt,
  };

  // Age group controllers
  final Map<String, TextEditingController> _ageGroupControllers = {
    'under18': TextEditingController(),
    '18to30': TextEditingController(),
    '31to45': TextEditingController(),
    'over45': TextEditingController(),
  };

  // Income options with icons
  final Map<String, IconData> incomeIcons = {
    '<5 triệu/tháng': Icons.money_off,
    '5-10 triệu/tháng': Icons.monetization_on,
    '10-20 triệu/tháng': Icons.account_balance_wallet,
    '>20 triệu/tháng': Icons.attach_money,
  };

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

    // Initialize data after animation controller
    _initializeData();
    // Cập nhật sau khi build hoàn tất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAttributeValues();
      _updateDebugInfo();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _ageGroupControllers.forEach((key, controller) => controller.dispose());
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
    };

    defaultValues.forEach((key, value) {
      localCustomerModelData.putIfAbsent(key, () => value);
    });

    // Populate from attribute values
    _populateFromAttributeValues();

    // Initialize age group controllers
    _initializeAgeGroupControllers();
  }

  void _initializeAgeGroupControllers() {
    _ageGroupControllers.forEach((key, controller) {
      controller.text =
          (localCustomerModelData['ageGroups'][key] ?? 0).toString();
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
            .where(
              (item) =>
                  item['attributeId'] == 6 ||
                  item['attributeId'] == 7 ||
                  item['attributeId'] == 8,
            )
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
    if (widget.reportData['attributeValues'] == null) return;

    List<dynamic> attributeValues = widget.reportData['attributeValues'];

    // Find gender attribute (attributeId: 6)
    final genderAttribute = attributeValues.firstWhere(
      (attr) => attr['attributeId'] == 6,
      orElse: () => <String, dynamic>{},
    );

    // Chỉ xử lý nếu genderAttribute có giá trị 'value' không null
    if (genderAttribute != null && genderAttribute['value'] != null) {
      String genderValue = genderAttribute['value'];
      String genderSelection = 'Nam'; // Giá trị mặc định
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
        localCustomerModelData['genderInfo'] =
            additionalInfo.replaceAll(RegExp(r'\s*%'), '').trim();
      } else {
        localCustomerModelData['genderInfo'] = additionalInfo;
      }
    }

    // Find age group attribute (attributeId: 7)
    final ageAttribute = attributeValues.firstWhere(
      (attr) => attr['attributeId'] == 7,
      orElse: () => <String, dynamic>{},
    );

    if (ageAttribute != null) {
      String additionalInfo = ageAttribute['additionalInfo'] ?? '';
      Map<String, int> ageGroups = {
        'under18': 0,
        '18to30': 0,
        '31to45': 0,
        'over45': 0,
      };
      RegExp regex = RegExp(
        r'(\d+)% nhóm khách hàng có độ tuổi (dưới 18|18-30|31-45|trên 45)',
      );
      Iterable<RegExpMatch> matches = regex.allMatches(additionalInfo);
      for (var match in matches) {
        String percentage = match.group(1) ?? '0';
        String ageRange = match.group(2) ?? '';
        int percentValue = int.tryParse(percentage) ?? 0;
        switch (ageRange) {
          case 'dưới 18':
            ageGroups['under18'] = percentValue;
            break;
          case '18-30':
            ageGroups['18to30'] = percentValue;
            break;
          case '31-45':
            ageGroups['31to45'] = percentValue;
            break;
          case 'trên 45':
            ageGroups['over45'] = percentValue;
            break;
        }
      }
      localCustomerModelData['ageGroups'] = ageGroups;
    }

    // Find income attribute (attributeId: 8)
    final incomeAttribute = attributeValues.firstWhere(
      (attr) => attr['attributeId'] == 8,
      orElse: () => <String, dynamic>{},
    );

    if (incomeAttribute != null) {
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
    }
  }

  void _updateAgeGroup(String key, String value) {
    int? intValue = int.tryParse(value);
    if (intValue != null && intValue > 100) {
      intValue = 100;
    }
    setState(() {
      localCustomerModelData['ageGroups'][key] = intValue ?? 0;
      _updateAttributeValues();
    });
  }

  void _updateAttributeValues() {
    final List<Map<String, dynamic>> attributeValues =
        List<Map<String, dynamic>>.from(
          widget.reportData['attributeValues'] ?? [],
        );

    // Xử lý gender (attributeId: 6)
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
      String rawAdditionalInfo = localCustomerModelData['genderInfo'] ?? '';
      // Thêm % vào additionalInfo nếu có giá trị
      String additionalInfo =
          rawAdditionalInfo.isNotEmpty ? "$rawAdditionalInfo %" : "";

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
        // Nếu đã tồn tại (có id), cập nhật changedAttributeValues
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
        // Nếu là mới, thay thế hoặc thêm vào newAttributeValues
        final newIndex = newAttributeValues.indexWhere(
          (attr) => attr['attributeId'] == attributeIds['gender'],
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
      } else if (genderValue.isNotEmpty) {
        attributeValues.add(newValue);
      }
    }

    // Xử lý ageGroups (attributeId: 7)
    Map<String, int> ageGroups = Map<String, int>.from(
      localCustomerModelData['ageGroups'],
    );
    bool hasAgeData = ageGroups.values.any((value) => value > 0);
    if (hasAgeData) {
      String dominantAgeGroup = "";
      int highestPercentage = 0;
      ageGroups.forEach((key, value) {
        if (value > highestPercentage) {
          highestPercentage = value;
          switch (key) {
            case 'under18':
              dominantAgeGroup = "dưới 18 tuổi";
              break;
            case '18to30':
              dominantAgeGroup = "18-30 tuổi";
              break;
            case '31to45':
              dominantAgeGroup = "31-45 tuổi";
              break;
            case 'over45':
              dominantAgeGroup = "trên 45 tuổi";
              break;
          }
        }
      });

      List<String> ageDetails = [];
      ageGroups.forEach((key, value) {
        if (value > 0) {
          String ageName = "";
          switch (key) {
            case 'under18':
              ageName = "dưới 18";
              break;
            case '18to30':
              ageName = "18-30";
              break;
            case '31to45':
              ageName = "31-45";
              break;
            case 'over45':
              ageName = "trên 45";
              break;
          }
          ageDetails.add("$value% nhóm khách hàng có độ tuổi $ageName");
        }
      });
      String additionalInfo = ageDetails.join(", ");

      final existingAttr = originalAttributeValues.firstWhere(
        (attr) => attr['attributeId'] == attributeIds['ageGroups'],
        orElse: () => {},
      );

      final newValue = {
        'attributeId': attributeIds['ageGroups'],
        'siteId': widget.reportData['siteId'] ?? 0,
        'value': dominantAgeGroup,
        'additionalInfo': additionalInfo,
        if (existingAttr['id'] != null) 'id': existingAttr['id'],
      };

      if (existingAttr['id'] != null) {
        final changeIndex = changedAttributeValues.indexWhere(
          (attr) => attr['id'] == existingAttr['id'],
        );
        final updatedValue = {
          'id': existingAttr['id'],
          'value': dominantAgeGroup,
          'additionalInfo': additionalInfo,
        };
        if (changeIndex != -1) {
          changedAttributeValues[changeIndex] = updatedValue;
        } else {
          changedAttributeValues.add(updatedValue);
        }
      } else {
        final newIndex = newAttributeValues.indexWhere(
          (attr) => attr['attributeId'] == attributeIds['ageGroups'],
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

    // Xử lý income (attributeId: 8)
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
      String additionalInfo = "Thu nhập ${localCustomerModelData['income']}";

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

    // Cập nhật reportData
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

  String _getGenderSubtitle() {
    return localCustomerModelData['gender'] ?? 'Chưa chọn';
  }

  String _getAgeGroupsSubtitle() {
    Map<String, int> ageGroups = Map<String, int>.from(
      localCustomerModelData['ageGroups'],
    );

    List<String> filledGroups = [];

    if ((ageGroups['under18'] ?? 0) > 0) {
      filledGroups.add("Dưới 18: ${ageGroups['under18']}%");
    }
    if ((ageGroups['18to30'] ?? 0) > 0) {
      filledGroups.add("18-30: ${ageGroups['18to30']}%");
    }
    if ((ageGroups['31to45'] ?? 0) > 0) {
      filledGroups.add("31-45: ${ageGroups['31to45']}%");
    }
    if ((ageGroups['over45'] ?? 0) > 0) {
      filledGroups.add("Trên 45: ${ageGroups['over45']}%");
    }

    return filledGroups.isEmpty
        ? 'Chưa điền thông tin'
        : filledGroups.join(', ');
  }

  String _getIncomeSubtitle() {
    return localCustomerModelData['income'] ?? 'Chưa chọn';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'III. Mô Hình Khách Hàng',
              style: widget.theme.textTheme.headlineLarge?.copyWith(
                color: widget.theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            InfoCard(
              icon: Icons.lightbulb_outline,
              content:
                  'Ghi chú giới tính, độ tuổi và mức thu nhập của khách hàng.',
              backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
              iconColor: Theme.of(context).colorScheme.secondary,
              borderRadius: 20.0,
              padding: EdgeInsets.all(20.0),
            ),

            SizedBox(height: 20.0),

            // Gender Section
            AnimatedExpansionCard(
              icon: Icons.people,
              title: 'Giới tính khách hàng chính',
              subtitle: _getGenderSubtitle(),
              theme: widget.theme,
              children: [
                _buildGenderSelectionWidget(),
                SizedBox(height: 16),
                // Additional info for gender if selected
                if (localCustomerModelData['gender'] != null)
                  CustomInputField(
                    label: 'Thông tin chi tiết về tỷ lệ giới tính',
                    hintText: 'Ví dụ: Nam chiếm 60%',
                    icon: Icons.info_outline,
                    theme: widget.theme,
                    initialValue: localCustomerModelData['genderInfo'] ?? '',
                    onSaved: (value) {
                      setState(() {
                        localCustomerModelData['genderInfo'] = value;
                        _updateAttributeValues();
                      });
                    },
                  ),
              ],
            ),

            // Age Group Section
            AnimatedExpansionCard(
              icon: Icons.group,
              title: 'Nhóm độ tuổi',
              subtitle: _getAgeGroupsSubtitle(),
              theme: widget.theme,
              children: [_buildAgeGroupSelectionWidget()],
            ),

            // Income Section
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
                });
              },
              theme: widget.theme,
            );
          }).toList(),
    );
  }

  Widget _buildAgeGroupSelectionWidget() {
    return Column(
      children: [
        CustomInputField(
          label: 'Dưới 18 tuổi',
          hintText: 'Nhập phần trăm khách hàng',
          icon: Icons.child_care,
          theme: widget.theme,
          initialValue:
              localCustomerModelData['ageGroups']['under18'].toString() != "0"
                  ? localCustomerModelData['ageGroups']['under18'].toString()
                  : '',
          keyboardType: TextInputType.number,
          numbersOnly: true,
          maxLength: 3,
          suffixText: '%',
          onSaved: (value) {
            _updateAgeGroup('under18', value);
          },
        ),
        CustomInputField(
          label: '18-30 tuổi',
          hintText: 'Nhập phần trăm khách hàng',
          icon: Icons.person,
          theme: widget.theme,
          initialValue:
              localCustomerModelData['ageGroups']['18to30'].toString() != "0"
                  ? localCustomerModelData['ageGroups']['18to30'].toString()
                  : '',
          keyboardType: TextInputType.number,
          numbersOnly: true,
          maxLength: 3,
          suffixText: '%',
          onSaved: (value) {
            _updateAgeGroup('18to30', value);
          },
        ),
        CustomInputField(
          label: '31-45 tuổi',
          hintText: 'Nhập phần trăm khách hàng',
          icon: Icons.person,
          theme: widget.theme,
          initialValue:
              localCustomerModelData['ageGroups']['31to45'].toString() != "0"
                  ? localCustomerModelData['ageGroups']['31to45'].toString()
                  : '',
          keyboardType: TextInputType.number,
          numbersOnly: true,
          maxLength: 3,
          suffixText: '%',
          onSaved: (value) {
            _updateAgeGroup('31to45', value);
          },
        ),
        CustomInputField(
          label: 'Trên 45 tuổi',
          hintText: 'Nhập phần trăm khách hàng',
          icon: Icons.elderly,
          theme: widget.theme,
          initialValue:
              localCustomerModelData['ageGroups']['over45'].toString() != "0"
                  ? localCustomerModelData['ageGroups']['over45'].toString()
                  : '',
          keyboardType: TextInputType.number,
          numbersOnly: true,
          maxLength: 3,
          suffixText: '%',
          onSaved: (value) {
            _updateAgeGroup('over45', value);
          },
        ),
      ],
    );
  }

  Widget _buildIncomeSelectionWidget() {
    return Column(
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
    );
  }
}
