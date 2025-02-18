import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final Function(String) onSaved;
  final ThemeData theme;
  final String initialValue;  // Add this

  const CustomInputField({
    Key? key,
    required this.label,
    required this.icon,
    required this.onSaved,
    required this.theme,
    this.initialValue = '',  // Add this
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,  // Add this
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: theme.colorScheme.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onSaved,  // Change this from onSaved to onChanged
      ),
    );
  }
}