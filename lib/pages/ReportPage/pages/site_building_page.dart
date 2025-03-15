import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siteplus_mb/pages/ReportPage/components/additional_notes.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/AreaDistrict/locations_provider.dart';
import 'package:siteplus_mb/utils/ReportPage/custom_input_field.dart';
import 'package:siteplus_mb/utils/Site/site_api_create_model.dart';

import './ReportPage.dart';

class SiteBuildingPage extends StatefulWidget {
  final String reportType;
  final int? siteCategoryId;
  final String? siteCategory;

  const SiteBuildingPage({
    super.key,
    required this.reportType,
    required this.siteCategoryId,
    required this.siteCategory,
  });

  @override
  State<SiteBuildingPage> createState() => _SiteBuildingPageState();
}

class _SiteBuildingPageState extends State<SiteBuildingPage> {
  late TextEditingController _siteNameController;
  late TextEditingController _addressController;
  late TextEditingController _buildingNameController;
  late TextEditingController _floorNumberController;
  final _formKey = GlobalKey<FormState>();
  final _additionalNotesKey = GlobalKey<AdditionalNotesComponentState>();
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  // Data storage
  late Map<String, dynamic> reportData;
  // ignore: unused_field
  bool _isInitialized = false;
  late LocationsProvider _locationsProvider;
  List<District> _districts = [];
  List<Area> _areas = [];
  String? _selectedDistrictName;
  int? _selectedDistrictId;
  String? _selectedAreaName;
  bool _isLoadingAreas = false;
  bool _isInBuilding = false;

  // Scroll controller for form
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Initialize the report data
    reportData = {
      'reportType': widget.reportType,
      'siteCategory': widget.siteCategory,
      'siteCategoryId': widget.siteCategoryId,
      'siteInfo': {
        'siteName': '',
        'siteCategory': widget.siteCategory,
        'siteCategoryId': widget.siteCategoryId,
        'address': '',
        'areaId': null,
        'status': 'Available',
        'buildingName': '',
        'floorNumber': '',
      },
      'customerFlow': {
        'vehicles': {
          'motorcycle': 0,
          'car': 0,
          'bicycle': 0,
          'pedestrian': 0,
          'other': null,
        },
        'peakHours': {'morning': 0, 'noon': 0, 'afternoon': 0, 'evening': 0},
        'overallRating': null,
      },
      'customerConcentration': {
        'customerTypes': [],
        'averageCustomers': null,
        'overallRating': null,
      },
      'customerModel': {
        'gender': null,
        'ageGroups': {'under18': 0, '18to30': 0, '31to45': 0, 'over45': 0},
        'income': null,
        'overallRating': null,
      },
      'siteArea': {
        'totalArea': 0,
        'shape': null,
        'condition': null,
        'overallRating': null,
      },
      'environmentalFactors': {
        'airQuality': null,
        'naturalLight': null,
        'greenery': null,
        'waste': null,
        'surroundingStores': [],
        'overallRating': null,
      },
      'visibilityAndObstruction': {
        'hasObstruction': false,
        'obstructionType': null,
        'obstructionLevel': null,
        'overallRating': null,
      },
      'convenience': {
        'terrain': null,
        'accessibility': null,
        'overallRating': null,
      },
      'additionalNotes': null,
      'hasImages': false,
    };

    // Initialize controllers with existing data or empty strings
    _siteNameController = TextEditingController(text: '');
    _addressController = TextEditingController(text: '');
    _buildingNameController = TextEditingController(text: '');
    _floorNumberController = TextEditingController(text: '');

    // Determine if it's a site within a building
    _isInBuilding = widget.reportType == 'Building';
    // Initialize locations provider in the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  Future<void> _initializeProviders() async {
    // Get the provider after the widget is built
    _locationsProvider = Provider.of<LocationsProvider>(context, listen: false);

