// site_info_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:siteplus_mb/utils/ReportPage/custom_input_field.dart';

class SiteInfoSection extends StatelessWidget {
  final TextEditingController siteNameController;
  final TextEditingController addressController;
  final TextEditingController sizeController;
  final String siteCategory;
  final Function(String?) onSiteNameSaved;
  final Function(String?) onAddressSaved;
  final Function(String?) onSizeSaved;

  const SiteInfoSection({
    Key? key,
    required this.siteNameController,
    required this.addressController,
    required this.sizeController,
    required this.siteCategory,
    required this.onSiteNameSaved,
    required this.onAddressSaved,
    required this.onSizeSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Tên mặt bằng (cho phép nhập chữ)
        CustomInputField(
          label: 'Tên mặt bằng',
          icon: Icons.store,
          onSaved: onSiteNameSaved,
          theme: theme,
          initialValue: siteNameController.text,
        ),
        const SizedBox(height: 16),

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
          icon: Icons.location_on,
          onSaved: onAddressSaved,
          theme: theme,
          initialValue: addressController.text,
        ),
        const SizedBox(height: 16),

        // Diện tích (Size) - chỉ nhận số
        CustomInputField(
          label: 'Diện tích',
          icon: Icons.square_foot,
          onSaved: onSizeSaved,
          theme: theme,
          initialValue: sizeController.text,
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
