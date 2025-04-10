import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:siteplus_mb/components/multi_tab_filter_panel.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/SiteDeal/site_deal_status.dart';

class ReportViewDialog extends StatefulWidget {
  final List<Map<String, dynamic>> siteDeals;
  final List<Map<String, dynamic>> attributeValues;
  final int siteCategoryId;
  final int siteId;

  const ReportViewDialog({
    super.key,
    required this.siteDeals,
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
  List<Map<String, dynamic>> _attributes = [];
  List<Map<String, dynamic>> _images = [];
  List<Map<String, dynamic>> _processedAttributeValues = [];
  bool _isLoading = true;
  String? _selectedStatus; // Selected status from the filter

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    final apiService = ApiService();
    try {
      _attributes = await apiService.getAllAttributes();
      _processedAttributeValues = _processAttributeValues(
        widget.attributeValues,
      );
      _images = await apiService.getSiteImages(widget.siteId).catchError((e) {
        debugPrint('Error retrieving site images: $e');
        return [];
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
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
        // Combine multiple values into one string joined with " and "
        final combinedValue = values.map((v) => v['value']).join(' and ');
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
              'Report Details',
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
              tabs: const [
                Tab(text: 'Negotiation'),
                Tab(text: 'Report'),
                Tab(text: 'Images'),
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
                      _buildReportTab(), // Keep this function unchanged
                      _buildImagesTab(), // Keep this function unchanged
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildDealTab() {
    final theme = Theme.of(context);
    final siteDealList = widget.siteDeals;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Panel
          MultiTabFilterPanel(
            groups: [
              FilterGroup(
                key: 'status',
                title: 'Filter by status',
                options: [
                  FilterOption(id: null, label: 'All'),
                  FilterOption(id: STATUS_IN_PROGRESS, label: 'In Progress'),
                  FilterOption(id: STATUS_ACTIVE, label: 'Active'),
                  FilterOption(id: STATUS_EXPIRED, label: 'Inactive'),
                ],
              ),
            ],
            onFilterChanged: (selections) {
              setState(() {
                _selectedStatus = selections['status'];
              });
            },
          ),
          const SizedBox(height: 16),
          // List of Site Deal Cards
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: siteDealList.length,
            itemBuilder: (context, index) {
              final deal = siteDealList[index];
              debugPrint(
                'Deal $index: status=${deal['status']}, statusName=${deal['statusName']}',
              );
              final statusName = getSiteDealStatusName(deal['statusName']);
              if (_selectedStatus == null || statusName == _selectedStatus) {
                return _buildSiteDealCard(deal);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSiteDealCard(Map<String, dynamic> deal) {
    final theme = Theme.of(context);
    final statusName = getSiteDealStatusName(deal['statusName']);
    final statusColor = getSiteDealStatusColor(context, statusName);
    bool isExpanded = false;
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: statusColor.withOpacity(0.2),
                  child: Icon(Icons.store, color: statusColor),
                ),
                title: Text(
                  'Deal #${deal['id']}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Created: ${deal['createdAt'].toString().substring(0, 10)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildDealDetails(deal),
                  ),
                ],
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    statusName,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDealDetails(Map<String, dynamic> deal) {
    String dealType = '';
    String leaseTermInput = '';
    final leaseTerm = deal['leaseTerm'] ?? '';
    if (leaseTerm.contains('Mặt bằng chuyển nhượng')) {
      dealType = 'Mặt bằng chuyển nhượng';
      leaseTermInput = '';
    } else if (leaseTerm.contains('Mặt bằng cho thuê')) {
      dealType = 'Mặt bằng cho thuê';
      leaseTermInput = leaseTerm.replaceFirst(
        'Mặt bằng cho thuê - Thời hạn ',
        '',
      );
    } else {
      dealType = 'Undefined';
      leaseTermInput = '';
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Negotiation Information',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        _buildDealInfoRow('Deal Type', dealType, Icons.store),
        if (dealType == 'Mặt bằng cho thuê')
          _buildDealInfoRow('Lease Term', leaseTermInput, Icons.calendar_today),
        _buildDealInfoRow(
          'Proposed Price',
          '${deal['proposedPrice'].toInt()} VND',
          Icons.money,
        ),
        _buildDealInfoRow(
          'Deposit',
          '${deal['deposit'].toInt()} VND',
          Icons.account_balance_wallet,
        ),
        _buildDealInfoRow(
          'Deposit Months',
          '${deal['depositMonth']}',
          Icons.calendar_month,
        ),
        _buildDealInfoRow(
          'Additional Terms',
          deal['additionalTerms'] ?? 'None',
          Icons.notes,
        ),
      ],
    );
  }

  Widget _buildDealInfoRow(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
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
          'Property Report',
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
            'No report data available',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.start,
          ),
        ),
      );
    } else {
      // Explicitly type attributeMap as Map<int, String>
      final Map<int, String> attributeMap = Map.fromEntries(
        _attributes.map((attr) {
          final int id = attr['id'] as int;
          final String name = attr['name'] as String;
          return MapEntry(id, name);
        }),
      );

      debugPrint('Attribute Map: $attributeMap');

      var reportSections = [
        CustomReportSection(
          title: 'Customer Traffic',
          attributeIds: [2, 3],
          icon: Icons.directions_car,
          processedAttributeValues: _processedAttributeValues,
          attributeMap: attributeMap,
          buildAgeGroupInfo: _buildAgeGroupInfo,
        ),
        CustomReportSection(
          title: 'Customer Density',
          attributeIds: [4, 5],
          icon: Icons.group,
          processedAttributeValues: _processedAttributeValues,
          attributeMap: attributeMap,
          buildAgeGroupInfo: _buildAgeGroupInfo,
        ),
        CustomReportSection(
          title: 'Customer Segments',
          attributeIds: [6, 7, 8],
          icon: Icons.person,
          processedAttributeValues: _processedAttributeValues,
          attributeMap: attributeMap,
          buildAgeGroupInfo: _buildAgeGroupInfo,
        ),
        CustomReportSection(
          title: 'Property',
          attributeIds:
              widget.siteCategoryId == 2 ? [9, 10, 11, 34, 35] : [9, 10, 11],
          icon: Icons.store,
          processedAttributeValues: _processedAttributeValues,
          attributeMap: attributeMap,
          buildAgeGroupInfo: _buildAgeGroupInfo,
        ),
        CustomReportSection(
          title: 'Environmental Factors',
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
          title: 'Vision & Barriers',
          attributeIds: widget.siteCategoryId == 2 ? [17, 18] : [17, 18, 28],
          icon: Icons.visibility,
          processedAttributeValues: _processedAttributeValues,
          attributeMap: attributeMap,
          buildAgeGroupInfo: _buildAgeGroupInfo,
        ),
        CustomReportSection(
          title: 'Amenities',
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
            'No images available',
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
      'Under 18': 0,
      '18-30': 0,
      '31-45': 0,
      'Over 45': 0,
    };

    // Get all records with attributeId: 7
    final sameAgeAttrs =
        _processedAttributeValues.where((a) => a['attributeId'] == 7).toList();

    // Debug: Print the list of records with attributeId: 7
    debugPrint('Processing age group attributes: $sameAgeAttrs');

    // Process the data
    for (var ageAttr in sameAgeAttrs) {
      final additionalInfo = ageAttr['additionalInfo'] ?? '';

      // Old format: Combined string
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
            // Convert Vietnamese age group key to English label
            switch (ageGroup) {
              case 'dưới 18':
                ageGroups['Under 18'] = percentValue;
                break;
              case '18-30':
                ageGroups['18-30'] = percentValue;
                break;
              case '31-45':
                ageGroups['31-45'] = percentValue;
                break;
              case 'trên 45':
                ageGroups['Over 45'] = percentValue;
                break;
            }
          }
        }
      } else {
        // New format: Single record
        final RegExp regex = RegExp(r'(\d+)% nhóm khách hàng có độ tuổi (.+)');
        final match = regex.firstMatch(additionalInfo);
        if (match != null) {
          final percentage = match.group(1);
          final ageGroup = match.group(2);
          final percentValue = int.tryParse(percentage ?? '0') ?? 0;
          if (ageGroup != null) {
            switch (ageGroup) {
              case 'dưới 18':
                ageGroups['Under 18'] = percentValue;
                break;
              case '18-30':
                ageGroups['18-30'] = percentValue;
                break;
              case '31-45':
                ageGroups['31-45'] = percentValue;
                break;
              case 'trên 45':
                ageGroups['Over 45'] = percentValue;
                break;
              default:
                ageGroups[ageGroup] = percentValue;
            }
          }
        }
      }
    }

    // Create a list for display in a fixed order
    List<Widget> ageGroupWidgets = [];
    ageGroups.forEach((ageGroup, percentage) {
      if (percentage > 0) {
        ageGroupWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '$ageGroup: $percentage%',
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
                  'No age data available',
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
                            widget.attributeMap[attrId] ?? 'Undefined';
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
                              if (attrId == 7)
                                // Only call buildAgeGroupInfo once
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
