// building_section.dart
import 'package:flutter/material.dart';
import 'package:siteplus_mb/components/searchable_dropdown.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_api_create_model.dart';
import 'package:siteplus_mb/utils/string_utils.dart';

class BuildingSection extends StatefulWidget {
  final int? areaId;
  final List<BuildingCreateRequest> buildings;
  final bool isLoadingBuildings;
  final Function(BuildingCreateRequest?) onBuildingSelected;
  final Function(int?, String?) onBuildingDataChanged;
  final BuildingCreateRequest? initialSelectedBuilding;
  final String? totalFloorNumber;
  final Function(String?) onFloorNumberChanged;
  final Function() onReloadBuildings;

  const BuildingSection({
    super.key,
    required this.areaId,
    required this.buildings,
    this.isLoadingBuildings = false,
    required this.onBuildingSelected,
    required this.onBuildingDataChanged,
    this.initialSelectedBuilding,
    this.totalFloorNumber,
    required this.onFloorNumberChanged,
    required this.onReloadBuildings,
  });

  @override
  State<BuildingSection> createState() => _BuildingSectionState();
}

class _BuildingSectionState extends State<BuildingSection> {
  final ApiService _apiService = ApiService();
  BuildingCreateRequest? _selectedBuilding;
  late TextEditingController _totalFloorNumberController;
  late TextEditingController _searchController;
  List<BuildingCreateRequest> _filteredBuildings = [];
  bool _isSearching = false;
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _totalFloorNumberController = TextEditingController(
      text: widget.totalFloorNumber ?? '',
    );
    _searchController = TextEditingController();
    _selectedBuilding = widget.initialSelectedBuilding;
    _filteredBuildings = List.from(widget.buildings);
  }

  @override
  void didUpdateWidget(BuildingSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialSelectedBuilding != _selectedBuilding) {
      setState(() {
        _selectedBuilding = widget.initialSelectedBuilding;
      });
    }

    if (widget.totalFloorNumber != _totalFloorNumberController.text) {
      _totalFloorNumberController.text = widget.totalFloorNumber ?? '';
    }
    if (widget.buildings != oldWidget.buildings) {
      setState(() {
        _filteredBuildings = List.from(widget.buildings);
        _filterBuildings(_searchController.text);
      });
    }
  }

  @override
  void dispose() {
    _totalFloorNumberController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterBuildings(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBuildings = List.from(widget.buildings);
      } else {
        final normalizedQuery = StringUtils.normalizeString(query);
        _filteredBuildings =
            widget.buildings.where((building) {
              final normalizedBuildingName = StringUtils.normalizeString(
                building.name,
              );
              return normalizedBuildingName.contains(normalizedQuery);
            }).toList();
      }
    });
  }

  void _showCreateBuildingDialog() {
    final TextEditingController buildingNameController =
        TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Create New Building'),
              content: Form(
                key: dialogFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: buildingNameController,
                      decoration: InputDecoration(
                        labelText: 'Building Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the building name';
                        }

                        // Case-insensitive comparison and contains check
                        final String normalizedInput =
                            value.trim().toLowerCase();

                        // Check for exact duplicate
                        final bool isExactDuplicate = widget.buildings.any(
                          (building) =>
                              building.name.toLowerCase() == normalizedInput,
                        );
                        if (isExactDuplicate) {
                          return 'A building with this name already exists';
                        }

                        // Check for partial match (if existing name contains input or input contains existing name)
                        for (var building in widget.buildings) {
                          final String existingName =
                              building.name.toLowerCase();
                          // Check if user input contains an existing building name
                          if (normalizedInput.contains(existingName) &&
                              existingName.length > 3) {
                            return 'Name too similar to existing building: ${building.name}';
                          }

                          // Check if existing building name contains user input
                          if (existingName.contains(normalizedInput) &&
                              normalizedInput.length > 3) {
                            return 'Name too similar to existing building: ${building.name}';
                          }
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    if (widget.areaId == null)
                      Text(
                        'Please select an area before creating a building',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed:
                      widget.areaId == null
                          ? null
                          : () async {
                            if (dialogFormKey.currentState!.validate()) {
                              setDialogState(() {});

                              try {
                                final newBuilding = await _apiService
                                    .createBuilding(
                                      buildingNameController.text,
                                      widget.areaId!,
                                    );
                                Navigator.of(context).pop();

                                // Update the buildings list before selecting
                                await widget.onReloadBuildings();

                                setState(() {
                                  _selectedBuilding = newBuilding;
                                });

                                widget.onBuildingSelected(newBuilding);
                                widget.onBuildingDataChanged(
                                  newBuilding.id,
                                  newBuilding.name,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Building created successfully!',
                                    ),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                  ),
                                );
                              }
                            }
                          },
                  child: Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Custom dropdown with integrated search
  Widget _buildIntegratedDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<BuildingCreateRequest> items,
    required Function(BuildingCreateRequest?) onChanged,
    bool isLoading = false,
    bool isEnabled = true,
  }) {
    final theme = Theme.of(context);

    return Theme(
      data: Theme.of(context).copyWith(),
      child: AnimatedOpacity(
        opacity: isLoading ? 0.6 : 1.0,
        duration: Duration(milliseconds: 300),
        child: Column(
          children: [
            // Integrated dropdown with search
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow:
                    isLoading
                        ? []
                        : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
              ),
              child: DropdownButtonHideUnderline(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.5),
                    ),
                    color: theme.colorScheme.surface,
                  ),
                  child: ExpansionTile(
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _isDropdownOpen = expanded;
                        if (!expanded) {
                          // Clear search when closing dropdown
                          _searchController.clear();
                          _filterBuildings('');
                        }
                      });
                    },
                    leading: Icon(icon, color: theme.colorScheme.primary),
                    title: Text(
                      value?.isNotEmpty == true ? value! : label,
                      style: TextStyle(
                        color:
                            value?.isNotEmpty == true
                                ? theme.textTheme.bodyLarge?.color
                                : theme.hintColor,
                        fontWeight:
                            value?.isNotEmpty == true
                                ? FontWeight.w500
                                : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing:
                        isLoading
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
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    children: [
                      // Search bar inside dropdown
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Search Building',
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
                                        _filterBuildings('');
                                      },
                                    )
                                    : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline.withOpacity(
                                  0.5,
                                ),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 12.0,
                            ),
                          ),
                          onChanged: (value) {
                            _filterBuildings(value);
                          },
                        ),
                      ),

                      // List of filtered buildings
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: 250, // Limit height of dropdown list
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          itemCount: _filteredBuildings.length,
                          itemBuilder: (context, index) {
                            final building = _filteredBuildings[index];
                            final isSelected =
                                _selectedBuilding?.id == building.id;

                            return InkWell(
                              onTap:
                                  isEnabled && !isLoading
                                      ? () {
                                        setState(() {
                                          _selectedBuilding = building;
                                          _isDropdownOpen = false;
                                          // Clear search when selecting an item
                                          _searchController.clear();
                                          _filterBuildings('');
                                        });
                                        onChanged(building);
                                      }
                                      : null,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 16.0,
                                ),
                                color:
                                    isSelected
                                        ? theme.colorScheme.primary.withOpacity(
                                          0.1,
                                        )
                                        : null,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.business,
                                      size: 18,
                                      color:
                                          isSelected
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onSurface
                                                  .withOpacity(0.6),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        building.name,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                          color:
                                              isSelected
                                                  ? theme.colorScheme.primary
                                                  : null,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check,
                                        color: theme.colorScheme.primary,
                                        size: 18,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      if (_filteredBuildings.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No buildings found',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: theme.hintColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Input field for floor number
  Widget _buildTotalFloorNumberInput() {
    return TextFormField(
      controller: _totalFloorNumberController,
      decoration: InputDecoration(
        labelText: 'Total number of floors',
        prefixIcon: Icon(
          Icons.stairs,
          color: Theme.of(context).colorScheme.primary,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      onChanged: (value) {
        debugPrint('TotalFloor changed from BuildingSection: $value');
        widget.onFloorNumberChanged(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Building dropdown with add button
        SearchableDropdown<BuildingCreateRequest>(
          selectedItem: _selectedBuilding,
          items: widget.buildings,
          selectedItemBuilder:
              (building) =>
                  building != null
                      ? Text(
                        building.name,
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )
                      : Text(
                        'Select Building',
                        style: TextStyle(
                          color: theme.hintColor,
                          fontWeight: FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
          itemBuilder:
              (building, isSelected) => Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                color:
                    isSelected
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : null,
                child: Row(
                  children: [
                    Icon(
                      Icons.business,
                      size: 18,
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        building.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? theme.colorScheme.primary : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check,
                        color: theme.colorScheme.primary,
                        size: 18,
                      ),
                  ],
                ),
              ),
          filter: (building, query) {
            final normalizedQuery = StringUtils.normalizeString(query);
            final normalizedName = StringUtils.normalizeString(building.name);
            return normalizedName.contains(normalizedQuery);
          },
          onChanged: (building) {
            setState(() {
              _selectedBuilding = building;
            });
            widget.onBuildingSelected(building);
            if (building != null) {
              widget.onBuildingDataChanged(building.id, building.name);
            } else {
              widget.onBuildingDataChanged(null, null);
            }
          },
          icon: Icons.apartment,
          isLoading: widget.isLoadingBuildings,
          isEnabled: widget.areaId != null && widget.buildings.isNotEmpty,
        ),
        SizedBox(height: 8),

        // Add new building button
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed:
                  widget.areaId == null ? null : _showCreateBuildingDialog,
              icon: Icon(Icons.add, size: 18),
              label: Text('Create New Building'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        // Floor number input
        _buildTotalFloorNumberInput(),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
