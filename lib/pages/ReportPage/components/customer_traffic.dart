import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:siteplus_mb/utils/ReportPage/animated_expansion_card.dart';
import 'package:siteplus_mb/utils/ReportPage/custom_input_field.dart';
import 'package:siteplus_mb/utils/ReportPage/info_card.dart';
import 'package:siteplus_mb/utils/ReportPage/rating_buttons.dart';
import 'package:siteplus_mb/utils/constants.dart';

class CustomerFlowSection extends StatefulWidget {
  final Map<String, dynamic> reportData;
  final Function(void Function()) setState;
  final ThemeData theme;

  const CustomerFlowSection({
    Key? key,
    required this.reportData,
    required this.setState,
    required this.theme,
  }) : super(key: key);

  @override
  _CustomerFlowSectionState createState() => _CustomerFlowSectionState();
}

class _CustomerFlowSectionState extends State<CustomerFlowSection> {
  late Map<String, dynamic> localCustomerFlow;
  final Logger _logger = Logger('CustomerFlow');
  List<String> selectedVehicles = [];
  List<String> selectedPeakHours = [];
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    localCustomerFlow = Map<String, dynamic>.from(
      widget.reportData['customerFlow'] ?? {},
    );

    final defaultValues = {
      'vehicles': <String>[],
      'vehicleCounts': <String, int>{},
      'peakHours': <String>[],
      'peakHourCounts': <String, int>{},
      'overallRating': '',
    };

    defaultValues.forEach((key, value) {
      localCustomerFlow.putIfAbsent(key, () => value);
    });

    _logger.info("Initial customerFlow: $localCustomerFlow");
  }

  final Map<String, IconData> vehicleIcons = {
    TRANSPORTATION_MOTORCYCLE: Icons.motorcycle,
    TRANSPORTATION_CAR: Icons.directions_car,
    TRANSPORTATION_BICYCLE: Icons.pedal_bike,
    TRANSPORTATION_PEDESTRIAN: Icons.directions_walk,
  };

  final Map<String, IconData> peakHourIcons = {
    PEAK_HOUR_MORNING: Icons.wb_sunny,
    PEAK_HOUR_NOON: Icons.lunch_dining,
    PEAK_HOUR_AFTERNOON: Icons.cloud,
    PEAK_HOUR_EVENING: Icons.nights_stay,
  };
  void _handleFactorSelection(String key, String value) {
    setState(() {
      localCustomerFlow[key] = value;
      widget.setState(() {
        widget.reportData['customerFlow'] = Map<String, dynamic>.from(
          localCustomerFlow,
        );
      });
      _logger.info("Updated $key: $value");
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
            'I. Lưu Lượng Khách Hàng',
            style: widget.theme.textTheme.headlineLarge?.copyWith(
              color: widget.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          InfoCard(
            icon: Icons.lightbulb_outline,
            content:
                'Ghi lại phương tiện di chuyển chính và giờ cao điểm của khách hàng.',
            backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
            iconColor: Theme.of(context).colorScheme.secondary,
            borderRadius: 20.0,
            padding: EdgeInsets.all(20.0),
          ),
          SizedBox(height: 12.0),
          // SECTION: Chọn phương tiện
          Text(
            'Chọn Phương Tiện Di Chuyển:',
            style: widget.theme.textTheme.titleMedium,
          ),
          Column(
            children:
                vehicleIcons.keys.map((vehicle) {
                  return CheckboxListTile(
                    title: Text(vehicle),
                    secondary: Icon(
                      vehicleIcons[vehicle],
                      color: widget.theme.colorScheme.primary,
                    ),
                    value: selectedVehicles.contains(vehicle),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedVehicles.add(vehicle);
                        } else {
                          selectedVehicles.remove(vehicle);
                        }
                      });
                    },
                  );
                }).toList(),
          ),

          // Hiển thị input cho phương tiện đã chọn
          ...selectedVehicles.map((vehicle) {
            return CustomInputField(
              label: vehicle,
              icon: vehicleIcons[vehicle]!,
              theme: widget.theme,
              onSaved:
                  (value) =>
                      widget.reportData['customerFlow']['vehicles'][vehicle
                          .toLowerCase()] = int.parse(value),
            );
          }),

          const SizedBox(height: 16),

          // SECTION: Chọn giờ cao điểm
          Text('Chọn Giờ Cao Điểm:', style: widget.theme.textTheme.titleMedium),
          Column(
            children:
                peakHourIcons.keys.map((hour) {
                  return CheckboxListTile(
                    title: Text(hour),
                    secondary: Icon(
                      peakHourIcons[hour],
                      color: widget.theme.colorScheme.primary,
                    ),
                    value: selectedPeakHours.contains(hour),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedPeakHours.add(hour);
                        } else {
                          selectedPeakHours.remove(hour);
                        }
                      });
                    },
                  );
                }).toList(),
          ),

          // Hiển thị input cho giờ cao điểm đã chọn
          ...selectedPeakHours.map((hour) {
            return CustomInputField(
              label: hour,
              icon: peakHourIcons[hour]!,
              theme: widget.theme,
              onSaved:
                  (value) =>
                      widget.reportData['customerFlow']['peakHours'][hour
                          .toLowerCase()] = int.parse(value),
            );
          }),

          const SizedBox(height: 16),

          // Đánh giá tổng thể
          AnimatedExpansionCard(
            icon: Icons.star_outline,
            title: 'Đánh Giá Tổng Quát',
            subtitle: localCustomerFlow['overallRating'] ?? 'Chưa đánh giá',
            theme: widget.theme,
            children: [
              RatingButtons(
                currentRating: localCustomerFlow['overallRating'] ?? '',
                onRatingSelected:
                    (rating) => _handleFactorSelection('overallRating', rating),
                theme: widget.theme,
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
