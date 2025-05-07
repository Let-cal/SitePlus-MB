import 'package:flutter/material.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/animated_expansion_card.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/custom_chip_group.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/info_card.dart';
import 'package:siteplus_mb/components/custom_input_field.dart';
import 'package:siteplus_mb/utils/constants.dart';

class CustomerFlowSection extends StatefulWidget {
  final Map<String, dynamic> reportData;
  final Function(void Function()) setState;
  final ThemeData theme;
  final int siteId;

  const CustomerFlowSection({
    super.key,
    required this.reportData,
    required this.setState,
    required this.theme,
    required this.siteId,
  });

  @override
  _CustomerFlowSectionState createState() => _CustomerFlowSectionState();
}

class _CustomerFlowSectionState extends State<CustomerFlowSection> {
  late Map<String, dynamic> localCustomerFlow;
  List<String> selectedVehicles = [];
  List<String> selectedPeakHours = [];
  List<String> customVehicles = [];
  List<String> customPeakHours = [];
  Map<String, List<String>> selectedVehicleCalculations = {};
  Map<String, String> vehicleCalculationAmounts = {};
  Map<String, String> peakHourAdditionalInfo = {};
  List<Map<String, dynamic>> changedAttributeValues = [];
  List<Map<String, dynamic>> newAttributeValues = [];
  late List<Map<String, dynamic>> originalAttributeValues;
  String _vehicleValidationMessage = '';

  final Map<String, int> attributeIds = {'vehicle': 2, 'peakHour': 3};

  final List<String> vehicleOptions = [
    TRANSPORTATION_MOTORCYCLE,
    TRANSPORTATION_CAR,
    TRANSPORTATION_BICYCLE,
    TRANSPORTATION_PEDESTRIAN,
    'khác',
  ];

  final Map<String, IconData> vehicleIcons = {
    TRANSPORTATION_MOTORCYCLE: Icons.motorcycle,
    TRANSPORTATION_CAR: Icons.directions_car,
    TRANSPORTATION_BICYCLE: Icons.pedal_bike,
    TRANSPORTATION_PEDESTRIAN: Icons.directions_walk,
    'khác': Icons.edit,
  };

  final List<String> calculationOptions = ['theo giờ', 'theo ngày'];

  final Map<String, IconData> calculationIcons = {
    'theo giờ': Icons.access_time,
    'theo ngày': Icons.calendar_today,
  };

  final List<String> peakHourOptions = [
    PEAK_HOUR_MORNING,
    PEAK_HOUR_NOON,
    PEAK_HOUR_AFTERNOON,
    PEAK_HOUR_EVENING,
    'khác',
  ];

  final Map<String, IconData> peakHourIcons = {
    PEAK_HOUR_MORNING: Icons.wb_sunny,
    PEAK_HOUR_NOON: Icons.lunch_dining,
    PEAK_HOUR_AFTERNOON: Icons.cloud,
    PEAK_HOUR_EVENING: Icons.nights_stay,
    'khác': Icons.edit,
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
    localCustomerFlow = Map<String, dynamic>.from(
      widget.reportData['customerFlow'] ?? {},
    );
    originalAttributeValues = List<Map<String, dynamic>>.from(
      widget.reportData['attributeValues'] ?? [],
    );

    selectedVehicles = List<String>.from(localCustomerFlow['vehicles'] ?? []);
    selectedPeakHours = List<String>.from(localCustomerFlow['peakHours'] ?? []);
    customVehicles = List<String>.from(
      localCustomerFlow['customVehicles'] ?? [],
    );
    customPeakHours = List<String>.from(
      localCustomerFlow['customPeakHours'] ?? [],
    );
    selectedVehicleCalculations =
        (localCustomerFlow['selectedVehicleCalculations'] != null)
            ? Map<String, List<String>>.from(
              localCustomerFlow['selectedVehicleCalculations'],
            )
            : {};
    vehicleCalculationAmounts =
        (localCustomerFlow['vehicleCalculationAmounts'] != null)
            ? Map<String, String>.from(
              localCustomerFlow['vehicleCalculationAmounts'],
            )
            : {};
    peakHourAdditionalInfo =
        (localCustomerFlow['peakHourAdditionalInfo'] != null)
            ? Map<String, String>.from(
              localCustomerFlow['peakHourAdditionalInfo'],
            )
            : {};

    for (var vehicle in selectedVehicles) {
      selectedVehicleCalculations.putIfAbsent(vehicle, () => []);
    }
    newAttributeValues = List<Map<String, dynamic>>.from(
      widget.reportData['newAttributeValues'] ?? [],
    );

    final peakHourAttrs =
        originalAttributeValues
            .where((attr) => attr['attributeId'] == attributeIds['peakHour'])
            .toList();
    if (peakHourAttrs.isNotEmpty) {
      selectedPeakHours.clear();
      String combinedValue = '';
      String additionalInfo = '';
      for (var attr in peakHourAttrs) {
        final value = attr['value'] as String;
        additionalInfo = attr['additionalInfo'] ?? '';
        if (value.contains(' và ')) {
          combinedValue = value;
          selectedPeakHours = value.split(' và ').toList();
        } else {
          if (!selectedPeakHours.contains(value)) {
            selectedPeakHours.add(value);
          }
        }
        if (additionalInfo.isNotEmpty) {
          peakHourAdditionalInfo[value] = additionalInfo;
        }
      }
      if (combinedValue.isNotEmpty) {
        selectedPeakHours = combinedValue.split(' và ').toList();
      }
      customPeakHours =
          selectedPeakHours.where((p) => !peakHourOptions.contains(p)).toList();
    }

    for (var vehicle in selectedVehicles) {
      for (var calc in selectedVehicleCalculations[vehicle] ?? []) {
        String key = '${vehicle}_$calc';
        if (vehicleCalculationAmounts[key] != null &&
            vehicleCalculationAmounts[key]!.isNotEmpty) {
          vehicleCalculationAmounts[key] = _formatNumber(
            vehicleCalculationAmounts[key]!,
          );
        }
      }
    }
  }

