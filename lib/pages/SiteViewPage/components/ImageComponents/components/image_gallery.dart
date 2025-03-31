import 'dart:io';

import 'package:flutter/material.dart';
import 'package:siteplus_mb/pages/SiteViewPage/components/ImageComponents/image_upload_controller.dart';

class ImageGallery extends StatelessWidget {
  final ImageUploadController controller;
  final VoidCallback onPickImage;
  final Function(int) onRemoveImage;

  const ImageGallery({
    super.key,
    required this.controller,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Thư viện ảnh',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${controller.images.length}/${controller.maxImages} ảnh',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
          height: 100,
          padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
          child: controller.images.isEmpty && !controller.isUploading
              ? const Center(child: Text('Chưa có ảnh nào'))
              : ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...controller.images.asMap().entries.map((entry) {
                      return _buildImageThumbnail(
                        context,
                        entry.value,
                        entry.key,
                        entry.key == controller.selectedImageIndex,
                      );
                    }),
                    if (controller.images.length < controller.maxImages &&
                        !controller.isUploading)
                      _buildAddButton(context),
                  ],
                ),
        ),
      ],
    ),
  );
}

  Widget _buildImageThumbnail(
    BuildContext context,
    ImageItem image,
    int index,
    bool isSelected,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => controller.selectImage(index),
      child: Container(
        width: 80,
        height: 80,
        margin: EdgeInsets.only(right: 8, top: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.5),
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
              child:
                  image.isRemote
                      ? Image.network(
                        image.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 20,
                              color: theme.colorScheme.error,
                            ),
                          );
                        },
                      )
                      : Image.file(File(image.file!.path), fit: BoxFit.cover),
            ),

            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  gradient:
                      isSelected
                          ? LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.4),
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.7],
                          )
                          : null,
                ),
              ),
            ),

            // Remove button
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => onRemoveImage(index),
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

            // Selection indicator
            if (isSelected)
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check,
                        size: 10,
                        color: theme.colorScheme.onPrimary,
                      ),
                      SizedBox(width: 2),
                      Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onPickImage,
      child: Container(
        width: 80,
        height: 80,
        margin: EdgeInsets.only(right: 8, top: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_photo_alternate,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Thêm ảnh',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Utility function
  int min(int a, int b) {
    return a < b ? a : b;
  }
}
