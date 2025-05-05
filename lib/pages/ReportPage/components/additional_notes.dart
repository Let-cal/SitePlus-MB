// lib/pages/ReportPage/components/additional_notes.dart
import 'package:flutter/material.dart';

class AdditionalNotesComponent extends StatefulWidget {
  final Map<String, dynamic> reportData;
  final ThemeData? theme;

  const AdditionalNotesComponent({
    super.key,
    required this.reportData,
    this.theme,
  });

  @override
  State<AdditionalNotesComponent> createState() =>
      AdditionalNotesComponentState();
}

class AdditionalNotesComponentState extends State<AdditionalNotesComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late TextEditingController _notesController;

  String getNotes() {
    return _notesController.text;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    // Initialize with existing data if available
    _notesController = TextEditingController(
      text: widget.reportData['additionalNotes'] ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String content,
    required Color backgroundColor,
    required Color iconColor,
    required double borderRadius,
    required EdgeInsets padding,
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          SizedBox(width: 12),
          Expanded(child: Text(content)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? Theme.of(context);
    return FadeTransition(
      opacity: _animation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            icon: Icons.lightbulb_outline,
            content: 'Add additional details describing the property.',
            backgroundColor: theme.colorScheme.primaryContainer.withOpacity(
              0.3,
            ),
            iconColor: theme.colorScheme.primary,
            borderRadius: 12.0,
            padding: EdgeInsets.all(16.0),
          ),
          SizedBox(height: 16),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            child: TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Supplementary Notes',
                hintText:
                    'Add a description of the property features, location...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              maxLines: 3,
              onChanged: (value) {
                widget.reportData['additionalNotes'] = value;
              },
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
