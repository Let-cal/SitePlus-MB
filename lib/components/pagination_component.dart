import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PaginationComponent extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final void Function(int) onPageChanged;

  const PaginationComponent({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ), // Giảm padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nút Previous More (nhảy về trang 1)
              _buildPaginationButton(
                context: context,
                icon: Icons.fast_rewind,
                onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
              ),
              const SizedBox(width: 4), // Giảm khoảng cách
              // Nút Previous
              _buildPaginationButton(
                context: context,
                icon: Icons.arrow_back_ios_rounded,
                onPressed:
                    currentPage > 1
                        ? () => onPageChanged(currentPage - 1)
                        : null,
              ),
              const SizedBox(width: 4),
              // Các số trang
              ..._buildPageNumbers(context),
              const SizedBox(width: 4),
              // Nút Next
              _buildPaginationButton(
                context: context,
                icon: Icons.arrow_forward_ios_rounded,
                onPressed:
                    currentPage < totalPages
                        ? () => onPageChanged(currentPage + 1)
                        : null,
              ),
              const SizedBox(width: 4),
              // Nút Next More (nhảy về trang cuối)
              _buildPaginationButton(
                context: context,
                icon: Icons.fast_forward,
                onPressed:
                    currentPage < totalPages
                        ? () => onPageChanged(totalPages)
                        : null,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildPaginationButton({
    required BuildContext context,
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    final theme = Theme.of(context);
    return Material(
      color:
          onPressed != null
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8), // Giảm padding
          child: Icon(
            icon,
            size: 16, // Giảm kích thước icon
            color:
                onPressed != null
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers(BuildContext context) {
    final theme = Theme.of(context);
    List<Widget> pageButtons = [];

    // Giới hạn tối đa số lượng nút số trang hiển thị
    const int maxVisiblePages = 5;

    // Xác định khoảng số trang hiển thị
    int startPage = currentPage - (maxVisiblePages ~/ 2);
    int endPage = currentPage + (maxVisiblePages ~/ 2);

    if (startPage < 1) {
      endPage = math.min(maxVisiblePages, totalPages);
      startPage = 1;
    }

    if (endPage > totalPages) {
      startPage = math.max(1, totalPages - maxVisiblePages + 1);
      endPage = totalPages;
    }

    // Đảm bảo chỉ hiển thị tối đa 5 nút số trang
    if (endPage - startPage + 1 > maxVisiblePages) {
      endPage = startPage + maxVisiblePages - 1;
    }

    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(_buildPageButton(context, i));
    }

    return pageButtons;
  }

  Widget _buildPageButton(BuildContext context, int page) {
    final theme = Theme.of(context);
    final bool isSelected = page == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2), // Giảm khoảng cách
      child: Material(
        color: isSelected ? theme.colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: isSelected ? null : () => onPageChanged(page),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 32, // Giảm kích thước nút
            height: 32,
            alignment: Alignment.center,
            decoration:
                isSelected
                    ? null
                    : BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
            child: Text(
              page.toString(),
              style: TextStyle(
                fontSize: 12, // Giảm kích thước chữ
                color:
                    isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
