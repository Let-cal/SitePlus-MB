import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:siteplus_mb/service/api_service.dart';

class ReportViewDialog extends StatefulWidget {
  final Map<String, dynamic> siteDeal;
  final List<Map<String, dynamic>> attributeValues;
  final int siteCategoryId;
  final int siteId;

  const ReportViewDialog({
    super.key,
    required this.siteDeal,
    required this.attributeValues,
    required this.siteCategoryId,
    required this.siteId,
  });

  @override
  _ReportViewDialogState createState() => _ReportViewDialogState();
}

class _ReportViewDialogState extends State<ReportViewDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _dealType = '';
  String _leaseTermInput = '';
  List<Map<String, dynamic>> _attributes = [];
  List<Map<String, dynamic>> _images = [];
  List<Map<String, dynamic>> _processedAttributeValues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeDealType();
    _fetchData();
  }

  void _initializeDealType() {
    final leaseTerm = widget.siteDeal['leaseTerm'] ?? '';
    if (leaseTerm.contains('Mặt bằng chuyển nhượng')) {
      _dealType = 'Mặt bằng chuyển nhượng';
      _leaseTermInput = '';
    } else if (leaseTerm.contains('Mặt bằng cho thuê')) {
      _dealType = 'Mặt bằng cho thuê';
      _leaseTermInput = leaseTerm.replaceFirst(
        'Mặt bằng cho thuê - Thời hạn ',
        '',
      );
    } else {
      _dealType = 'Không xác định';
      _leaseTermInput = '';
    }
  }

  Future<void> _fetchData() async {
    final apiService = ApiService();
    try {
      _attributes = await apiService.getAllAttributes();
      _processedAttributeValues = _processAttributeValues(
        widget.attributeValues,
      );
      try {
        _images = await apiService.getSiteImages(widget.siteId);
      } catch (e) {
        debugPrint('Lỗi lấy ảnh site: $e');
        _images = [];
      }
    } catch (e) {
      debugPrint('Lỗi khi tải dữ liệu: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _processAttributeValues(
    List<Map<String, dynamic>> attributeValues,
  ) {
    final Map<int, List<Map<String, dynamic>>> groupedByAttrId = {};
    for (var attr in attributeValues) {
      final attrId = attr['attributeId'];
      groupedByAttrId.putIfAbsent(attrId, () => []).add(attr);
    }

    final List<Map<String, dynamic>> processedValues = [];
    groupedByAttrId.forEach((attrId, values) {
      if (attrId == 3) {
        final combinedValue = values.map((v) => v['value']).join(' và ');
        final latestValue = values.reduce(
          (a, b) =>
              DateTime.parse(
                    a['updatedAt'],
                  ).isAfter(DateTime.parse(b['updatedAt']))
                  ? a
                  : b,
        );
        processedValues.add({
          'id': latestValue['id'],
          'attributeId': attrId,
          'siteId': latestValue['siteId'],
          'value': combinedValue,
          'additionalInfo': latestValue['additionalInfo'],
          'createdAt': latestValue['createdAt'],
          'updatedAt': latestValue['updatedAt'],
        });
      } else {
        processedValues.addAll(values);
      }
    });

    return processedValues;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: theme.colorScheme.surface,
            title: const Text(
              'Chi Tiết Báo Cáo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: theme.colorScheme.primary,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(
                0.6,
              ),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              labelPadding: EdgeInsets.symmetric(horizontal: 2),
              tabs: const [
                Tab(text: 'Thương Lượng'),
                Tab(text: 'Báo Cáo'),
                Tab(text: 'Hình Ảnh'),
              ],
            ),
          ),
          body:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDealTab(),
                      _buildReportTab(),
                      _buildImagesTab(),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildDealTab() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin thương lượng',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              _buildDealInfoRow('Loại mặt bằng', _dealType, Icons.store),
              if (_dealType == 'Mặt bằng cho thuê')
                _buildDealInfoRow(
                  'Thời hạn thuê',
                  _leaseTermInput,
                  Icons.calendar_today,
                ),
              _buildDealInfoRow(
                'Giá đề xuất',
                '${widget.siteDeal['proposedPrice'].toInt()} VND',
                Icons.money,
              ),
              _buildDealInfoRow(
                'Tiền đặt cọc',
                '${widget.siteDeal['deposit'].toInt()} VND',
                Icons.account_balance_wallet,
              ),
              _buildDealInfoRow(
                'Điều khoản bổ sung',
                widget.siteDeal['additionalTerms']?.toString() ?? 'Không có',
                Icons.notes,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDealInfoRow(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTab() {
    final theme = Theme.of(context);
    List<Widget> sections = [];

    sections.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          'Báo cáo mặt bằng',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.start,
        ),
      ),
    );

    if (_processedAttributeValues.isEmpty) {
      sections.add(
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Không có dữ liệu báo cáo',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.start,
          ),
        ),
      );
    } else {
      // Explicitly type the attributeMap as Map<int, String>
      final Map<int, String> attributeMap = Map.fromEntries(
        _attributes.map((attr) {
          final int id = attr['id'] as int; // Ensure id is an int
          final String name = attr['name'] as String; // Ensure name is a String
          return MapEntry(id, name);
        }),
      );

      debugPrint('Attribute Map: $attributeMap'); // Debug logging

      var reportSections = [
        CustomReportSection(
          title: 'Lưu lượng khách hàng',
          attributeIds: [2, 3],
          icon: Icons.directions_car,
          processedAttributeValues: _processedAttributeValues,
          attributeMap: attributeMap,
          buildAgeGroupInfo: _buildAgeGroupInfo,
        ),
        CustomReportSection(
          title: 'Mật độ khách hàng',
          attributeIds: [4, 5],
          icon: Icons.group,
          processedAttributeValues: _processedAttributeValues,
          attributeMap: attributeMap,
          buildAgeGroupInfo: _buildAgeGroupInfo,
        ),
        CustomReportSection(
          title: 'Mô hình khách hàng',
          attributeIds: [6, 7, 8],
          icon: Icons.person,
          processedAttributeValues: _processedAttributeValues,
          attributeMap: attributeMap,
          buildAgeGroupInfo: _buildAgeGroupInfo,
        ),
        CustomReportSection(
          title: 'Mặt bằng',
          attributeIds:
              widget.siteCategoryId == 2 ? [9, 10, 11, 34, 35] : [9, 10, 11],
          icon: Icons.store,
          processedAttributeValues: _processedAttributeValues,
          attributeMap: attributeMap,
          buildAgeGroupInfo: _buildAgeGroupInfo,
        ),
        CustomReportSection(
          title: 'Yếu tố môi trường',
          attributeIds:
              widget.siteCategoryId == 1
                  ? [12, 13, 14, 15, 16, 24, 26, 27]
                  : [12, 13, 14, 15, 16],
          icon: Icons.eco,
          processedAttributeValues: _processedAttributeValues,
          attributeMap: attributeMap,
          buildAgeGroupInfo: _buildAgeGroupInfo,
        ),
        CustomReportSection(
          title: 'Tầm nhìn & Cản trở',
          attributeIds: widget.siteCategoryId == 2 ? [17, 18] : [17, 18, 28],
          icon: Icons.visibility,
          processedAttributeValues: _processedAttributeValues,
          attributeMap: attributeMap,
          buildAgeGroupInfo: _buildAgeGroupInfo,
        ),
        CustomReportSection(
          title: 'Tiện ích',
          attributeIds: widget.siteCategoryId == 2 ? [19, 20] : [19, 20, 29],
          icon: Icons.build,
          processedAttributeValues: _processedAttributeValues,
          attributeMap: attributeMap,
          buildAgeGroupInfo: _buildAgeGroupInfo,
        ),
      ];

      sections.addAll(reportSections.where((section) => section.hasContent));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections,
      ),
    );
  }

  Widget _buildImagesTab() {
    final theme = Theme.of(context);
    return _images.isEmpty
        ? Center(
          child: Text(
            'Không có hình ảnh nào',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.start,
          ),
        )
        : GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: _images.length,
          itemBuilder: (context, index) {
            final image = _images[index];
            return GestureDetector(
              onTap: () => _showFullImage(context, image['url']),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: image['url'],
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                  errorWidget:
                      (context, url, error) =>
                          const Icon(Icons.error, color: Colors.red),
                ),
              ),
            );
          },
        );
  }

  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                placeholder:
                    (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                errorWidget:
                    (context, url, error) =>
                        const Icon(Icons.error, color: Colors.red),
              ),
            ),
          ),
    );
  }

  Widget _buildAgeGroupInfo(Map<String, dynamic> attr) {
    final theme = Theme.of(context);
    Map<String, int> ageGroups = {
      'dưới 18 tuổi': 0,
      '18-30 tuổi': 0,
      '31-45 tuổi': 0,
      'trên 45 tuổi': 0,
    };

    // Lấy tất cả các bản ghi có attributeId: 7
    final sameAgeAttrs =
        _processedAttributeValues.where((a) => a['attributeId'] == 7).toList();

    // Debug: In ra danh sách các bản ghi attributeId: 7
    debugPrint('Processing age group attributes: $sameAgeAttrs');

    // Xử lý dữ liệu
    for (var ageAttr in sameAgeAttrs) {
      final additionalInfo = ageAttr['additionalInfo'] ?? '';

      // Định dạng cũ: Chuỗi gộp
      if (additionalInfo.contains(',')) {
        final RegExp regex = RegExp(
          r'(\d+)% nhóm khách hàng có độ tuổi (dưới 18|18-30|31-45|trên 45)',
        );
        final matches = regex.allMatches(additionalInfo);
        for (var match in matches) {
          final percentage = match.group(1);
          final ageGroup = match.group(2);
          final percentValue = int.tryParse(percentage ?? '0') ?? 0;
          if (ageGroup != null) {
            ageGroups[ageGroup] = percentValue;
          }
        }
      } else {
        // Định dạng mới: Bản ghi riêng lẻ
        final RegExp regex = RegExp(r'(\d+)% nhóm khách hàng có độ tuổi (.+)');
        final match = regex.firstMatch(additionalInfo);
        if (match != null) {
          final percentage = match.group(1);
          final ageGroup = match.group(2);
          final percentValue = int.tryParse(percentage ?? '0') ?? 0;
          if (ageGroup != null) {
            ageGroups[ageGroup] = percentValue;
          }
        }
      }
    }

    // Tạo danh sách hiển thị theo thứ tự cố định
    List<Widget> ageGroupWidgets = [];
    ageGroups.forEach((ageGroup, percentage) {
      if (percentage > 0) {
        // Chỉ hiển thị nếu phần trăm lớn hơn 0
        String displayAgeGroup;
        switch (ageGroup) {
          case 'dưới 18':
            displayAgeGroup = 'Dưới 18 tuổi';
            break;
          case '18-30':
            displayAgeGroup = '18-30 tuổi';
            break;
          case '31-45':
            displayAgeGroup = '31-45 tuổi';
            break;
          case 'trên 45':
            displayAgeGroup = 'Trên 45 tuổi';
            break;
          default:
            displayAgeGroup = ageGroup;
        }
        ageGroupWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '$displayAgeGroup: $percentage%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.start,
            ),
          ),
        );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          ageGroupWidgets.isNotEmpty
              ? ageGroupWidgets
              : [
                Text(
                  'Không có dữ liệu độ tuổi',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
    );
  }
}

