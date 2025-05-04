import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/expiration_status.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/storage_type.dart';
import 'package:zer0_waste_ai/features/inventory/presentation/widgets/nutrition_info_chip.dart'; // Assuming this widget exists or will be created
import 'package:zer0_waste_ai/features/inventory/presentation/screens/inventory_screen.dart'; // For batch dialog
import 'package:zer0_waste_ai/core/utils/date_extensions.dart'; // For date formatting

// TODO: Define route name constant if needed elsewhere
// const String foodDetailRouteName = 'foodDetail';

class FoodDetailScreen extends ConsumerWidget {
  final String itemId;

  const FoodDetailScreen({super.key, required this.itemId});

  // Helper to format expiration (similar to IngredientDetailScreen)
  String _formatExpirationDuration(DateTime? expirationDate) {
    if (expirationDate == null) {
      return 'N/A'; // Or 'Sin fecha'
    }
    final now = DateTime.now();
    final difference = expirationDate.difference(now);
    final days = difference.inDays;

    if (days < -1) {
      return 'Vencido hace ${days.abs()} días';
    } else if (days == -1) {
      return 'Vencido ayer';
    } else if (days == 0) {
      final hours = difference.inHours;
      if (hours <= 0) {
        return 'Vencido hoy';
      } else {
        return 'Vence hoy';
      }
    } else if (days == 1) {
      return 'Vence mañana';
    } else {
      return 'Vence en $days días';
    }
  }

  Color _getExpirationColor(ExpirationStatus status, BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    switch (status) {
      case ExpirationStatus.expired:
        return AppColors.error;
      case ExpirationStatus.expiringSoon:
        return isDark ? AppColors.warningTextDark : AppColors.warningTextLight;
      default:
        // Use a less prominent color for fresh items
        return isDark
            ? AppColors.darkSecondaryText
            : AppColors.lightSecondaryText;
    }
  }

  // Helper to get expiration status and associated data for a specific batch
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

