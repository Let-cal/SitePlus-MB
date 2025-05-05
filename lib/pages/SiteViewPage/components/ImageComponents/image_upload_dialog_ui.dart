// image_upload_dialog_ui.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/ImageComponents/components/action_section.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/ImageComponents/components/dialog_header.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/ImageComponents/components/image_gallery.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/ImageComponents/components/image_preview.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/ImageComponents/image_upload_controller.dart';

class ImageUploadDialogUI extends StatefulWidget {
  final List<ImageItem> initialImages;
  final Function(List<ImageItem>) onImagesSelected;
  final int maxImages;
  final int siteId;
  final int? buildingId;
  final bool loadExistingImages;
  final bool preventUploadImages;

  const ImageUploadDialogUI({
    super.key,
    this.initialImages = const [],
    required this.onImagesSelected,
    this.maxImages = 3,
    required this.siteId,
    this.buildingId,
    this.loadExistingImages = true,
    this.preventUploadImages = false,
  });
  // Thêm vào file image_upload_dialog_ui.dart
  static Future<List<ImageItem>?> show(
    BuildContext context, {
    required int siteId,
    int? buildingId,
    bool loadExistingImages = true,
    bool preventUploadImages = false,
    List<ImageItem> initialImages = const [],
    int maxImages = 3,
  }) async {
    return showDialog<List<ImageItem>>(
      context: context,
      builder:
          (context) => ImageUploadDialogUI(
            initialImages: initialImages,
            onImagesSelected: (images) => Navigator.of(context).pop(images),
            maxImages: maxImages,
            siteId: siteId,
            buildingId: buildingId,
            loadExistingImages: loadExistingImages,
            preventUploadImages: preventUploadImages,
          ),
    );
  }

  @override
  State<ImageUploadDialogUI> createState() => _ImageUploadDialogUIState();
}

class _ImageUploadDialogUIState extends State<ImageUploadDialogUI>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late ImageUploadController _imageController;

  @override
  void initState() {
    super.initState();

    // Khởi tạo animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    // Khởi tạo controller
    _imageController = ImageUploadController(
      initialImages: widget.initialImages,
      onImagesSelected: widget.onImagesSelected,
      maxImages: widget.maxImages,
      siteId: widget.siteId,
      buildingId: widget.buildingId,
      loadExistingImages: widget.loadExistingImages,
    );

    // Lắng nghe các lỗi từ controller
    _imageController.addListener(_handleControllerUpdate);
  }

  void _handleControllerUpdate() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _handlePickImage() async {
    print('handlePickImage called'); // Debug xem hàm có được gọi không
    try {
      final count = await _imageController.pickImage(context);
      print('Picked image count: $count');
      if (count == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có ảnh nào được chọn')),
        );
      }
    } catch (e) {
      print('Error in handlePickImage: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _handleRemoveImage(int index) {
    final imageToRemove = _imageController.images[index];

    if (imageToRemove.isRemote) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Xác nhận xóa'),
              content: const Text('Bạn có chắc chắn muốn xóa ảnh này không?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _imageController.removeImage(index); // Chỉ xóa trên UI
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Xóa'),
                ),
              ],
            ),
      );
    } else {
      _imageController.removeImage(index); // Xóa ảnh cục bộ ngay lập tức
    }
  }

  void _handleClose() {
    if (_imageController.images.isEmpty && widget.preventUploadImages == true) {
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Confirmation'),
              content: const Text(
                'You need to upload at least one image before sending the report to the Area-Manager.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Understood'),
                ),
              ],
            ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return ScaleTransition(
      scale: _animation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: math.min(600.0, size.width * 0.95),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              DialogHeader(onClose: () => Navigator.of(context).pop()),

              // Content
              Container(
                constraints: BoxConstraints(maxHeight: size.height * 0.7),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Preview
                      ImagePreview(
                        controller: _imageController,
                        onPickImage: _handlePickImage,
                        onRemoveImage: _handleRemoveImage,
                      ),

                      // Gallery
                      ImageGallery(
                        controller: _imageController,
                        onPickImage: _handlePickImage,
                        onRemoveImage: _handleRemoveImage,
                      ),

                      ActionSection(
                        controller: _imageController,
                        onCancel: _handleClose,
                        onPreventUpload: widget.preventUploadImages,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