// Custom Report Section Widget
class CustomReportSection extends StatefulWidget {
  final String title;
  final List<int> attributeIds;
  final IconData icon;
  final List<Map<String, dynamic>> processedAttributeValues;
  final Map<int, String> attributeMap;
  final Widget Function(Map<String, dynamic>) buildAgeGroupInfo;
  bool get hasContent => _sectionAttributes.isNotEmpty;

  late final List<Map<String, dynamic>> _sectionAttributes;

  CustomReportSection({
    Key? key,
    required this.title,
    required this.attributeIds,
    required this.icon,
    required this.processedAttributeValues,
    required this.attributeMap,
    required this.buildAgeGroupInfo,
  }) : super(key: key) {
    _sectionAttributes =
        processedAttributeValues
            .where((attr) => attributeIds.contains(attr['attributeId']))
            .toList();
  }

  @override
  _CustomReportSectionState createState() => _CustomReportSectionState();
}

class _CustomReportSectionState extends State<CustomReportSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget._sectionAttributes.isEmpty) {
      return const SizedBox.shrink();
    }

    final groupedAttributes = <int, List<Map<String, dynamic>>>{};
    for (var attr in widget._sectionAttributes) {
      final attrId = attr['attributeId'];
      if (widget.attributeMap.containsKey(attrId)) {
        groupedAttributes.putIfAbsent(attrId, () => []).add(attr);
      }
    }
    if (groupedAttributes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                  if (_isExpanded) {
                    _animationController.forward();
                  } else {
                    _animationController.reverse();
                  }
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    RotationTransition(
                      turns: _rotateAnimation,
                      child: Icon(
                        Icons.expand_more,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      groupedAttributes.entries.map((entry) {
                        final attrId = entry.key;
                        final values = entry.value;
                        final attrName =
                            widget.attributeMap[attrId] ?? 'Không xác định';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                attrName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                                textAlign: TextAlign.start,
                              ),
                              const SizedBox(height: 8),
                              if (attrId ==
                                  7) // Chỉ gọi _buildAgeGroupInfo một lần
                                widget.buildAgeGroupInfo(values.first)
                              else
                                ...values.map((attr) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          attr['value'],
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.8),
                                              ),
                                          textAlign: TextAlign.start,
                                        ),
                                        if (attr['additionalInfo'] != null &&
                                            attr['additionalInfo'].isNotEmpty)
                                          Text(
                                            attr['additionalInfo'],
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.7),
                                                ),
                                            textAlign: TextAlign.start,
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
              crossFadeState:
                  _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}
