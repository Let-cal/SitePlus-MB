import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  const CustomInputField({
    Key? key,
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
    this.isDescription = false, // Mặc định là false
  }) : super(key: key);

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<TextInputFormatter> formatters = [];

    if (widget.numbersOnly) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
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
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hintText,
          prefixIcon: Icon(
            widget.icon,
            color: widget.theme.colorScheme.primary,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          suffixText: widget.suffixText,
          // Tùy chỉnh giao diện khi là description
          filled: widget.isDescription,
          fillColor:
              widget.isDescription
                  ? widget.theme.colorScheme.surfaceVariant
                  : null,
          contentPadding:
              widget.isDescription
                  ? const EdgeInsets.all(16.0)
                  : const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
        ),
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
