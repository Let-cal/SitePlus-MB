// site_building_page.dart - Main component file
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siteplus_mb/pages/ReportPage/components/SiteComponents/location_section.dart';
import 'package:siteplus_mb/pages/ReportPage/components/SiteComponents/section_header.dart';
import 'package:siteplus_mb/pages/ReportPage/components/SiteComponents/site_info_section.dart';
import 'package:siteplus_mb/pages/ReportPage/components/additional_notes.dart';
import 'package:siteplus_mb/pages/ReportPage/components/building_section.dart';
import 'package:siteplus_mb/pages/ReportPage/pages/report_create_dialog.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/AreaDistrict/locations_provider.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_api_create_model.dart';
import 'package:siteplus_mb/utils/constants.dart';

class SiteBuildingDialog extends StatefulWidget {
  final String reportType;
  final int? siteCategoryId;
  final int? areaId;
  final String? siteCategory;
  final int taskId;
  final String taskStatus;
  final int? siteId;
  final VoidCallback? onUpdateSuccess;

  const SiteBuildingDialog({
    super.key,
    required this.reportType,
    required this.siteCategoryId,
    required this.areaId,
    required this.siteCategory,
    required this.taskId,
    required this.taskStatus,
    this.siteId,
    this.onUpdateSuccess,
  });

  @override
  State<SiteBuildingDialog> createState() => _SiteBuildingDialogState();
}

class _SiteBuildingDialogState extends State<SiteBuildingDialog> {
  late TextEditingController _addressController;
  late TextEditingController _totalFloorNumberController;
  late TextEditingController _floorNumberController;
  late TextEditingController _sizeController;
  final _formKey = GlobalKey<FormState>();
  final _additionalNotesKey = GlobalKey<AdditionalNotesComponentState>();
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  // Data storage
  late Map<String, dynamic> reportData;
  bool _isInitialized = false;
  late LocationsProvider _locationsProvider;

  // Location related state
  List<District> _districts = [];
  List<Area> _areas = [];
  String? _selectedDistrictName;
  int? _selectedDistrictId;
  String? _selectedAreaName;
  int? _selectedAreaId;
  bool _isLoadingAreas = false;

  int? _userAreaId;
  // Building related state
  bool _isInBuilding = false;
  List<BuildingCreateRequest> _buildings = [];
  BuildingCreateRequest? _selectedBuilding;
  bool _isLoadingBuildings = false;

