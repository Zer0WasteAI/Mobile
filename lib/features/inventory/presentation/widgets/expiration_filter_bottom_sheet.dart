import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/expiration_status.dart';

class ExpirationFilterBottomSheet extends StatefulWidget {
  final Set<ExpirationStatus> initialSelectedStatuses;
  final ValueChanged<Set<ExpirationStatus>> onApply;

  const ExpirationFilterBottomSheet({
    super.key,
    required this.initialSelectedStatuses,
    required this.onApply,
  });

  @override
  State<ExpirationFilterBottomSheet> createState() =>
      _ExpirationFilterBottomSheetState();
}

class _ExpirationFilterBottomSheetState
    extends State<ExpirationFilterBottomSheet> {
  late Set<ExpirationStatus> _selectedStatuses;

  @override
  void initState() {
    super.initState();
    _selectedStatuses = Set<ExpirationStatus>.from(
      widget.initialSelectedStatuses,
    );
  }

  void _toggleSelection(ExpirationStatus status) {
    setState(() {
      if (_selectedStatuses.contains(status)) {
        _selectedStatuses.remove(status);
      } else {
        _selectedStatuses.add(status);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00B894);
    const Color mainTextColor = Color(0xFF3A3A3A);
    const Color secondaryTextColor = Color(0xFF70605A);
    const Color sheetBackgroundColor = Colors.white;

    final availableStatuses = ExpirationStatus.values.toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
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
            'Filtrar por Estado',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              color: mainTextColor,
            ),
          ),
          const SizedBox(height: 16.0),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableStatuses.length,
              itemBuilder: (context, index) {
                final status = availableStatuses[index];
                // Don't show the 'all' option in the multi-select sheet
                if (status == ExpirationStatus.all)
                  return const SizedBox.shrink();

                final isSelected = _selectedStatuses.contains(status);
                return CheckboxListTile(
                  title: Text(
                    status.displayName,
                    style: GoogleFonts.inter(color: mainTextColor),
                  ),
                  secondary: Icon(status.icon, color: secondaryTextColor),
                  value: isSelected,
                  onChanged: (bool? value) {
                    _toggleSelection(status);
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
                  widget.onApply(_selectedStatuses);
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
