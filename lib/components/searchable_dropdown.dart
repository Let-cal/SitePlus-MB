import 'package:flutter/material.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final T? selectedItem;
  final List<T> items;
  final Widget Function(T?) selectedItemBuilder;
  final Widget Function(T, bool isSelected) itemBuilder;
  final bool Function(T, String) filter;
  final void Function(T?) onChanged;
  final IconData icon;
  final bool isLoading;
  final bool isEnabled;
  final bool useNewUI;

  const SearchableDropdown({
    super.key,
    required this.selectedItem,
    required this.items,
    required this.selectedItemBuilder,
    required this.itemBuilder,
    required this.filter,
    required this.onChanged,
    required this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.useNewUI = false,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void didUpdateWidget(SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      setState(() {
        _filteredItems = widget.items;
      });
    }
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems =
            widget.items.where((item) => widget.filter(item, query)).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius =
        widget.useNewUI ? 16.0 : 12.0; // Điều chỉnh borderRadius

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow:
            widget.isLoading
                ? []
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color:
                widget.useNewUI
                    ? theme.colorScheme.primary.withOpacity(0.5) // Màu viền mới
                    : theme.colorScheme.outline.withOpacity(0.5), // Màu viền cũ
          ),
          color: theme.colorScheme.surface,
        ),
        child: ExpansionTile(
          onExpansionChanged: (expanded) {
            setState(() {
              _isDropdownOpen = expanded;
              if (!expanded) {
                _searchController.clear();
                _filterItems('');
              }
            });
          },
          leading: Icon(widget.icon, color: theme.colorScheme.primary),
          title: widget.selectedItemBuilder(widget.selectedItem),
          trailing:
              widget.isLoading
                  ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                  )
                  : Icon(
                    _isDropdownOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: theme.colorScheme.primary,
                  ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _filterItems('');
                            },
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      widget.useNewUI ? 16.0 : 8.0,
                    ),
                    borderSide: BorderSide(
                      color:
                          widget.useNewUI
                              ? theme.colorScheme.primary.withOpacity(0.5)
                              : theme.colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      widget.useNewUI ? 16.0 : 8.0,
                    ),
                    borderSide: BorderSide(
                      color:
                          widget.useNewUI
                              ? theme.colorScheme.primary.withOpacity(0.5)
                              : theme.colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      widget.useNewUI ? 16.0 : 8.0,
                    ),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 12.0,
                  ),
                ),
                onChanged: _filterItems,
              ),
            ),
            Container(
              constraints: BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: false,
                padding: EdgeInsets.symmetric(vertical: 8),
                itemCount: _filteredItems.length,
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final isSelected = item == widget.selectedItem;
                  return InkWell(
                    onTap:
                        widget.isEnabled && !widget.isLoading
                            ? () {
                              widget.onChanged(item);
                              setState(() {
                                _isDropdownOpen = false;
                                _searchController.clear();
                                _filterItems('');
                              });
                            }
                            : null,
                    child: widget.itemBuilder(item, isSelected),
                  );
                },
              ),
            ),
            if (_filteredItems.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No items found',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: theme.hintColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
