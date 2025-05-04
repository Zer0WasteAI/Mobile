import 'dart:developer'; // For logging date picker errors

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart'; // Use hooks for local state
import 'package:hooks_riverpod/hooks_riverpod.dart'; // Use hooks_riverpod
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/storage_type.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/expiration_status.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/item_category.dart'; // Import ItemCategory
import 'package:zer0_waste_ai/core/utils/date_extensions.dart'; // Import the extension
import 'package:zer0_waste_ai/features/inventory/presentation/screens/inventory_screen.dart'; // For quantity dialog

// TODO: Define route name constant if needed elsewhere
// const String ingredientDetailRouteName = 'ingredientDetail';

// Using HooksConsumerWidget for local state management (like the selected date)
class IngredientDetailScreen extends HookConsumerWidget {
  final String itemId;

  const IngredientDetailScreen({super.key, required this.itemId});

  // --- Helper Methods (Moved outside build for clarity) ---

  // Helper to get expiration status and associated data
  ({
    String text,
    Color color,
    IconData icon,
    bool isExpired,
    bool isExpiringSoon,
  })
  _getExpirationInfo(DateTime? expirationDate, BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color errorColor = AppColors.error;
    final Color warningColor =
        isDark ? AppColors.warningTextDark : AppColors.warningTextLight;
    final Color defaultColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    // Use the extension method for the text part
    final String expirationText = expirationDate.formatExpirationStatus();

    // Keep the logic for color/icon based on days difference
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final expiryDateOnly = DateUtils.dateOnly(expirationDate!);
    final differenceInDays = expiryDateOnly.difference(today).inDays;

    if (differenceInDays < 0) {
      return (
        text: expirationText, // Use text from extension
        color: errorColor,
        icon: Icons.error_outline,
        isExpired: true,
        isExpiringSoon: false,
      );
    } else if (differenceInDays <= 1) {
      // Adjusted threshold for warning icon/color (Vence hoy/mañana)
      return (
        text: expirationText, // Use text from extension
        color: warningColor,
        icon: Icons.warning_amber_outlined,
        isExpired: false,
        isExpiringSoon: true, // Consider today/tomorrow as 'soon'
      );
    } else {
      return (
        text: expirationText, // Use text from extension
        color: defaultColor,
        icon: Icons.check_circle_outline,
        isExpired: false,
        isExpiringSoon: false,
      );
    }
  }

