import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:siteplus_mb/service/api_service.dart';

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

class ImageUploadController extends ChangeNotifier {
  final List<ImageItem> _images;
  final int _maxImages;
  final int _siteId;
  final int? _buildingId;
  final bool _loadExistingImages;
  final ApiService _apiService = ApiService();

  final Function(List<ImageItem>) onImagesSelected;

  ImageItem? _selectedPreviewImage;
  int _selectedImageIndex = -1;
  bool _isUploading = false;
  bool _isLoading = false;
  bool _hasLoadedExistingImages = false;

  // Getters
  List<ImageItem> get images => _images;
  ImageItem? get selectedPreviewImage => _selectedPreviewImage;
  int get selectedImageIndex => _selectedImageIndex;
  bool get isUploading => _isUploading;
  bool get isLoading => _isLoading;
  int get maxImages => _maxImages;

  ImageUploadController({
    required List<ImageItem> initialImages,
    required this.onImagesSelected,
    required int maxImages,
    required int siteId,
    int? buildingId,
    bool loadExistingImages = true,
  }) : _images = List<ImageItem>.from(initialImages),
       _maxImages = maxImages,
       _siteId = siteId,
       _buildingId = buildingId,
       _loadExistingImages = loadExistingImages {
    if (_images.isNotEmpty) {
      _selectedPreviewImage = _images.first;
      _selectedImageIndex = 0;
    }

    if (_loadExistingImages) {
      _loadExistingImagesFromServer();
    }
  }

  Future<void> _loadExistingImagesFromServer() async {
    if (_hasLoadedExistingImages) return;

    _isLoading = true;
    notifyListeners();

    try {
      final siteImages = await _apiService.getSiteImages(_siteId);

      if (siteImages.isNotEmpty) {
        final imageItems =
            siteImages
                .map((url) => ImageItem(imageUrl: url, isUploaded: true))
                .toList();

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
      }
    } catch (e) {
      // Error handling remains the same
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> pickImage(BuildContext context) async {
    if (_images.length >= _maxImages) {
      throw Exception('Đã đạt số lượng ảnh tối đa ($_maxImages)');
    }

    final ImagePicker picker = ImagePicker();

    try {
      final List<XFile> selectedImages = await picker.pickMultiImage();
      if (selectedImages.isNotEmpty) {
        final remainingSlots = _maxImages - _images.length;
        final imagesToAdd = selectedImages.take(remainingSlots).toList();

        if (imagesToAdd.isNotEmpty) {
          _isUploading = true;
          notifyListeners();

          try {
            final uploadedUrls = await _apiService.uploadImages(
              imagesToAdd,
              _siteId,
              buildingId: _buildingId,
            );

            final newImageItems = List.generate(
              min(imagesToAdd.length, uploadedUrls.length),
              (index) => ImageItem(
                file: imagesToAdd[index],
                imageUrl: uploadedUrls[index],
                isUploaded: true,
              ),
            );

            _images.addAll(newImageItems);

            if (_selectedImageIndex == -1 && _images.isNotEmpty) {
              _selectedPreviewImage = _images.first;
              _selectedImageIndex = 0;
            }

            return newImageItems.length;
          } finally {
            _isUploading = false;
            notifyListeners();
          }
        }
      }
      return 0;
    } catch (e) {
      rethrow;
    }
  }

  void removeImage(int index) {
    _images.removeAt(index);
    _updateSelectedImageAfterRemoval(index);
    notifyListeners();
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

  void selectImage(int index) {
    _selectedImageIndex = index;
    _selectedPreviewImage = _images[index];
    notifyListeners();
  }

  void confirmSelection() {
    onImagesSelected(_images);
  }

  // Utility
  int min(int a, int b) => a < b ? a : b;
}
