import 'dart:io';

import 'package:flutter/material.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/ImageComponents/image_upload_controller.dart';

class ImagePreview extends StatelessWidget {
  final ImageUploadController controller;
  final VoidCallback onPickImage;
  final Function(int) onRemoveImage;

  const ImagePreview({
    super.key,
    required this.controller,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: size.height * 0.35,
          margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child:
              controller.selectedPreviewImage != null
                  ? _buildImageView(context, theme)
                  : _buildEmptyState(context, theme),
        ),
        if (controller.isUploading || controller.isLoading)
          _buildLoadingOverlay(context, theme),
      ],
    );
  }

  Widget _buildImageView(BuildContext context, ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          controller.selectedPreviewImage!.isRemote
              ? Image.network(
                controller.selectedPreviewImage!.imageUrl!,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 48,
                          color: theme.colorScheme.error,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Không thể tải ảnh',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
              : Image.file(
                File(controller.selectedPreviewImage!.file!.path),
                fit: BoxFit.contain,
              ),

          // Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ảnh ${controller.selectedImageIndex + 1}/${controller.images.length}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.zoom_out_map, size: 20),
                        onPressed: () {},
                        color: Colors.white,
                        tooltip: 'Xem toàn màn hình',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, size: 20),
                        onPressed:
                            () => onRemoveImage(controller.selectedImageIndex),
                        color: Colors.white,
                        tooltip: 'Xóa ảnh này',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
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
            onPressed: onPickImage,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context, ThemeData theme) {
    String message;

    // Ưu tiên kiểm tra trạng thái vừa upload vừa delete
    if (controller.isUploading && controller.isDeleting) {
      message = 'Đang xử lý...';
    }
    // Chỉ upload
    else if (controller.isUploading) {
      message = 'Đang tải ảnh lên...';
    }
    // Chỉ delete
    else if (controller.isDeleting) {
      message = 'Đang xóa ảnh...';
    }
    // Chỉ load từ API
    else if (controller.isLoading) {
      message = 'Đang tải ảnh...';
    }
    // Mặc định (nếu không rơi vào trường hợp nào)
    else {
      message = 'Đang xử lý...';
    }

    return Positioned.fill(
      child: Container(
        margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: theme.colorScheme.primary),
              SizedBox(height: 16),
              Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
