import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SiteBuildingSection extends StatefulWidget {
  final Map<String, dynamic> reportData;
  final Function setState;
  final ThemeData theme;

  const SiteBuildingSection({
    super.key,
    required this.reportData,
    required this.setState,
    required this.theme,
  });

  @override
  State<SiteBuildingSection> createState() => _SiteBuildingState();
}

class _SiteBuildingState extends State<SiteBuildingSection> {
  late TextEditingController _siteNameController;
  late TextEditingController _addressController;
  late TextEditingController _buildingNameController;
  late TextEditingController _floorNumberController;

  // Assume these lists would be populated from API or elsewhere
  final List<String> _cities = [
    'Hà Nội',
    'TP.HCM',
    'Đà Nẵng',
    'Cần Thơ',
    'Hải Phòng',
  ];
  final Map<String, List<String>> _districts = {
    'Hà Nội': ['Ba Đình', 'Hoàn Kiếm', 'Hai Bà Trưng', 'Đống Đa', 'Cầu Giấy'],
    'TP.HCM': ['Quận 1', 'Quận 2', 'Quận 3', 'Quận 4', 'Quận 5'],
    'Đà Nẵng': [
      'Hải Châu',
      'Thanh Khê',
      'Sơn Trà',
      'Ngũ Hành Sơn',
      'Liên Chiểu',
    ],
    'Cần Thơ': ['Ninh Kiều', 'Bình Thủy', 'Cái Răng', 'Ô Môn', 'Thốt Nốt'],
    'Hải Phòng': ['Hồng Bàng', 'Ngô Quyền', 'Lê Chân', 'Kiến An', 'Hải An'],
  };

  String? _selectedCity;
  String? _selectedDistrict;
  bool _isInBuilding = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data or empty strings
    _siteNameController = TextEditingController(
      text: widget.reportData['siteInfo']?['siteName'] ?? '',
    );
    _addressController = TextEditingController(
      text: widget.reportData['siteInfo']?['address'] ?? '',
    );
    _buildingNameController = TextEditingController(
      text: widget.reportData['siteInfo']?['buildingName'] ?? '',
    );
    _floorNumberController = TextEditingController(
      text: widget.reportData['siteInfo']?['floorNumber'] ?? '',
    );

    // Initialize dropdown values
    _selectedCity = widget.reportData['siteInfo']?['city'];
    _selectedDistrict = widget.reportData['siteInfo']?['district'];

    // Determine if it's a site within a building
    _isInBuilding = widget.reportData['reportType'] == 'Building';

    // Initialize reportData structure if not already set
    if (widget.reportData['siteInfo'] == null) {
      widget.setState(() {
        widget.reportData['siteInfo'] = {
          'siteName': '',
          'siteCategory': widget.reportData['siteCategory'] ?? 'Commercial',
          'address': '',
          'area': null,
          'district': null,
          'status': 'Available',
          'buildingName': '',
          'floorNumber': '',
        };
      });
    }
  }

  @override
  void dispose() {
    _siteNameController.dispose();
    _addressController.dispose();
    _buildingNameController.dispose();
    _floorNumberController.dispose();
    super.dispose();
  }

  void _updateReportData(String field, dynamic value) {
    widget.setState(() {
      widget.reportData['siteInfo'][field] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin Mặt bằng',
              style: widget.theme.textTheme.headlineLarge?.copyWith(
                color: widget.theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Site Name
            _buildTextField(
              controller: _siteNameController,
              label: 'Tên mặt bằng',
              icon: Icons.store,
              onChanged: (value) => _updateReportData('siteName', value),
            ),

            const SizedBox(height: 16),

            // Site Category (Auto-filled and read-only)
            _buildReadOnlyField(
              label: 'Loại mặt bằng',
              value: widget.reportData['siteCategory'] ?? 'Commercial',
              icon: Icons.category,
            ),

            const SizedBox(height: 16),

            // Address
            _buildTextField(
              controller: _addressController,
              label: 'Địa chỉ',
              icon: Icons.location_on,
              onChanged: (value) => _updateReportData('address', value),
            ),

            const SizedBox(height: 16),

            // City and District Dropdowns (on the same row)
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: 'Thành phố',
                    icon: Icons.location_city,
                    value: _selectedCity,
                    items:
                        _cities
                            .map(
                              (city) => DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value as String?;
                        // Reset district when city changes
                        _selectedDistrict = null;
                      });
                      _updateReportData('city', value);
                      _updateReportData('district', null);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    label: 'Quận/Huyện',
                    icon: Icons.map,
                    value: _selectedDistrict,
                    items:
                        (_selectedCity != null &&
                                _districts.containsKey(_selectedCity))
                            ? _districts[_selectedCity]!
                                .map(
                                  (district) => DropdownMenuItem(
                                    value: district,
                                    child: Text(district),
                                  ),
                                )
                                .toList()
                            : [],
                    onChanged:
                        _selectedCity == null
                            ? null
                            : (value) {
                              setState(() {
                                _selectedDistrict = value as String?;
                              });
                              _updateReportData('district', value);
                            },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Status (Always "Available" and read-only)
            _buildReadOnlyField(
              label: 'Trạng thái',
              value: 'Available',
              icon: Icons.check_circle,
            ),

            // Only show building fields if it's a site within a building
            if (_isInBuilding) ...[
              const SizedBox(height: 24),

              Text(
                'Thông tin Tòa nhà',
                style: widget.theme.textTheme.titleLarge?.copyWith(
                  color: widget.theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Building Name
              _buildTextField(
                controller: _buildingNameController,
                label: 'Tên tòa nhà',
                icon: Icons.apartment,
                onChanged: (value) => _updateReportData('buildingName', value),
              ),

              const SizedBox(height: 16),

              // Floor Number
              _buildTextField(
                controller: _floorNumberController,
                label: 'Số tầng',
                icon: Icons.stairs,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => _updateReportData('floorNumber', value),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: widget.theme.colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập $label';
        }
        return null;
      },
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: widget.theme.colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        filled: true,
        fillColor: widget.theme.colorScheme.surface.withOpacity(0.5),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(Object?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: widget.theme.colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
      ),
      items: items,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng chọn $label';
        }
        return null;
      },
      isExpanded: true,
    );
  }
}
