import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/home/application/providers/home_providers.dart'; // Import provider
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider_config.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart'; // Import AppColors
import 'package:go_router/go_router.dart'; // Import GoRouter

class InventorySummaryCard extends ConsumerWidget {
  const InventorySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get colors from theme
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBackgroundColor =
        isDark ? AppColors.darkSurface : Colors.white;
    final Color primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final Color mainTextColor =
        isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final Color secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final Color expiringSoonColor =
        isDark ? AppColors.warningTextDark : AppColors.warningTextLight;

    final summary = ref.watch(inventorySummaryProvider);
    final inventoryState = ref.watch(inventoryStateProvider);
    final isLoading = inventoryState.isLoading;

    return Card(
      elevation: isDark ? 1 : 2, // Less elevation in dark mode
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: cardBackgroundColor, // Use theme-aware card color
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
                  Row(
                    children: [
                      if (isLoading) ...[
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          isLoading
                              ? 'Cargando inventario...'
                              : 'Ingredientes activos: ${summary.activeItems}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: mainTextColor, // Use theme color
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (!isLoading)
                    Text(
                      'Próximos a vencer: ${summary.expiringSoonItems}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color:
                            summary.expiringSoonItems > 0
                                ? expiringSoonColor // Use theme warning color
                                : secondaryTextColor, // Use theme color
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
                // Navigate to the inventory screen
                context.go('/inventory');
                // print("Navigate to Inventory Screen"); // Original print statement
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                minimumSize: Size.zero, // Remove default min size
                tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap, // Reduce tap area
                foregroundColor: primaryColor, // Use theme color
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
