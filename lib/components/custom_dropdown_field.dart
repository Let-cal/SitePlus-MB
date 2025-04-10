import 'package:flutter/material.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String labelText;
  final String? hintText;
  final IconData prefixIcon;
  final Function(T?) onChanged;
  final String? Function(T?)? validator;
  final Widget Function(T)?
  itemBuilder; // Để tùy chỉnh hiển thị item trong dropdown
  final Widget Function(T)?
  selectedItemBuilder; // Để tùy chỉnh hiển thị khi chọn
  final double borderRadius;
  final double menuMaxHeight;
  final bool useSmallText;
  final ThemeData theme;

  const CustomDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.labelText,
    required this.onChanged,
    required this.theme,
    this.hintText,
    this.prefixIcon = Icons.arrow_drop_down,
    this.validator,
    this.itemBuilder,
    this.selectedItemBuilder,
    this.borderRadius = 16.0,
    this.menuMaxHeight = 350.0,
    this.useSmallText = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      isExpanded: true,
      value: value,
      dropdownColor: Colors.white,
      menuMaxHeight: menuMaxHeight,

      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: theme.colorScheme.primary,
          fontSize:
              useSmallText ? 12 : null, // Giảm kích thước nếu useSmallText
        ),
        hintText: hintText,
        hintStyle:
            useSmallText
                ? theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                )
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(prefixIcon, color: theme.colorScheme.primary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      items:
          items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child:
                  itemBuilder != null
                      ? itemBuilder!(item)
                      : Text(
                        item.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: useSmallText ? theme.textTheme.bodySmall : null,
                      ),
            );
          }).toList(),
      onChanged: onChanged,
      validator: validator,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: theme.colorScheme.primary,
      ),
      selectedItemBuilder:
          selectedItemBuilder != null
              ? (context) =>
                  items.map((item) => selectedItemBuilder!(item)).toList()
              : null,
    );
  }
}
