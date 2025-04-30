import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart'; // Assuming AppColors exists
import 'package:zer0_waste_ai/features/inventory/domain/enums/storage_type.dart';

class StorageFilterBottomSheet extends StatefulWidget {
  final Set<StorageType> initialSelectedTypes;
  final ValueChanged<Set<StorageType>> onApply;

  const StorageFilterBottomSheet({
    super.key,
    required this.initialSelectedTypes,
    required this.onApply,
  });

  @override
  State<StorageFilterBottomSheet> createState() =>
      _StorageFilterBottomSheetState();
}

class _StorageFilterBottomSheetState extends State<StorageFilterBottomSheet> {
  late Set<StorageType> _selectedTypes;

  @override
  void initState() {
    super.initState();
    _selectedTypes = Set<StorageType>.from(widget.initialSelectedTypes);
  }

  void _toggleSelection(StorageType type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define colors (you might want to pass these or get from theme)
    const Color primaryColor = Color(0xFF00B894);
    const Color mainTextColor = Color(0xFF3A3A3A);
    const Color secondaryTextColor = Color(0xFF70605A);
    const Color sheetBackgroundColor = Colors.white;

    final availableTypes = StorageType.values.toList();

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: sheetBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar por Almacenamiento',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              color: mainTextColor,
            ),
          ),
          const SizedBox(height: 16.0),
          Flexible(
            // Allows the list to take remaining space but not overflow
            child: ListView.builder(
              shrinkWrap: true, // Important for Column
              itemCount: availableTypes.length,
              itemBuilder: (context, index) {
                final type = availableTypes[index];
                final isSelected = _selectedTypes.contains(type);
                return CheckboxListTile(
                  title: Text(
                    type.displayName,
                    style: GoogleFonts.inter(color: mainTextColor),
                  ),
                  secondary: Icon(type.icon, color: secondaryTextColor),
                  value: isSelected,
                  onChanged: (bool? value) {
                    _toggleSelection(type);
                  },
                  activeColor: primaryColor,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.inter(color: secondaryTextColor),
                ),
              ),
              const SizedBox(width: 12.0),
              ElevatedButton(
                onPressed: () {
                  widget.onApply(_selectedTypes);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: Text('Aplicar', style: GoogleFonts.inter()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
