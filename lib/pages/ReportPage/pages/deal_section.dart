import 'package:flutter/material.dart';
import 'package:siteplus_mb/components/custom_dropdown_field.dart';
import 'package:siteplus_mb/components/custom_input_field.dart';

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
  String _leaseTermInput = '';
  TextEditingController? _proposedPriceController;
  TextEditingController? _depositController;
  TextEditingController? _depositMonthController; // Make nullable
  TextEditingController? _additionalTermsController;
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
    _leaseTermController = TextEditingController();
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
    }
  }

  void _initializeLeaseTerm(String? leaseTerm) {
    if (leaseTerm != null && leaseTerm.isNotEmpty) {
      debugPrint('Raw leaseTerm: $leaseTerm');

      // Chuẩn hóa chuỗi: chuyển về dạng không dấu để so sánh
      String normalizedLeaseTerm = _normalizeString(leaseTerm);
      debugPrint('Normalized leaseTerm: $normalizedLeaseTerm');

      if (normalizedLeaseTerm.contains('mat bang chuyen nhuong')) {
        setState(() {
          _dealType = 'Mặt bằng chuyển nhượng';
          _leaseTermInput = '';
          _leaseTermController?.text = '';
          debugPrint('Initialized _dealType: Mặt bằng chuyển nhượng');
        });
      } else if (normalizedLeaseTerm.contains('mat bang cho thue')) {
        setState(() {
          _dealType = 'Mặt bằng cho thuê';
          _leaseTermInput = leaseTerm.replaceFirst(
            'Mặt bằng cho thuê - Thời hạn ',
            '',
          );
          _leaseTermController?.text = _leaseTermInput;
          debugPrint(
            'Initialized _dealType: Mặt bằng cho thuê, _leaseTermInput: $_leaseTermInput',
          );
        });
      } else {
        debugPrint('Unknown leaseTerm format: $leaseTerm');
      }
    } else {
      debugPrint('leaseTerm is null or empty');
    }
  }

  String _normalizeString(String input) {
    String normalized = input.toLowerCase();
    const Map<String, String> vietnameseBaseChars = {
      'ă': 'a',
      'â': 'a',
      'đ': 'd',
      'ê': 'e',
      'ô': 'o',
      'ơ': 'o',
      'ư': 'u',
    };

    vietnameseBaseChars.forEach((key, value) {
      normalized = normalized.replaceAll(key, value);
    });

    normalized = normalized.replaceAll(RegExp(r'[\u0300-\u036F]'), '');

    const Map<String, String> vietnameseDiacritics = {
      'à': 'a',
      'á': 'a',
      'ạ': 'a',
      'ả': 'a',
      'ã': 'a',
      'â': 'a',
      'ầ': 'a',
      'ấ': 'a',
      'ậ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'ă': 'a',
      'ằ': 'a',
      'ắ': 'a',
      'ặ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'è': 'e',
      'é': 'e',
      'ẹ': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ê': 'e',
      'ề': 'e',
      'ế': 'e',
      'ệ': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ì': 'i',
      'í': 'i',
      'ị': 'i',
      'ỉ': 'i',
      'ĩ': 'i',
      'ò': 'o',
      'ó': 'o',
      'ọ': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ô': 'o',
      'ồ': 'o',
      'ố': 'o',
      'ộ': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ơ': 'o',
      'ờ': 'o',
      'ớ': 'o',
      'ợ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ù': 'u',
      'ú': 'u',
      'ụ': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ư': 'u',
      'ừ': 'u',
      'ứ': 'u',
      'ự': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ỳ': 'y',
      'ý': 'y',
      'ỵ': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'đ': 'd',
    };

    vietnameseDiacritics.forEach((key, value) {
      normalized = normalized.replaceAll(key, value);
    });

    return normalized;
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

  void _updateLeaseTerm() {
    widget.setState(() {
      if (_dealType == 'Mặt bằng chuyển nhượng') {
        widget.dealData['leaseTerm'] = 'Mặt bằng chuyển nhượng';
      } else {
        widget.dealData['leaseTerm'] =
            _leaseTermInput.isNotEmpty
                ? 'Mặt bằng cho thuê - Thời hạn $_leaseTermInput'
                : 'Mặt bằng cho thuê';
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
                      _leaseTermInput = '';
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
                      _leaseTermInput = '';
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
            CustomInputField(
              label: 'Lease Term',
              hintText: 'Enter term (e.g., 6 months)',
              icon: Icons.calendar_today,
              controller:
                  _leaseTermController ??
                  TextEditingController(), // Fallback if null
              onSaved: (value) {
                _leaseTermInput = value;
                _updateLeaseTerm();
              },
              validator: (value) {
                if (_dealType == 'Mặt bằng cho thuê') {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập thời hạn thuê';
                  }
                  // Chuẩn hóa giá trị nhập vào
                  String normalizedValue = _normalizeString(value);
                  // Regex mới cho chuỗi không dấu
                  final regex = RegExp(
                    r'^(\d+\s*thang|\d+\s*nam|\d+\s*nam\s+\d+\s*thang)$',
                  );
                  if (!regex.hasMatch(normalizedValue)) {
                    return 'Định dạng không hợp lệ. Vui lòng nhập: [số + "tháng"], [số + "năm"] hoặc [số + "năm" + số + "tháng"]. Ví dụ: 2 tháng / 2 năm hoặc 2 năm 2 tháng';
                  }
                }
                return null;
              },
              theme: widget.theme,
              useSmallText: widget.useSmallText,
              useNewUI: widget.useNewUI,
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
                widget.dealData['depositMonth'] =
                    value.isNotEmpty ? '$value tháng' : '';
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
