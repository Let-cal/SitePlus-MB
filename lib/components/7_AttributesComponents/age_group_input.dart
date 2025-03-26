import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BuildAgeGroupInput extends StatelessWidget {
  final String label;
  final String keyName;
  final Map<String, dynamic> reportData;
  final ThemeData theme;

  const BuildAgeGroupInput({
    super.key,
    required this.label,
    required this.keyName,
    required this.reportData,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: '$label (%)',
          prefixIcon: Icon(Icons.person, color: theme.colorScheme.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSaved: (value) => reportData['customerModel']['ageGroups'][keyName] =
            int.tryParse(value ?? '0') ?? 0,
      ),
    );
  }
}
