import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_category.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_category_provider.dart';

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
  late SiteCategoriesProvider _categoriesProvider;
  List<SiteCategory> _categories = [];
  bool _isLoading = true;

  final Map<String, String> categoryNameMapping = {
    'Mặt bằng nội khu': 'Internal Site',
    'Mặt bằng độc lập': 'Independent site',
  };
  @override
  void initState() {
    super.initState();
    _categoriesProvider = Provider.of<SiteCategoriesProvider>(
      context,
      listen: false,
    );
    _initializeCategories();
  }

  Future<void> _initializeCategories() async {
    setState(() {
      _isLoading = true;
    });

    if (_categoriesProvider.isLoaded) {
      print(
        'Using cached categories: ${_categoriesProvider.categories.length} categories',
      );
      setState(() {
        _categories = _categoriesProvider.categories;
        _isLoading = false;
      });
    } else {
      try {
        print('Fetching categories from API');
        final categories = await ApiService().getSiteCategories(widget.token);
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
                  "Select Report Type",
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
          "No report type data available",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_categories.length * 2 - 1, (index) {
        if (index % 2 == 0) {
          final categoryIndex = index ~/ 2;
          final category = _categories[categoryIndex];
          final englishName =
              categoryNameMapping[category.name] ?? category.name;
          return _buildOption(
            context,
            icon: categoryIndex == 0 ? Icons.business : Icons.apartment,
            title: englishName, // Sử dụng tên tiếng Anh
            value: englishName,
            categoryId: category.id,
          );
        } else {
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
        widget.onReportSelected(value, categoryId, title);
      },
    );
  }
}
