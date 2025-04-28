// location_section.dart
import 'package:flutter/material.dart';
import 'package:siteplus_mb/components/custom_input_field.dart';
import 'package:siteplus_mb/utils/AreaDistrict/locations_provider.dart';

class LocationSection extends StatelessWidget {
  final List<District> districts;
  final List<Area> areas;
  final String? selectedDistrictName;
  final String? selectedAreaName;
  final bool isLoadingAreas;
  final Function(String?) onDistrictChanged;
  final Function(String?) onAreaChanged;
  final bool isAreaSelectionEnabled;
  final TextEditingController addressController; // Added controller for address
  final Function(String?) onAddressSaved; // Added callback for address
  final bool isProposeMode;

  const LocationSection({
    super.key,
    required this.districts,
    required this.areas,
    required this.selectedDistrictName,
    required this.selectedAreaName,
    required this.isLoadingAreas,
    required this.onDistrictChanged,
    required this.onAreaChanged,
    required this.isAreaSelectionEnabled,
    required this.addressController,
    required this.onAddressSaved,
    this.isProposeMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Address - translated from site_info_section
        CustomInputField(
          label: 'Address',
          hintText: 'e.g.: District 14/200 D3 Street...',
          icon: Icons.location_on,
          onSaved: onAddressSaved,
          theme: theme,
          initialValue: addressController.text,
        ),
        SizedBox(height: 23),
        // District Dropdown
        _buildStyledDropdown(
          context: context,
          label: 'District',
          icon: Icons.location_city,
          value: selectedDistrictName,
          items: districts.map((district) => district.name).toList(),
          onChanged: onDistrictChanged,
          isEnabled: isProposeMode,
        ),
        SizedBox(height: 23),

        // Area Dropdown
        _buildStyledDropdown(
          context: context,
          label: 'Ward',
          icon: Icons.map,
          value: selectedAreaName,
          items: areas.map((area) => area.name).toList(),
          onChanged: onAreaChanged,
          isLoading: isLoadingAreas,
          isEnabled: isProposeMode && isAreaSelectionEnabled,
        ),
      ],
    );
  }

  Widget _buildStyledDropdown({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isLoading = false,
    bool isEnabled = true,
  }) {
    final theme = Theme.of(context);

    return AnimatedOpacity(
      opacity: isLoading ? 0.6 : 1.0,
      duration: Duration(milliseconds: 300),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              isLoading
                  ? []
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
        ),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: theme.colorScheme.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
            suffixIcon:
                isLoading
                    ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary.withOpacity(0.5),
                          ),
                        ),
                      ),
                    )
                    : null,
            enabled: isEnabled && !isLoading,
          ),
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
          onChanged: isEnabled && !isLoading ? onChanged : null,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select $label';
            }
            return null;
          },
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
          menuMaxHeight: 200,
          dropdownColor: theme.colorScheme.surface,
        ),
      ),
    );
  }
}
