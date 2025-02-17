import 'package:flutter/material.dart';

class CustomChipGroup extends StatefulWidget {
  final List<String> options;
  final List<String> selectedOptions;
  final List<String> customOptions;
  final Map<String, IconData> optionIcons;
  final Function(String) onOptionSelected;
  final Function(String) onCustomOptionAdded;
  final Function(String) onCustomOptionRemoved;

  const CustomChipGroup({
    Key? key,
    required this.options,
    required this.selectedOptions,
    required this.customOptions,
    required this.optionIcons,
    required this.onOptionSelected,
    required this.onCustomOptionAdded,
    required this.onCustomOptionRemoved,
  }) : super(key: key);

  @override
  _CustomChipGroupState createState() => _CustomChipGroupState();
}

class _CustomChipGroupState extends State<CustomChipGroup> {
  final TextEditingController _otherController = TextEditingController();
  static const IconData _otherIcon = Icons.edit;

  void _addOtherOption() {
    final value = _otherController.text.trim();
    if (value.isNotEmpty && !widget.customOptions.contains(value)) {
      widget.onCustomOptionAdded(value);
      _otherController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Preset chips
            ...widget.options.map((option) {
              final isSelected = widget.selectedOptions.contains(option);
              return FilterChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (_) => widget.onOptionSelected(option),
                avatar: Icon(widget.optionIcons[option], size: 18),
                showCheckmark: false,
              );
            }),

            // Custom chips
            ...widget.customOptions.map((option) {
              return FilterChip(
                label: Text(option),
                selected: true,
                onSelected:
                    (_) => widget.onCustomOptionRemoved(
                      option,
                    ), // Enable interaction
                avatar: const Icon(_otherIcon, size: 18),
                showCheckmark: false,
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => widget.onCustomOptionRemoved(option),
              );
            }),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _otherController,
          decoration: InputDecoration(
            labelText: 'Add other option',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addOtherOption,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (_) => _addOtherOption(),
        ),
      ],
    );
  }
}