    // Load districts
    await _loadDistricts();
    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _loadDistricts() async {
    try {
      await _locationsProvider.initialize();

      // Update state in a safe way
      if (mounted) {
        setState(() {
          _districts = _locationsProvider.districts;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải danh sách quận/huyện'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _loadAreas(int districtId) async {
    setState(() {
      _isLoadingAreas = true;
      _areas = [];
      _selectedAreaName = null;
    });

    try {
      final areas = await _locationsProvider.getAreasForDistrict(districtId);
      setState(() {
        _areas = areas;
        _isLoadingAreas = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAreas = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải danh sách khu vực/phường'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _siteNameController.dispose();
    _addressController.dispose();
    _buildingNameController.dispose();
    _floorNumberController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateReportData(String field, dynamic value) {
    setState(() {
      reportData['siteInfo'][field] = value;
    });
  }

  Future<void> _createSite() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        // Lấy dữ liệu ảnh từ AdditionalNotesComponent
        final additionalNotesState = _additionalNotesKey.currentState;

        // Tạo request object từ reportData và danh sách ảnh URL
        final siteRequest = SiteCreateRequest.fromReportData(reportData);

        // Gọi API tạo site
        final result = await _apiService.createSite(siteRequest);

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tạo mặt bằng thành công!',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: Duration(seconds: 2),
          ),
        );

        // Sau khi tạo thành công, có thể điều hướng về trang trước hoặc đến trang chi tiết site
        Navigator.pop(context);
      } catch (e) {
        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi: ${e.toString()}',
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: Duration(seconds: 3),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // Nếu form chưa hợp lệ, thông báo cho người dùng
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _proceedToFullReport() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Chuyển sang trang báo cáo đầy đủ với dữ liệu đã thu thập
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ReportPage(
                reportType: widget.reportType,
                siteCategory: widget.siteCategory,
                siteCategoryId: widget.siteCategoryId,
                initialReportData: reportData,
              ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Custom styled dropdown for district and area
  Widget _buildStyledDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isLoading = false,
    bool isEnabled = true,
  }) {
    final theme = Theme.of(context);

    // Custom theme for dropdown with limited height
    return Theme(
      data: Theme.of(context).copyWith(),
      child: AnimatedOpacity(
        opacity: isLoading ? 0.6 : 1.0, // Fade out when loading
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
              filled: true, // Bật màu nền
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
            // Limit items shown in dropdown
            menuMaxHeight: 200, // Show maximum of ~5 items at once
            dropdownColor: theme.colorScheme.surface,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Thông tin mặt bằng',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text('Hướng dẫn'),
                        content: Text(
                          'Điền đầy đủ thông tin mặt bằng và thêm ghi chú, hình ảnh để tiến hành khảo sát đầy đủ. Nếu bạn điền xong và chỉ muốn đăng tải thông tin của mặt bằng lên trước thì bạn hãy tạo thông tin cho mặt trước rồi sau đó tiếp tục viết báo cáo chi tiết sau !!!',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Đã hiểu'),
                          ),
                        ],
                      ),
                );
              },
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section: Thông tin Mặt bằng
                  _buildSectionHeader(
                    title: 'Thông tin Mặt bằng',
                    icon: Icons.store_mall_directory,
                    theme: theme,
                  ),
                  SizedBox(height: 16),
                  // Tên mặt bằng - Using CustomInputField
                  CustomInputField(
                    label: 'Tên mặt bằng',
                    icon: Icons.store,
                    onSaved: (value) => _updateReportData('siteName', value),
                    theme: theme,
                    initialValue: _siteNameController.text,
                  ),
                  SizedBox(height: 16),
                  // Loại mặt bằng (read-only)
                  _buildReadOnlyField(
                    label: 'Loại mặt bằng',
                    value: widget.siteCategory ?? 'Commercial',
                    icon: Icons.category,
                  ),
                  SizedBox(height: 16),
                  // Địa chỉ - Using CustomInputField
                  CustomInputField(
                    label: 'Địa chỉ',
                    icon: Icons.location_on,
                    onSaved: (value) => _updateReportData('address', value),
                    theme: theme,
                    initialValue: _addressController.text,
                  ),
                  SizedBox(height: 16),
                  // Dropdown: Thành phố và Quận/Huyện with improved styling
                  _buildStyledDropdown(
                    label: 'Quận/Huyện',
                    icon: Icons.location_city,
                    value: _selectedDistrictName,
                    items: _districts.map((district) => district.name).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        final district = _districts.firstWhere(
                          (d) => d.name == value,
                          orElse: () => District(id: -1, name: '', cityId: -1),
                        );

                        if (district.id != -1) {
                          setState(() {
                            _selectedDistrictName = value;
                            _selectedDistrictId = district.id;
                            _selectedAreaName = null;
                          });
                          _updateReportData('areaId', null);
                          _loadAreas(district.id);
                        }
                      }
                    },
                  ),
                  SizedBox(height: 23),
                  _buildStyledDropdown(
                    label: 'Phường/Xã',
                    icon: Icons.map,
                    value: _selectedAreaName,
                    items: _areas.map((area) => area.name).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        final area = _areas.firstWhere(
                          (a) => a.name == value,
                          orElse: () => Area(id: -1, name: '', districtId: -1),
                        );

                        if (area.id != -1) {
                          setState(() {
                            _selectedAreaName = value;
                          });
                          _updateReportData('areaId', area.id);
                        }
                      }
                    },
                    isLoading: _isLoadingAreas,
                    isEnabled: _selectedDistrictId != null && _areas.isNotEmpty,
                  ),
                  SizedBox(height: 23),
                  // Trạng thái (read-only)
                  _buildReadOnlyField(
                    label: 'Trạng thái',
                    value: 'Available',
                    icon: Icons.check_circle,
                  ),
                  // Hiển thị thông tin tòa nhà nếu báo cáo thuộc loại Building
                  if (_isInBuilding) ...[
                    SizedBox(height: 24),
                    _buildSectionHeader(
                      title: 'Thông tin Tòa nhà',
                      icon: Icons.apartment,
                      theme: theme,
                    ),
                    SizedBox(height: 16),
                    // Using CustomInputField for building name
                    CustomInputField(
                      label: 'Tên tòa nhà',
                      icon: Icons.apartment,
                      onSaved:
                          (value) => _updateReportData('buildingName', value),
                      theme: theme,
                      initialValue: _buildingNameController.text,
                    ),
                    SizedBox(height: 16),
                    // Using CustomInputField for floor number
                    CustomInputField(
                      label: 'Số tầng',
                      icon: Icons.stairs,
                      onSaved:
                          (value) => _updateReportData('floorNumber', value),
                      theme: theme,
                      initialValue: _floorNumberController.text,
                    ),
                  ],
                  SizedBox(height: 24),
                  Divider(color: theme.colorScheme.primary.withOpacity(0.2)),
                  SizedBox(height: 24),
                  // Component: Ghi chú & Hình ảnh
                  AdditionalNotesComponent(
                    key: _additionalNotesKey,
                    reportData: reportData,
                    theme: theme,
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
        // Cập nhật bottomNavigationBar để thêm button "Tạo thông tin cho mặt bằng"
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Button gọi API tạo site
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createSite,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child:
                      _isLoading
                          ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onSecondary,
                            ),
                          )
                          : Text('Tạo thông tin cho mặt bằng'),
                ),
              ),
              SizedBox(height: 8),
              // Nút Hủy và Tiếp tục báo cáo đầy đủ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                    icon: Icon(Icons.arrow_back),
                    label: Text('Hủy'),
                  ),
                  FilledButton.icon(
                    onPressed: _proceedToFullReport,
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    icon: Icon(Icons.navigate_next),
                    label: Text('Tiếp tục báo cáo đầy đủ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
