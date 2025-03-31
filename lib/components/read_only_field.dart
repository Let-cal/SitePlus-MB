// read_only_field.dart
import 'package:flutter/material.dart';

class ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const ReadOnlyField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      ),
    );
  }
}
