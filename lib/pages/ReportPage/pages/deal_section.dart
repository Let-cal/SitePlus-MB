import 'package:flutter/material.dart';
import 'package:siteplus_mb/components/custom_dropdown_field.dart';
import 'package:siteplus_mb/components/custom_input_field.dart';
import 'package:siteplus_mb/utils/string_utils.dart';

class DealSection extends StatefulWidget {
  final Map<String, dynamic> dealData;
  final Function(void Function()) setState;
  final ThemeData theme;
  final bool useSmallText;
  final bool useNewUI;

  const DealSection({
    super.key,
    required this.dealData,
    required this.setState,
    required this.theme,
    this.useSmallText = false,
    this.useNewUI = false,
  });

  @override
  _DealSectionState createState() => _DealSectionState();
}

class _DealSectionState extends State<DealSection> {
  String _dealType = 'Mặt bằng cho thuê';
  final List<String> _dealTypeOptions = [
    'Mặt bằng cho thuê',
    'Mặt bằng chuyển nhượng',
  ];

  // New controllers for separate year and month inputs
  TextEditingController? _leaseYearController;
  TextEditingController? _leaseMonthController;

  TextEditingController? _proposedPriceController;
  TextEditingController? _depositController;
  TextEditingController? _depositMonthController;
  TextEditingController? _additionalTermsController;

  // Keep this for backward compatibility
  TextEditingController? _leaseTermController;

  @override
  void initState() {
    super.initState();
    print('dealData in DealSection: ${widget.dealData}');
    _proposedPriceController = TextEditingController(
      text: _formatNumber(widget.dealData['proposedPrice']?.toString()),
    );
    _depositController = TextEditingController(
      text: _formatNumber(widget.dealData['deposit']?.toString()),
    );
    _depositMonthController = TextEditingController(
      text:
          widget.dealData['depositMonth']?.toString().replaceAll(
            ' tháng',
            '',
          ) ??
          '',
    );
    _additionalTermsController = TextEditingController(
      text: widget.dealData['additionalTerms'] ?? '',
    );

    // Initialize the legacy controller
    _leaseTermController = TextEditingController();

    // Initialize new controllers for year and month
    _leaseYearController = TextEditingController();
    _leaseMonthController = TextEditingController();

    // Parse existing lease term value if it exists
    _initializeLeaseTerm(widget.dealData['leaseTerm']);
  }