  String _formatNumber(String value) {
    if (value.isEmpty) return '';
    final number = int.tryParse(value.replaceAll(',', '')) ?? 0;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _generatePeakHourAdditionalInfo(List<String> selectedPeakHours) {
    if (selectedPeakHours.isEmpty) {
      return '';
    }
    return 'Tập trung đông đúc đa số vào ${selectedPeakHours.join(' và ')}';
  }

  void _handlePeakHourSelected(String option) {
    setState(() {
      if (selectedPeakHours.contains(option)) {
        selectedPeakHours.remove(option);
      } else {
        selectedPeakHours.add(option);
      }
      String newAdditionalInfo = _generatePeakHourAdditionalInfo(
        selectedPeakHours,
      );
      for (var peakHour in selectedPeakHours) {
        peakHourAdditionalInfo[peakHour] = newAdditionalInfo;
      }
    });
    _updateAttributeValues();
  }

  void _handleVehicleSelected(String vehicle) {
    setState(() {
      if (selectedVehicles.contains(vehicle)) {
        selectedVehicles.remove(vehicle);
        selectedVehicleCalculations.remove(vehicle);
        for (var calc in calculationOptions) {
          vehicleCalculationAmounts.remove('${vehicle}_$calc');
        }
      } else {
        selectedVehicles.add(vehicle);
        selectedVehicleCalculations[vehicle] = [];
      }
    });
    _updateAttributeValues();
  }

  void _handleCalculationSelected(String vehicle, String calculation) {
    setState(() {
      if (selectedVehicleCalculations[vehicle]!.contains(calculation)) {
        selectedVehicleCalculations[vehicle]!.remove(calculation);
        vehicleCalculationAmounts.remove('${vehicle}_$calculation');
      } else {
        selectedVehicleCalculations[vehicle]!.add(calculation);
        vehicleCalculationAmounts['${vehicle}_$calculation'] = '';
      }
    });
    _updateAttributeValues();
  }

  void _handleCustomVehicleAdded(String option) {
    setState(() {
      customVehicles.add(option);
      selectedVehicles.add(option);
      selectedVehicleCalculations[option] = [];
    });
    _updateAttributeValues();
  }

  void _handleCustomPeakHourAdded(String option) {
    setState(() {
      customPeakHours.add(option);
      selectedPeakHours.add(option);
      String newAdditionalInfo = _generatePeakHourAdditionalInfo(
        selectedPeakHours,
      );
      for (var peakHour in selectedPeakHours) {
        peakHourAdditionalInfo[peakHour] = newAdditionalInfo;
      }
    });
    _updateAttributeValues();
  }

  void _handleCustomVehicleRemoved(String option) {
    setState(() {
      customVehicles.remove(option);
      selectedVehicles.remove(option);
      selectedVehicleCalculations.remove(option);
      for (var calc in calculationOptions) {
        vehicleCalculationAmounts.remove('${option}_$calc');
      }
    });
    _updateAttributeValues();
  }

  void _handleCustomPeakHourRemoved(String option) {
    setState(() {
      customPeakHours.remove(option);
      selectedPeakHours.remove(option);
      String newAdditionalInfo = _generatePeakHourAdditionalInfo(
        selectedPeakHours,
      );
      for (var peakHour in selectedPeakHours) {
        peakHourAdditionalInfo[peakHour] = newAdditionalInfo;
      }
    });
    _updateAttributeValues();
  }

  void _updateAttributeValues() {
    final List<Map<String, dynamic>> attributeValues =
        List<Map<String, dynamic>>.from(
          widget.reportData['attributeValues'] ?? [],
        );

    int totalVehiclesPerHour = 0;
    int totalVehiclesPerDay = 0;

    selectedVehicleCalculations.forEach((vehicle, calculations) {
      for (var calc in calculations) {
        String key = '${vehicle}_$calc';
        String rawAmount =
            vehicleCalculationAmounts[key]?.replaceAll(',', '') ?? '';
        if (rawAmount.isNotEmpty) {
          int amount = int.parse(rawAmount);
          String unit = calc == 'theo giờ' ? 'người/giờ' : 'người/ngày';
          if (vehicle == TRANSPORTATION_PEDESTRIAN) {
            unit = calc == 'theo giờ' ? 'người/giờ' : 'người/ngày';
          } else {
            unit = calc == 'theo giờ' ? 'chiếc/giờ' : 'chiếc/ngày';
          }
          String additionalInfo = '$amount $unit';

          final existingAttr = originalAttributeValues.firstWhere(
            (attr) =>
                attr['attributeId'] == attributeIds['vehicle'] &&
                attr['value'] == vehicle &&
                attr['additionalInfo'].endsWith(unit),
            orElse: () => {},
          );

          if (existingAttr['id'] != null) {
            final changeIndex = changedAttributeValues.indexWhere(
              (attr) => attr['id'] == existingAttr['id'],
            );
            final updatedValue = {
              'id': existingAttr['id'],
              'value': vehicle,
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
                  attr['attributeId'] == attributeIds['vehicle'] &&
                  attr['value'] == vehicle &&
                  attr['additionalInfo'].endsWith(unit),
            );
            final newValue = {
              'attributeId': attributeIds['vehicle'],
              'siteId': widget.siteId,
              'value': vehicle,
              'additionalInfo': additionalInfo,
            };
            if (newIndex != -1) {
              newAttributeValues[newIndex] = newValue;
            } else {
              newAttributeValues.add(newValue);
            }
          }

          final index = attributeValues.indexWhere(
            (attr) => attr['id'] == existingAttr['id'],
          );
          final newValue = {
            'attributeId': attributeIds['vehicle'],
            'siteId': widget.siteId,
            'value': vehicle,
            'additionalInfo': additionalInfo,
            if (existingAttr['id'] != null) 'id': existingAttr['id'],
          };
          if (index != -1) {
            attributeValues[index] = newValue;
          } else {
            attributeValues.add(newValue);
          }

          if (calc == 'theo giờ') {
            totalVehiclesPerHour += amount;
          } else if (calc == 'theo ngày') {
            totalVehiclesPerDay += amount;
          }
        }
      }
    });

    if (selectedPeakHours.isNotEmpty) {
      String combinedValue = selectedPeakHours.join(' và ');
      String additionalInfo = _generatePeakHourAdditionalInfo(
        selectedPeakHours,
      );

      final existingPeakHourAttrs =
          originalAttributeValues
              .where((attr) => attr['attributeId'] == attributeIds['peakHour'])
              .toList();

      if (existingPeakHourAttrs.isNotEmpty) {
        for (var existingAttr in existingPeakHourAttrs) {
          final changeIndex = changedAttributeValues.indexWhere(
            (attr) => attr['id'] == existingAttr['id'],
          );
          final updatedValue = {
            'id': existingAttr['id'],
            'value': combinedValue,
            'additionalInfo': additionalInfo,
          };
          if (changeIndex != -1) {
            changedAttributeValues[changeIndex] = updatedValue;
          } else {
            changedAttributeValues.add(updatedValue);
          }

          final attrIndex = attributeValues.indexWhere(
            (attr) => attr['id'] == existingAttr['id'],
          );
          if (attrIndex != -1) {
            attributeValues[attrIndex] = {
              'attributeId': attributeIds['peakHour'],
              'siteId': widget.siteId,
              'value': combinedValue,
              'additionalInfo': additionalInfo,
              'id': existingAttr['id'],
            };
          }
        }
        final peakHourIds = existingPeakHourAttrs.map((e) => e['id']).toList();
        attributeValues.removeWhere(
          (attr) =>
              attr['attributeId'] == attributeIds['peakHour'] &&
              !peakHourIds.contains(attr['id']),
        );
      } else {
        final newIndex = newAttributeValues.indexWhere(
          (attr) => attr['attributeId'] == attributeIds['peakHour'],
        );
        final newValue = {
          'attributeId': attributeIds['peakHour'],
          'siteId': widget.siteId,
          'value': combinedValue,
          'additionalInfo': additionalInfo,
        };
        if (newIndex != -1) {
          newAttributeValues[newIndex] = newValue;
        } else {
          newAttributeValues.add(newValue);
        }

        final attrIndex = attributeValues.indexWhere(
          (attr) => attr['attributeId'] == attributeIds['peakHour'],
        );
        if (attrIndex != -1) {
          attributeValues[attrIndex] = newValue;
        } else {
          attributeValues.add(newValue);
        }
      }
    } else {
      attributeValues.removeWhere(
        (attr) => attr['attributeId'] == attributeIds['peakHour'],
      );
      newAttributeValues.removeWhere(
        (attr) => attr['attributeId'] == attributeIds['peakHour'],
      );
      changedAttributeValues.removeWhere(
        (attr) => attr['attributeId'] == attributeIds['peakHour'],
      );
    }

    widget.setState(() {
      widget.reportData['customerFlow'] = {
        'vehicles': selectedVehicles,
        'peakHours': selectedPeakHours,
        'selectedVehicleCalculations': selectedVehicleCalculations,
        'vehicleCalculationAmounts': vehicleCalculationAmounts,
        'peakHourAdditionalInfo': peakHourAdditionalInfo,
        'customVehicles': customVehicles,
        'customPeakHours': customPeakHours,
      };
      widget.reportData['attributeValues'] = attributeValues;
      widget.reportData['changedAttributeValues'] =
          List<Map<String, dynamic>>.from(changedAttributeValues);
      widget.reportData['newAttributeValues'] = List<Map<String, dynamic>>.from(
        newAttributeValues,
      );
      widget.reportData['totalVehiclesPerHour'] = totalVehiclesPerHour;
      widget.reportData['totalVehiclesPerDay'] = totalVehiclesPerDay;
    });

    _updateDebugInfo();
  }

  void _updateDebugInfo() {
    final List<Map<String, dynamic>> attributeValues =
        List<Map<String, dynamic>>.from(
          widget.reportData['attributeValues'] ?? [],
        );
    final trafficAttributes =
        attributeValues
            .where(
              (item) => item['attributeId'] == 2 || item['attributeId'] == 3,
            )
            .toList();

    debugPrint(
      'attributeValues:\n${trafficAttributes.map((item) => '  - attributeId: ${item['attributeId']}\n'
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
      '    additionalInfo: ${item['additionalInfo']}').join('\n\n')}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'I. Lưu Lượng Khách Hàng',
            style: widget.theme.textTheme.titleLarge?.copyWith(
              color: widget.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          InfoCard(
            icon: Icons.lightbulb_outline,
            content:
                'Ghi lại phương tiện di chuyển chính và giờ cao điểm của khách hàng.',
            backgroundColor: widget.theme.colorScheme.tertiaryFixed,
            iconColor: widget.theme.colorScheme.secondary,
            borderRadius: 20.0,
            padding: const EdgeInsets.all(20.0),
          ),
          const SizedBox(height: 16),
          AnimatedExpansionCard(
            icon: Icons.directions_car,
            title: 'Phương Tiện Di Chuyển',
            subtitle:
                selectedVehicles.isEmpty
                    ? 'Chưa chọn'
                    : selectedVehicles.join(', '),
            theme: widget.theme,
            showInfo: true,
            infoTitle: 'Hướng dẫn nhập phương tiện di chuyển',
            useBulletPoints: true,
            bulletPoints: [
              'Chọn các phương tiện di chuyển phổ biến của khách hàng.',
              'Nhập số lượng phương tiện theo giờ hoặc theo ngày (chiếc/giờ hoặc chiếc/ngày).',
              'Tổng số phương tiện không được vượt quá tổng số dân trong khu vực.',
              'Kiểm tra thông báo nếu số liệu vượt quá giới hạn.',
            ],
            children: [
              CustomChipGroup(
                options: vehicleOptions,
                selectedOptions: selectedVehicles,
                customOptions: customVehicles,
                optionIcons: vehicleIcons,
                onOptionSelected: _handleVehicleSelected,
                onCustomOptionAdded: _handleCustomVehicleAdded,
                onCustomOptionRemoved: _handleCustomVehicleRemoved,
                showOtherInputOnlyWhenSelected: true,
                otherOptionKey: 'khác',
              ),
              const SizedBox(height: 12),
              ...selectedVehicles.map((vehicle) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cách tính cho $vehicle:',
                      style: widget.theme.textTheme.titleMedium,
                    ),
                    CustomChipGroup(
                      options: calculationOptions,
                      selectedOptions:
                          selectedVehicleCalculations[vehicle] ?? [],
                      customOptions: [],
                      optionIcons: calculationIcons,
                      onOptionSelected:
                          (calc) => _handleCalculationSelected(vehicle, calc),
                      onCustomOptionAdded: null,
                      onCustomOptionRemoved: null,
                      showOtherInputOnlyWhenSelected: false,
                    ),
                    const SizedBox(height: 8),
                    ...selectedVehicleCalculations[vehicle]!.map((calc) {
                      String key = '${vehicle}_$calc';
                      String unit =
                          calc == 'theo giờ' ? 'chiếc/giờ' : 'chiếc/ngày';
                      if (vehicle == TRANSPORTATION_PEDESTRIAN) {
                        unit = calc == 'theo giờ' ? 'người/giờ' : 'người/ngày';
                      }
                      return CustomInputField(
                        key: ValueKey(key),
                        label: 'Số lượng $vehicle $calc',
                        hintText: 'Ví dụ: 1,000',
                        icon: vehicleIcons[vehicle] ?? Icons.directions_car,
                        initialValue: vehicleCalculationAmounts[key] ?? '',
                        theme: widget.theme,
                        keyboardType: TextInputType.number,
                        numbersOnly: true,
                        formatThousands: true,
                        suffixText: unit,
                        onSaved: (value) {
                          setState(() {
                            vehicleCalculationAmounts[key] = value.replaceAll(
                              ',',
                              '',
                            );

                            _updateAttributeValues();
                          });
                        },
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            int? inputValue = int.tryParse(
                              value.replaceAll(',', ''),
                            );
                            int totalPopulation =
                                widget.reportData['totalPopulationPerDay'] ?? 0;
                            if (inputValue != null && totalPopulation > 0) {
                              int totalVehicles = 0;
                              vehicleCalculationAmounts.forEach((k, v) {
                                if (k != key) {
                                  int? amount = int.tryParse(
                                    v.replaceAll(',', ''),
                                  );
                                  if (amount != null) totalVehicles += amount;
                                }
                              });
                              totalVehicles += inputValue;
                              if (totalVehicles > totalPopulation) {
                                return 'Tổng số phương tiện ($totalVehicles) vượt quá tổng số dân ($totalPopulation)';
                              }
                            }
                          }
                          return null;
                        },
                      );
                    }),
                    const SizedBox(height: 12),
                  ],
                );
              }),
            ],
          ),
          AnimatedExpansionCard(
            icon: Icons.access_time,
            title: 'Giờ Cao Điểm',
            subtitle:
                selectedPeakHours.isEmpty
                    ? 'Chưa chọn'
                    : selectedPeakHours.join(', '),
            theme: widget.theme,
            showInfo: true,
            infoTitle: 'Hướng dẫn nhập giờ cao điểm',
            useBulletPoints: true,
            bulletPoints: [
              'Chọn các khung giờ cao điểm mà khách hàng thường xuất hiện.',
              'Có thể thêm khung giờ tùy chỉnh nếu không có trong danh sách.',
              'Hệ thống sẽ tự động gộp các khung giờ thành một câu mô tả.',
            ],
            children: [
              CustomChipGroup(
                options: peakHourOptions,
                selectedOptions: selectedPeakHours,
                customOptions: customPeakHours,
                optionIcons: peakHourIcons,
                onOptionSelected: _handlePeakHourSelected,
                onCustomOptionAdded: _handleCustomPeakHourAdded,
                onCustomOptionRemoved: _handleCustomPeakHourRemoved,
                showOtherInputOnlyWhenSelected: true,
                otherOptionKey: 'khác',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
