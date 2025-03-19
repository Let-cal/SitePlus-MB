import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:siteplus_mb/service/api_service.dart';

class ImageUploadDialog extends StatefulWidget {
  final List<ImageItem> initialImages;
  final Function(List<ImageItem>) onImagesSelected;
  final int maxImages;
  final int siteId;
  final int? buildingId;
  final bool loadExistingImages;

  const ImageUploadDialog({
    Key? key,
    this.initialImages = const [],
    required this.onImagesSelected,
    this.maxImages = 3,
    required this.siteId,
    this.buildingId,
    this.loadExistingImages = true,
  }) : super(key: key);

  static Future<List<ImageItem>?> show(
    BuildContext context, {
    List<ImageItem> initialImages = const [],
    int maxImages = 3,
    required int siteId,
    int? buildingId,
    bool loadExistingImages = true,
  }) async {
    return await showDialog<List<ImageItem>>(
      context: context,
      builder:
          (context) => ImageUploadDialog(
            initialImages: initialImages,
            onImagesSelected: (images) {
              Navigator.of(context).pop(images);
            },
            maxImages: maxImages,
            siteId: siteId,
            buildingId: buildingId,
            loadExistingImages: loadExistingImages,
          ),
    );
  }

  @override
  State<ImageUploadDialog> createState() => _ImageUploadDialogState();
}

// Image item class to handle both local files and remote URLs
class ImageItem {
  final XFile? file;
  final String? imageUrl;
  final bool isUploaded;

  ImageItem({this.file, this.imageUrl, this.isUploaded = false})
    : assert(file != null || imageUrl != null);

  // Get display path (either file path or URL)
  String get displayPath => imageUrl ?? file!.path;

  // Check if this is a remote image
  bool get isRemote => imageUrl != null && isUploaded;
}

