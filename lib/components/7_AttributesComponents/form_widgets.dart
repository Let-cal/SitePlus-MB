import 'package:flutter/material.dart';

class FormWidgets {
  static Widget buildCheckboxListTile({
    required String title,
    required String key,
    required String
    parentKey, // Thêm parentKey để chỉ định vị trí trong reportData
    required Map<String, dynamic> reportData,
    required ThemeData theme,
    required Function(void Function()) setState,
    required Map<String, IconData> icons,
  }) {
    reportData[parentKey] ??= {}; // Đảm bảo parentKey tồn tại
    reportData[parentKey][key] ??=
        []; // Đảm bảo key tồn tại bên trong parentKey

    return CheckboxListTile(
      title: Text(title),
      secondary: Icon(icons[title], color: theme.colorScheme.primary),
      value: (reportData[parentKey][key] ?? []).contains(title),
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            reportData[parentKey][key]!.add(title);
          } else {
            reportData[parentKey][key]!.remove(title);
          }
        });
      },
    );
  }

  static Widget buildRadioGroup({
    required String key,
    required String parentKey,
    required List<String> options,
    required Map<String, dynamic> reportData,
    required Function(void Function()) setState,
  }) {
    reportData[parentKey] =
        (reportData[parentKey] as Map<String, dynamic>?) ?? {};

    return Column(
      children:
          options.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: reportData[parentKey][key] as String?,
              onChanged: (String? value) {
                setState(() {
                  if (value != null) {
                    (reportData[parentKey] as Map<String, dynamic>)[key] =
                        value;
                  }
                });
              },
            );
          }).toList(),
    );
  }
}
