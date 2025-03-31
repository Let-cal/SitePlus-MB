// site_info_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:siteplus_mb/components/custom_input_field.dart';
import 'package:siteplus_mb/components/read_only_field.dart'; // Import component mới

class SiteInfoSection extends StatelessWidget {
  final TextEditingController sizeController;
  final TextEditingController floorNumberController;
  final String siteCategory;
  final int? siteCategoryId;
  final Function(String?) onSiteNameSaved;
  final Function(String?) onSizeSaved;
  final Function(String?) onFloorSaved;

  const SiteInfoSection({
    super.key,
    required this.sizeController,
    required this.floorNumberController,
    required this.siteCategory,
    required this.siteCategoryId,
    required this.onSiteNameSaved,
    required this.onSizeSaved,
    required this.onFloorSaved,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Loại mặt bằng (read-only)
        ReadOnlyField(
          label: 'Loại mặt bằng',
          value: siteCategory,
          icon: Icons.category,
        ),
        const SizedBox(height: 16),

        // Diện tích (Size) - chỉ nhận số
        CustomInputField(
          label: 'Diện tích',
          hintText: 'Ví dụ: 200m2',
          icon: Icons.square_foot,
          onSaved: onSizeSaved,
          suffixText: "m2",
          theme: theme,
          initialValue: sizeController.text,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16),

        // Tầng
        CustomInputField(
          label: siteCategoryId == 1 ? 'Tầng' : 'Tổng số tầng',
          hintText:
              siteCategoryId == 1
                  ? 'Ví dụ: tầng 2'
                  : 'Gợi ý: tổng cộng có 2 tầng',
          icon: Icons.stairs,
          onSaved: onFloorSaved,
          theme: theme,
          initialValue: floorNumberController.text,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16),

        // Trạng thái (read-only) - chuyển từ location_section
        ReadOnlyField(
          label: 'Trạng thái',
          value: 'Đang hoạt động',
          icon: Icons.check_circle,
        ),
      ],
    );
  }
}