  // Scroll controller for form
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _locationsProvider = Provider.of<LocationsProvider>(context, listen: false);
    _initializeData();
  }

  Future<void> _initializeData() async {
    reportData = _createInitialReportData();

    _addressController = TextEditingController(text: '');
    _sizeController = TextEditingController(text: '');
    _floorNumberController = TextEditingController(text: '');
    _totalFloorNumberController = TextEditingController(text: '');

    _isInBuilding = widget.reportType == 'Building';
    await _getUserAreaInfo();

    await _loadDistricts();
    if (_districts.isEmpty) {
      debugPrint('Districts chưa được tải, không thể chọn district/area');
      return;
    }

    // Kiểm tra nếu là chỉnh sửa (task.status == STATUS_DA_NHAN và có siteId)
    if (widget.taskStatus == STATUS_DA_NHAN && widget.siteId != null) {
      await _loadSiteData(widget.siteId!);
    } else if (widget.areaId != null) {
      // Trường hợp tạo mới với areaId từ task
      await _autoSelectDistrictAndArea(widget.areaId!);
    }

    if (_isInBuilding) {
      _loadAllBuildings();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  Future<void> _loadSiteData(int siteId) async {
    try {
      final siteResponse = await _apiService.getSiteById(siteId);
      final siteData = siteResponse['data'];

      setState(() {
        // Điền dữ liệu vào controllers
        _addressController.text = siteData['address'] ?? '';
        _sizeController.text = siteData['size'].toString();
        _floorNumberController.text = siteData['floor'].toString();
        _totalFloorNumberController.text = siteData['totalFloor'].toString();

        // Cập nhật reportData
        reportData['siteInfo'] = {
          'siteName': '',
          'siteCategory': widget.siteCategory,
          'siteCategoryId': siteData['siteCategoryId'],
          'address': siteData['address'],
          'size': siteData['size'].toString(),
          'areaId': siteData['areaId'],
          'status': siteData['status'],
          'floor': siteData['floor'].toString(),
          'buildingId': siteData['buildingId'],
          'buildingName': siteData['buildingName'] ?? '',
          'totalFloor': siteData['totalFloor'].toString(),
          'taskId': widget.taskId,
        };

        // Cập nhật selection cho area và district
        _selectedAreaId = siteData['areaId'];
        _selectedAreaName = siteData['areaName'];
      });

      // Tự động chọn district dựa trên areaId
      await _autoSelectDistrictFromArea(siteData['areaId']);
    } catch (e) {
      debugPrint('Error loading site data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải thông tin site: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _autoSelectDistrictFromArea(int areaId) async {
    final allAreas = await _apiService.getAllAreas();
    final selectedArea = allAreas.firstWhere((area) => area.id == areaId);
    final district = _districts.firstWhere(
      (d) => d.id == selectedArea.districtId,
    );

    setState(() {
      _selectedDistrictId = district.id;
      _selectedDistrictName = district.name;
    });

    await _loadAreas(district.id);
    setState(() {
      _selectedAreaId = areaId;
      _selectedAreaName = selectedArea.name;
    });
  }

  Future<void> _createOrUpdateSite() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        final siteRequest =
            SiteCreateRequest.fromReportData(reportData).toJson();

        if (widget.taskStatus == STATUS_DA_NHAN && widget.siteId != null) {
          // Cập nhật site
          final response = await _apiService.updateSite(
            widget.siteId!,
            siteRequest,
          );
          if (response['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cập nhật mặt bằng thành công!'),
                backgroundColor: Colors.green,
              ),
            );
            await Future.delayed(Duration(milliseconds: 500));
            widget.onUpdateSuccess?.call();
            Navigator.of(context).pop(true);
          } else {
            throw Exception('Failed to update site: ${response['message']}');
          }
        } else {
          // Tạo mới site
          final response = await _apiService.createSite(
            SiteCreateRequest.fromReportData(reportData),
          );
          if (response['success'] == true || response.containsKey('siteId')) {
            final statusTaskUpdated = await _apiService.updateTaskStatus(
              widget.taskId,
              2,
            );
            if (statusTaskUpdated) {
              debugPrint('Task status updated to "Đã nhận" (2)');
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Tạo mặt bằng thành công!'),
                backgroundColor: Colors.green,
              ),
            );
            await Future.delayed(Duration(milliseconds: 500));
            widget.onUpdateSuccess?.call();
            Navigator.of(context).pop(true);
          } else {
            throw Exception('Failed to create site: ${response['message']}');
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')));
    }
  }

  Map<String, dynamic> _createInitialReportData() {
    return {
      'reportType': widget.reportType,
      'siteCategory': widget.siteCategory,
      'siteCategoryId': widget.siteCategoryId,
      'siteInfo': {
        'siteName': '',
        'siteCategory': widget.siteCategory,
        'siteCategoryId': widget.siteCategoryId,
        'address': '',
        'size': '',
        'areaId': null,
        'status': 'Available',
        'floor': '',
        'buildingId': null,
        'buildingName': '',
        'totalFloor': '',
        'taskId': widget.taskId,
      },
    };
  }

  Future<void> _loadDistricts() async {
    try {
      await _locationsProvider.initialize();
      if (mounted) {
        setState(() {
          _districts = _locationsProvider.districts;
          debugPrint('Districts loaded: ${_districts.length}');
          _districts.forEach((district) {
            debugPrint('District: ${district.id} - ${district.name}');
          });
        });
      }
    } catch (e) {
      debugPrint('Error loading districts: $e');
    }
  }

  Future<void> _autoSelectDistrictAndArea(int areaId) async {
    try {
      // Gọi API để lấy tất cả areas
      final allAreas = await _apiService.getAllAreas();

      // Tìm area có id bằng areaId
      final selectedArea = allAreas.firstWhere(
        (area) => area.id == areaId,
        orElse: () => Area(id: -1, name: '', districtId: -1),
      );

      if (selectedArea.id != -1) {
        final districtId = selectedArea.districtId;

        // Tìm district tương ứng trong _districts
        final selectedDistrict = _districts.firstWhere(
          (district) => district.id == districtId,
          orElse: () => District(id: -1, name: '', cityId: -1),
        );

        if (selectedDistrict.id != -1) {
          setState(() {
            _selectedDistrictId = districtId;
            _selectedDistrictName = selectedDistrict.name;
            _selectedAreaId = areaId;
            _selectedAreaName = selectedArea.name;
          });

          // Load areas cho district đã chọn
          await _loadAreas(districtId);

          // Cập nhật reportData
          _updateReportData('areaId', areaId);
        } else {
          debugPrint('Không tìm thấy district với districtId: $districtId');
        }
      } else {
        debugPrint('Không tìm thấy area với areaId: $areaId');
      }
    } catch (e) {
      debugPrint('Lỗi khi tự động chọn district và area: $e');
      // Có thể hiển thị thông báo lỗi cho người dùng nếu cần
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tự động chọn vị trí: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _getUserAreaInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? areaId = prefs.getInt('areaId');

      if (areaId != null) {
        setState(() {
          _userAreaId = areaId;
        });

        // Update report data
        _updateReportData('areaId', areaId);
      }
    } catch (e) {
      debugPrint('Error getting user area info: $e');
    }
  }

  // New method to load all buildings regardless of area
  Future<void> _loadAllBuildings() async {
    setState(() {
      _isLoadingBuildings = true;
      _buildings = [];
      _selectedBuilding = null;
    });

    try {
      if (_userAreaId != null) {
        // Get the actual buildings list from the API
        final buildings = await _apiService.getBuildingsByAreaId(_userAreaId!);

        setState(() {
          _buildings =
              buildings; // Now buildings should be a List<BuildingCreateRequest>
          _isLoadingBuildings = false;
        });
      } else {
        // Handle case when area ID is null
        setState(() {
          _isLoadingBuildings = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingBuildings = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải danh sách tòa nhà: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _initializeProviders() async {
    _locationsProvider = Provider.of<LocationsProvider>(context, listen: false);
    await _loadDistricts();
    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _loadAreas(int districtId) async {
    setState(() {
      _isLoadingAreas = true;
      _areas = [];
      _selectedAreaName = null;
      _selectedAreaId = null;
    });

    try {
      final areas = await _locationsProvider.getAreasForDistrict(districtId);

      if (mounted) {
        setState(() {
          _areas = areas;
          _isLoadingAreas = false;
        });
      }
    } catch (e) {
      if (mounted) {
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
  }

  @override
  void dispose() {
    _addressController.dispose();
    _sizeController.dispose();
    _floorNumberController.dispose();
    _totalFloorNumberController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateReportData(String field, dynamic value) {
    setState(() {
      reportData['siteInfo'][field] = value;
    });
  }

  void _proceedToFullReport() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ReportCreateDialog(
                reportType: widget.reportType,
                siteCategory: widget.siteCategory,
                siteCategoryId: widget.siteCategoryId,
                taskId: widget.taskId,
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

  void _handleDistrictChanged(String? value) {
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
          _selectedAreaId = null;
        });
        _updateReportData('areaId', null);
        _loadAreas(district.id);
      }
    }
  }

  void _handleAreaChanged(String? value) {
    if (value != null) {
      final area = _areas.firstWhere(
        (a) => a.name == value,
        orElse: () => Area(id: -1, name: '', districtId: -1),
      );

      if (area.id != -1) {
        setState(() {
          _selectedAreaName = value;
          _selectedAreaId = area.id;
        });
        _updateReportData('areaId', area.id);
      }
    }
  }

  void _handleBuildingSelected(BuildingCreateRequest? building) {
    setState(() {
      _selectedBuilding = building;
    });
    print("Selected building: ${building?.id}, ${building?.name}");
  }

  void _handleBuildingDataChanged(int? buildingId, String? buildingName) {
    _updateReportData('buildingId', buildingId);
    _updateReportData('buildingName', buildingName ?? '');
    print("Updated buildingId in reportData: $buildingId");
  }

  void _handleFloorNumberChanged(String? value) {
    debugPrint('Updating totalFloor in reportData: $value');
    _updateReportData('totalFloor', value);
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
              onPressed: () => _showHelpDialog(context),
            ),
          ],
          elevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor,
        ),
        body: Form(
          key: _formKey,
          child:
              _isInitialized
                  ? _buildFormContent(theme)
                  : Center(child: CircularProgressIndicator()),
        ),
        bottomNavigationBar: _buildBottomBar(theme),
      ),
    );
  }

  Widget _buildFormContent(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.05),
            theme.scaffoldBackgroundColor,
          ],
          stops: [0.0, 0.3],
        ),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              _buildProgressIndicator(theme),
              SizedBox(height: 24),

              // Section: Thông tin Mặt bằng
              _buildSectionWithAnimation(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Thông tin Mặt bằng',
                      icon: Icons.store_mall_directory,
                    ),
                    SizedBox(height: 20),

                    // Site Info Section - in a card
                    _buildElevatedCard(
                      child: SiteInfoSection(
                        addressController: _addressController,
                        sizeController: _sizeController,
                        floorNumberController: _floorNumberController,
                        siteCategory: widget.siteCategory ?? 'Commercial',
                        siteCategoryId: widget.siteCategoryId,
                        onSiteNameSaved:
                            (value) => _updateReportData('siteName', value),
                        onAddressSaved:
                            (value) => _updateReportData('address', value),
                        onSizeSaved:
                            (value) => _updateReportData('size', value),
                        onFloorSaved: (value) {
                          debugPrint(
                            'Floor saved from SiteInfoSection: $value',
                          );
                          _updateReportData('floor', value);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Location Section
              _buildSectionWithAnimation(
                delay: Duration(milliseconds: 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: 'Vị trí', icon: Icons.location_on),
                    SizedBox(height: 20),

                    // Location fields in a card
                    _buildElevatedCard(
                      child: LocationSection(
                        districts: _districts,
                        areas: _areas,
                        selectedDistrictName: _selectedDistrictName,
                        selectedAreaName: _selectedAreaName,
                        isLoadingAreas: _isLoadingAreas,
                        onDistrictChanged: _handleDistrictChanged,
                        onAreaChanged: _handleAreaChanged,
                        isAreaSelectionEnabled:
                            _selectedDistrictId != null && _areas.isNotEmpty,
                      ),
                    ),
                  ],
                ),
              ),

              // Building Section (conditional)
              if (_isInBuilding) ...[
                SizedBox(height: 32),
                _buildSectionWithAnimation(
                  delay: Duration(milliseconds: 300),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Thông tin Tòa nhà',
                        icon: Icons.apartment,
                      ),
                      SizedBox(height: 20),

                      // Building fields in a card
                      _buildElevatedCard(
                        child: BuildingSection(
                          areaId: _userAreaId,
                          buildings: _buildings,
                          isLoadingBuildings: _isLoadingBuildings,
                          onBuildingSelected: _handleBuildingSelected,
                          onBuildingDataChanged: _handleBuildingDataChanged,
                          initialSelectedBuilding: _selectedBuilding,
                          totalFloorNumber:
                              reportData['siteInfo']['totalFloor'],
                          onFloorNumberChanged: _handleFloorNumberChanged,
                          onReloadBuildings: _loadAllBuildings,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 32),

              // Additional Notes Component
              _buildSectionWithAnimation(
                delay: Duration(milliseconds: 450),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Ghi chú bổ sung',
                      icon: Icons.note_add,
                    ),
                    SizedBox(height: 20),

                    // Notes in a card
                    _buildElevatedCard(
                      child: AdditionalNotesComponent(
                        key: _additionalNotesKey,
                        reportData: reportData,
                        theme: theme,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 80), // Space for bottom bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    // Calculate progress based on form completion
    double progress = 0.25; // Minimum progress

    if (_selectedDistrictId != null) progress += 0.25;
    if (_selectedAreaId != null) progress += 0.25;
    if (_addressController.text.isNotEmpty &&
        _sizeController.text.isNotEmpty &&
        _floorNumberController.text.isNotEmpty)
      progress += 0.25;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tiến độ thông tin',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionWithAnimation({required Widget child, Duration? delay}) {
    return AnimatedOpacity(
      opacity: _isInitialized ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      // Thêm delay để tạo hiệu ứng tuần tự
      onEnd: () {},
      child: AnimatedSlide(
        offset: _isInitialized ? Offset.zero : Offset(0, 0.1),
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        child: child,
      ),
    );
  }

  Widget _buildElevatedCard({required Widget child}) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: EdgeInsets.all(16), child: child),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nút lưu mặt bằng
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _createOrUpdateSite,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon: Icon(Icons.save),
                        label: Text(
                          widget.taskStatus == STATUS_DA_NHAN
                              ? 'Cập nhật mặt bằng'
                              : 'Lưu thông tin mặt bằng',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    // Row chứa nút tiếp tục và nút hủy
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                              side: BorderSide(color: theme.colorScheme.error),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.close,
                                  color: theme.colorScheme.error,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Hủy',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        // Nút tiếp tục báo cáo đầy đủ
                        Expanded(
                          flex: 3,
                          child: OutlinedButton.icon(
                            onPressed: _proceedToFullReport,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              side: BorderSide(
                                color: theme.colorScheme.primary,
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Icon(Icons.navigate_next),
                            label: Text(
                              'Tiếp tục báo cáo đầy đủ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Nút hủy với viền và icon
                      ],
                    ),
                  ],
                ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Hướng dẫn'),
            content: Text(
              'Điền đầy đủ thông tin mặt bằng và thêm ghi chú để tiến hành khảo sát đầy đủ. Nếu bạn điền xong và chỉ muốn đăng tải thông tin của mặt bằng lên trước thì bạn hãy tạo thông tin cho mặt trước rồi sau đó tiếp tục viết báo cáo chi tiết sau !!!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Đã hiểu'),
              ),
            ],
          ),
    );
  }
}
