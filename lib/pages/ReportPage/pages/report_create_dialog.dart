import 'package:flutter/material.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/ReportPage/CustomerSegmentModel/customer_segment.dart';
import 'package:siteplus_mb/utils/ReportPage/CustomerSegmentModel/customer_segment_provider.dart';
import 'package:siteplus_mb/utils/constants.dart';

import '../components/7_Attributes/convenience.dart';
import '../components/7_Attributes/customer_concentration.dart';
import '../components/7_Attributes/customer_model.dart';
import '../components/7_Attributes/customer_traffic.dart';
import '../components/7_Attributes/environmental_factors.dart';
import '../components/7_Attributes/site_area.dart';
import '../components/7_Attributes/visibility_obstruction.dart';

class ReportCreateDialog extends StatefulWidget {
  final String reportType;
  final String? siteCategory;
  final int? siteCategoryId;
  final int? siteId;
  final int? taskId;
  final Map<String, dynamic>? initialReportData;
  final bool isEditMode;

  const ReportCreateDialog({
    super.key,
    required this.reportType,
    this.siteCategory,
    this.siteCategoryId,
    this.siteId,
    required this.taskId,
    this.initialReportData,
    this.isEditMode = false,
  });

  @override
  _ReportCreateDialogState createState() => _ReportCreateDialogState();
}