  // Helper to show Date Picker
  Future<void> _selectDate(
    BuildContext context,
    ValueNotifier<DateTime?> selectedDateNotifier,
    DateTime? initialDate,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateNotifier.value ?? initialDate ?? DateTime.now(),
      firstDate: DateTime(2000), // Allow past dates for initial entry
      lastDate: DateTime(2101),
      // You can customize the theme here if needed
    );
    if (picked != null && picked != selectedDateNotifier.value) {
      log('Date selected: $picked'); // Log the picked date
      // Ensure the new value is not null before assigning
      selectedDateNotifier.value = picked;
    } else {
      log('Date selection cancelled or unchanged.');
    }
  }

  // Updated _selectDate to call notifier directly
  Future<void> _selectDateAndUpdate(
    BuildContext context,
    WidgetRef ref,
    InventoryItem item,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          item.expirationDate ?? DateTime.now(), // Use current item date
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != item.expirationDate) {
      log('Date selected: $picked. Updating notifier.');
      ref
          .read(inventoryProvider.notifier)
          .updateExpirationDate(item.id, picked);
    } else {
      log('Date selection cancelled or unchanged.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryState = ref.watch(inventoryProvider);
    final item = inventoryState.items.firstWhere(
      (item) => item.id == itemId,
      orElse: () => InventoryItem.empty(),
    );

    // Get all batches for this ingredient
    final allBatchesForIngredient =
        inventoryState.items
            .where(
              (batchItem) =>
                  batchItem.name == item.name &&
                  batchItem.category == item.category,
            )
            .toList();

    // Sort batches by expiration date
    allBatchesForIngredient.sort((a, b) {
      if (a.expirationDate == null && b.expirationDate == null) return 0;
      if (a.expirationDate == null) return 1;
      if (b.expirationDate == null) return -1;
      return a.expirationDate!.compareTo(b.expirationDate!);
    });

    final inventoryNotifier = ref.read(inventoryProvider.notifier);

    if (item.id.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Ingrediente no encontrado.')),
      );
    }

    // --- Theme and Colors ---
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color primaryGreen = const Color(0xFF00B894); // Defined green color
    final Color screenBackgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final Color mainTextColor =
        isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final Color secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final Color cardBackgroundColor =
        isDark ? AppColors.darkSurface : Colors.white;
    final Color lightGrayBackground = Colors.grey.shade200;
    final Color darkGrayBackground = Colors.grey.shade700;
    final Color chipBackgroundColor =
        isDark ? darkGrayBackground : lightGrayBackground;
    final Color tipBackgroundColor =
        isDark ? AppColors.darkFormBackground : AppColors.lightFormBackground;

    // Get expiration info based on the item's date directly
    final expirationInfo = _getExpirationInfo(item.expirationDate, context);

    // --- Build Method ---
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Ingrediente',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: mainTextColor,
            fontSize: textTheme.titleLarge?.fontSize,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: mainTextColor),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // --- 1. Encabezado visual ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
              child: Column(
                children: [
                  Text(
                    item.image.isNotEmpty ? item.image : '🍲',
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: textTheme.headlineMedium?.fontSize,
                      fontWeight: FontWeight.bold,
                      color: mainTextColor,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Chip(
                    label: Text(item.storageType.displayName),
                    backgroundColor: chipBackgroundColor,
                    labelStyle: GoogleFonts.inter(
                      color: secondaryTextColor,
                      fontSize: 12,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      side: BorderSide.none,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),

          // --- 2. Lotes disponibles ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lotes disponibles',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: mainTextColor,
                        ),
                      ),
                      Text(
                        '${allBatchesForIngredient.length} lote${allBatchesForIngredient.length > 1 ? 's' : ''}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  // Lista de lotes
                  ...allBatchesForIngredient.map((batch) {
                    final batchExpirationInfo = _getExpirationInfo(
                      batch.expirationDate,
                      context,
                    );
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      decoration: BoxDecoration(
                        color: cardBackgroundColor,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16.0),
                        onTap: () {
                          // Destacar este lote en el inventario
                          inventoryNotifier.setUserSelectedBatch(
                            item.name,
                            batch.id,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Fila superior: Cantidad y botón de edición
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Cantidad:',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: secondaryTextColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 6.0),
                                      Text(
                                        _formatQuantity(
                                          batch.quantity,
                                          batch.unitType,
                                        ),
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: mainTextColor,
                                        ),
                                      ),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        batch.unitType,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color: primaryGreen,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      showQuantityEditDialog(
                                        context,
                                        batch,
                                        ref,
                                      );
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    splashRadius: 24,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12.0),

                              // Fila inferior: Fecha de expiración y almacenamiento
                              Row(
                                children: [
                                  Icon(
                                    batchExpirationInfo.icon,
                                    color: batchExpirationInfo.color,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    batchExpirationInfo.text,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: batchExpirationInfo.color,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: Icon(
                                      Icons.calendar_today_outlined,
                                      color: secondaryTextColor,
                                      size: 18,
                                    ),
                                    onPressed:
                                        () => _selectDateAndUpdate(
                                          context,
                                          ref,
                                          batch,
                                        ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    splashRadius: 24,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // --- 3. Consejo de conservación ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consejo de conservación',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: mainTextColor,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: tipBackgroundColor,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.tips_and_updates_outlined,
                          color: secondaryTextColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            item.tips ??
                                "Consejos sobre cómo conservar mejor el ingrediente, recomendación de uso, etc.",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: secondaryTextColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets (Moved outside build) ---
  Widget _buildSustainabilityNote(String note, Color textColor, Color bgColor) {
    // Determine icon based on note content (simple example)
    IconData iconData = Icons.recycling; // Default
    if (note.contains('✅')) iconData = Icons.check_circle_outline;
    if (note.contains('🌱')) iconData = Icons.eco_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          Icon(iconData, color: textColor, size: 20),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              note.substring(
                note.indexOf(' ') + 1,
              ), // Remove leading emoji for display
              style: GoogleFonts.inter(fontSize: 14, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to format quantity display
  String _formatQuantity(double quantity, String unitType) {
    if (unitType.toLowerCase() == 'unidades') {
      return quantity.toInt().toString(); // Show units as integer
    } else {
      // For kg, g, lt, ml, show one decimal place if not whole
      if (quantity == quantity.truncate()) {
        return quantity.toInt().toString(); // 5.0 becomes "5"
      } else {
        return quantity.toStringAsFixed(1); // 5.1 becomes "5.1"
      }
    }
  }
}

// Helper extension for ExpirationStatus (if not already defined elsewhere)
// You might already have this in your project
/*
extension ExpirationStatusExtension on ExpirationStatus {
  IconData get icon {
    switch (this) {
      case ExpirationStatus.expired:
        return Icons.error_outline;
      case ExpirationStatus.expiringSoon:
        return Icons.warning_amber_outlined;
      case ExpirationStatus.fresh:
        return Icons.check_circle_outline;
      case ExpirationStatus.unknown:
      default:
        return Icons.help_outline; // Or another suitable icon
    }
  }

  static ExpirationStatus fromDate(DateTime? date) {
     if (date == null) return ExpirationStatus.unknown;
     final now = DateTime.now();
     final difference = date.difference(now).inDays;
     final startOfToday = DateTime(now.year, now.month, now.day);
     final startOfExpirationDay = DateTime(date.year, date.month, date.day);
     final dayDifference = startOfExpirationDay.difference(startOfToday).inDays;


     if (dayDifference < 0) {
       return ExpirationStatus.expired;
     } else if (dayDifference <= 5) { // Expiring within 5 days (inclusive of today)
       return ExpirationStatus.expiringSoon;
     } else {
       return ExpirationStatus.fresh;
     }
   }
}
*/

// Add an empty factory to InventoryItem for the orElse case
/*
extension InventoryItemExtension on InventoryItem {
  static InventoryItem empty() => InventoryItem(
    id: '',
    name: '',
    image: '',
    quantity: 0,
    storageType: StorageType.unknown,
    category: ItemCategory.food, // Or a default category
    addedDate: DateTime.now(),
    // Add other fields with default values if necessary
    unitType: 'unidades',
    tips: null,
    expirationDate: null,
  );
}
 */
