import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:siteplus_mb/service/api_service.dart';

class ImageItem {
  final XFile? file;
  final String? imageUrl;
  final int? imageId;
  final bool isUploaded;

  ImageItem({this.file, this.imageUrl, this.imageId, this.isUploaded = false})
    : assert(file != null || imageUrl != null);

  String get displayPath => imageUrl ?? file!.path;
  bool get isRemote => imageUrl != null && isUploaded;
}

class ImageUploadController extends ChangeNotifier {
  final List<ImageItem> _images;
  final int _maxImages;
  final int _siteId;
  final int? _buildingId;
  final bool _loadExistingImages;
  final ApiService _apiService = ApiService();
  final List<ImageItem> _deletedImages = []; // Ảnh bị xóa tạm thời
  final List<ImageItem> _newImages = []; // Ảnh mới thêm nhưng chưa upload
  final Function(List<ImageItem>) onImagesSelected;

  ImageItem? _selectedPreviewImage;
  int _selectedImageIndex = -1;
  bool _isUploading = false;
  bool _isLoading = false;
  bool _isDeleting = false;
  bool _hasLoadedExistingImages = false;

  List<ImageItem> get images => _images;
  List<ImageItem> get deletedImages => _deletedImages;
  List<ImageItem> get newImages => _newImages;
  ImageItem? get selectedPreviewImage => _selectedPreviewImage;
  int get selectedImageIndex => _selectedImageIndex;
  bool get isUploading => _isUploading;
  bool get isLoading => _isLoading;
  bool get isDeleting => _isDeleting;
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

  Future<void> removeImage(int index) async {
    if (index < 0 || index >= _images.length) return;
    final image = _images[index];

    // Thêm vào danh sách xóa tạm thời nếu là ảnh từ server
    if (image.isRemote) {
      _deletedImages.add(image);
    }
    // Xóa khỏi danh sách hiển thị
    _images.removeAt(index);
    _updateSelectedImageAfterRemoval(index);
    notifyListeners();
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
                .map(
                  (imageData) => ImageItem(
                    imageUrl: imageData['url'],
                    imageId: imageData['id'],
                    isUploaded: true,
                  ),
                )
                .toList();

        final existingIds =
            _images
                .where((img) => img.imageId != null)
                .map((img) => img.imageId)
                .toSet();
        final newImages =
            imageItems
                .where((img) => !existingIds.contains(img.imageId))
                .toList();

        if (newImages.isNotEmpty) {
          _images.addAll(newImages);
          if (_selectedImageIndex == -1 && _images.isNotEmpty) {
            _selectedPreviewImage = _images.first;
            _selectedImageIndex = 0;
          }
        }
        _hasLoadedExistingImages = true;
      }
    } catch (e) {
      rethrow; // Sử dụng rethrow thay vì throw e
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tách logic pickImage để giảm độ phức tạp
  Future<int> pickImage(BuildContext context) async {
    if (_images.length >= _maxImages) {
      throw Exception('Đã đạt số lượng ảnh tối đa ($_maxImages)');
    }
    print('pickImage called'); // Debug xem hàm có được gọi không
    final selectedImages = await _pickImagesFromGallery();
    return await _processSelectedImages(selectedImages);
  }

  Future<int> _processSelectedImages(List<XFile> selectedImages) async {
    print('Selected images count: ${selectedImages.length}');
    if (selectedImages.isEmpty) return 0;

    final remainingSlots = _maxImages - _images.length;
    final imagesToAdd = selectedImages.take(remainingSlots).toList();
    print('Images to add: ${imagesToAdd.length}');
    if (imagesToAdd.isEmpty) return 0;

    // Thêm ảnh mới vào danh sách tạm mà không upload ngay
    final newImageItems =
        imagesToAdd.map((file) => ImageItem(file: file)).toList();
    _newImages.addAll(newImageItems);
    _images.addAll(newImageItems);
    print('Total images after adding: ${_images.length}');
    if (_selectedImageIndex == -1 && _images.isNotEmpty) {
      _selectedPreviewImage = _images.first;
      _selectedImageIndex = 0;
    }

    notifyListeners();
    return newImageItems.length;
  }

  Future<List<XFile>> _pickImagesFromGallery() async {
    try {
      // Kiểm tra xem FilePicker.platform có sẵn không
      // ignore: unnecessary_null_comparison
      if (FilePicker.platform == null) {
        print('FilePicker.platform is not initialized');
        return [];
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        List<XFile> selectedImages =
            result.files
                .where(
                  (file) => file.path != null,
                ) // Đảm bảo file.path không null
                .map((file) => XFile(file.path!))
                .toList();
        print('Images picked from file picker: ${selectedImages.length}');
        return selectedImages;
      } else {
        print('No images selected from file picker');
        return [];
      }
    } catch (e) {
      print('Error picking images: $e');
      return [];
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

  void selectImage(int index) {
    _selectedImageIndex = index;
    _selectedPreviewImage = _images[index];
    notifyListeners();
  }

  Future<void> confirmSelection() async {
    _isUploading = true;
    if (_deletedImages.isNotEmpty) {
      _isDeleting = true;
    }
    notifyListeners();

    try {
      // Upload các ảnh mới
      if (_newImages.isNotEmpty) {
        final uploadedUrls = await _apiService.uploadImages(
          _newImages.map((item) => item.file!).toList(),
          _siteId,
          buildingId: _buildingId,
        );

        // Cập nhật danh sách ảnh với URL từ server
        for (int i = 0; i < min(_newImages.length, uploadedUrls.length); i++) {
          final index = _images.indexOf(_newImages[i]);
          if (index != -1) {
            _images[index] = ImageItem(
              file: _newImages[i].file,
              imageUrl: uploadedUrls[i],
              isUploaded: true,
            );
          }
        }
        _newImages.clear();
      }

      // Xóa các ảnh đã đánh dấu
      for (var image in _deletedImages) {
        if (image.imageId != null) {
          await _apiService.deleteImage(image.imageId!);
        }
      }
      _deletedImages.clear();

      onImagesSelected(_images);
    } catch (e) {
      rethrow;
    } finally {
      _isUploading = false;
      _isDeleting = false;
      notifyListeners();
    }
  }

  int min(int a, int b) => a < b ? a : b;
}
