// location_section.dart
import 'package:flutter/material.dart';
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

  const LocationSection({
    Key? key,
    required this.districts,
    required this.areas,
    required this.selectedDistrictName,
    required this.selectedAreaName,
    required this.isLoadingAreas,
    required this.onDistrictChanged,
    required this.onAreaChanged,
    required this.isAreaSelectionEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // District Dropdown
        _buildStyledDropdown(
          context: context,
          label: 'Quận/Huyện',
          icon: Icons.location_city,
          value: selectedDistrictName,
          items: districts.map((district) => district.name).toList(),
          onChanged: onDistrictChanged,
        ),
        
        SizedBox(height: 23),
        
        // Area Dropdown
        _buildStyledDropdown(
          context: context,
          label: 'Phường/Xã',
          icon: Icons.map,
          value: selectedAreaName,
          items: areas.map((area) => area.name).toList(),
          onChanged: onAreaChanged,
          isLoading: isLoadingAreas,
          isEnabled: isAreaSelectionEnabled,
        ),
        
        SizedBox(height: 23),
        
        // Status (read-only)
        _buildReadOnlyField(
          context: context,
          label: 'Trạng thái',
          value: 'Available',
          icon: Icons.check_circle,
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
          boxShadow: isLoading
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
            suffixIcon: isLoading
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
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: isEnabled && !isLoading ? onChanged : null,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng chọn $label';
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