    final String expirationText = _formatExpirationDuration(expirationDate);

    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);

    if (expirationDate == null) {
      return (
        text: "Sin fecha",
        color: defaultColor,
        icon: Icons.help_outline,
        isExpired: false,
        isExpiringSoon: false,
      );
    }

    final expiryDateOnly = DateUtils.dateOnly(expirationDate);
    final differenceInDays = expiryDateOnly.difference(today).inDays;

    if (differenceInDays < 0) {
      return (
        text: expirationText,
        color: errorColor,
        icon: Icons.error_outline,
        isExpired: true,
        isExpiringSoon: false,
      );
    } else if (differenceInDays <= 1) {
      return (
        text: expirationText,
        color: warningColor,
        icon: Icons.warning_amber_outlined,
        isExpired: false,
        isExpiringSoon: true,
      );
    } else {
      return (
        text: expirationText,
        color: defaultColor,
        icon: Icons.check_circle_outline,
        isExpired: false,
        isExpiringSoon: false,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch the specific item using the itemId
    final inventoryState = ref.watch(inventoryProvider);
    final item = inventoryState.items.firstWhere(
      (item) => item.id == itemId,
      orElse: () => InventoryItem.empty(), // Return an empty item if not found
    );

    // Get all batches for this food item (by name)
    final allBatchesForFood =
        inventoryState.items
            .where(
              (batchItem) =>
                  batchItem.name == item.name &&
                  batchItem.category == item.category,
            )
            .toList();

    // Sort batches by expiration date
    allBatchesForFood.sort((a, b) {
      if (a.expirationDate == null && b.expirationDate == null) return 0;
      if (a.expirationDate == null) return 1;
      if (b.expirationDate == null) return -1;
      return a.expirationDate!.compareTo(b.expirationDate!);
    });

    final inventoryNotifier = ref.read(inventoryProvider.notifier);

    if (item.id.isEmpty) {
      // Handle case where item is not found
      return const Scaffold(body: Center(child: Text('Plato no encontrado.')));
    }

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final bool isDark = theme.brightness == Brightness.dark;

    // Define colors from spec (using AppColors where possible)
    final Color screenBackgroundColor =
        isDark ? AppColors.darkBackground : const Color(0xFFFAF9F6);
    final Color mainTextColor =
        isDark ? AppColors.darkMainText : const Color(0xFF3A3A3A);
    final Color secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : const Color(0xFF70605A);
    final Color primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    const Color categoryChipColor = Color(0xFFF4A261); // Orange-like
    final Color categoryTextColor =
        Colors.white; // Or dark gray like #3A3A3A? Using white for contrast.
    final Color tipsBackgroundColor =
        isDark ? AppColors.darkFormBackground : const Color(0xFFEDF2F4);
    final Color nutritionChipBorderColor =
        isDark ? AppColors.darkOutline : const Color(0xFFEDF2F4);
    final Color nutritionChipBackgroundColor =
        isDark ? AppColors.darkSurface : Colors.white;
    final Color cardBackgroundColor =
        isDark ? AppColors.darkSurface : Colors.white;

    final expirationStatus = ExpirationStatusExtension.fromDate(
      item.expirationDate,
    );
    final expirationColor = _getExpirationColor(expirationStatus, context);
    final expirationText = _formatExpirationDuration(item.expirationDate);

    // Get data from current selected item
    final String description =
        item.description ??
        "Descripción detallada del plato preparado, incluyendo notas sobre su sabor o preparación.";
    final int calories = item.calories ?? 250;
    final int portions = item.quantity.toInt();
    final List<String> mainIngredients =
        item.mainIngredients ??
        ['Ingrediente 1', 'Ingrediente 2', 'Ingrediente 3'];
    final String tips =
        item.tips ??
        "Consejos sobre cómo conservar mejor el plato, si se puede recalentar, etc.";

    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Plato',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: mainTextColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: mainTextColor),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // --- Header ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 20.0,
              ),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      item.image.isNotEmpty ? item.image : '🍲',
                      style: const TextStyle(fontSize: 72),
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
                    if (item.foodCategory != null &&
                        item.foodCategory!.isNotEmpty)
                      Chip(
                        label: Text(item.foodCategory!),
                        backgroundColor: categoryChipColor,
                        labelStyle: GoogleFonts.inter(
                          color: categoryTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 4.0,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: const StadiumBorder(), // Pill shape
                      ),
                  ],
                ),
              ),
            ),
          ),

          // --- Description ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Descripción",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: mainTextColor,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 20,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          description,
                          style: GoogleFonts.inter(
                            fontSize: textTheme.bodyMedium?.fontSize,
                            color: secondaryTextColor,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- Nutritional Data ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Datos",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: mainTextColor,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Wrap(
                    // Use Wrap for responsiveness
                    spacing: 12.0, // Horizontal space
                    runSpacing: 12.0, // Vertical space if wrapping
                    alignment: WrapAlignment.spaceBetween, // Distribute space
                    children: [
                      if (calories > 0)
                        NutritionInfoChip(
                          icon: Icons.local_fire_department_outlined,
                          label: '$calories kcal',
                          backgroundColor: nutritionChipBackgroundColor,
                          borderColor: nutritionChipBorderColor,
                          textColor: secondaryTextColor,
                        ),
                      // Show portions from first lote only as reference
                      if (portions > 0)
                        NutritionInfoChip(
                          icon: Icons.person_outline,
                          label: '$portions porción${portions > 1 ? 'es' : ''}',
                          backgroundColor: nutritionChipBackgroundColor,
                          borderColor: nutritionChipBorderColor,
                          textColor: secondaryTextColor,
                        ),
                      NutritionInfoChip(
                        icon: item.storageType.icon,
                        label: item.storageType.displayName,
                        backgroundColor: nutritionChipBackgroundColor,
                        borderColor: nutritionChipBorderColor,
                        textColor: secondaryTextColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- Lotes disponibles ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 0),
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
                        '${allBatchesForFood.length} lote${allBatchesForFood.length > 1 ? 's' : ''}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  // Lista de lotes
                  ...allBatchesForFood.map((batch) {
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
                                      color: primaryColor,
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
                                  // Expiration info
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

                                  // Storage type info with icon
                                  Icon(
                                    batch.storageType.icon,
                                    color: secondaryTextColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    batch.storageType.displayName,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: secondaryTextColor,
                                    ),
                                  ),

                                  const SizedBox(width: 12.0),
                                  IconButton(
                                    icon: Icon(
                                      Icons.calendar_today_outlined,
                                      color: secondaryTextColor,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      _selectDateAndUpdate(context, ref, batch);
                                    },
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

          // --- Main Ingredients ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ingredientes principales",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: mainTextColor,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  if (mainIngredients.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                      ), // Indent bullets
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            mainIngredients
                                .map(
                                  (ingredient) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          '• ',
                                          style: GoogleFonts.inter(
                                            color: secondaryTextColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            ingredient,
                                            style: GoogleFonts.inter(
                                              color: secondaryTextColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    )
                  else
                    Text(
                      'No se especificaron ingredientes.',
                      style: GoogleFonts.inter(
                        color: secondaryTextColor.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // --- Tips ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Consejos",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: mainTextColor,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: tipsBackgroundColor,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 20,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            tips,
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

  // Helper to format quantity display
  String _formatQuantity(double quantity, String unitType) {
    if (unitType.toLowerCase() == 'unidades' ||
        unitType.toLowerCase() == 'porciones') {
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

  // Helper for updating expiration date
  Future<void> _selectDateAndUpdate(
    BuildContext context,
    WidgetRef ref,
    InventoryItem item,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: item.expirationDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != item.expirationDate) {
      ref
          .read(inventoryProvider.notifier)
          .updateExpirationDate(item.id, picked);
    }
  }
}


// Helper extension for ExpirationStatus (copy if not globally available)
// Placeholder - assumes ExpirationStatusExtension exists as defined previously
/*
extension ExpirationStatusExtension on ExpirationStatus {
  IconData get icon { ... }
  static ExpirationStatus fromDate(DateTime? date) { ... }
}
*/

// Placeholder - assumes InventoryItem.empty() exists
/*
extension InventoryItemExtension on InventoryItem {
 static InventoryItem empty() => InventoryItem(...);
 // Need to add fields like:
 // description: null,
 // calories: null,
 // servingQuantity: null,
 // mainIngredients: null,
 // foodCategory: null,
}
*/

// TODO: Need to add fields to InventoryItem model:
// - String? description
// - int? calories
// - int? servingQuantity
// - List<String>? mainIngredients
// - String? foodCategory (e.g., 'Entrada', 'Postre')

// TODO: Create NutritionInfoChip widget
// A simple stateless widget displaying an icon and text in a styled chip/card.
// Example: lib/features/inventory/presentation/widgets/nutrition_info_chip.dart
/*
class NutritionInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const NutritionInfoChip({
    Key? key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Fit content
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 6.0),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
*/

