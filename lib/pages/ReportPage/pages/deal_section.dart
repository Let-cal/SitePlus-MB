import 'package:flutter/material.dart';
import 'package:siteplus_mb/components/custom_input_field.dart';

class DealSection extends StatefulWidget {
  final Map<String, dynamic> dealData;
  final Function(void Function()) setState;
  final ThemeData theme;

  const DealSection({
    super.key,
    required this.dealData,
    required this.setState,
    required this.theme,
  });

  @override
  _DealSectionState createState() => _DealSectionState();
}

class _DealSectionState extends State<DealSection> {
  String _dealType = 'Mặt bằng cho thuê'; // Giá trị mặc định
  final List<String> _dealTypeOptions = [
    'Mặt bằng cho thuê',
    'Mặt bằng chuyển nhượng',
  ];
  String _leaseTermInput = '';
  late TextEditingController _proposedPriceController;
  late TextEditingController _depositController;
  late TextEditingController _additionalTermsController;
  late TextEditingController _leaseTermController;

  @override
  void initState() {
    super.initState();
    _proposedPriceController = TextEditingController(
      text: _formatNumber(widget.dealData['proposedPrice']?.toString()),
    );
    _depositController = TextEditingController(
      text: _formatNumber(widget.dealData['deposit']?.toString()),
    );
    _additionalTermsController = TextEditingController(
      text: widget.dealData['additionalTerms'] ?? '',
    );
    _leaseTermController = TextEditingController();

    // Khởi tạo giá trị ban đầu từ dealData
    _initializeLeaseTerm(widget.dealData['leaseTerm']);
  }

  @override
  void didUpdateWidget(covariant DealSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dealData != widget.dealData) {
      _proposedPriceController.text = _formatNumber(
        widget.dealData['proposedPrice']?.toString(),
      );
      _depositController.text = _formatNumber(
        widget.dealData['deposit']?.toString(),
      );
      _additionalTermsController.text =
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
          _leaseTermController.text = '';
          debugPrint('Initialized _dealType: Mặt bằng chuyển nhượng');
        });
      } else if (normalizedLeaseTerm.contains('mat bang cho thue')) {
        setState(() {
          _dealType = 'Mặt bằng cho thuê';
          _leaseTermInput = leaseTerm.replaceFirst(
            'Mặt bằng cho thuê - Thời hạn ',
            '',
          );
          _leaseTermController.text = _leaseTermInput;
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

  // Hàm chuẩn hóa chuỗi: chuyển về không dấu hoàn toàn
  String _normalizeString(String input) {
    // Bước 1: Chuyển chuỗi về dạng lowercase
    String normalized = input.toLowerCase();

    // Bước 2: Thay thế các ký tự đặc biệt (ă, â, đ, v.v.) trước
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

    // Bước 3: Loại bỏ các ký tự dấu (combining diacritics)
    // Dùng RegExp để loại bỏ các ký tự dấu (U+0300 đến U+036F là các combining diacritics)
    normalized = normalized.replaceAll(RegExp(r'[\u0300-\u036F]'), '');

    // Bước 4: Thay thế các ký tự có dấu còn lại (nếu có)
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
    debugPrint('dealData: $widget.dealData');
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
    _proposedPriceController.dispose();
    _depositController.dispose();
    _additionalTermsController.dispose();
    _leaseTermController.dispose();
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
            'Thông Tin Thương Lượng',
            style: widget.theme.textTheme.titleLarge?.copyWith(
              color: widget.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _dealType,
            decoration: InputDecoration(
              labelText: 'Loại Mặt Bằng',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              prefixIcon: Icon(
                Icons.store,
                color: widget.theme.colorScheme.primary,
              ),
            ),
            items:
                _dealTypeOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _dealType = newValue!;
                if (_dealType == 'Mặt bằng chuyển nhượng') {
                  _leaseTermInput = '';
                  _leaseTermController.text = '';
                }
                _updateLeaseTerm();
              });
            },
          ),
          const SizedBox(height: 16),
          CustomInputField(
            label: 'Giá Thuê Đề Xuất (VND/Tháng)',
            hintText: 'Nhập giá đề xuất',
            icon: Icons.money,
            controller: _proposedPriceController,
            onSaved: (value) {
              widget.setState(() {
                widget.dealData['proposedPrice'] = value?.replaceAll(',', '');
              });
              _updateDealDebugInfo();
            },
            theme: widget.theme,
            keyboardType: TextInputType.number,
            numbersOnly: true,
            formatThousands: true,
          ),
          if (_dealType == 'Mặt bằng cho thuê') ...[
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Thời Hạn Thuê',
              hintText: 'Nhập thời hạn (ví dụ: 6 tháng)',
              icon: Icons.calendar_today,
              controller: _leaseTermController,
              onSaved: (value) {
                _leaseTermInput = value ?? '';
                _updateLeaseTerm();
              },
              theme: widget.theme,
            ),
          ],
          const SizedBox(height: 16),
          CustomInputField(
            label: 'Tiền Đặt Cọc (VND)',
            hintText: 'Nhập số tiền đặt cọc',
            suffixText: 'VND',
            icon: Icons.account_balance_wallet,
            controller: _depositController,
            onSaved: (value) {
              widget.setState(() {
                widget.dealData['deposit'] = value?.replaceAll(',', '');
              });
              _updateDealDebugInfo();
            },
            theme: widget.theme,
            keyboardType: TextInputType.number,
            numbersOnly: true,
            formatThousands: true,
          ),
          const SizedBox(height: 16),
          CustomInputField(
            label: 'Điều Khoản Thêm',
            hintText: 'Nhập điều khoản bổ sung (nếu có)',
            icon: Icons.notes,
            controller: _additionalTermsController,
            onSaved: (value) {
              widget.setState(() {
                widget.dealData['additionalTerms'] = value;
              });
              _updateDealDebugInfo();
            },
            theme: widget.theme,
            isDescription: true,
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
    );
  }
}
