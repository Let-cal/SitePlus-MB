import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadDialog extends StatefulWidget {
  final List<XFile> initialImages;
  final Function(List<XFile>) onImagesSelected;
  final int maxImages;

  const ImageUploadDialog({
    Key? key,
    this.initialImages = const [],
    required this.onImagesSelected,
    this.maxImages = 3,
  }) : super(key: key);

  static Future<List<XFile>?> show(
    BuildContext context, {
    List<XFile> initialImages = const [],
    int maxImages = 3,
  }) async {
    return await showDialog<List<XFile>>(
      context: context,
      builder:
          (context) => ImageUploadDialog(
            initialImages: initialImages,
            onImagesSelected: (images) {
              Navigator.of(context).pop(images);
            },
            maxImages: maxImages,
          ),
    );
  }

  @override
  State<ImageUploadDialog> createState() => _ImageUploadDialogState();
}

class _ImageUploadDialogState extends State<ImageUploadDialog>
    with SingleTickerProviderStateMixin {
  late List<XFile> _images;
  final ImagePicker _picker = ImagePicker();
  late AnimationController _controller;
  late Animation<double> _animation;
  XFile? _selectedPreviewImage;
  int _selectedImageIndex = -1;

  @override
  void initState() {
    super.initState();
    _images = List<XFile>.from(widget.initialImages);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    if (_images.isNotEmpty) {
      _selectedPreviewImage = _images.first;
      _selectedImageIndex = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_images.length >= widget.maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã đạt số lượng ảnh tối đa (${widget.maxImages})',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    try {
      final List<XFile> selectedImages = await _picker.pickMultiImage();
      if (selectedImages.isNotEmpty) {
        setState(() {
          // Add new images, but don't exceed max
          final remainingSlots = widget.maxImages - _images.length;
          final imagesToAdd = selectedImages.take(remainingSlots).toList();

          _images.addAll(imagesToAdd);

          // Select the first newly added image
          if (_selectedImageIndex == -1 && _images.isNotEmpty) {
            _selectedPreviewImage = _images.first;
            _selectedImageIndex = 0;
          }
        });

        // Show success message
        final addedCount = min(
          selectedImages.length,
          widget.maxImages - _images.length + selectedImages.length,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã thêm ${addedCount} ảnh thành công!',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể chọn ảnh: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);

      // Update selected image if needed
      if (_selectedImageIndex == index) {
        if (_images.isEmpty) {
          _selectedPreviewImage = null;
          _selectedImageIndex = -1;
        } else {
          _selectedImageIndex = 0;
          _selectedPreviewImage = _images[0];
        }
      } else if (_selectedImageIndex > index) {
        // If we removed an image before the selected one, update the index
        _selectedImageIndex--;
      }
    });
  }

  void _selectImage(int index) {
    setState(() {
      _selectedImageIndex = index;
      _selectedPreviewImage = _images[index];
    });
  }

  Widget _buildImageThumbnail(XFile image, int index, bool isSelected) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _selectImage(index),
      child: Container(
        width: 80,
        height: 80,
        margin: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                  : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.file(File(image.path), fit: BoxFit.cover),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 12,
                    color: theme.colorScheme.onError,
                  ),
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${index + 1}/${_images.length}',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 80,
        height: 80,
        margin: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            SizedBox(height: 4),
            Text(
              'Thêm ảnh',
              style: TextStyle(color: theme.colorScheme.primary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return ScaleTransition(
      scale: _animation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: math.min(500.0, size.width * 0.9),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 15,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quản lý hình ảnh',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        foregroundColor: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Image preview section
              Container(
                width: double.infinity,
                height: size.height * 0.3,
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child:
                    _selectedPreviewImage != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(_selectedPreviewImage!.path),
                            fit: BoxFit.contain,
                          ),
                        )
                        : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 64,
                                color: theme.colorScheme.primary.withOpacity(
                                  0.5,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Chưa có ảnh nào được chọn',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: 8),
                              FilledButton.icon(
                                icon: Icon(Icons.add_photo_alternate),
                                label: Text('Thêm ảnh ngay'),
                                onPressed: _pickImage,
                              ),
                            ],
                          ),
                        ),
              ),

              // Image thumbnails scrolling list
              Container(
                height: 100,
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Carousel of selected images
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ..._images.asMap().entries.map((entry) {
                            return _buildImageThumbnail(
                              entry.value,
                              entry.key,
                              entry.key == _selectedImageIndex,
                            );
                          }).toList(),
                          if (_images.length < widget.maxImages)
                            _buildAddButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Status and info
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_images.length}/${widget.maxImages} hình ảnh',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'JPG, PNG (tối đa 10MB)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Hủy'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    FilledButton(
                      onPressed: () {
                        widget.onImagesSelected(_images);
                      },
                      child: Text('Xác nhận'),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Utility function
int min(int a, int b) {
  return a < b ? a : b;
}
