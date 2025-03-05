import 'package:flutter/material.dart';
import 'package:siteplus_mb/utils/ReportPage/animated_expansion_card.dart';
import 'package:siteplus_mb/utils/ReportPage/custom_chip_group.dart';
import 'package:siteplus_mb/utils/ReportPage/custom_input_field.dart';
import 'package:siteplus_mb/utils/ReportPage/info_card.dart';
import 'package:siteplus_mb/utils/ReportPage/rating_buttons.dart';
import 'package:siteplus_mb/utils/ReportPage/selectable_option_button.dart';

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

  final Map<String, IconData> shapeIcons = {
    'Hình vuông': Icons.square, // Hình vuông chuẩn
    'Dài hẹp': Icons.rectangle, // Hình chữ nhật tiêu chuẩn
    'Hình chữ L': Icons.signpost, // Biểu tượng có hình dạng giống chữ “L”
    'Khác': Icons.extension, // Biểu tượng linh hoạt cho hình dạng khác
  };

  final Map<String, IconData> conditionIcons = {
    'Hoàn thành': Icons.check_circle,
    'Đang thi công': Icons.construction,
    'Cần sửa chữa nhỏ': Icons.handyman,
    'Cần sửa chữa lớn': Icons.warning,
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    localSiteData = Map<String, dynamic>.from(
      widget.reportData['siteArea'] ?? {},
    );
    // Cập nhật conditionIcons trong nội bộ (nếu cần)
    final Map<String, IconData> conditionIcons = {
      'Hoàn thành': Icons.check_circle, // Hoàn thành
      'Đang thi công': Icons.construction, // Đang thi công
      'Cần sửa chữa nhỏ': Icons.handyman, // Cần sửa chữa nhỏ
      'Cần sửa chữa lớn': Icons.warning, // Cần sửa chữa lớn
    };

    final defaultValues = {
      'totalArea': '',
      'shapes': <String>[],
      'customShapes': <String>[],
      'condition': '',
      'overallRating': '',
    };

    defaultValues.forEach((key, value) {
      localSiteData.putIfAbsent(key, () => value);
    });
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
      widget.setState(() {
        widget.reportData['siteArea'] = Map<String, dynamic>.from(
          localSiteData,
        );
      });
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

        widget.setState(() {
          widget.reportData['siteArea'] = Map<String, dynamic>.from(
            localSiteData,
          );
        });
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

      widget.setState(() {
        widget.reportData['siteArea'] = Map<String, dynamic>.from(
          localSiteData,
        );
      });
    });
  }

  void _handleConditionSelection(String condition) {
    setState(() {
      localSiteData['condition'] = condition;
      widget.setState(() {
        widget.reportData['siteArea'] = Map<String, dynamic>.from(
          localSiteData,
        );
      });
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

  void _handleRatingSelection(String rating) {
    setState(() {
      localSiteData['overallRating'] = rating;
      widget.setState(() {
        widget.reportData['siteArea'] = Map<String, dynamic>.from(
          localSiteData,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IV. Mặt Bằng',
            style: widget.theme.textTheme.headlineLarge?.copyWith(
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
                localSiteData['totalArea']?.toString().isNotEmpty == true
                    ? '${localSiteData['totalArea']} m²'
                    : 'Chưa chỉ định',
            theme: widget.theme,
            children: [
              CustomInputField(
                label: 'Diện tích tổng (m²)',
                icon: Icons.edit,
                theme: widget.theme,
                initialValue: localSiteData['totalArea'].toString(),
                onSaved: (value) {
                  setState(() {
                    localSiteData['totalArea'] = value;
                    widget.setState(() {
                      widget.reportData['siteArea'] = Map<String, dynamic>.from(
                        localSiteData,
                      );
                    });
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
            subtitle: localSiteData['condition'] ?? 'Chưa chọn',
            theme: widget.theme,
            children: [
              Column(
                children:
                    [
                      'Hoàn thành',
                      'Đang thi công',
                      'Cần sửa chữa nhỏ',
                      'Cần sửa chữa lớn',
                    ].map((String value) {
                      return SelectableOptionButton(
                        value: value,
                        icon: conditionIcons[value] ?? Icons.help_outline,
                        isSelected: localSiteData['condition'] == value,
                        onTap: () {
                          setState(() {
                            localSiteData['condition'] = value;
                            widget.setState(() {
                              widget.reportData['siteArea'] =
                                  Map<String, dynamic>.from(localSiteData);
                            });
                          });
                        },
                        theme: widget.theme,
                      );
                    }).toList(),
              ),
            ],
          ),

          // Đánh giá tổng quan
          AnimatedExpansionCard(
            icon: Icons.star_outline,
            title: 'Đánh giá tổng quan',
            subtitle: localSiteData['overallRating'] ?? 'Chưa đánh giá',
            theme: widget.theme,
            children: [
              RatingButtons(
                currentRating: localSiteData['overallRating'] ?? '',
                onRatingSelected: _handleRatingSelection,
                theme: widget.theme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
