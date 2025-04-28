import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/animated_expansion_card.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/custom_chip_group.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/info_card.dart';
import 'package:siteplus_mb/components/7_AttributesComponents/selectable_option_button.dart';
import 'package:siteplus_mb/components/custom_input_field.dart';

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
  late int? siteCategoryId;
  List<Map<String, dynamic>> newAttributeValues = []; // Lưu giá trị mới
  List<Map<String, dynamic>> changedAttributeValues =
      []; // Lưu giá trị cập nhật
  late List<Map<String, dynamic>> originalAttributeValues; // Lưu giá trị gốc
  String _debugAttributeValues = '';
  String? hasCommonAmenities; // Biến lưu trữ "có" hoặc "không" cho tiện ích
  List<String> selectedAmenities = []; // Danh sách các tiện ích được chọn
  Map<String, String> selectedAmenityStatuses =
      {}; // Map lưu trạng thái cho từng tiện ích
  List<String> customAmenities = [];
  final Map<String, Map<String, dynamic>> factorConfigs = {
    'airQuality': {
      'title': 'Chất lượng không khí \n(AQI/PM2.5)',
      'icon': Icons.air,
      'options': [
        {
          'label': 'Tốt (AQI 0–50; PM2.5 ≤5)',
          'icon': Icons.check_circle_outline,
        },
        {
          'label': 'Trung bình (AQI 51–100; PM2.5 5–12)',
          'icon': Icons.remove_circle_outline,
        },
        {'label': 'Kém (AQI >100; PM2.5 >12)', 'icon': Icons.cancel_outlined},
      ],
      'infoTitle': 'AQI (Air Quality Index) - Chỉ số chất lượng không khí',
      'bulletPoints': [
        'Là chỉ số tổng hợp thể hiện mức độ ô nhiễm không khí từ nhiều chất ô nhiễm như PM2.5, PM10, NO₂, SO₂, CO và O₃.',
        'Thang điểm từ 0 đến 500, càng cao càng ô nhiễm.',
        'Dưới 50 là tốt, trên 100 có thể gây ảnh hưởng đến sức khỏe, đặc biệt là nhóm nhạy cảm.',
      ],
    },
    'naturalLight': {
      'title': 'Ánh sáng tự nhiên (lux)',
      'icon': Icons.wb_sunny,
      'options': [
        {'label': 'Tốt (≥500 lux)', 'icon': Icons.brightness_high},
        {'label': 'Trung bình (300–500 lux)', 'icon': Icons.brightness_medium},
        {'label': 'Kém (<300 lux)', 'icon': Icons.brightness_low},
      ],
      'infoTitle': 'Cường độ chiếu sáng (lux) đo tại mặt tiền:',
      'bulletPoints': [
        '1 lux = lượng ánh sáng rơi trên diện tích 1 mét vuông từ nguồn sáng 1 lumen.',
        'Ánh sáng ngoài trời ban ngày thường > 10,000 lux, còn trong nhà thì 100–500 lux tùy chức năng.',
        'Trong mặt bằng bán lẻ, ≥ 500 lux được xem là đủ sáng.',
      ],
    },
    'greenery': {
      'title': 'Không gian xanh \n(3–30–300)',
      'icon': Icons.park,
      'options': [
        {'label': 'Phong phú (≥30 %)', 'icon': Icons.forest},
        {'label': 'Trung bình (10–30 %)', 'icon': Icons.grass},
        {'label': 'Hiếm (<10 %)', 'icon': Icons.crop_square},
      ],
      'infoTitle': 'Áp dụng quy tắc 3–30–300:',
      'bulletPoints': [
        '3 m: khoảng cách tối đa đến cây to nhất trong vòng 3 m từ mặt tiền',
        '30 %: tỷ lệ che phủ xanh trong bán kính 300 m quanh địa điểm ≥ 30 % là “phong phú”',
        '300 m: phải có công viên ≥ 0,5 ha trong bán kính 300 m',
        'Phong phú: ≥ 30 %',
        'Trung bình: 10–30 %',
        'Hiếm/Thiếu: < 10 %.',
      ],
    },
    'waste': {
      'title': 'Quản lý rác thải (mẩu/100 m)',
      'icon': Icons.delete_outline,
      'options': [
        {'label': 'Không có (0)', 'icon': Icons.check_circle_outline},
        {'label': 'Ít (1–5)', 'icon': Icons.remove_circle_outline},
        {'label': 'Nhiều (>5)', 'icon': Icons.cancel_outlined},
      ],
      'infoTitle': 'Đếm số mẩu rác trong 100 m đường phố sát mặt tiền:',
      'bulletPoints': ['Không có: 0 mẩu', 'Ít: 1–5 mẩu', 'Nhiều: > 5 mẩu'],
    },
    'noise': {
      'title': 'Tiếng ồn (dB)',
      'icon': Icons.hearing,
      'options': [
        {'label': 'Thấp (<55 dB)', 'icon': Icons.volume_mute},
        {'label': 'Trung bình (55–70 dB)', 'icon': Icons.volume_down},
        {'label': 'Cao (>70 dB)', 'icon': Icons.volume_up},
      ],
      'infoTitle': 'dB (Decibel) – Đơn vị đo âm lượng',
      'bulletPoints': [
        'Là đơn vị logarit để đo cường độ âm thanh.',
        '30 dB: yên tĩnh như thư viện',
        '60 dB: âm lượng hội thoại thông thường',
        '>70 dB: có thể ảnh hưởng đến sức khỏe nếu kéo dài',
      ],
    },
  };

  final Map<String, Map<String, dynamic>> additionalFactorConfigs = {
    'ventilation': {
      'title': 'Thông gió (ACH)',
      'icon': Icons.air,
      'options': [
        {'label': 'Tốt (≥6 ACH)', 'icon': Icons.check_circle},
        {'label': 'Trung bình (3–6 ACH)', 'icon': Icons.remove_circle},
        {'label': 'Kém (<3 ACH)', 'icon': Icons.cancel},
      ],
      'infoTitle':
          'ACH (Air Changes per Hour) – Số lần trao đổi không khí mỗi giờ',
      'bulletPoints': [
        'Cho biết không khí trong phòng được thay mới bao nhiêu lần mỗi giờ.',
        'Ví dụ: 6 ACH nghĩa là không khí được thay mới 6 lần mỗi giờ.',
      ],
    },
    'airConditioning': {
      'title': 'Điều hòa (BTU/ft²)',
      'icon': Icons.ac_unit,
      'options': [
        {'label': 'Tốt (≥20 BTU/ft²)', 'icon': Icons.check_circle},
        {'label': 'Trung bình (15–20 BTU/ft²)', 'icon': Icons.remove_circle},
        {'label': 'Kém (<15 BTU/ft²)', 'icon': Icons.cancel},
      ],
      'infoTitle':
          'BTU/ft² (British Thermal Unit trên foot vuông) – Đơn vị công suất điều hòa trên diện tích',
      'bulletPoints': [
        'BTU là đơn vị đo nhiệt lượng, thường dùng để xác định công suất máy lạnh.',
        '1 ft² (foot vuông) ≈ 0.093 m²',
        'Ví dụ: mặt bằng 500 ft² cần điều hòa có công suất từ 10,000–12,000 BTU.',
      ],
    },
    'commonAmenities': {
      'title': 'Tiện ích chung',
      'icon': Icons.local_parking,
      'amenities': [
        'Thang máy',
        'Thang bộ',
        'Bãi đỗ xe',
        'Phòng gym',
        'Hồ bơi',
        'Khu vui chơi',
      ],
      'statuses': ['Rộng', 'Đầy đủ', 'Hiện đại', 'Tiện nghi'],
      'infoTitle': 'Tiện ích chung trong tòa nhà',
      'bulletPoints': [
        'Thang máy giúp khách hàng dễ dàng di chuyển giữa các tầng, đặc biệt với mặt bằng ở tầng cao.',
        'Thang bộ đảm bảo an toàn và là phương tiện thoát hiểm cơ bản.',
        'Các tiện ích như bãi đỗ xe, phòng gym, hồ bơi góp phần tạo môi trường làm việc và kinh doanh chuyên nghiệp.',
      ],
    },
  };

  final Map<String, int> attributeIdMap = {
    'airQuality': 12,
    'naturalLight': 13,
    'greenery': 14,
    'waste': 15,
    'noise': 40,
    'surroundingStores': 16,
    'ventilation': 24,
    'airConditioning': 26,
    'commonAmenities': 27,
  };

  final Map<String, IconData> surroundingStoresIcons = {
    'Siêu thị': Icons.store_mall_directory,
    'Nhà hàng': Icons.restaurant,
    'Trường học': Icons.school,
    'Văn phòng': Icons.business,
  };

  final Map<String, IconData> amenityIcons = {
    'Bãi đỗ xe': Icons.local_parking,
    'Phòng gym': Icons.fitness_center,
    'Hồ bơi': Icons.pool,
    'Khu vui chơi': Icons.child_care,
  };

  final Map<String, IconData> statusIcons = {
    'Rộng': Icons.space_bar,
    'Đầy đủ': Icons.check_circle,
    'Hiện đại': Icons.trending_up,
    'Tiện nghi': Icons.star,
  };

  @override
  void initState() {
    super.initState();
    siteCategoryId = widget.reportData['siteCategoryId'] as int?;
    _initializeData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAttributeValues();
      _updateDebugInfo();
    });
  }

  void _initializeData() {
    localEnvironmentalFactors = Map.from(
      widget.reportData['environmentalFactors'] ?? {},
    );
    originalAttributeValues = List<Map<String, dynamic>>.from(
      widget.reportData['attributeValues'] ?? [],
    );
    newAttributeValues = List<Map<String, dynamic>>.from(
      widget.reportData['newAttributeValues'] ?? [],
    );

    // Khởi tạo giá trị mặc định
    final defaultValues = {
      'airQuality': {'value': '', 'additionalInfo': ''},
      'naturalLight': {'value': '', 'additionalInfo': ''},
      'greenery': {'value': '', 'additionalInfo': ''},
      'waste': {'value': '', 'additionalInfo': ''},
      'noise': {'value': '', 'additionalInfo': ''},
      'surroundingStores': [],
      'customStores': [],
      'surroundingStores_additionalInfo': '',
      'ventilation': {'exists': null, 'quality': null, 'additionalInfo': ''},
      'airConditioning': {
        'exists': null,
        'quality': null,
        'additionalInfo': '',
      },
      'commonAmenities': {
        'hasCommonAmenities': null,
        'selectedAmenities': [],
        'selectedAmenityStatuses': {},
        'customAmenities': [],
        'additionalInfo': '',
      },
    };

    defaultValues.forEach((key, value) {
      localEnvironmentalFactors.putIfAbsent(key, () => value);
    });

    hasCommonAmenities =
        localEnvironmentalFactors['commonAmenities']['hasCommonAmenities'];
    selectedAmenities = List<String>.from(
      localEnvironmentalFactors['commonAmenities']['selectedAmenities'] ?? [],
    );
    selectedAmenityStatuses = Map<String, String>.from(
      localEnvironmentalFactors['commonAmenities']['selectedAmenityStatuses'] ??
          {},
    );
    customAmenities = List<String>.from(
      localEnvironmentalFactors['commonAmenities']['customAmenities'] ?? [],
    );

    _populateFromAttributeValues();
    _logger.info(
      "Initialized environmentalFactors: $localEnvironmentalFactors",
    );
  }

  void _populateFromAttributeValues() {
    if (widget.reportData['attributeValues'] == null) return;

    List<dynamic> attributeValues = widget.reportData['attributeValues'];

    for (var attr in attributeValues) {
      final int attrId = attr['attributeId'];
      final String value = attr['value'] ?? '';
      final String additionalInfo = attr['additionalInfo'] ?? '';

      switch (attrId) {
        case 12: // airQuality
          localEnvironmentalFactors['airQuality'] = {
            'value': value,
            'additionalInfo': additionalInfo,
          };
          break;
        case 13: // naturalLight
          localEnvironmentalFactors['naturalLight'] = {
            'value': value,
            'additionalInfo': additionalInfo,
          };
          break;
        case 14: // greenery
          localEnvironmentalFactors['greenery'] = {
            'value': value,
            'additionalInfo': additionalInfo,
          };
          break;
        case 15: // waste
          localEnvironmentalFactors['waste'] = {
            'value': value,
            'additionalInfo': additionalInfo,
          };
          break;
        case 40: // noise
          localEnvironmentalFactors['noise'] = {
            'value': value,
            'additionalInfo': additionalInfo,
          };
          break;
        case 16: // surroundingStores
          final stores = value.split(', ').toList();
          final presetStores =
              stores
                  .where((s) => surroundingStoresIcons.keys.contains(s))
                  .toList();
          final customStores =
              stores.where((s) => !presetStores.contains(s)).toList();
          localEnvironmentalFactors['surroundingStores'] = presetStores;
          localEnvironmentalFactors['customStores'] = customStores;
          localEnvironmentalFactors['surroundingStores_additionalInfo'] =
              additionalInfo;
          break;
        case 24: // ventilation
          if (value == 'không') {
            localEnvironmentalFactors['ventilation'] = {
              'exists': 'không',
              'quality': null,
              'additionalInfo': additionalInfo,
            };
          } else {
            final parts = value.split(' - ');
            localEnvironmentalFactors['ventilation'] = {
              'exists': parts[0] == 'có' ? 'có' : null,
              'quality': parts.length > 1 ? parts[1] : null,
              'additionalInfo': additionalInfo,
            };
          }
          break;
        case 26: // airConditioning
          if (value == 'không') {
            localEnvironmentalFactors['airConditioning'] = {
              'exists': 'không',
              'quality': null,
              'additionalInfo': additionalInfo,
            };
          } else {
            final parts = value.split(' - ');
            localEnvironmentalFactors['airConditioning'] = {
              'exists': parts[0] == 'có' ? 'có' : null,
              'quality': parts.length > 1 ? parts[1] : null,
              'additionalInfo': additionalInfo,
            };
          }
          break;
        case 27: // commonAmenities
          if (value == 'không') {
            localEnvironmentalFactors['commonAmenities'] = {
              'hasCommonAmenities': 'không',
              'selectedAmenities': [],
              'selectedAmenityStatuses': {},
              'customAmenities': [],
              'additionalInfo': additionalInfo,
            };
            hasCommonAmenities = 'không';
            selectedAmenities.clear();
            selectedAmenityStatuses.clear();
            customAmenities.clear();
          } else if (value.isNotEmpty) {
            hasCommonAmenities = 'có';
            final parts = value.split(', ');
            for (var part in parts) {
              final subParts = part.split(' - ');
              if (subParts.length >= 2) {
                final amenity = subParts[0].replaceFirst('Có ', '');
                final status = subParts[1];
                if (!selectedAmenities.contains(amenity)) {
                  selectedAmenities.add(amenity);
                }
                selectedAmenityStatuses[amenity] = status;
                if (!additionalFactorConfigs['commonAmenities']!['amenities']
                        .contains(amenity) &&
                    !customAmenities.contains(amenity)) {
                  customAmenities.add(amenity);
                }
              }
            }
            localEnvironmentalFactors['commonAmenities'] = {
              'hasCommonAmenities': 'có',
              'selectedAmenities': selectedAmenities,
              'selectedAmenityStatuses': selectedAmenityStatuses,
              'customAmenities': customAmenities,
              'additionalInfo': additionalInfo,
            };
          }
          break;
      }
    }
  }

  void _updateDebugInfo() {
    final List<Map<String, dynamic>> attributeValues =
        List<Map<String, dynamic>>.from(
          widget.reportData['attributeValues'] ?? [],
        );
    final factorsAttributes =
        attributeValues
            .where(
              (item) => attributeIdMap.values.contains(item['attributeId']),
            )
            .toList();

    _debugAttributeValues =
        'attributeValues:\n${factorsAttributes.map((item) => '  - attributeId: ${item['attributeId']}\n'
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

  void _handleFactorSelection(String key, String value) {
    setState(() {
      if (localEnvironmentalFactors[key] is Map) {
        localEnvironmentalFactors[key]['value'] = value;
      } else {
        localEnvironmentalFactors[key] = {'value': value, 'additionalInfo': ''};
      }
      _updateAttributeValues();
    });
  }

  void _handleStoreSelection(String store) {
    setState(() {
      List<String> stores = List.from(
        localEnvironmentalFactors['surroundingStores'] ?? [],
      );
      if (stores.contains(store)) {
        stores.remove(store);
      } else {
        stores.add(store);
      }
      localEnvironmentalFactors['surroundingStores'] = stores;
      _updateAttributeValues();
    });
  }

  void _handleCustomStoreAdded(String store) {
    setState(() {
      List<String> customStores = List.from(
        localEnvironmentalFactors['customStores'] ?? [],
      );
      if (!customStores.contains(store)) {
        customStores.add(store);
        localEnvironmentalFactors['customStores'] = customStores;
        _updateAttributeValues();
      }
    });
  }

  void _handleCustomStoreRemoved(String store) {
    setState(() {
      List<String> customStores = List.from(
        localEnvironmentalFactors['customStores'] ?? [],
      );
      customStores.remove(store);
      localEnvironmentalFactors['customStores'] = customStores;
      _updateAttributeValues();
    });
  }

  void _updateAttributeValues() {
    final List<Map<String, dynamic>> attributeValues =
        List<Map<String, dynamic>>.from(
          widget.reportData['attributeValues'] ?? [],
        );

    _logger.info('Before update - attributeValues: $attributeValues');

    // Cập nhật các yếu tố cơ bản
    for (var key in factorConfigs.keys) {
      final attributeId = attributeIdMap[key];
      if (attributeId != null) {
        final factorData = localEnvironmentalFactors[key];
        if (factorData is Map &&
            factorData['value'] is String &&
            (factorData['value'] as String).isNotEmpty) {
          final value = factorData['value'] as String;
          final additionalInfo = factorData['additionalInfo'] ?? '';
          _updateSingleAttribute(
            attributeValues,
            attributeId,
            value,
            additionalInfo,
          );
        }
      }
    }

    // Cập nhật surroundingStores
    final stores = List<String>.from(
      localEnvironmentalFactors['surroundingStores'] ?? [],
    );
    final customStores = List<String>.from(
      localEnvironmentalFactors['customStores'] ?? [],
    );
    final allStores = [...stores, ...customStores];
    final storesValue = allStores.join(', ');
    final storesAttributeId = attributeIdMap['surroundingStores'];
    if (storesAttributeId != null && allStores.isNotEmpty) {
      final additionalInfo =
          localEnvironmentalFactors['surroundingStores_additionalInfo'] ?? '';
      _updateSingleAttribute(
        attributeValues,
        storesAttributeId,
        storesValue,
        additionalInfo,
      );
    }

    // Cập nhật các yếu tố bổ sung nếu siteCategoryId == 1
    if (siteCategoryId == 1) {
      for (var key in ['ventilation', 'airConditioning']) {
        final attributeId = attributeIdMap[key];
        if (attributeId != null) {
          final factorData =
              localEnvironmentalFactors[key] as Map<String, dynamic>?;
          if (factorData != null) {
            String value = '';
            String additionalInfo = factorData['additionalInfo'] ?? '';

            if (factorData['exists'] == 'không') {
              value = 'không';
            } else if (factorData['exists'] == 'có') {
              final quality = factorData['quality'];
              value = quality != null ? 'có - $quality' : 'có';
            }

            if (value.isNotEmpty) {
              _updateSingleAttribute(
                attributeValues,
                attributeId,
                value,
                additionalInfo,
              );
            }
          }
        }
      }

      // Cập nhật commonAmenities
      final commonAmenitiesData =
          localEnvironmentalFactors['commonAmenities'] as Map<String, dynamic>?;
      if (commonAmenitiesData != null) {
        final attributeId = attributeIdMap['commonAmenities'];
        if (attributeId != null) {
          String value = '';
          final additionalInfo = commonAmenitiesData['additionalInfo'] ?? '';
          if (hasCommonAmenities == 'không') {
            value = 'không';
          } else if (hasCommonAmenities == 'có' &&
              selectedAmenities.isNotEmpty) {
            value = selectedAmenities
                .map(
                  (amenity) =>
                      'Có $amenity - ${selectedAmenityStatuses[amenity] ?? ''}',
                )
                .join(', ');
          }
          debugPrint('Updating commonAmenities with value: $value');
          if (value.isNotEmpty) {
            _updateSingleAttribute(
              attributeValues,
              attributeId,
              value,
              additionalInfo,
            );
          }
        }
      }
    }

    widget.setState(() {
      widget.reportData['environmentalFactors'] = localEnvironmentalFactors;
      widget.reportData['attributeValues'] = attributeValues;
      widget.reportData['changedAttributeValues'] =
          List<Map<String, dynamic>>.from(changedAttributeValues);
      widget.reportData['newAttributeValues'] = List<Map<String, dynamic>>.from(
        newAttributeValues,
      );
    });

    _logger.info('After update - attributeValues: $attributeValues');
    _updateDebugInfo();
  }

  void _handleAmenitySelected(String amenity) {
    setState(() {
      if (selectedAmenities.contains(amenity)) {
        selectedAmenities.remove(amenity);
        selectedAmenityStatuses.remove(amenity);
      } else {
        selectedAmenities.add(amenity);
        // Khởi tạo trạng thái mặc định nếu chưa có
        if (!selectedAmenityStatuses.containsKey(amenity)) {
          selectedAmenityStatuses[amenity] =
              additionalFactorConfigs['commonAmenities']!['statuses'][0];
        }
      }
      debugPrint('Selected amenities: $selectedAmenities');
      localEnvironmentalFactors['commonAmenities']['selectedAmenities'] =
          selectedAmenities;
      localEnvironmentalFactors['commonAmenities']['selectedAmenityStatuses'] =
          selectedAmenityStatuses;
      _updateAttributeValues();
    });
  }

  void _handleAmenityStatusSelected(String amenity, String status) {
    setState(() {
      selectedAmenityStatuses[amenity] = status;
      localEnvironmentalFactors['commonAmenities']['selectedAmenityStatuses'] =
          selectedAmenityStatuses;
      _updateAttributeValues();
    });
  }

  void _handleCustomAmenityAdded(String amenity) {
    setState(() {
      if (!customAmenities.contains(amenity)) {
        customAmenities.add(amenity);
        selectedAmenities.add(amenity);
        selectedAmenityStatuses[amenity] =
            additionalFactorConfigs['commonAmenities']!['statuses'][0];
        localEnvironmentalFactors['commonAmenities']['customAmenities'] =
            customAmenities;
        localEnvironmentalFactors['commonAmenities']['selectedAmenities'] =
            selectedAmenities;
        localEnvironmentalFactors['commonAmenities']['selectedAmenityStatuses'] =
            selectedAmenityStatuses;
        _updateAttributeValues();
      }
    });
  }

  void _handleCustomAmenityRemoved(String amenity) {
    setState(() {
      customAmenities.remove(amenity);
      selectedAmenities.remove(amenity);
      selectedAmenityStatuses.remove(amenity);
      localEnvironmentalFactors['commonAmenities']['customAmenities'] =
          customAmenities;
      localEnvironmentalFactors['commonAmenities']['selectedAmenities'] =
          selectedAmenities;
      localEnvironmentalFactors['commonAmenities']['selectedAmenityStatuses'] =
          selectedAmenityStatuses;
      _updateAttributeValues();
    });
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

  String _getSubtitle(String key) {
    final value = localEnvironmentalFactors[key];
    if (value is Map &&
        value.containsKey('value') &&
        value['value'] is String &&
        (value['value'] as String).isNotEmpty) {
      return value['value'] as String;
    }
    if (key == 'surroundingStores' || key == 'customStores') {
      return _totalSelectedStores;
    }
    if (key == 'ventilation' || key == 'airConditioning') {
      if (value is Map<String, dynamic>) {
        final exists = value['exists'];
        if (exists == null) return 'Chưa chọn';
        if (exists == 'không') return 'Không';
        final quality = value['quality'];
        return quality != null ? 'Có - $quality' : 'Có';
      }
      return 'Chưa chọn';
    }
    if (key == 'commonAmenities') {
      if (hasCommonAmenities == 'không') return 'Không';
      if (hasCommonAmenities == 'có' && selectedAmenities.isNotEmpty) {
        return selectedAmenities
            .map(
              (amenity) =>
                  '$amenity - ${selectedAmenityStatuses[amenity] ?? ''}',
            )
            .join(', ');
      }
      return hasCommonAmenities == null ? 'Chưa chọn' : 'Chưa chọn tiện ích';
    }
    return 'Chưa chọn';
  }

  String _getTitle(String key) {
    if (key == 'waste') {
      return siteCategoryId == 1
          ? 'Quản lý rác thải trong tòa nhà'
          : 'Quản lý rác thải';
    }
    return factorConfigs[key]!['title'] as String;
  }

  String get _totalSelectedStores {
    final selectedPresetStores =
        (localEnvironmentalFactors['surroundingStores'] as List? ?? []).length;
    final customStores =
        (localEnvironmentalFactors['customStores'] as List? ?? []).length;
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
            style: widget.theme.textTheme.titleLarge?.copyWith(
              color: widget.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          InfoCard(
            icon: Icons.lightbulb_outline,
            content: 'Đánh giá các yếu tố môi trường xung quanh mặt bằng.',
            backgroundColor: widget.theme.colorScheme.tertiaryFixed,
            iconColor: widget.theme.colorScheme.secondary,
            borderRadius: 20.0,
            padding: const EdgeInsets.all(20.0),
          ),
          const SizedBox(height: 12),
          ...factorConfigs.keys.map(
            (key) => AnimatedExpansionCard(
              icon: factorConfigs[key]!['icon'] as IconData,
              title: _getTitle(key),
              subtitle: _getSubtitle(key),
              theme: widget.theme,
              showInfo: true,
              useBulletPoints: true,
              infoTitle: factorConfigs[key]!['infoTitle'] as String,
              bulletPoints:
                  (factorConfigs[key]!['bulletPoints'] as List)
                      .map<String>((item) => item.toString())
                      .toList(),
              children: [
                Column(
                  children:
                      (factorConfigs[key]!['options']
                              as List<Map<String, dynamic>>)
                          .map(
                            (option) => SelectableOptionButton(
                              value: option['label'] as String,
                              icon: option['icon'] as IconData,
                              isSelected:
                                  localEnvironmentalFactors[key]['value'] ==
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
                const SizedBox(height: 8),
                CustomInputField(
                  label: 'Thông tin bổ sung',
                  hintText: 'Nhập thông tin bổ sung',
                  icon: Icons.info,
                  onSaved: (value) {
                    localEnvironmentalFactors[key]['additionalInfo'] = value;
                    _updateAttributeValues();
                  },
                  theme: widget.theme,
                  isDescription: true,
                  initialValue:
                      localEnvironmentalFactors[key]['additionalInfo'] ?? '',
                ),
              ],
            ),
          ),
          AnimatedExpansionCard(
            icon: Icons.store,
            title:
                siteCategoryId == 1
                    ? 'Cửa hàng xung quanh tòa nhà'
                    : 'Cửa hàng xung quanh',
            subtitle: _totalSelectedStores,
            theme: widget.theme,
            showInfo: true,
            description:
                'Đánh giá các cửa hàng hoặc cơ sở xung quanh mặt bằng, như siêu thị, nhà hàng, trường học, v.v.',
            children: [
              CustomChipGroup(
                options: surroundingStoresIcons.keys.toList(),
                selectedOptions: List.from(
                  localEnvironmentalFactors['surroundingStores'] ?? [],
                ),
                customOptions: List.from(
                  localEnvironmentalFactors['customStores'] ?? [],
                ),
                optionIcons: surroundingStoresIcons,
                onOptionSelected: _handleStoreSelection,
                onCustomOptionAdded: _handleCustomStoreAdded,
                onCustomOptionRemoved: _handleCustomStoreRemoved,
              ),
              const SizedBox(height: 8),
              CustomInputField(
                label: 'Thông tin bổ sung',
                hintText: 'Nhập thông tin bổ sung',
                icon: Icons.info,
                onSaved: (value) {
                  localEnvironmentalFactors['surroundingStores_additionalInfo'] =
                      value;
                  _updateAttributeValues();
                },
                theme: widget.theme,
                isDescription: true,
                initialValue:
                    localEnvironmentalFactors['surroundingStores_additionalInfo'] ??
                    '',
              ),
            ],
          ),
          if (siteCategoryId == 1) ...[
            AnimatedExpansionCard(
              icon: additionalFactorConfigs['ventilation']!['icon'] as IconData,
              title: additionalFactorConfigs['ventilation']!['title'] as String,
              subtitle: _getSubtitle('ventilation'),
              theme: widget.theme,
              showInfo: true,
              useBulletPoints: true,
              infoTitle:
                  additionalFactorConfigs['ventilation']!['infoTitle']
                      as String,
              bulletPoints:
                  (additionalFactorConfigs['ventilation']!['bulletPoints']
                          as List)
                      .map<String>((item) => item.toString())
                      .toList(),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Có hệ thống thông gió?',
                          style: widget.theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 16),
                        Radio<String>(
                          value: 'có',
                          groupValue:
                              localEnvironmentalFactors['ventilation']['exists'],
                          onChanged: (value) {
                            setState(() {
                              localEnvironmentalFactors['ventilation']['exists'] =
                                  value;
                            });
                            _updateAttributeValues();
                          },
                        ),
                        const Text('Có'),
                        const SizedBox(width: 16),
                        Radio<String>(
                          value: 'không',
                          groupValue:
                              localEnvironmentalFactors['ventilation']['exists'],
                          onChanged: (value) {
                            setState(() {
                              localEnvironmentalFactors['ventilation']['exists'] =
                                  value;
                            });
                            _updateAttributeValues();
                          },
                        ),
                        const Text('Không'),
                      ],
                    ),
                    if (localEnvironmentalFactors['ventilation']['exists'] ==
                        'có') ...[
                      const SizedBox(height: 8),
                      Text(
                        'Chất lượng:',
                        style: widget.theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children:
                              (additionalFactorConfigs['ventilation']!['options']
                                      as List<Map<String, dynamic>>)
                                  .map(
                                    (option) => Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: SelectableOptionButton(
                                        value: option['label'] as String,
                                        icon: option['icon'] as IconData,
                                        isSelected:
                                            localEnvironmentalFactors['ventilation']['quality'] ==
                                            option['label'],
                                        onTap: () {
                                          setState(() {
                                            localEnvironmentalFactors['ventilation']['quality'] =
                                                option['label'];
                                          });
                                          _updateAttributeValues();
                                        },
                                        theme: widget.theme,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomInputField(
                        label: 'Thông tin bổ sung',
                        hintText:
                            'Ví dụ: Có hệ thống thông gió trong góc của phòng',
                        icon: Icons.info,
                        onSaved: (value) {
                          localEnvironmentalFactors['ventilation']['additionalInfo'] =
                              value;
                          _updateAttributeValues();
                        },
                        theme: widget.theme,
                        isDescription: true,
                        initialValue:
                            localEnvironmentalFactors['ventilation']['additionalInfo'] ??
                            '',
                      ),
                    ],
                  ],
                ),
              ],
            ),
            AnimatedExpansionCard(
              icon:
                  additionalFactorConfigs['airConditioning']!['icon']
                      as IconData,
              title:
                  additionalFactorConfigs['airConditioning']!['title']
                      as String,
              subtitle: _getSubtitle('airConditioning'),
              theme: widget.theme,
              showInfo: true,
              useBulletPoints: true,
              infoTitle:
                  additionalFactorConfigs['airConditioning']!['infoTitle']
                      as String,
              bulletPoints:
                  (additionalFactorConfigs['airConditioning']!['bulletPoints']
                          as List)
                      .map<String>((item) => item.toString())
                      .toList(),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Có hệ thống điều hòa?',
                          style: widget.theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 16),
                        Radio<String>(
                          value: 'có',
                          groupValue:
                              localEnvironmentalFactors['airConditioning']['exists'],
                          onChanged: (value) {
                            setState(() {
                              localEnvironmentalFactors['airConditioning']['exists'] =
                                  value;
                            });
                            _updateAttributeValues();
                          },
                        ),
                        const Text('Có'),
                        const SizedBox(width: 16),
                        Radio<String>(
                          value: 'không',
                          groupValue:
                              localEnvironmentalFactors['airConditioning']['exists'],
                          onChanged: (value) {
                            setState(() {
                              localEnvironmentalFactors['airConditioning']['exists'] =
                                  value;
                            });
                            _updateAttributeValues();
                          },
                        ),
                        const Text('Không'),
                      ],
                    ),
                    if (localEnvironmentalFactors['airConditioning']['exists'] ==
                        'có') ...[
                      const SizedBox(height: 8),
                      Text(
                        'Chất lượng:',
                        style: widget.theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children:
                              (additionalFactorConfigs['airConditioning']!['options']
                                      as List<Map<String, dynamic>>)
                                  .map(
                                    (option) => Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: SelectableOptionButton(
                                        value: option['label'] as String,
                                        icon: option['icon'] as IconData,
                                        isSelected:
                                            localEnvironmentalFactors['airConditioning']['quality'] ==
                                            option['label'],
                                        onTap: () {
                                          setState(() {
                                            localEnvironmentalFactors['airConditioning']['quality'] =
                                                option['label'];
                                          });
                                          _updateAttributeValues();
                                        },
                                        theme: widget.theme,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomInputField(
                        label: 'Thông tin bổ sung',
                        hintText:
                            'Ví dụ: Có hệ thống điều hòa được cấp sẵn bởi tòa nhà',
                        icon: Icons.info,
                        onSaved: (value) {
                          localEnvironmentalFactors['airConditioning']['additionalInfo'] =
                              value;
                          _updateAttributeValues();
                        },
                        theme: widget.theme,
                        isDescription: true,
                        initialValue:
                            localEnvironmentalFactors['airConditioning']['additionalInfo'] ??
                            '',
                      ),
                    ],
                  ],
                ),
              ],
            ),
            AnimatedExpansionCard(
              icon:
                  additionalFactorConfigs['commonAmenities']!['icon']
                      as IconData,
              title:
                  additionalFactorConfigs['commonAmenities']!['title']
                      as String,
              subtitle: _getSubtitle('commonAmenities'),
              theme: widget.theme,
              showInfo: true,
              useBulletPoints: true,
              infoTitle:
                  additionalFactorConfigs['commonAmenities']!['infoTitle']
                      as String,
              bulletPoints:
                  (additionalFactorConfigs['commonAmenities']!['bulletPoints']
                          as List)
                      .map<String>((item) => item.toString())
                      .toList(),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Có tiện ích trong tòa nhà không?',
                          style: widget.theme.textTheme.bodyMedium,
                        ),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'có',
                              groupValue: hasCommonAmenities,
                              onChanged: (value) {
                                setState(() {
                                  hasCommonAmenities = value;
                                  if (value == 'không') {
                                    selectedAmenities.clear();
                                    selectedAmenityStatuses.clear();
                                    customAmenities.clear();
                                  }
                                  localEnvironmentalFactors['commonAmenities']['hasCommonAmenities'] =
                                      value;
                                  _updateAttributeValues();
                                });
                              },
                            ),
                            const Text('Có'),
                            const SizedBox(width: 16),
                            Radio<String>(
                              value: 'không',
                              groupValue: hasCommonAmenities,
                              onChanged: (value) {
                                setState(() {
                                  hasCommonAmenities = value;
                                  if (value == 'không') {
                                    selectedAmenities.clear();
                                    selectedAmenityStatuses.clear();
                                    customAmenities.clear();
                                  }
                                  localEnvironmentalFactors['commonAmenities']['hasCommonAmenities'] =
                                      value;
                                  _updateAttributeValues();
                                });
                              },
                            ),
                            const Text('Không'),
                          ],
                        ),
                      ],
                    ),
                    if (hasCommonAmenities == 'có') ...[
                      const SizedBox(height: 16),
                      Text(
                        'Loại tiện ích:',
                        style: widget.theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      CustomChipGroup(
                        options:
                            additionalFactorConfigs['commonAmenities']!['amenities']
                                as List<String>,
                        selectedOptions: selectedAmenities,
                        customOptions: customAmenities,
                        optionIcons: amenityIcons,
                        onOptionSelected: _handleAmenitySelected,
                        onCustomOptionAdded: _handleCustomAmenityAdded,
                        onCustomOptionRemoved: _handleCustomAmenityRemoved,
                        showOtherInputOnlyWhenSelected: true,
                        otherOptionKey: 'Khác',
                      ),
                      ...selectedAmenities.map((amenity) {
                        final statusOptions =
                            additionalFactorConfigs['commonAmenities']!['statuses']
                                as List<String>;
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
                                        amenityIcons[amenity] ??
                                            Icons.help_outline,
                                        color: widget.theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Trạng thái cho: $amenity',
                                        style: widget
                                            .theme
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  CustomChipGroup(
                                    options: statusOptions,
                                    selectedOptions:
                                        selectedAmenityStatuses[amenity] != null
                                            ? [
                                              selectedAmenityStatuses[amenity]!,
                                            ]
                                            : [],
                                    customOptions: [],
                                    optionIcons: statusIcons,
                                    onOptionSelected:
                                        (status) =>
                                            _handleAmenityStatusSelected(
                                              amenity,
                                              status,
                                            ),
                                    onCustomOptionAdded: (_) {},
                                    onCustomOptionRemoved: (_) {},
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
                        hintText: 'Nhập thông tin bổ sung',
                        icon: Icons.info,
                        onSaved: (value) {
                          localEnvironmentalFactors['commonAmenities']['additionalInfo'] =
                              value;
                          _updateAttributeValues();
                        },
                        theme: widget.theme,
                        isDescription: true,
                        initialValue:
                            localEnvironmentalFactors['commonAmenities']['additionalInfo'] ??
                            '',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