class _ReportCreateDialogState extends State<ReportCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final _reportApiService = ApiService();
  late Map<String, dynamic> reportData;
  bool _isSubmitting = false;
  bool _isLoading = true;
  bool _isEditMode = false;
  List<Map<String, dynamic>> newAttributeValues = [];
  List<CustomerSegment> customerSegments = [];
  @override
  void initState() {
    super.initState();
    reportData =
        widget.initialReportData ??
        {
          'reportType': widget.reportType,
          'siteCategory': widget.siteCategory,
          'siteCategoryId': widget.siteCategoryId,
          'attributeValues': [],
          'changedAttributeValues': [], // Thêm để lưu các thay đổi
          'siteId': widget.siteId,
          'customerFlow': {
            'vehicles': [],
            'peakHours': [],
            'vehicleAdditionalInfo': {},
            'peakHourAdditionalInfo': {},
            'customVehicles': [],
            'customPeakHours': [],
          },
          'customerConcentration': {
            'customerTypes': [],
            'averageCustomers': null,
          },
          'customerModel': {
            'gender': null,
            'ageGroups': {'under18': 0, '18to30': 0, '31to45': 0, 'over45': 0},
            'income': null,
          },
          'siteArea': {
            'totalArea': '',
            'frontageWidth': '',
            'roadDistance': '',
            'shapes': null,
            'condition': null,
          },
          'environmentalFactors': {
            'airQuality': {'value': '', 'additionalInfo': ''},
            'naturalLight': {'value': '', 'additionalInfo': ''},
            'greenery': {'value': '', 'additionalInfo': ''},
            'waste': {'value': '', 'additionalInfo': ''},
            'surroundingStores': [],
            'customStores': [],
            'surroundingStores_additionalInfo': '',
            'ventilation': {
              'exists': null,
              'quality': null,
              'additionalInfo': '',
            },
            'airConditioning': {
              'exists': null,
              'quality': null,
              'additionalInfo': '',
            },
            'commonAmenities': {
              'amenity': null,
              'status': null,
              'additionalInfo': '',
            },
          },
          'visibilityAndObstruction': {
            'hasObstruction': null,
            'obstructionType': null,
            'obstructionLevel': null,
            'visibility': null,
            'obstructionAdditionalInfo': '',
            'obstructionLevelAdditionalInfo': '',
            'visibilityAdditionalInfo': '',
          },
          'convenience': {
            'terrain': {'value': '', 'additionalInfo': ''},
            'accessibility': {'value': '', 'additionalInfo': ''},
          },
          'newAttributeValues': [],
        };

    _isEditMode = widget.isEditMode;
    if (_isEditMode && widget.siteId != null) {
      _fetchAttributeValues();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch customer segments từ CustomerSegmentProvider
      await initCustomerSegments();
      final provider = CustomerSegmentProvider();
      customerSegments = await provider.getCustomerSegments();

      if (_isEditMode && widget.siteId != null) {
        await _fetchAttributeValues();
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  int _currentPage = 0;
  final List<String> _pageNames = [
    'Customer Flow',
    'Customer Concentration',
    'Customer Model',
    'Site Area',
    'Environmental Factors',
    'Visibility & Obstruction',
    'Convenience',
  ];

  Future<void> _fetchAttributeValues() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final attributeValues = await _reportApiService
          .getAttributeValuesBySiteId(widget.siteId!);
      debugPrint(
        'Fetched attributeValues in ReportCreateDialog: $attributeValues',
      );
      if (attributeValues.isNotEmpty) {
        setState(() {
          reportData['attributeValues'] = attributeValues;
          reportData['changedAttributeValues'] = [];
          _isEditMode = true;
          _updateSectionsFromAttributeValues(attributeValues);
        });
      }
    } catch (e) {
      debugPrint('Error fetching attribute values: $e');
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _updateSectionsFromAttributeValues(
    List<Map<String, dynamic>> attributeValues,
  ) {
    final Map<int, List<Map<String, dynamic>>> attributesByType = {};
    for (var attr in attributeValues) {
      final int attrId = attr['attributeId'];
      attributesByType.putIfAbsent(attrId, () => []).add(attr);
    }

    _updateCustomerFlowData(
      attributesByType[2] ?? [],
      attributesByType[3] ?? [],
    );
    _updateCustomerModelData(
      attributesByType[6] ?? [],
      attributesByType[7] ?? [],
      attributesByType[8] ?? [],
    );
  }

  void _updateCustomerFlowData(
    List<Map<String, dynamic>> vehicleAttrs,
    List<Map<String, dynamic>> peakHourAttrs,
  ) {
    final Map<String, dynamic> customerFlow = reportData['customerFlow'];

    final List<String> vehicles = [];
    final Map<String, List<String>> selectedVehicleCalculations = {};
    final Map<String, String> vehicleCalculationAmounts = {};

    // Danh sách các tùy chọn mặc định cho vehicle
    const List<String> defaultVehicleOptions = [
      TRANSPORTATION_MOTORCYCLE,
      TRANSPORTATION_CAR,
      TRANSPORTATION_BICYCLE,
      TRANSPORTATION_PEDESTRIAN,
    ];

    // Danh sách các tùy chọn mặc định cho peakHour
    const List<String> defaultPeakHourOptions = [
      PEAK_HOUR_MORNING,
      PEAK_HOUR_NOON,
      PEAK_HOUR_AFTERNOON,
      PEAK_HOUR_EVENING,
    ];

    for (var attr in vehicleAttrs) {
      final String vehicle = attr['value'];
      final String additionalInfo = attr['additionalInfo'] ?? '';

      if (!vehicles.contains(vehicle)) {
        vehicles.add(vehicle);
        selectedVehicleCalculations[vehicle] = [];
      }

      if (additionalInfo.isNotEmpty) {
        String calculation = 'theo giờ';
        if (additionalInfo.contains('chiếc/giờ')) {
          calculation = 'theo giờ';
        } else if (additionalInfo.contains('chiếc/ngày')) {
          calculation = 'theo ngày';
        } else if (additionalInfo.contains('chiếc/tuần')) {
          calculation = 'theo tuần';
        }

        if (!selectedVehicleCalculations[vehicle]!.contains(calculation)) {
          selectedVehicleCalculations[vehicle]!.add(calculation);
        }

        final RegExp regExp = RegExp(r'(\d+)');
        final match = regExp.firstMatch(additionalInfo);
        if (match != null) {
          vehicleCalculationAmounts['${vehicle}_$calculation'] =
              match.group(1) ?? '';
        }
      }
    }

    final List<String> peakHours = [];
    final Map<String, String> peakHourAdditionalInfo = {};

    for (var attr in peakHourAttrs) {
      final String peakHour = attr['value'];
      final String additionalInfo = attr['additionalInfo'] ?? '';

      if (!peakHours.contains(peakHour)) {
        peakHours.add(peakHour);
      }

      if (additionalInfo.isNotEmpty) {
        peakHourAdditionalInfo[peakHour] = additionalInfo;
      }
    }

    customerFlow['vehicles'] = vehicles;
    customerFlow['peakHours'] = peakHours;
    customerFlow['selectedVehicleCalculations'] = selectedVehicleCalculations;
    customerFlow['vehicleCalculationAmounts'] = vehicleCalculationAmounts;
    customerFlow['peakHourAdditionalInfo'] = peakHourAdditionalInfo;

    // Chỉ thêm vào customVehicles nếu không thuộc defaultVehicleOptions
    final customVehicles =
        vehicles.where((v) => !defaultVehicleOptions.contains(v)).toList();
    final customPeakHours =
        peakHours.where((p) => !defaultPeakHourOptions.contains(p)).toList();

    customerFlow['customVehicles'] = customVehicles;
    customerFlow['customPeakHours'] = customPeakHours;

    reportData['customerFlow'] = customerFlow;
  }

  void _updateCustomerModelData(
    List<Map<String, dynamic>> genderAttrs,
    List<Map<String, dynamic>> ageAttrs,
    List<Map<String, dynamic>> incomeAttrs,
  ) {
    final Map<String, dynamic> customerModel =
        reportData['customerModel'] ?? {};

    if (genderAttrs.isNotEmpty) {
      final genderAttr = genderAttrs.first;
      final String value = genderAttr['value'] ?? '';
      final String additionalInfo = genderAttr['additionalInfo'] ?? '';
      if (value.contains('nam')) {
        customerModel['gender'] = 'Nam';
      } else if (value.contains('nữ')) {
        customerModel['gender'] = 'Nữ';
      } else if (value.contains('đa dạng')) {
        customerModel['gender'] = 'Khác';
      }
      customerModel['genderInfo'] = additionalInfo;
    }

    if (ageAttrs.isNotEmpty) {
      final ageAttr = ageAttrs.first;
      final String additionalInfo = ageAttr['additionalInfo'] ?? '';
      final Map<String, int> ageGroups = {
        'under18': 0,
        '18to30': 0,
        '31to45': 0,
        'over45': 0,
      };
      final RegExp percentageRegex = RegExp(
        r'(\d+)% nhóm khách hàng có độ tuổi ([\w\s\-]+)',
      );
      final matches = percentageRegex.allMatches(additionalInfo);
      for (var match in matches) {
        final String percentage = match.group(1) ?? '0';
        final String ageRange = match.group(2) ?? '';
        if (ageRange.contains('dưới 18')) {
          ageGroups['under18'] = int.tryParse(percentage) ?? 0;
        } else if (ageRange.contains('18-30')) {
          ageGroups['18to30'] = int.tryParse(percentage) ?? 0;
        } else if (ageRange.contains('31-45')) {
          ageGroups['31to45'] = int.tryParse(percentage) ?? 0;
        } else if (ageRange.contains('trên 45')) {
          ageGroups['over45'] = int.tryParse(percentage) ?? 0;
        }
      }
      customerModel['ageGroups'] = ageGroups;
    }

    if (incomeAttrs.isNotEmpty) {
      final incomeAttr = incomeAttrs.first;
      final String additionalInfo = incomeAttr['additionalInfo'] ?? '';
      if (additionalInfo.contains('<5 triệu/tháng')) {
        customerModel['income'] = '<5 triệu/tháng';
      } else if (additionalInfo.contains('5-10 triệu/tháng')) {
        customerModel['income'] = '5-10 triệu/tháng';
      } else if (additionalInfo.contains('10-20 triệu/tháng')) {
        customerModel['income'] = '10-20 triệu/tháng';
      } else if (additionalInfo.contains('>20 triệu/tháng')) {
        customerModel['income'] = '>20 triệu/tháng';
      }
    }

    reportData['customerModel'] = customerModel;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Báo cáo mặt bằng',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Theme(
      data: theme.copyWith(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Báo cáo mặt bằng',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            if (_isSubmitting)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              )
            else
              TextButton.icon(
                icon: Icon(_isEditMode ? Icons.save : Icons.create),
                label: Text(_isEditMode ? 'Lưu' : 'Tạo mới'),
                onPressed: _submitForm,
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              CustomerFlowSection(
                reportData: reportData,
                setState: (fn) {
                  if (mounted) setState(fn);
                },
                theme: theme,
                siteId: widget.siteId ?? 0,
              ),
              CustomerConcentrationSection(
                reportData: reportData,
                setState: (fn) {
                  if (mounted) setState(fn);
                },
                theme: theme,
                siteId: widget.siteId ?? 0,
                customerSegments: customerSegments,
              ),
              CustomerModelSection(
                reportData: reportData,
                setState: (fn) {
                  if (mounted) setState(fn);
                },
                theme: theme,
              ),
              SiteAreaSection(
                reportData: reportData,
                setState: (fn) {
                  if (mounted) setState(fn);
                },
                theme: theme,
              ),
              EnvironmentalFactorsSection(
                reportData: reportData,
                setState: (fn) {
                  if (mounted) setState(fn);
                },
                theme: theme,
              ),
              VisibilityObstructionSection(
                reportData: reportData,
                setState: (fn) {
                  if (mounted) setState(fn);
                },
                theme: theme,
              ),
              ConvenienceSection(
                reportData: reportData,
                setState: (fn) {
                  if (mounted) setState(fn);
                },
                theme: theme,
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed:
                      _currentPage > 0
                          ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                          : null,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  child: const Text('Trước'),
                ),
                Text(
                  '${_currentPage + 1}/${_pageNames.length}',
                  style: theme.textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed:
                      _currentPage < _pageNames.length - 1
                          ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                          : null,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  child: const Text('Tiếp'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final List<Map<String, dynamic>> changedAttributeValues =
          List<Map<String, dynamic>>.from(
            reportData['changedAttributeValues'] ?? [],
          );
      final List<Map<String, dynamic>> newAttributeValues =
          List<Map<String, dynamic>>.from(
            reportData['newAttributeValues'] ?? [],
          );

      if (changedAttributeValues.isEmpty &&
          newAttributeValues.isEmpty &&
          _isEditMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Không có thay đổi hoặc giá trị mới nào để cập nhật.',
            ),
          ),
        );
        return;
      }

      if (reportData['attributeValues'] == null ||
          (reportData['attributeValues'] as List).isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập ít nhất một giá trị thuộc tính'),
          ),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        bool success = true;
        if (_isEditMode) {
          if (changedAttributeValues.isNotEmpty) {
            final List<Map<String, dynamic>> updateData =
                changedAttributeValues.map((attr) {
                  return {
                    'id': attr['id'],
                    'value': attr['value'],
                    'additionalInfo': attr['additionalInfo'],
                  };
                }).toList();
            debugPrint('Sending update data: $updateData');
            success = await _reportApiService.updateReport(
              widget.siteId!,
              updateData,
            );
            if (!success) {
              debugPrint('Update failed for changedAttributeValues');
            }
          }
          if (newAttributeValues.isNotEmpty) {
            final List<Map<String, dynamic>> createData = [
              {'attributeValues': newAttributeValues},
            ];
            debugPrint('Sending create data: $createData');
            success =
                success && await _reportApiService.createReport(createData);
            if (!success) {
              debugPrint('Create failed for newAttributeValues');
            }
          }
        } else {
          final List<Map<String, dynamic>> apiData = [
            {
              'attributeValues': List<Map<String, dynamic>>.from(
                reportData['attributeValues'] as List,
              ),
            },
          ];
          debugPrint('Sending create data for new report: $apiData');
          success = await _reportApiService.createReport(apiData);
          if (success && widget.siteId != null) {
            final statusSiteUpdated = await _reportApiService.updateSiteStatus(
              widget.siteId!,
              3,
            );
            debugPrint('Task ID before updating status: ${widget.taskId}');
            final statusTaskUpdated = await _reportApiService.updateTaskStatus(
              widget.taskId!,
              3,
            );
            if (statusSiteUpdated && statusTaskUpdated) {
              debugPrint('Site and Task status updated to "Chờ phê duyệt" (3)');
            } else {
              debugPrint('Failed to update site/task status');
            }
          }
        }

        setState(() {
          _isSubmitting = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditMode
                    ? 'Báo cáo đã được cập nhật'
                    : 'Báo cáo đã được gửi thành công',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditMode
                    ? 'Cập nhật báo cáo thất bại'
                    : 'Gửi báo cáo thất bại',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        debugPrint('Error submitting form: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
