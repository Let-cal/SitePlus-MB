import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:siteplus_mb/utils/ReportPage/info_card.dart';

class AdditionalNotesSection extends StatefulWidget {
  final Map<String, dynamic> reportData;
  final Function(void Function()) setState;
  final ThemeData theme;

  const AdditionalNotesSection({
    super.key,
    required this.reportData,
    required this.setState,
    required this.theme,
  });

  @override
  State<AdditionalNotesSection> createState() => _AdditionalNotesSectionState();
}

class _AdditionalNotesSectionState extends State<AdditionalNotesSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      setState(() {
        _images.addAll(selectedImages);
        if (_images.length > 3) _images = _images.sublist(0, 3);
        widget.reportData['hasImages'] = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Images added successfully!',
            style: TextStyle(color: widget.theme.colorScheme.onPrimary),
          ),
          backgroundColor: widget.theme.colorScheme.primary,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      if (_images.isEmpty) {
        widget.reportData['hasImages'] = false;
      }
    });
  }

  Widget _buildImageCard(XFile? image, int index) {
    return Container(
      width: 100,
      height: 100,
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.theme.colorScheme.primary,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.file(File(image.path), fit: BoxFit.cover),
            )
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  color: widget.theme.colorScheme.primary,
                ),
                SizedBox(height: 4),
                Text(
                  'Add Photo',
                  style: TextStyle(color: widget.theme.colorScheme.primary),
                ),
              ],
            ),
          if (image != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: widget.theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: widget.theme.colorScheme.onError,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: FadeTransition(
        opacity: _animation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VIII. Additional Notes',
              style: widget.theme.textTheme.headlineLarge?.copyWith(
                color: widget.theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            InfoCard(
              icon: Icons.lightbulb_outline,
              content: 'Include any other relevant details.',
              backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
              iconColor: Theme.of(context).colorScheme.secondary,
              borderRadius: 20.0,
              padding: EdgeInsets.all(20.0),
            ),
            SizedBox(height: 16),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.theme.colorScheme.shadow.withAlpha(26),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Additional Notes',

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: widget.theme.colorScheme.surfaceVariant,
                ),
                maxLines: 5,
                onSaved:
                    (value) => widget.reportData['additionalNotes'] = value,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Attach Images (Max 3)',
              style: widget.theme.textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length < 3 ? _images.length + 1 : 3,
                itemBuilder: (context, index) {
                  if (index < _images.length) {
                    return _buildImageCard(_images[index], index);
                  } else {
                    return GestureDetector(
                      onTap: _pickImage,
                      child: _buildImageCard(null, index),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
