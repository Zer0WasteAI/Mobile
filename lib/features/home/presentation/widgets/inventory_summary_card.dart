import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/home/application/providers/home_providers.dart'; // Import provider

class InventorySummaryCard extends ConsumerWidget {
  const InventorySummaryCard({super.key});

  // Define colors locally
  static const Color _primaryColor = Color(0xFF00B894);
  static const Color _accentColor = Color(0xFFF07548);
  static const Color _mainTextColor = Color(0xFF3A3A3A);
  static const Color _secondaryTextColor = Color(0xFF70605A);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(inventorySummaryProvider);

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: Colors.white, // Explicitly white background
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Image.asset(
              'assets/icons/home/ingredients_inventory.png',
              height: 60,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingredientes activos: ${summary.activeItems}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _mainTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Próximos a vencer: ${summary.expiringSoonItems}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color:
                          summary.expiringSoonItems > 0
                              ? _accentColor
                              : _secondaryTextColor, // Orange if items are expiring
                      fontWeight:
                          summary.expiringSoonItems > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                // TODO: Implement navigation to inventory screen
                print("Navigate to Inventory Screen");
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                minimumSize: Size.zero, // Remove default min size
                tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap, // Reduce tap area
                foregroundColor: _primaryColor,
              ),
              child: Text(
                'Ver Inventario',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
