// building_section.dart
import 'package:flutter/material.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_api_create_model.dart';

class BuildingSection extends StatefulWidget {
  final int? areaId;
  final List<BuildingCreateRequest> buildings;
  final bool isLoadingBuildings;
  final Function(BuildingCreateRequest?) onBuildingSelected;
  final Function(int?, String?) onBuildingDataChanged;
  final BuildingCreateRequest? initialSelectedBuilding;
  final String? floorNumber;
  final Function(String?) onFloorNumberChanged;
  final Function() onReloadBuildings;

  const BuildingSection({
    Key? key,
    required this.areaId,
    required this.buildings,
    this.isLoadingBuildings = false,
    required this.onBuildingSelected,
    required this.onBuildingDataChanged,
    this.initialSelectedBuilding,
    this.floorNumber,
    required this.onFloorNumberChanged,
    required this.onReloadBuildings,
  }) : super(key: key);

  @override
  State<BuildingSection> createState() => _BuildingSectionState();
}

class _BuildingSectionState extends State<BuildingSection> {
  final ApiService _apiService = ApiService();
  BuildingCreateRequest? _selectedBuilding;
  late TextEditingController _floorNumberController;

  @override
  void initState() {
    super.initState();
    _floorNumberController = TextEditingController(
      text: widget.floorNumber ?? '',
    );
    _selectedBuilding = widget.initialSelectedBuilding;
  }

  @override
  void didUpdateWidget(BuildingSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialSelectedBuilding != _selectedBuilding) {
      setState(() {
        _selectedBuilding = widget.initialSelectedBuilding;
      });
    }

    if (widget.floorNumber != _floorNumberController.text) {
      _floorNumberController.text = widget.floorNumber ?? '';
    }
  }

  @override
  void dispose() {
    _floorNumberController.dispose();
    super.dispose();
  }

  void _showCreateBuildingDialog() {
    final TextEditingController buildingNameController =
        TextEditingController();
    final _dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Tạo Tòa Nhà Mới'),
              content: Form(
                key: _dialogFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: buildingNameController,
                      decoration: InputDecoration(
                        labelText: 'Tên tòa nhà',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      enableSuggestions: true,
                      enableIMEPersonalizedLearning: true,
                      autocorrect: false,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên tòa nhà';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    if (widget.areaId == null)
                      Text(
                        'Vui lòng chọn khu vực trước khi tạo tòa nhà',
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
                  child: Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed:
                      widget.areaId == null
                          ? null
                          : () async {
                            if (_dialogFormKey.currentState!.validate()) {
                              // Set loading state
                              setDialogState(() {});

                              try {
                                final newBuilding = await _apiService
                                    .createBuilding(
                                      buildingNameController.text,
                                      widget.areaId!,
                                    );
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Tạo tòa nhà thành công!'),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                );
                                setState(() {
                                  _selectedBuilding = newBuilding;
                                });
                                widget.onBuildingSelected(newBuilding);
                                widget.onBuildingDataChanged(
                                  newBuilding.id,
                                  newBuilding.name,
                                );

                                if (widget.areaId != null) {
                                  widget.onReloadBuildings.call();
                                }
                              } catch (e) {
                                // Hiển thị thông báo lỗi
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Lỗi: ${e.toString()}'),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                  ),
                                );
                              }
                            }
                          },
                  child: Text('Tạo'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Custom styled dropdown for buildings
  Widget _buildStyledDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isLoading = false,
    bool isEnabled = true,
  }) {
    final theme = Theme.of(context);

    return Theme(
      data: Theme.of(context).copyWith(),
      child: AnimatedOpacity(
        opacity: isLoading ? 0.6 : 1.0,
        duration: Duration(milliseconds: 300),
        child: DecoratedBox(
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
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: theme.colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              suffixIcon:
                  isLoading
                      ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary.withOpacity(0.5),
                            ),
                          ),
                        ),
                      )
                      : null,
              enabled: isEnabled && !isLoading,
            ),
            items:
                items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
            onChanged: isEnabled && !isLoading ? onChanged : null,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng chọn $label';
              }
              return null;
            },
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
            menuMaxHeight: 200,
            dropdownColor: theme.colorScheme.surface,
          ),
        ),
      ),
    );
  }

  // Input field for floor number
  Widget _buildFloorNumberInput() {
    return TextFormField(
      controller: _floorNumberController,
      decoration: InputDecoration(
        labelText: 'Số tầng',
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
        // Section header
        _buildSectionHeader(
          title: 'Thông tin Tòa nhà',
          icon: Icons.apartment,
          theme: theme,
        ),
        SizedBox(height: 16),

        // Building dropdown with add button
        _buildStyledDropdown(
          label: 'Tòa nhà',
          icon: Icons.apartment,
          value: _selectedBuilding?.name,
          items: widget.buildings.map((building) => building.name).toList(),
          onChanged: (value) {
            if (value != null) {
              final building = widget.buildings.firstWhere(
                (b) => b.name == value,
                orElse:
                    () => BuildingCreateRequest(
                      id: -1,
                      name: '',
                      areaId: -1,
                      areaName: '',
                      status: -1,
                      statusName: '',
                    ),
              );

              if (building.id != -1) {
                setState(() {
                  _selectedBuilding = building;
                });

                // Update parent component
                widget.onBuildingSelected(building);
                widget.onBuildingDataChanged(building.id, building.name);
              }
            }
          },
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
              label: Text('Tạo tòa nhà mới'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        // Floor number input
        _buildFloorNumberInput(),
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
