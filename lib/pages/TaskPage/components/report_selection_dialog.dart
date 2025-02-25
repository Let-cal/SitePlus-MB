import 'package:flutter/material.dart';

class ReportSelectionDialog extends StatelessWidget {
  final Function(String) onReportSelected;

  const ReportSelectionDialog({Key? key, required this.onReportSelected})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header với nút đóng (X)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Chọn loại Report",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildOption(
              context,
              icon: Icons.business,
              title: "Report cho Site Độc Lập",
              value: "independent",
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                height: 24, // Điều chỉnh chiều cao của Divider
                thickness: 1.2,
                color: Theme.of(context).dividerColor,
              ),
            ),
            _buildOption(
              context,
              icon: Icons.apartment,
              title: "Report cho Site Trong Building",
              value: "building",
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        Navigator.of(context).pop();
        onReportSelected(value);
      },
    );
  }
}
