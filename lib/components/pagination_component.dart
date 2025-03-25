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
    // Nếu chỉ có 1 trang thì không hiển thị phân trang
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nút Previous
              _buildPaginationButton(
                context: context,
                icon: Icons.arrow_back_ios_rounded,
                onPressed:
                    currentPage > 1
                        ? () => onPageChanged(currentPage - 1)
                        : null,
              ),
              const SizedBox(width: 8),
              // Các số trang
              ..._buildPageNumbers(context),
              const SizedBox(width: 8),
              // Nút Next
              _buildPaginationButton(
                context: context,
                icon: Icons.arrow_forward_ios_rounded,
                onPressed:
                    currentPage < totalPages
                        ? () => onPageChanged(currentPage + 1)
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
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 18,
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

    // Xác định khoảng số trang hiển thị (2 trang trước và 2 trang sau trang hiện tại)
    int startPage = currentPage - 2;
    int endPage = currentPage + 2;

    if (startPage < 1) {
      endPage = math.min(endPage + (1 - startPage), totalPages);
      startPage = 1;
    }

    if (endPage > totalPages) {
      startPage = math.max(1, startPage - (endPage - totalPages));
      endPage = totalPages;
    }

    // Nếu trang đầu không nằm trong khoảng hiển thị, thêm nút trang đầu và dấu "..."
    if (startPage > 1) {
      pageButtons.add(_buildPageButton(context, 1));
      if (startPage > 2) {
        pageButtons.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '...',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        );
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(_buildPageButton(context, i));
    }

    // Nếu trang cuối không nằm trong khoảng hiển thị, thêm dấu "..." và nút trang cuối
    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        pageButtons.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '...',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        );
      }
      pageButtons.add(_buildPageButton(context, totalPages));
    }

    return pageButtons;
  }

  Widget _buildPageButton(BuildContext context, int page) {
    final theme = Theme.of(context);
    final bool isSelected = page == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: isSelected ? theme.colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: isSelected ? null : () => onPageChanged(page),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 36,
            height: 36,
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