class _ImageUploadDialogState extends State<ImageUploadDialog>
    with SingleTickerProviderStateMixin {
  late List<ImageItem> _images;
  final ImagePicker _picker = ImagePicker();
  late AnimationController _controller;
  late Animation<double> _animation;
  ImageItem? _selectedPreviewImage;
  int _selectedImageIndex = -1;
  bool _isUploading = false;

  bool _isLoading = false;
  bool _hasLoadedExistingImages = false;
  // Initialize API service
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _images = List<ImageItem>.from(widget.initialImages);
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
    if (widget.loadExistingImages) {
      _loadExistingImages();
    }
  }

  Future<void> _loadExistingImages() async {
    if (_hasLoadedExistingImages) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final siteImages = await _apiService.getSiteImages(widget.siteId);

      if (siteImages.isNotEmpty) {
        final imageItems =
            siteImages
                .map((url) => ImageItem(imageUrl: url, isUploaded: true))
                .toList();

        setState(() {
          // Combine with any initial images, avoiding duplicates
          final existingUrls =
              _images
                  .where((img) => img.isRemote)
                  .map((img) => img.imageUrl)
                  .toSet();
          final newImages =
              imageItems
                  .where((img) => !existingUrls.contains(img.imageUrl))
                  .toList();

          if (newImages.isNotEmpty) {
            _images.addAll(newImages);

            // Select the first image if none is selected
            if (_selectedImageIndex == -1 && _images.isNotEmpty) {
              _selectedPreviewImage = _images.first;
              _selectedImageIndex = 0;
            }
          }

          _hasLoadedExistingImages = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể tải ảnh từ máy chủ: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        // Calculate how many more images we can add
        final remainingSlots = widget.maxImages - _images.length;
        final imagesToAdd = selectedImages.take(remainingSlots).toList();

        if (imagesToAdd.isNotEmpty) {
          setState(() {
            _isUploading = true;
          });

          try {
            // Upload the images
            final uploadedUrls = await _apiService.uploadImages(
              imagesToAdd,
              widget.siteId,
              buildingId: widget.buildingId,
            );

            // Create ImageItem objects with both file and URL
            final newImageItems = List.generate(
              math.min(imagesToAdd.length, uploadedUrls.length),
              (index) => ImageItem(
                file: imagesToAdd[index],
                imageUrl: uploadedUrls[index],
                isUploaded: true,
              ),
            );

            setState(() {
              _images.addAll(newImageItems);
              _isUploading = false;

              // Select the first newly added image if none is selected
              if (_selectedImageIndex == -1 && _images.isNotEmpty) {
                _selectedPreviewImage = _images.first;
                _selectedImageIndex = 0;
              }
            });

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Đã tải lên ${newImageItems.length} ảnh thành công!',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          } catch (error) {
            setState(() {
              _isUploading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Lỗi khi tải ảnh lên: $error',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
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
    final imageToRemove = _images[index];

    // Show confirmation dialog for remote images
    if (imageToRemove.isRemote) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Xác nhận xóa'),
              content: Text('Bạn có chắc chắn muốn xóa ảnh này không?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _images.removeAt(index);
                      _updateSelectedImageAfterRemoval(index);
                    });
                  },
                  child: Text('Xóa'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
      );
    } else {
      setState(() {
        _images.removeAt(index);
        _updateSelectedImageAfterRemoval(index);
      });
    }
  }

  void _updateSelectedImageAfterRemoval(int removedIndex) {
    if (_selectedImageIndex == removedIndex) {
      if (_images.isEmpty) {
        _selectedPreviewImage = null;
        _selectedImageIndex = -1;
      } else {
        _selectedImageIndex = 0;
        _selectedPreviewImage = _images[0];
      }
    } else if (_selectedImageIndex > removedIndex) {
      _selectedImageIndex--;
    }
  }

  void _selectImage(int index) {
    setState(() {
      _selectedImageIndex = index;
      _selectedPreviewImage = _images[index];
    });
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
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modern header with tab selection
              _buildHeader(context),

              // Main content
              Container(
                constraints: BoxConstraints(maxHeight: size.height * 0.7),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Image preview section
                      _buildImagePreview(context),

                      // Thumbnail gallery
                      _buildImageGallery(context),

                      // Info and action section
                      _buildActionSection(context),
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

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
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
          Row(
            children: [
              Icon(
                Icons.photo_library,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Quản lý hình ảnh',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
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
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: size.height * 0.35,
          margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child:
              _selectedPreviewImage != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _selectedPreviewImage!.isRemote
                            ? Image.network(
                              _selectedPreviewImage!.imageUrl!,
                              fit: BoxFit.contain,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
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
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              color: theme.colorScheme.error,
                                            ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                            : Image.file(
                              File(_selectedPreviewImage!.file!.path),
                              fit: BoxFit.contain,
                            ),
                        // Image metadata overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ảnh ${_selectedImageIndex + 1}/${_images.length}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.zoom_out_map, size: 20),
                                      onPressed: () {
                                        // Implement fullscreen preview
                                      },
                                      color: Colors.white,
                                      tooltip: 'Xem toàn màn hình',
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        size: 20,
                                      ),
                                      onPressed:
                                          () =>
                                              _removeImage(_selectedImageIndex),
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
                  )
                  : Center(
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
                          onPressed: _pickImage,
                        ),
                      ],
                    ),
                  ),
        ),
        if (_isUploading || _isLoading)
          Positioned.fill(
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
                      _isUploading ? 'Đang tải ảnh lên...' : 'Đang tải ảnh...',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageGallery(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
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
                  '${_images.length}/${widget.maxImages} ảnh',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 100,
            padding: EdgeInsets.only(bottom: 12, left: 12, right: 12),
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
                if (_images.length < widget.maxImages && !_isUploading)
                  _buildAddButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Info section
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin hình ảnh',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Định dạng: JPG, PNG • Kích thước tối đa: 10MB • Số lượng: ${widget.maxImages} ảnh',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Hủy'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(width: 16),
              FilledButton.icon(
                onPressed:
                    _isUploading || _isLoading
                        ? null
                        : () {
                          widget.onImagesSelected(_images);
                        },
                icon: Icon(Icons.check),
                label: Text('Xác nhận'),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Updated thumbnail rendering for better visuals
  Widget _buildImageThumbnail(ImageItem image, int index, bool isSelected) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _selectImage(index),
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
            // Overlay gradient for better visibility of icons
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

  // Updated add button with animation
  Widget _buildAddButton() {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 80,
        height: 80,
        margin: EdgeInsets.only(right: 8, top: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
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
