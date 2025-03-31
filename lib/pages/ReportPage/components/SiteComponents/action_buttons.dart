// action_buttons.dart
import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCreateSite;
  final VoidCallback onCancel;
  final VoidCallback onProceedToFullReport;

  const ActionButtons({
    super.key,
    required this.isLoading,
    required this.onCreateSite,
    required this.onCancel,
    required this.onProceedToFullReport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Button to create site
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onCreateSite,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child:
                  isLoading
                      ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onSecondary,
                        ),
                      )
                      : Text('Tạo thông tin cho mặt bằng'),
            ),
          ),
          SizedBox(height: 8),

          // Cancel and Continue buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                ),
                icon: Icon(Icons.arrow_back),
                label: Text('Hủy'),
              ),
              FilledButton.icon(
                onPressed: onProceedToFullReport,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: Icon(Icons.navigate_next),
                label: Text('Tiếp tục báo cáo đầy đủ'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
