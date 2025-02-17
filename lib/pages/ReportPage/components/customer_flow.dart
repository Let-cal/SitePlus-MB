import 'package:flutter/material.dart';
import 'package:siteplus_mb/utils/ReportPage/custom_input_field.dart';
import 'package:siteplus_mb/utils/ReportPage/rating_selection.dart';

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
  List<String> selectedVehicles = [];
  List<String> selectedPeakHours = [];

  final Map<String, IconData> vehicleIcons = {
    'Motorcycle': Icons.motorcycle,
    'Car': Icons.directions_car,
    'Bicycle': Icons.pedal_bike,
    'Pedestrian': Icons.directions_walk,
  };

  final Map<String, IconData> peakHourIcons = {
    'Morning (07:00 - 10:00)': Icons.wb_sunny,
    'Noon (11:00 - 14:00)': Icons.lunch_dining,
    'Afternoon (15:00 - 18:00)': Icons.cloud,
    'Evening (19:00 - 22:00)': Icons.nights_stay,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'I. Customer Flow',
            style: widget.theme.textTheme.headlineLarge?.copyWith(
              color: widget.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // SECTION: Chọn phương tiện
          Text('Select Transportation Methods:', style: widget.theme.textTheme.titleMedium),
          Column(
            children: vehicleIcons.keys.map((vehicle) {
              return CheckboxListTile(
                title: Text(vehicle),
                secondary: Icon(vehicleIcons[vehicle], color: widget.theme.colorScheme.primary),
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
              onSaved: (value) => widget.reportData['customerFlow']['vehicles'][vehicle.toLowerCase()] = int.parse(value),
            );
          }),

          const SizedBox(height: 16),

          // SECTION: Chọn giờ cao điểm
          Text('Select Peak Hours:', style: widget.theme.textTheme.titleMedium),
          Column(
            children: peakHourIcons.keys.map((hour) {
              return CheckboxListTile(
                title: Text(hour),
                secondary: Icon(peakHourIcons[hour], color: widget.theme.colorScheme.primary),
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
              onSaved: (value) => widget.reportData['customerFlow']['peakHours'][hour.toLowerCase()] = int.parse(value),
            );
          }),

          const SizedBox(height: 16),

          // Đánh giá tổng thể
          RatingSelection(
            selectedRating: widget.reportData['customerFlow']['overallRating'] ?? '',
            onChanged: (value) => widget.setState(() => widget.reportData['customerFlow']['overallRating'] = value),
            theme: widget.theme,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
