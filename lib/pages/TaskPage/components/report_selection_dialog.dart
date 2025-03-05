import 'package:flutter/material.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/Site/site_category.dart';
import 'package:siteplus_mb/utils/Site/site_category_provider.dart';

class ReportSelectionDialog extends StatefulWidget {
  final Function(String, int, String) onReportSelected;
  final String token;

  const ReportSelectionDialog({
    super.key,
    required this.onReportSelected,
    required this.token,
  });

  @override
  _ReportSelectionDialogState createState() => _ReportSelectionDialogState();
}

class _ReportSelectionDialogState extends State<ReportSelectionDialog> {
  final ApiService _apiService = ApiService();
  final SiteCategoriesProvider _categoriesProvider = SiteCategoriesProvider();
  List<SiteCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeCategories();
  }

  Future<void> _initializeCategories() async {
    // Đặt trạng thái loading ban đầu
    setState(() {
      _isLoading = true;
    });

    // Kiểm tra xem categories đã được load chưa
    if (_categoriesProvider.isLoaded) {
      print(
        'Using cached categories: ${_categoriesProvider.categories.length} categories',
      );
      setState(() {
        _categories = _categoriesProvider.categories;
        _isLoading =
            false; // Quan trọng: Phải đặt isLoading = false khi dùng cached data
      });
    } else {
      // Fallback để fetch categories
      try {
        print('Fetching categories from API');
        final categories = await _apiService.getSiteCategories(widget.token);
        _categoriesProvider.setCategories(categories);

        if (mounted) {
          setState(() {
            _categories = categories;
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Error fetching categories: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header với nút đóng (X)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Chọn loại báo cáo",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _isLoading
                ? const CircularProgressIndicator()
                : _buildCategoriesList(),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    if (_categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "Không có dữ liệu loại báo cáo",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_categories.length * 2 - 1, (index) {
        // Nếu index là số chẵn, hiển thị mục danh sách
        if (index % 2 == 0) {
          final categoryIndex = index ~/ 2;
          final category = _categories[categoryIndex];

          return _buildOption(
            context,
            icon: categoryIndex == 0 ? Icons.business : Icons.apartment,
            title: category.name,
            value: category.id.toString(),
            categoryId: category.id,
          );
        } else {
          // Hiển thị divider giữa các mục
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 24,
              thickness: 1.2,
              color: Theme.of(context).dividerColor,
            ),
          );
        }
      }),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required int categoryId,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        Navigator.of(context).pop();
        widget.onReportSelected(value, categoryId, title);
      },
    );
  }
}