  @override
  void didUpdateWidget(covariant DealSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dealData != widget.dealData) {
      _proposedPriceController?.text = _formatNumber(
        widget.dealData['proposedPrice']?.toString(),
      );
      _depositController?.text = _formatNumber(
        widget.dealData['deposit']?.toString(),
      );
      _depositMonthController?.text =
          widget.dealData['depositMonth']?.toString().replaceAll(
            ' tháng',
            '',
          ) ??
          '';
      _additionalTermsController?.text =
          widget.dealData['additionalTerms'] ?? '';
      _initializeLeaseTerm(widget.dealData['leaseTerm']);
      debugPrint(
        'Updated controllers - Year: ${_leaseYearController?.text}, Month: ${_leaseMonthController?.text}',
      );
    }
  }

  void _initializeLeaseTerm(String? leaseTerm) {
    if (leaseTerm != null && leaseTerm.isNotEmpty) {
      debugPrint('Raw leaseTerm: $leaseTerm');

      // Chuẩn hóa chuỗi: chuyển về dạng không dấu để so sánh
      String normalizedLeaseTerm = StringUtils.normalizeString(leaseTerm);
      debugPrint('Normalized leaseTerm: $normalizedLeaseTerm');

      if (normalizedLeaseTerm.contains('mat bang chuyen nhuong')) {
        setState(() {
          _dealType = 'Mặt bằng chuyển nhượng';
          _leaseYearController?.text = '';
          _leaseMonthController?.text = '';
          _leaseTermController?.text = '';
          debugPrint('Initialized _dealType: Mặt bằng chuyển nhượng');
        });
      } else if (normalizedLeaseTerm.contains('mat bang cho thue')) {
        setState(() {
          _dealType = 'Mặt bằng cho thuê';

          // Parse the lease term value to extract years and months
          _parseAndSetLeaseTermValues(leaseTerm);

          debugPrint(
            'Initialized _dealType: Mặt bằng cho thuê, Year: ${_leaseYearController?.text}, Month: ${_leaseMonthController?.text}',
          );
        });
      } else {
        debugPrint('Unknown leaseTerm format: $leaseTerm');
      }
    } else {
      debugPrint('leaseTerm is null or empty');
    }
  }

  void _parseAndSetLeaseTermValues(String leaseTerm) {
    // Extract the part after "Mặt bằng cho thuê - Thời hạn "
    String termPart = leaseTerm.replaceFirst(
      'Mặt bằng cho thuê - Thời hạn ',
      '',
    );

    // Reset controllers
    _leaseYearController?.text = '';
    _leaseMonthController?.text = '';

    // Extract year value if exists
    RegExp yearRegex = RegExp(r'(\d+)\s*năm');
    Match? yearMatch = yearRegex.firstMatch(termPart);
    if (yearMatch != null && yearMatch.groupCount >= 1) {
      _leaseYearController?.text = yearMatch.group(1) ?? '';
    }

    // Extract month value if exists
    RegExp monthRegex = RegExp(r'(\d+)\s*tháng');
    Match? monthMatch = monthRegex.firstMatch(termPart);
    if (monthMatch != null && monthMatch.groupCount >= 1) {
      _leaseMonthController?.text = monthMatch.group(1) ?? '';
    }

    // For backward compatibility
    _leaseTermController?.text = termPart;
  }

  String _formatNumber(String? value) {
    if (value == null || value.isEmpty) return '';
    final number = double.tryParse(value.replaceAll(',', '')) ?? 0;
    return number
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _updateDealDebugInfo() {
    debugPrint('dealData: ${widget.dealData}');
  }

  // Create formatted lease term from year and month inputs
  void _updateLeaseTerm() {
    widget.setState(() {
      if (_dealType == 'Mặt bằng chuyển nhượng') {
        widget.dealData['leaseTerm'] = 'Mặt bằng chuyển nhượng';
      } else {
        // Get values from separate year and month inputs
        String yearValue = _leaseYearController?.text.trim() ?? '';
        String monthValue = _leaseMonthController?.text.trim() ?? '';

        // Construct the lease term string based on what user entered
        String leaseTerm = 'Mặt bằng cho thuê';

        if (yearValue.isNotEmpty || monthValue.isNotEmpty) {
          leaseTerm += ' - Thời hạn ';

          // Add year part if present
          if (yearValue.isNotEmpty) {
            leaseTerm += '$yearValue năm';

            // Add space if month part will follow
            if (monthValue.isNotEmpty) {
              leaseTerm += ' ';
            }
          }

          // Add month part if present
          if (monthValue.isNotEmpty) {
            leaseTerm += '$monthValue tháng';
          }
        }

        widget.dealData['leaseTerm'] = leaseTerm;
      }
    });
    _updateDealDebugInfo();
  }

  @override
  void dispose() {
    _proposedPriceController?.dispose();
    _depositController?.dispose();
    _depositMonthController?.dispose();
    _additionalTermsController?.dispose();
    _leaseTermController?.dispose();
    _leaseYearController?.dispose();
    _leaseMonthController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building DealSection with _dealType: $_dealType');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deal Details',
            style: widget.theme.textTheme.titleLarge?.copyWith(
              color: widget.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          widget.useNewUI
              ? CustomDropdownField<String>(
                value: _dealType,
                items: _dealTypeOptions,
                labelText: 'Select Deal Type',
                hintText: 'Select deal type',
                prefixIcon: Icons.store,
                theme: widget.theme,
                useSmallText: widget.useSmallText,
                onChanged: (String? newValue) {
                  setState(() {
                    _dealType = newValue!;
                    if (_dealType == 'Mặt bằng chuyển nhượng') {
                      _leaseYearController?.text = '';
                      _leaseMonthController?.text = '';
                      _leaseTermController?.text = '';
                    }
                    _updateLeaseTerm();
                  });
                },
              )
              : DropdownButtonFormField<String>(
                isExpanded: true,
                value: _dealType,
                decoration: InputDecoration(
                  label: Text(
                    'Select Deal Type',
                    overflow: TextOverflow.ellipsis,
                    style:
                        widget.useSmallText
                            ? widget.theme.textTheme.bodySmall
                            : null,
                  ),
                  hintText: 'Select deal type',
                  hintStyle:
                      widget.useSmallText
                          ? widget.theme.textTheme.bodySmall?.copyWith(
                            color: widget.theme.colorScheme.onSurface
                                .withOpacity(0.6),
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: widget.theme.colorScheme.onSurface.withOpacity(
                        0.2,
                      ),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: widget.theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: widget.theme.colorScheme.surface,
                  prefixIcon: Icon(
                    Icons.store,
                    color: widget.theme.colorScheme.primary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                ),
                items:
                    _dealTypeOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          overflow: TextOverflow.ellipsis,
                          style:
                              widget.useSmallText
                                  ? widget.theme.textTheme.bodySmall
                                  : null,
                        ),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _dealType = newValue!;
                    if (_dealType == 'Mặt bằng chuyển nhượng') {
                      _leaseYearController?.text = '';
                      _leaseMonthController?.text = '';
                      _leaseTermController?.text = '';
                    }
                    _updateLeaseTerm();
                  });
                },
              ),
          const SizedBox(height: 16),
          CustomInputField(
            label: 'Proposed Price (VND/Month)',
            hintText: 'Enter proposed price',
            icon: Icons.money,
            controller:
                _proposedPriceController ??
                TextEditingController(), // Fallback if null
            onSaved: (value) {
              widget.setState(() {
                widget.dealData['proposedPrice'] = value.replaceAll(',', '');
              });
              _updateDealDebugInfo();
            },
            theme: widget.theme,
            keyboardType: TextInputType.number,
            numbersOnly: true,
            formatThousands: true,
            useSmallText: widget.useSmallText,
            useNewUI: widget.useNewUI,
          ),
          if (_dealType == 'Mặt bằng cho thuê') ...[
            const SizedBox(height: 16),

            // Two input fields in a Column for year and month
            Column(
              children: [
                // Year input
                CustomInputField(
                  label: 'Years',
                  hintText: 'Enter years',
                  suffixText: widget.useNewUI ? null : 'Years(s)',
                  icon: Icons.calendar_today,
                  controller: _leaseYearController ?? TextEditingController(),
                  onSaved: (value) {
                    // Update both local state and controller
                    setState(() {
                      _leaseYearController?.text = value;
                      // Make sure the value is reflected in the controller
                      if (_leaseYearController != null) {
                        _leaseYearController!.text = value;
                      }
                    });
                    _updateLeaseTerm();
                  },
                  theme: widget.theme,
                  keyboardType: TextInputType.number,
                  numbersOnly: true,
                  useSmallText: widget.useSmallText,
                  useNewUI: widget.useNewUI,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  validator: (value) {
                    // At least one of year or month must be filled
                    if ((value == null || value.isEmpty) &&
                        (_leaseMonthController?.text.isEmpty ?? true)) {
                      return 'Enter either years or months';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Month input
                CustomInputField(
                  label: 'Months',
                  hintText: 'Enter months',
                  suffixText: widget.useNewUI ? null : 'Month(s)',
                  icon: Icons.date_range,
                  controller: _leaseMonthController ?? TextEditingController(),
                  onSaved: (value) {
                    setState(() {
                      _leaseMonthController?.text = value;
                      // Make sure the value is reflected in the controller
                      if (_leaseMonthController != null) {
                        _leaseMonthController!.text = value;
                      }
                    });
                    _updateLeaseTerm();
                  },
                  theme: widget.theme,
                  keyboardType: TextInputType.number,
                  numbersOnly: true,
                  useSmallText: widget.useSmallText,
                  useNewUI: widget.useNewUI,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  validator: (value) {
                    // At least one of year or month must be filled
                    if ((value == null || value.isEmpty) &&
                        (_leaseYearController?.text.isEmpty ?? true)) {
                      return 'Enter either years or months';
                    }
                    return null;
                  },
                ),
              ],
            ),

            // Display the combined lease term (optional, for debugging)
            if (widget.dealData['leaseTerm'] != null &&
                widget.dealData['leaseTerm'].isNotEmpty &&
                widget.dealData['leaseTerm'].contains('Thời hạn'))
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.dealData['leaseTerm'].replaceFirst(
                    'Mặt bằng cho thuê - ',
                    '',
                  ),
                  style: TextStyle(
                    fontSize: widget.useSmallText ? 11 : 12,
                    color: widget.theme.colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
          const SizedBox(height: 16),
          CustomInputField(
            label: 'Deposit Amount (VND)',
            hintText: 'Enter deposit amount',
            suffixText: 'VND',
            icon: Icons.account_balance_wallet,
            controller:
                _depositController ??
                TextEditingController(), // Fallback if null
            onSaved: (value) {
              widget.setState(() {
                widget.dealData['deposit'] = value.replaceAll(',', '');
              });
              _updateDealDebugInfo();
            },
            theme: widget.theme,
            keyboardType: TextInputType.number,
            numbersOnly: true,
            formatThousands: true,
            useSmallText: widget.useSmallText,
            useNewUI: widget.useNewUI,
          ),
          const SizedBox(height: 16),
          CustomInputField(
            label: 'Deposit Duration (Months)',
            hintText: 'Enter deposit duration (e.g., 3)',
            suffixText: "Months",
            icon: Icons.timer,
            controller:
                _depositMonthController ??
                TextEditingController(), // Fallback if null
            onSaved: (value) {
              widget.setState(() {
                widget.dealData['depositMonth'] =
                    value.isNotEmpty ? '$value tháng' : '';
              });
              _updateDealDebugInfo();
            },
            theme: widget.theme,
            keyboardType: TextInputType.number,
            numbersOnly: true,
            useSmallText: widget.useSmallText,
            useNewUI: widget.useNewUI,
          ),
          const SizedBox(height: 16),
          CustomInputField(
            label: 'Additional Terms',
            hintText: 'Enter additional terms (if any)',
            icon: Icons.notes,
            controller:
                _additionalTermsController ??
                TextEditingController(), // Fallback if null
            onSaved: (value) {
              widget.setState(() {
                widget.dealData['additionalTerms'] = value;
              });
              _updateDealDebugInfo();
            },
            theme: widget.theme,
            isDescription: true,
            keyboardType: TextInputType.multiline,
            useSmallText: widget.useSmallText,
            useNewUI: widget.useNewUI,
          ),
        ],
      ),
    );
  }
}
