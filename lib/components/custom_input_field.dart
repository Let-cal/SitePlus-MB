import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Formatter để thêm dấu phẩy khi nhập
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Loại bỏ các ký tự không phải số
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // Định dạng số với dấu phẩy
    final number = int.parse(newText);
    final formatted = _formatNumber(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

class CustomInputField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final Function(String) onSaved;
  final ThemeData theme;
  final String? initialValue;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffixText;
  final int? maxLength;
  final bool numbersOnly;
  final bool isDescription; // Thêm prop mới
  final bool formatThousands;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final bool useSmallText;
  final bool useNewUI;

  const CustomInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.onSaved,
    required this.theme,
    this.initialValue = '',
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.suffixText,
    this.maxLength,
    this.numbersOnly = false,
    this.isDescription = false,
    this.formatThousands = false,
    this.controller,
    this.onTap, // Thêm vào constructor
    this.useSmallText = false,
    this.useNewUI = false,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    // Sử dụng controller từ widget nếu được cung cấp, nếu không thì tạo mới
    if (widget.controller != null) {
      _internalController = widget.controller!;
    } else {
      if (widget.formatThousands &&
          widget.initialValue != null &&
          widget.initialValue!.isNotEmpty) {
        final number =
            int.tryParse(widget.initialValue!.replaceAll(',', '')) ?? 0;
        _internalController = TextEditingController(
          text: _formatNumber(number),
        );
      } else {
        _internalController = TextEditingController(text: widget.initialValue);
      }
    }
  }

  @override
  void dispose() {
    // Chỉ dispose controller nội bộ nếu không dùng controller từ ngoài
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    List<TextInputFormatter> formatters = [];

    if (widget.numbersOnly) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }
    if (widget.formatThousands) {
      formatters.add(ThousandsSeparatorInputFormatter());
    }
    if (widget.maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(widget.maxLength));
    }
    if (widget.inputFormatters != null) {
      formatters.addAll(widget.inputFormatters!);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _internalController,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hintText,
          labelStyle:
              widget.useNewUI
                  ? TextStyle(
                    color: widget.theme.colorScheme.primary,
                    fontSize: widget.useSmallText ? 12 : null,
                  )
                  : (widget.useSmallText
                      ? widget.theme.textTheme.bodySmall
                      : null),
          hintStyle:
              widget.useSmallText
                  ? widget.theme.textTheme.bodySmall?.copyWith(
                    color: widget.theme.colorScheme.onSurface.withOpacity(0.6),
                  )
                  : null,
          prefixIcon: Icon(
            widget.icon,
            color: widget.theme.colorScheme.primary,
          ),
          border:
              widget.useNewUI
                  ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide(
                      color: widget.theme.colorScheme.primary,
                    ),
                  )
                  : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
          enabledBorder:
              widget.useNewUI
                  ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide(
                      color: widget.theme.colorScheme.primary.withOpacity(0.5),
                    ),
                  )
                  : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: widget.theme.colorScheme.onSurface.withOpacity(
                        0.2,
                      ),
                    ),
                  ),
          focusedBorder:
              widget.useNewUI
                  ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide(
                      color: widget.theme.colorScheme.primary,
                      width: 2,
                    ),
                  )
                  : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: widget.theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
          suffixText: widget.suffixText,
          // Tùy chỉnh giao diện khi là description
          filled: true,
          fillColor: widget.theme.colorScheme.surface,
          contentPadding:
              widget.isDescription
                  ? const EdgeInsets.all(16.0)
                  : const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
        ),
        style: widget.useSmallText ? widget.theme.textTheme.bodySmall : null,
        keyboardType:
            widget.isDescription
                ? TextInputType.multiline
                : widget.keyboardType,
        maxLines:
            widget.isDescription
                ? null
                : 1, // Tự động mở rộng khi là description
        minLines: widget.isDescription ? 1 : 1, // Chiều cao tối thiểu
        textInputAction:
            widget.isDescription
                ? TextInputAction.newline
                : TextInputAction.done,
        inputFormatters:
            widget.isDescription
                ? null
                : formatters, // Bỏ formatters khi là description
        onChanged: (value) {
          widget.onSaved(value);
        },
      ),
    );
  }
}
