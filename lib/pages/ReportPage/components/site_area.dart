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
    Key? key,
    required this.reportData,
    required this.setState,
    required this.theme,
  }) : super(key: key);

  @override
  SiteAreaSectionState createState() => SiteAreaSectionState();
}

class SiteAreaSectionState extends State<SiteAreaSection> {
  late Map<String, dynamic> localSiteData;
  final Map<String, IconData> shapeIcons = {
    'Square': Icons.square, // Hình vuông chuẩn
    'Long and narrow': Icons.rectangle, // Hình chữ nhật tiêu chuẩn
    'L-shaped': Icons.signpost, // Biểu tượng có hình dạng giống chữ 'L'
    'Other': Icons.extension, // Biểu tượng linh hoạt cho hình dạng khác
  };

  final Map<String, IconData> conditionIcons = {
    'Finished': Icons.check_circle,
    'Under construction': Icons.construction,
    'Needs minor repairs': Icons.build,
    'Needs major repairs': Icons.warning,
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
    final Map<String, IconData> conditionIcons = {
      'Finished': Icons.check_circle, // Hoàn thành
      'Under construction': Icons.construction, // Đang thi công
      'Needs minor repairs': Icons.handyman, // Cần sửa chữa nhỏ
      'Needs major repairs': Icons.warning, // Cần sửa chữa lớn
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
        shapes = [shape]; // Only allow one selection
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

    if (total == 0) return 'Not selected';
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
            'IV. Site Area',
            style: widget.theme.textTheme.headlineLarge?.copyWith(
              color: widget.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          InfoCard(
            icon: Icons.lightbulb_outline,
            content: 'Provide size, shape, and condition of the site.',
            backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
            iconColor: Theme.of(context).colorScheme.secondary,
            borderRadius: 20.0,
            padding: EdgeInsets.all(20.0),
          ),
          const SizedBox(height: 12),

          // Total Area
          AnimatedExpansionCard(
            icon: Icons.area_chart,
            title: 'Total Area',
            subtitle:
                localSiteData['totalArea']?.toString().isNotEmpty == true
                    ? '${localSiteData['totalArea']} m²'
                    : 'Not specified',
            theme: widget.theme,
            children: [
              CustomInputField(
                label: 'Total area (m²)',
                icon: Icons.edit,
                theme: widget.theme,
                initialValue: localSiteData['totalArea'].toString(), // Add this
                onSaved: (value) {
                  setState(() {
                    localSiteData['totalArea'] =
                        value; // Remove int.parse to handle empty string
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

          // Site Shape
          AnimatedExpansionCard(
            icon: Icons.crop_square,
            title: 'Site Shape',
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
                showOtherInputOnlyWhenSelected: true, // Enable new behavior
                otherOptionKey: 'Other', // Specify which option is "Other"
              ),
            ],
          ),

          // Site Condition
          AnimatedExpansionCard(
            icon: Icons.construction,
            title: 'Site Condition',
            subtitle: localSiteData['condition'] ?? 'Not selected',
            theme: widget.theme,
            children: [
              Column(
                children:
                    [
                      'Finished',
                      'Under construction',
                      'Needs minor repairs',
                      'Needs major repairs',
                    ].map((String value) {
                      return SelectableOptionButton(
                        value: value,
                        icon:
                            conditionIcons[value] ??
                            Icons.help_outline, // Sử dụng icon phù hợp
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

          // Overall Rating
          AnimatedExpansionCard(
            icon: Icons.star_outline,
            title: 'Overall Rating',
            subtitle: localSiteData['overallRating'] ?? 'Not rated',
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
