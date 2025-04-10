// site_building_page.dart - Main component file
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siteplus_mb/components/help_dialog.dart';
import 'package:siteplus_mb/pages/ReportPage/components/SiteComponents/building_section.dart';
import 'package:siteplus_mb/pages/ReportPage/components/SiteComponents/location_section.dart';
import 'package:siteplus_mb/pages/ReportPage/components/SiteComponents/section_header.dart';
import 'package:siteplus_mb/pages/ReportPage/components/SiteComponents/site_info_section.dart';
import 'package:siteplus_mb/pages/ReportPage/components/additional_notes.dart';
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
  final bool isProposeMode;

  const SiteBuildingDialog({
    super.key,
    required this.reportType,
    required this.siteCategoryId,
    this.areaId,
    required this.siteCategory,
    required this.taskId,
    required this.taskStatus,
    this.siteId,
    this.onUpdateSuccess,
    this.isProposeMode = false,
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
    setState(() {
      _isLoading = true;
    });
    reportData = _createInitialReportData();

    _addressController = TextEditingController(text: '');
    _sizeController = TextEditingController(text: '');
    _floorNumberController = TextEditingController(text: '');
    _totalFloorNumberController = TextEditingController(text: '');
    debugPrint('Report type received: ${widget.reportType}');

    _isInBuilding =
        widget.reportType == 'Building' ||
        widget.reportType == 'Internal Site' ||
        widget.reportType == '1';
    await Future.wait([_getUserAreaInfo(), _loadDistricts()]);
    if (_districts.isEmpty) {
      debugPrint('Districts have not been loaded, cannot select district/area');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // If editing (task.status == STATUS_DA_NHAN and there is a siteId)
    if (widget.taskStatus == STATUS_DA_NHAN && widget.siteId != null) {
      await _loadSiteData(widget.siteId!);
    } else if (widget.areaId != null) {
      await _autoSelectDistrictAndArea(widget.areaId!);
    }

    if (_isInBuilding && widget.taskStatus != STATUS_DA_NHAN) {
      _loadAllBuildings();
    }
    setState(() {
      _isLoading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  Future<void> _loadSiteData(int siteId) async {
    try {
      debugPrint('Site id received from task: ${siteId.toString()}');
      final siteResponse = await _apiService.getSiteById(siteId);
      final siteData = siteResponse['data'];
      // Retrieve all areas to find areaId from areaName
      final allAreas = await _apiService.getAllAreas();
      final selectedArea = allAreas.firstWhere(
        (area) => area.name == siteData['areaName'],
        orElse: () => Area(id: -1, name: '', districtId: -1),
      );

      int? areaId = selectedArea.id != -1 ? selectedArea.id : null;
      int? districtId = selectedArea.id != -1 ? selectedArea.districtId : null;
      setState(() {
        // Fill data into controllers
        _addressController.text = siteData['address'] ?? '';
        _sizeController.text = siteData['size'].toString();
        _floorNumberController.text = siteData['floor'].toString();
        _totalFloorNumberController.text = siteData['totalFloor'].toString();
        // Create BuildingCreateRequest from API data
        if (siteData['buildingId'] != null) {
          final BuildingCreateRequest initialBuilding = BuildingCreateRequest(
            id: siteData['buildingId'],
            name: siteData['buildingName'] ?? '',
            areaId: siteData['areaId'] ?? -1,
            areaName: siteData['areaName'] ?? '',
            status: 1,
            statusName: 'Active',
          );
          // Check whether the building already exists in the list
          bool buildingExists = _buildings.any(
            (b) => b.id == initialBuilding.id,
          );
          if (!buildingExists) {
            _buildings.add(initialBuilding);
          }

          // Set the selected building
          _selectedBuilding = initialBuilding;
        }
        // Update reportData
        reportData['siteInfo'] = {
          'siteName': '',
          'siteCategory': widget.siteCategory,
          'siteCategoryId': siteData['siteCategoryId'],
          'address': siteData['address'],
          'size': siteData['size'].toString(),
          'areaId': areaId,
          'status': siteData['status'],
          'floor': siteData['floor'].toString(),
          'buildingId': siteData['buildingId'],
          'buildingName': siteData['buildingName'] ?? '',
          'totalFloor': siteData['totalFloor'].toString(),
          'taskId': widget.taskId,
        };
        debugPrint('Building id: ${siteData['buildingId']}');
        debugPrint('Building name: ${siteData['buildingName']}');
        // Update area and district selection
        _selectedAreaName = siteData['areaName'];
        _selectedAreaId = areaId;
      });

      // Auto-select district if districtId is found
      if (districtId != null) {
        await _autoSelectDistrictFromArea(areaId);
      }
      await _loadAllBuildings();
    } catch (e) {
      debugPrint('Error loading site data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load site information: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _autoSelectDistrictFromArea(int? areaId) async {
    if (areaId == null) return;

    try {
      final allAreas = await _apiService.getAllAreas();
      final selectedArea = allAreas.firstWhere(
        (area) => area.id == areaId,
        orElse: () => Area(id: -1, name: '', districtId: -1),
      );

      if (selectedArea.id == -1) {
        debugPrint('Area not found with id: $areaId');
        return;
      }

      final district = _districts.firstWhere(
        (d) => d.id == selectedArea.districtId,
        orElse: () => District(id: -1, name: '', cityId: -1),
      );

      if (district.id != -1) {
        setState(() {
          _selectedDistrictId = district.id;
          _selectedDistrictName = district.name;
        });

        await _loadAreas(district.id);
        setState(() {
          _selectedAreaId = areaId;
          _selectedAreaName = selectedArea.name;
        });
      } else {
        debugPrint('District not found with id: ${selectedArea.districtId}');
      }
    } catch (e) {
      debugPrint('Error in auto selecting district: $e');
    }
  }

  Future<void> _createOrUpdateSite() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        if (widget.taskStatus == STATUS_DA_NHAN && widget.siteId != null) {
          // Update site
          final siteRequest =
              SiteCreateRequest.fromReportData(reportData).toJson();
          final response = await _apiService.updateSite(
            widget.siteId!,
            siteRequest,
          );
          if (response['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Site updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            await Future.delayed(Duration(milliseconds: 500));
            widget.onUpdateSuccess?.call();
            Navigator.of(context).pop(true);
          } else {
            throw Exception('Failed to update site: ${response['message']}');
          }
        } else if (widget.taskStatus == STATUS_CHUA_NHAN) {
          // Create new site
          final response = await _apiService.createSite(
            SiteCreateRequest.fromReportData(reportData, customStatus: 2),
          );
          if (response['success'] == true || response.containsKey('siteId')) {
            final statusTaskUpdated = await _apiService.updateTaskStatus(
              widget.taskId,
              2,
            );
            if (statusTaskUpdated) {
              debugPrint('Task status updated to "Received" (2)');
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Site created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            await Future.delayed(Duration(milliseconds: 500));
            widget.onUpdateSuccess?.call(); // Call callback
            Navigator.of(context).pop(true);
          } else {
            throw Exception('Failed to create site: ${response['message']}');
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all required fields')),
      );
    }
  }

  Future<void> _createSite() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        // Copy reportData for modifications
        Map<String, dynamic> modifiedReportData = Map.from(reportData);

        // Remove taskId if in propose mode
        if (widget.isProposeMode) {
          modifiedReportData['siteInfo'].remove('taskId');
        }
        final siteRequest = SiteCreateRequest.fromReportData(
          modifiedReportData,
          customStatus:
              widget.isProposeMode ? 9 : 2, // 9 for propose, 2 for normal
        );
        debugPrint(
          'Site request sent for API create site when isProposeMode == ${widget.isProposeMode}: ${siteRequest.toJson()}',
        );
        final response = await _apiService.createSite(siteRequest);

        if (response['siteId'] != null &&
            response['siteId']['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isProposeMode
                    ? 'Site proposed successfully!'
                    : 'Site created successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          final errorMessage =
              response['siteId']?['message'] ??
              response['message'] ??
              'Unknown error';
          throw Exception('Failed to create site: $errorMessage');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
    }
  }

  Map<String, dynamic> _createInitialReportData() {
    final initialData = {
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
        'status': '',
        'floor': '',
        'buildingId': null,
        'buildingName': '',
        'totalFloor': '',
      },
    };

    // Only add taskId if not in propose mode
    if (!widget.isProposeMode) {
      final siteInfo = initialData['siteInfo'] as Map<String, dynamic>?;
      if (siteInfo != null) {
        siteInfo['taskId'] = widget.taskId;
      }
    }

    return initialData;
  }

  Future<void> _loadDistricts() async {
    try {
      await _locationsProvider.initialize();
      if (mounted) {
        setState(() {
          _districts = _locationsProvider.districts;
          debugPrint('Districts loaded: ${_districts.length}');
          for (var district in _districts) {
            debugPrint('District: ${district.id} - ${district.name}');
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading districts: $e');
    }
  }

  Future<void> _autoSelectDistrictAndArea(int areaId) async {
    try {
      // Call API to get all areas
      final allAreas = await _apiService.getAllAreas();

      // Find the area with the given areaId
      final selectedArea = allAreas.firstWhere(
        (area) => area.id == areaId,
        orElse: () => Area(id: -1, name: '', districtId: -1),
      );

      if (selectedArea.id != -1) {
        final districtId = selectedArea.districtId;

        // Find the corresponding district in _districts
        final selectedDistrict = _districts.firstWhere(
          (district) => district.id == districtId,
          orElse: () => District(id: -1, name: '', cityId: -1),
        );

        if (selectedDistrict.id != -1) {
          setState(() {
            _selectedDistrictId = districtId;
            _selectedDistrictName = selectedDistrict.name;
          });

          // Load areas for the selected district
          await _loadAreas(districtId);
          setState(() {
            _selectedAreaId = areaId;
            _selectedAreaName = selectedArea.name;
          });
          // Update reportData
          _updateReportData('areaId', areaId);
        } else {
          debugPrint('District not found with districtId: $districtId');
        }
      } else {
        debugPrint('Area not found with areaId: $areaId');
      }
    } catch (e) {
      debugPrint('Error when auto-selecting district and area: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to auto select location: $e'),
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
    });

    try {
      List<BuildingCreateRequest> buildings = [];
      int? areaIdToUse = _userAreaId ?? _selectedAreaId;
      if (areaIdToUse != null) {
        buildings = await _apiService.getBuildingsByAreaId(areaIdToUse);
      } else {
        debugPrint('No areaId available to load buildings');
        setState(() {
          _isLoadingBuildings = false;
        });
        return;
      }

      setState(() {
        _buildings = buildings;
        // Check if _selectedBuilding is still valid
        if (_selectedBuilding != null &&
            !_buildings.any((b) => b.id == _selectedBuilding!.id)) {
          _selectedBuilding = null;
        }
        _isLoadingBuildings = false;
      });
      debugPrint('Buildings loaded: ${_buildings.map((b) => b.name).toList()}');
    } catch (e) {
      setState(() {
        _isLoadingBuildings = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load building list: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
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
    });

    try {
      final areas = await _locationsProvider.getAreasForDistrict(districtId);

      if (mounted) {
        setState(() {
          _areas = areas;
          _isLoadingAreas = false;
          if (_selectedAreaId != null &&
              _areas.any((a) => a.id == _selectedAreaId)) {
            final selectedArea = _areas.firstWhere(
              (a) => a.id == _selectedAreaId,
            );
            _selectedAreaName = selectedArea.name;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAreas = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to load list of areas/wards'),
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

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirmation'),
              content: Text(
                'If you continue with the report, the property information you entered will be saved. Are you sure you want to continue?',
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text('Confirm'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if the user exits the dialog without choosing
  }

  Future<void> _proceedToFullReport() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Display confirmation dialog
      final bool confirmed = await _showConfirmationDialog();
      if (!confirmed) {
        return; // The user did not confirm; exit the function.
      }

      setState(() {
        _isLoading = true;
      });

      try {
        if (widget.taskStatus == STATUS_CHUA_NHAN) {
          // Create a new site
          final siteRequest = SiteCreateRequest.fromReportData(
            reportData,
            customStatus: 2,
          );
          final createResponse = await _apiService.createSite(siteRequest);

          if (createResponse['siteId'] != null &&
              createResponse['siteId']['success'] == true) {
            final statusTaskUpdated = await _apiService.updateTaskStatus(
              widget.taskId,
              2,
            );
            if (statusTaskUpdated) {
              debugPrint('Task status updated to "Received" (2)');
            } else {
              debugPrint('Failed to update task status to 2');
              throw Exception('Task status update failed');
            }
          }
          if (createResponse['siteId'] != null) {
            final siteId =
                createResponse['siteId']['data']; // Retrieve siteId from response
            const siteStatus = 2; // Assume default status for a new site

            // Replace SiteBuildingDialog with ReportCreateDialog
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ReportCreateDialog(
                      reportType: widget.reportType,
                      siteCategory: widget.siteCategory,
                      siteCategoryId: widget.siteCategoryId,
                      taskId: widget.taskId,
                      initialReportData: {
                        ...reportData,
                        'siteId': siteId,
                        'siteStatus': siteStatus,
                      },
                    ),
              ),
            );
          } else {
            throw Exception(
              'Failed to create site: ${createResponse['message']}',
            );
          }
        } else if (widget.taskStatus == STATUS_DA_NHAN) {
          // Update the site
          final siteRequest =
              SiteCreateRequest.fromReportData(reportData).toJson();
          final updateResponse = await _apiService.updateSite(
            widget.siteId!,
            siteRequest,
          );

          if (updateResponse['success'] == true) {
            final siteStatus =
                reportData['siteInfo']['status'] ??
                updateResponse['data']['status'];
            debugPrint(
              "Site status passed to ReportCreateDialog is: ${siteStatus}",
            );

            bool isEditMode = [4, 7, 8].contains(siteStatus);
            debugPrint(
              "isEditMode passed to ReportCreateDialog is: ${isEditMode}",
            );
            debugPrint(
              "siteId passed to ReportCreateDialog is: ${widget.siteId}",
            );

            // Open ReportCreateDialog, keeping the current dialog in the stack
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ReportCreateDialog(
                      reportType: widget.reportType,
                      siteCategory: widget.siteCategory,
                      siteCategoryId: widget.siteCategoryId,
                      taskId: widget.taskId,
                      siteId: widget.siteId,
                      initialReportData: {
                        ...reportData,
                        'siteStatus': siteStatus,
                      },
                      isEditMode: isEditMode,
                    ),
              ),
            );
          } else {
            throw Exception(
              'Failed to update site: ${updateResponse['message']}',
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete all required fields.'),
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
            widget.isProposeMode ? 'Propose Site' : 'Create Site',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed:
                  () => HelpDialog.show(
                    context,
                    content:
                        'Fill in all required site information and add notes to proceed. You can save the site information first and complete a detailed report later.',
                  ),
            ),
          ],
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

              // Section: Site Information
              _buildSectionWithAnimation(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Site Information',
                      icon: Icons.store_mall_directory,
                    ),
                    SizedBox(height: 20),

                    // Site Info Section - in a card
                    _buildElevatedCard(
                      child: SiteInfoSection(
                        sizeController: _sizeController,
                        floorNumberController: _floorNumberController,
                        siteCategory: widget.siteCategory ?? 'Commercial',
                        siteCategoryId: widget.siteCategoryId,
                        onSiteNameSaved:
                            (value) => _updateReportData('siteName', value),
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
              // Building Section (conditional)
              if (_isInBuilding) ...[
                _buildSectionWithAnimation(
                  delay: Duration(milliseconds: 300),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Building Information',
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
                SizedBox(height: 32),
              ],
              // Location Section
              _buildSectionWithAnimation(
                delay: Duration(milliseconds: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: 'Location', icon: Icons.location_on),
                    SizedBox(height: 20),
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
                        addressController: _addressController,
                        onAddressSaved:
                            (value) => _updateReportData('address', value),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Additional Notes Component
              _buildSectionWithAnimation(
                delay: Duration(milliseconds: 450),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Additional Notes',
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
    double progress = 0; // Minimum progress

    if (_addressController.text.isNotEmpty) progress += 0.25;
    if (_selectedAreaId != null) progress += 0.25;
    if (_sizeController.text.isNotEmpty &&
        _floorNumberController.text.isNotEmpty) {
      progress += 0.25;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Information Progress',
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
      // Add delay for sequential animation
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
                    // Save site information button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            widget.isProposeMode
                                ? _createSite
                                : _createOrUpdateSite,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          iconColor: theme.colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon: Icon(Icons.save),
                        label: Text(
                          widget.taskStatus == STATUS_DA_NHAN
                              ? 'Update site information'
                              : widget.isProposeMode
                              ? 'Propose Site'
                              : 'Save site information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    // Row with Continue and Close buttons
                    if (!widget.isProposeMode)
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.error,
                                side: BorderSide(
                                  color: theme.colorScheme.error,
                                ),
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
                                    'Close',
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
                          // Continue to full report button
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
                                'Continue Full Report',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
      ),
    );
  }
}
