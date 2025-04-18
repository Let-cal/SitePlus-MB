import 'package:flutter/material.dart';
import 'package:siteplus_mb/components/help_dialog.dart';
import 'package:siteplus_mb/components/loading_overlay.dart';
import 'package:siteplus_mb/pages/ReportPage/components/site_deal_confirmation_dialog.dart';
import 'package:siteplus_mb/pages/ReportPage/pages/deal_section.dart';
import 'package:siteplus_mb/pages/SiteDealPage/pages/create_site_deal_dialog.dart';
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
  final double? siteSize;

  const ReportCreateDialog({
    super.key,
    required this.reportType,
    this.siteCategory,
    this.siteCategoryId,
    this.siteId,
    required this.taskId,
    this.initialReportData,
    this.isEditMode = false,
    this.siteSize,
  });

  @override
  _ReportCreateDialogState createState() => _ReportCreateDialogState();
}

class _ReportCreateDialogState extends State<ReportCreateDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final _reportApiService = ApiService();
  late TabController _tabController;
  late Map<String, dynamic> reportData;
  late Map<String, dynamic> dealData;
  bool _isSubmitting = false;
  bool _isLoading = true;
  bool _isEditMode = false;
  List<Map<String, dynamic>> newAttributeValues = [];
  List<CustomerSegment> customerSegments = [];

  // Thêm biến để lưu ScaffoldMessengerState
  // ignore: unused_field
  late ScaffoldMessengerState _scaffoldMessenger;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _isEditMode = widget.isEditMode;

    final defaultReportData = {
      'reportType': widget.reportType,
      'siteCategory': widget.siteCategory,
      'siteCategoryId': widget.siteCategoryId,
      'attributeValues': [],
      'changedAttributeValues': [],
      'siteId': widget.siteId,
      'customerFlow': {
        'vehicles': [],
        'peakHours': [],
        'vehicleAdditionalInfo': {},
        'peakHourAdditionalInfo': {},
        'customVehicles': [],
        'customPeakHours': [],
      },
      'customerConcentration': {'customerTypes': [], 'averageCustomers': null},
      'customerModel': {
        'gender': null,
        'ageGroups': {'under18': 0, '18to30': 0, '31to45': 0, 'over45': 0},
        'income': null,
      },
      'siteArea': {
        'totalArea': widget.isEditMode ? '' : (widget.siteSize?.toInt() ?? ''),
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
        'ventilation': {'exists': null, 'quality': null, 'additionalInfo': ''},
        'airConditioning': {
          'exists': null,
          'quality': null,
          'additionalInfo': '',
        },
        'commonAmenities': {
          'hasCommonAmenities': null,
          'selectedAmenities': [],
          'selectedAmenityStatuses': {},
          'customAmenities': [],
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
    reportData = {...defaultReportData, ...?widget.initialReportData};
    dealData = {
      'siteId': widget.siteId,
      'proposedPrice': '',
      'leaseTerm': '',
      'deposit': '',
      'depositMonth': '',
      'additionalTerms': '',
      'status': '',
    };

    _fetchCustomerSegments();
    if (_isEditMode && widget.siteId != null) {
      _fetchData();
    } else {
      setState(() => _isLoading = false);
    }

    // Nếu site.status == 7, mặc định hiển thị tab "Thương Lượng Mặt Bằng"
    if (widget.initialReportData?['siteStatus'] == 7 ||
        widget.initialReportData?['siteStatus'] == 4) {
      _tabController.index = 0;
    }
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
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      if (_isEditMode && widget.siteId != null) {
        await _fetchAttributeValues();
        if (widget.initialReportData?['siteStatus'] == 4 ||
            widget.initialReportData?['siteStatus'] == 7) {
          await _fetchSiteDeal();
        }
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    } finally {
      setState(
        () => _isLoading = false,
      ); // Chỉ tắt loading khi tất cả hoàn thành
    }
  }

  Future<void> _fetchCustomerSegments() async {
    try {
      await initCustomerSegments();
      final provider = CustomerSegmentProvider();
      customerSegments = await provider.getCustomerSegments();
    } catch (e) {
      debugPrint('Error fetching customer segments: $e');
    }
  }

  Future<Map<String, dynamic>?> _fetchSiteDealBySiteId() async {
    try {
      final apiService = ApiService();
      final siteDeals = await apiService.getSiteDealBySiteId(widget.siteId!);

      // Find the first site deal with status == 0 (Mới tạo)
      if (siteDeals.isNotEmpty) {
        final siteDealWithStatus0 = siteDeals.firstWhere(
          (deal) => deal['status'] == 0,
          orElse: () => <String, dynamic>{},
        );

        if (siteDealWithStatus0.isNotEmpty) {
          return siteDealWithStatus0;
        }
      }
      return null; // Return null if no site deal with status == 0 is found
    } catch (e) {
      debugPrint('Error fetching site deal: $e');
      return null;
    }
  }

  Future<void> _fetchSiteDeal() async {
    try {
      final siteDeals = await _reportApiService.getSiteDealBySiteId(
        widget.siteId!,
      );

      // Find the first site deal with status == 0 (Mới tạo)
      if (siteDeals.isNotEmpty) {
        final siteDealWithStatus0 = siteDeals.firstWhere(
          (deal) => deal['status'] == 0,
          orElse: () => siteDeals.first,
        );

        if (siteDealWithStatus0.isNotEmpty) {
          setState(() {
            dealData = {
              'id': siteDealWithStatus0['id'],
              'siteId': widget.siteId,
              'proposedPrice': siteDealWithStatus0['proposedPrice'].toString(),
              'leaseTerm': siteDealWithStatus0['leaseTerm'],
              'deposit': siteDealWithStatus0['deposit'].toString(),
              'depositMonth':
                  siteDealWithStatus0['depositMonth']?.toString() ?? '',
              'additionalTerms': siteDealWithStatus0['additionalTerms'],
              'status': siteDealWithStatus0['status'] ?? 0,
            };
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching site deal: $e');
    }
  }

  Future<void> _fetchAttributeValues() async {
    try {
      debugPrint(
        'Bắt đầu gọi API getAttributeValuesBySiteId với siteId: ${widget.siteId}',
      );
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
          debugPrint(
            'Updated reportData[attributeValues]: ${reportData['attributeValues']}',
          );
        });
      }
    } catch (e) {
      debugPrint('Error fetching attribute values: $e');
    }
  }

  // Hàm kiểm tra tất cả steps có value
  bool _validateAllSteps() {
    final List<Map<String, dynamic>> attributeValues =
        List<Map<String, dynamic>>.from(reportData['attributeValues'] ?? []);
    final List<Map<String, dynamic>> newAttributeValues =
        List<Map<String, dynamic>>.from(reportData['newAttributeValues'] ?? []);

    // Gộp attributeValues và newAttributeValues để kiểm tra
    final List<Map<String, dynamic>> combinedAttributeValues = [
      ...attributeValues,
      ...newAttributeValues,
    ];

    final missingFields = <String>[];
    final int? siteCategoryId = widget.siteCategoryId;

    final Map<String, List<int>> requiredAttributesByStep = {
      'Customer Flow': [2, 3],
      'Customer Concentration': [4, 5],
      'Customer Model': [6, 7, 8],
      'Site Area': siteCategoryId == 2 ? [9, 10, 11, 34, 35] : [9, 10, 11],
      'Environmental Factors':
          siteCategoryId == 1
              ? [12, 13, 14, 15, 16, 24, 26, 27]
              : [12, 13, 14, 15, 16],
      'Visibility & Obstruction': siteCategoryId == 2 ? [17, 18] : [17, 18, 28],
      'Convenience': siteCategoryId == 2 ? [19, 20] : [19, 20, 29],
    };

    final Map<String, String> stepDisplayNames = {
      'Customer Flow': 'Lưu lượng khách hàng',
      'Customer Concentration': 'Mật độ khách hàng',
      'Customer Model': 'Mô hình khách hàng',
      'Site Area': 'Mặt bằng',
      'Environmental Factors': 'Yếu tố môi trường',
      'Visibility & Obstruction': 'Tầm nhìn & Cản trở',
      'Convenience': 'Tiện ích',
    };

    requiredAttributesByStep.forEach((step, requiredIds) {
      bool isStepValid = requiredIds.every(
        (id) => combinedAttributeValues.any(
          (attr) =>
              attr['attributeId'] == id &&
              attr['value'] != null &&
              attr['value'].toString().isNotEmpty,
        ),
      );
      if (!isStepValid) {
        missingFields.add(stepDisplayNames[step]!);
      }
    });

    if (missingFields.isNotEmpty) {
      if (mounted) {
        _scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Vui lòng điền đầy đủ: ${missingFields.join(', ')}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return false;
    }

    return true;
  }

  bool _validateDealData() {
    final missingFields = <String>[];
    if (dealData['proposedPrice'].isEmpty) missingFields.add('Giá đề xuất');
    if (dealData['leaseTerm'].isEmpty) missingFields.add('Thời hạn thuê');
    if (dealData['deposit'].isEmpty) missingFields.add('Tiền đặt cọc');
    if (dealData['depositMonth'].isEmpty)
      missingFields.add('Số tháng đặt cọc');

    if (missingFields.isNotEmpty) {
      if (mounted) {
        _scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Vui lòng điền đầy đủ: ${missingFields.join(', ')}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return false;
    }
    return true;
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
    _updateCustomerConcentrationData(
      attributesByType[4] ?? [], // customerTypes
      attributesByType[5] ?? [], // customerCount
    );
    _updateCustomerModelData(
      attributesByType[6] ?? [],
      attributesByType[7] ?? [],
      attributesByType[8] ?? [],
    );
  }

  void _updateCustomerConcentrationData(
    List<Map<String, dynamic>> customerTypeAttrs,
    List<Map<String, dynamic>> customerCountAttrs,
  ) {
    final Map<String, dynamic> customerConcentration =
        reportData['customerConcentration'];

    // Cập nhật customerTypes
    final List<String> customerTypes = [];
    final Map<String, String> customerTypeAdditionalInfo = {};
    for (var attr in customerTypeAttrs) {
      final String type = attr['value'];
      final String additionalInfo = attr['additionalInfo'] ?? '';
      if (!customerTypes.contains(type)) {
        customerTypes.add(type);
      }
      if (additionalInfo.isNotEmpty) {
        customerTypeAdditionalInfo[type] = additionalInfo;
      }
    }

    // Cập nhật averageCustomers
    String? averageCustomers;
    if (customerCountAttrs.isNotEmpty) {
      final attr = customerCountAttrs.first;
      final String additionalInfo = attr['additionalInfo'] ?? '';
      final RegExp regExp = RegExp(r'(\d+)');
      final match = regExp.firstMatch(additionalInfo);
      if (match != null) {
        averageCustomers = match.group(1);
      }
    }

    customerConcentration['customerTypes'] = customerTypes;
    customerConcentration['customerTypeAdditionalInfo'] =
        customerTypeAdditionalInfo;
    customerConcentration['averageCustomers'] = averageCustomers;

    reportData['customerConcentration'] = customerConcentration;
  }

  void _updateCustomerFlowData(
    List<Map<String, dynamic>> vehicleAttrs,
    List<Map<String, dynamic>> peakHourAttrs,
  ) {
    final Map<String, dynamic> customerFlow = reportData['customerFlow'];

    final List<String> vehicles = [];
    final Map<String, List<String>> selectedVehicleCalculations = {};
    final Map<String, String> vehicleCalculationAmounts = {};

    const List<String> defaultVehicleOptions = [
      TRANSPORTATION_MOTORCYCLE,
      TRANSPORTATION_CAR,
      TRANSPORTATION_BICYCLE,
      TRANSPORTATION_PEDESTRIAN,
    ];

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

    if (peakHourAttrs.isNotEmpty) {
      // Xử lý dữ liệu peakHours (có thể gộp hoặc chưa gộp)
      final firstAttr = peakHourAttrs.first;
      final String value = firstAttr['value'] ?? '';
      final String additionalInfo = firstAttr['additionalInfo'] ?? '';

      if (value.contains(' và ')) {
        // Dữ liệu đã gộp
        peakHours.addAll(value.split(' và '));
      } else {
        // Dữ liệu chưa gộp
        for (var attr in peakHourAttrs) {
          final String peakHour = attr['value'];
          if (!peakHours.contains(peakHour)) {
            peakHours.add(peakHour);
          }
          if (additionalInfo.isNotEmpty) {
            peakHourAdditionalInfo[peakHour] = additionalInfo;
          }
        }
      }

      if (additionalInfo.isNotEmpty) {
        for (var peakHour in peakHours) {
          peakHourAdditionalInfo[peakHour] = additionalInfo;
        }
      }
    }

    customerFlow['vehicles'] = vehicles;
    customerFlow['peakHours'] = peakHours;
    customerFlow['selectedVehicleCalculations'] = selectedVehicleCalculations;
    customerFlow['vehicleCalculationAmounts'] = vehicleCalculationAmounts;
    customerFlow['peakHourAdditionalInfo'] = peakHourAdditionalInfo;

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

    // Gender
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

    // Age groups
    if (ageAttrs.isNotEmpty) {
      final Map<String, int> ageGroups = {
        'under18': 0,
        '18to30': 0,
        '31to45': 0,
        'over45': 0,
      };
      for (var attr in ageAttrs) {
        String additionalInfo = attr['additionalInfo'] ?? '';
        final RegExp percentageRegex = RegExp(
          r'(\d+)% nhóm khách hàng có độ tuổi (.+)',
        );
        final match = percentageRegex.firstMatch(additionalInfo);
        if (match != null) {
          final String percentage = match.group(1) ?? '0';
          final String ageRange = match.group(2) ?? '';
          int percentValue = int.tryParse(percentage) ?? 0;
          switch (ageRange) {
            case 'dưới 18 tuổi':
              ageGroups['under18'] = percentValue;
              break;
            case '18-30 tuổi':
              ageGroups['18to30'] = percentValue;
              break;
            case '31-45 tuổi':
              ageGroups['31to45'] = percentValue;
              break;
            case 'trên 45 tuổi':
              ageGroups['over45'] = percentValue;
              break;
          }
        } else {
          // Dữ liệu cũ
          RegExp oldFormatRegex = RegExp(
            r'(\d+)% nhóm khách hàng có độ tuổi (dưới 18|18-30|31-45|trên 45)',
          );
          Iterable<RegExpMatch> matches = oldFormatRegex.allMatches(
            additionalInfo,
          );
          for (var match in matches) {
            String percentage = match.group(1) ?? '0';
            String ageRange = match.group(2) ?? '';
            int percentValue = int.tryParse(percentage) ?? 0;
            switch (ageRange) {
              case 'dưới 18':
                ageGroups['under18'] = percentValue;
                break;
              case '18-30':
                ageGroups['18to30'] = percentValue;
                break;
              case '31-45':
                ageGroups['31to45'] = percentValue;
                break;
              case 'trên 45':
                ageGroups['over45'] = percentValue;
                break;
            }
          }
        }
      }
      customerModel['ageGroups'] = ageGroups;
    }

    // Income
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
    return LoadingOverlay(
      isLoading:
          _isSubmitting ||
          _isLoading, // Hiển thị overlay khi đang loading hoặc submitting
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.initialReportData?['siteStatus'] == 7 ||
                    widget.initialReportData?['siteStatus'] == 4
                ? 'Site Management'
                : 'Site Report',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom:
              (widget.initialReportData?['siteStatus'] == 7 ||
                      widget.initialReportData?['siteStatus'] == 4)
                  ? TabBar(
                    controller: _tabController,
                    indicatorColor: theme.colorScheme.primary,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurface
                        .withOpacity(0.6),
                    tabs: const [Tab(text: 'Negotiate'), Tab(text: 'Report')],
                  )
                  : null,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed:
                  () => HelpDialog.show(
                    context,
                    content:
                        widget.initialReportData?['siteStatus'] == 7
                            ? 'Fill in the negotiation and report information. You can save the draft for the next survey or click "Send Report" to send all the data.'
                            : widget.initialReportData?['siteStatus'] == 8
                            ? 'Fill in all the information for the steps to create the report. Click "Send Report" to send all the data to the site negotiation stage.'
                            : widget.initialReportData?['siteStatus'] == 4
                            ? 'Fill in all the information for the steps to create the report. Click "Send Report" to send all the data.'
                            : 'Fill in all the information for the steps to create the report. You can save the draft for the next survey.',
                  ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child:
              _isLoading
                  ? const SizedBox.shrink()
                  : (widget.initialReportData?['siteStatus'] == 7 ||
                      widget.initialReportData?['siteStatus'] == 4)
                  ? TabBarView(
                    controller: _tabController,
                    children: [_buildDealTab(theme), _buildReportTab(theme)],
                  )
                  : _buildReportTab(theme),
        ),
        bottomNavigationBar: _buildBottomBar(theme),
      ),
    );
  }

  Widget _buildDealTab(ThemeData theme) {
    return DealSection(dealData: dealData, setState: setState, theme: theme);
  }

  Widget _buildReportTab(ThemeData theme) {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) => setState(() => _currentPage = index),
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
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!(widget.initialReportData?['siteStatus'] == 7 ||
              widget.initialReportData?['siteStatus'] == 4))
            Row(
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
                  child: const Text('Back'),
                ),
                Text('${_currentPage + 1}/${_pageNames.length}'),
                TextButton(
                  onPressed:
                      _currentPage < _pageNames.length - 1
                          ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                          : null,
                  child: const Text('Next'),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (!_isEditMode || widget.initialReportData?['siteStatus'] == 8)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : _saveDraft,
                    icon: const Icon(Icons.note),
                    label: const Text('Save Draft'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              if (!_isEditMode || widget.initialReportData?['siteStatus'] == 8)
                const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitForm,
                  icon: Icon(_isEditMode ? Icons.send : Icons.create),
                  label: Text(_isEditMode ? 'Send Report' : 'Create Report'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    iconColor: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          // Thêm nút "Continue to Create Site Deal" nếu siteStatus == 2
          if (widget.initialReportData?['siteStatus'] == 2) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, // Full width
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _continueToCreateSiteDeal,
                child: const Text('Continue to Create Site Deal'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Hàm xử lý khi nhấn nút "Continue to Create Site Deal"
  Future<void> _continueToCreateSiteDeal() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if ((widget.initialReportData?['siteStatus'] == 2) &&
          !_validateAllSteps()) {
        return;
      }
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Confirmation'),
              content: const Text(
                'If you continue, you will be redirected to the page to create a site deal for this site with the purpose of sending the report directly to the Area-Manager. Are you sure?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Continue'),
                ),
              ],
            ),
      );

      if (confirm == true) {
        setState(() => _isSubmitting = true);
        try {
          final List<Map<String, dynamic>> newAttributeValues =
              List<Map<String, dynamic>>.from(
                reportData['newAttributeValues'] ?? [],
              );

          if (newAttributeValues.isNotEmpty) {
            final List<Map<String, dynamic>> createData = [
              {'attributeValues': newAttributeValues},
            ];
            final success = await _reportApiService.createReport(createData);
            if (success) {
              // Cập nhật siteStatus lên 7
              final siteStatusUpdated = await _reportApiService
                  .updateSiteStatus(widget.siteId!, 7);
              if (siteStatusUpdated) {
                // Đóng dialog hiện tại
                Navigator.of(context).pop();
                // Mở dialog CreateSiteDealDialog
                showDialog(
                  context: context,
                  builder:
                      (context) => CreateSiteDealDialog(
                        siteId: widget.siteId,
                        siteStatus: 7,
                      ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update site status'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to create report'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No new attribute values to create'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        } finally {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  // Hàm xử lý lưu bản nháp
  Future<void> _saveDraft() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final List<Map<String, dynamic>> changedAttributeValues =
          List<Map<String, dynamic>>.from(
            reportData['changedAttributeValues'] ?? [],
          );

      final List<Map<String, dynamic>> newAttributeValues =
          List<Map<String, dynamic>>.from(
            reportData['newAttributeValues'] ?? [],
          );

      bool success = true;

      if (_isEditMode) {
        // For edit mode, update existing values and create new ones
        if (changedAttributeValues.isNotEmpty) {
          final List<Map<String, dynamic>> updateData =
              changedAttributeValues.map((attr) {
                return {
                  'id': attr['id'],
                  'value': attr['value'],
                  'additionalInfo': attr['additionalInfo'],
                };
              }).toList();
          success = await _reportApiService.updateReport(
            widget.siteId!,
            updateData,
          );
        }

        if (newAttributeValues.isNotEmpty) {
          final List<Map<String, dynamic>> createData = [
            {'attributeValues': newAttributeValues},
          ];
          success = success && await _reportApiService.createReport(createData);
        }
      } else {
        // For new report, create all values
        if (newAttributeValues.isNotEmpty) {
          final List<Map<String, dynamic>> apiData = [
            {'attributeValues': newAttributeValues},
          ];
          success = success && await _reportApiService.createReport(apiData);
        }
      }

      // Always update site status to 8 (Bản nháp) when saving draft
      if (success && widget.siteId != null) {
        success = await _reportApiService.updateSiteStatus(widget.siteId!, 8);
      }

      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu bản nháp thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi lưu bản nháp: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if ((widget.initialReportData?['siteStatus'] == 7 ||
              widget.initialReportData?['siteStatus'] == 4) &&
          (!_validateDealData() || !_validateAllSteps())) {
        return; // Bắt buộc điền đầy đủ cả Deal và Report cho status 4 và 7
      } else if (!(widget.initialReportData?['siteStatus'] == 7 ||
              widget.initialReportData?['siteStatus'] == 4) &&
          !_validateAllSteps()) {
        return; // Chỉ cần validate report cho các status khác
      }

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
        if (!_validateAllSteps()) {
          return;
        }
        if (mounted) {
          _scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Không có thay đổi hoặc giá trị mới nào để cập nhật.',
              ),
            ),
          );
        }
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        bool success = true;
        int newSiteStatus;
        int? newTaskStatus;

        // Xử lý chung cho siteStatus == 4 và siteStatus == 7
        if (widget.initialReportData?['siteStatus'] == 4 ||
            widget.initialReportData?['siteStatus'] == 7) {
          // Chuẩn bị dữ liệu site deal
          final updateDealData = {
            'proposedPrice': double.tryParse(dealData['proposedPrice']) ?? 0,
            'leaseTerm': dealData['leaseTerm'],
            'deposit': double.tryParse(dealData['deposit']) ?? 0,
            'depositMonth': dealData['depositMonth'],
            'additionalTerms': dealData['additionalTerms'],
            'status': dealData['status'] ?? 0,
            'updatedAt': DateTime.now().toUtc().toIso8601String(),
          };

          if (dealData['id'] == null) {
            // Tạo mới site deal nếu chưa có
            success = await _reportApiService.createSiteDeal(dealData);
          } else {
            // Cập nhật site deal nếu đã có
            success = await _reportApiService.updateSiteDeal(
              dealData['id'],
              updateDealData,
            );
          }

          if (!success) {
            if (mounted) {
              _scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Thao tác với site deal thất bại'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            setState(() => _isSubmitting = false);
            return;
          }

          // Cập nhật hoặc tạo attribute values
          if (changedAttributeValues.isNotEmpty) {
            final List<Map<String, dynamic>> updateData =
                changedAttributeValues.map((attr) {
                  return {
                    'id': attr['id'],
                    'value': attr['value'],
                    'additionalInfo': attr['additionalInfo'],
                  };
                }).toList();
            success = await _reportApiService.updateReport(
              widget.siteId!,
              updateData,
            );
          }

          if (newAttributeValues.isNotEmpty) {
            final List<Map<String, dynamic>> createData = [
              {'attributeValues': newAttributeValues},
            ];
            success =
                success && await _reportApiService.createReport(createData);
          }

          newSiteStatus = 3; // Chờ phê duyệt
          newTaskStatus = 3;
        }
        // Giữ nguyên logic cũ cho các status khác
        else if (_isEditMode) {
          if (widget.initialReportData?['siteStatus'] == 8) {
            newSiteStatus = 7; // Đang thương lượng
            newTaskStatus = null;
          } else {
            newSiteStatus = 7; // Default cho edit mode
            newTaskStatus = null;
          }

          // Update existing attribute values
          if (changedAttributeValues.isNotEmpty) {
            final List<Map<String, dynamic>> updateData =
                changedAttributeValues.map((attr) {
                  return {
                    'id': attr['id'],
                    'value': attr['value'],
                    'additionalInfo': attr['additionalInfo'],
                  };
                }).toList();
            success = await _reportApiService.updateReport(
              widget.siteId!,
              updateData,
            );
          }

          // Create new attribute values
          if (newAttributeValues.isNotEmpty) {
            final List<Map<String, dynamic>> createData = [
              {'attributeValues': newAttributeValues},
            ];
            success =
                success && await _reportApiService.createReport(createData);
          }
        } else {
          if (widget.initialReportData?['siteStatus'] == 2) {
            final siteDeal = await _fetchSiteDealBySiteId();
            if (siteDeal != null) {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => SiteDealConfirmationDialog(
                      siteDeal: siteDeal,
                      siteId: widget.siteId!,
                      siteCategoryId: widget.siteCategoryId!,
                    ),
              );
              if (confirm != true) {
                setState(() {
                  _isSubmitting = false;
                });
                return; // Không tiếp tục nếu người dùng chọn "Đóng"
              }
              newSiteStatus = 3; // Chờ phê duyệt
              newTaskStatus = 3;
            } else {
              newSiteStatus = 7; // Đang thương lượng
            }
          } else {
            newSiteStatus =
                7; // Đang thương lượng mặc định cho các trường hợp khác
          }
          newTaskStatus = null;

          if (newAttributeValues.isNotEmpty) {
            final List<Map<String, dynamic>> createData = [
              {'attributeValues': newAttributeValues},
            ];
            success =
                success && await _reportApiService.createReport(createData);
          }
        }

        // Cập nhật site status nếu thành công
        if (success && widget.siteId != null) {
          final siteStatusUpdated = await _reportApiService.updateSiteStatus(
            widget.siteId!,
            newSiteStatus,
          );
          if (newTaskStatus != null && widget.taskId != null) {
            final taskStatusUpdated = await _reportApiService.updateTaskStatus(
              widget.taskId!,
              newTaskStatus,
            );
            success = success && siteStatusUpdated && taskStatusUpdated;
          } else {
            success = success && siteStatusUpdated;
          }
        }

        setState(() {
          _isSubmitting = false;
        });

        if (success) {
          if (mounted) {
            _scaffoldMessenger.showSnackBar(
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
          }
        } else {
          if (mounted) {
            _scaffoldMessenger.showSnackBar(
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
        }
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        debugPrint('Error submitting form: $e');
        if (mounted) {
          _scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Đã xảy ra lỗi: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
