// site_info_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:siteplus_mb/components/custom_input_field.dart';

class SiteInfoSection extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController sizeController;
  final TextEditingController floorNumberController;
  final String siteCategory;
  final int? siteCategoryId;
  final Function(String?) onSiteNameSaved;
  final Function(String?) onAddressSaved;
  final Function(String?) onSizeSaved;
  final Function(String?) onFloorSaved;

  const SiteInfoSection({
    Key? key,
    required this.addressController,
    required this.sizeController,
    required this.floorNumberController,
    required this.siteCategory,
    required this.siteCategoryId,
    required this.onSiteNameSaved,
    required this.onAddressSaved,
    required this.onSizeSaved,
    required this.onFloorSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Loại mặt bằng (read-only)
        _buildReadOnlyField(
          context: context,
          label: 'Loại mặt bằng',
          value: siteCategory,
          icon: Icons.category,
        ),
        const SizedBox(height: 16),

        // Địa chỉ (cho phép nhập chữ)
        CustomInputField(
          label: 'Địa chỉ',
          hintText: 'Ví dụ: phường 14/200 đường D3...',
          icon: Icons.location_on,
          onSaved: onAddressSaved,
          theme: theme,
          initialValue: addressController.text,
        ),
        const SizedBox(height: 16),

        // Diện tích (Size) - chỉ nhận số
        CustomInputField(
          label: 'Diện tích',
          hintText: 'Ví dụ: 200m2',
          icon: Icons.square_foot,
          onSaved: onSizeSaved,
          suffixText: "m2",
          theme: theme,
          initialValue: sizeController.text,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16),
        CustomInputField(
          label: 'Tầng',
          hintText:
              siteCategoryId == 1
                  ? 'Ví dụ: tầng 2'
                  : 'Ví dụ: tổng cộng có 2 tầng',
          icon: Icons.stairs,
          onSaved: onFloorSaved,
          theme: theme,
          initialValue: floorNumberController.text,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      ),
    );
  }
}
