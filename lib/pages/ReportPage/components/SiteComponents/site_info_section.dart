// site_info_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:siteplus_mb/components/custom_input_field.dart';
import 'package:siteplus_mb/components/read_only_field.dart'; // Import new component

class SiteInfoSection extends StatelessWidget {
  final TextEditingController sizeController;
  final TextEditingController floorNumberController;
  final String siteCategory;
  final int? siteCategoryId;
  final Function(String?) onSiteNameSaved;
  final Function(String?) onSizeSaved;
  final Function(String?) onFloorSaved;

  const SiteInfoSection({
    super.key,
    required this.sizeController,
    required this.floorNumberController,
    required this.siteCategory,
    required this.siteCategoryId,
    required this.onSiteNameSaved,
    required this.onSizeSaved,
    required this.onFloorSaved,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Site Type (read-only)
        ReadOnlyField(
          label: 'Site Type',
          value: siteCategory,
          icon: Icons.category,
        ),
        const SizedBox(height: 16),

        // Size (numeric input only)
        CustomInputField(
          label: 'Size',
          hintText: 'e.g.: 200m2',
          icon: Icons.square_foot,
          onSaved: onSizeSaved,
          suffixText: "m2",
          theme: theme,
          initialValue: sizeController.text,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16),

        // Floor input
        CustomInputField(
          label: siteCategoryId == 1 ? 'Floor' : 'Total Floors',
          hintText:
              siteCategoryId == 1
                  ? 'e.g.: Floor 2'
                  : 'Suggestion: Total 2 floors',
          icon: Icons.stairs,
          onSaved: onFloorSaved,
          theme: theme,
          initialValue: floorNumberController.text,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
