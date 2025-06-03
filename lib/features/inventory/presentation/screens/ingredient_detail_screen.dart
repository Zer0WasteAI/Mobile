import 'dart:developer'; // For logging date picker errors

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/storage_type.dart';
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
  // ignore: unused_element
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
    // ignore: unused_local_variable
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
                            color: Colors.black.withValues(alpha: 0.05),
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
                  }),
                ],
              ),
            ),
          ),

          // --- 3. Consejo de conservación ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
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

          // --- 4. Impacto ambiental ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Impacto ambiental',
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.eco_outlined,
                              size: 20,
                              color: Colors.green[600],
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Text(
                                "Al consumir este ingrediente antes de que se eche a perder evitas:",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        // CO2 y agua en tarjetas lado a lado
                        Row(
                          children: [
                            // CO2 impact card
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: cardBackgroundColor,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: Colors.grey.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.cloud_outlined,
                                      size: 28,
                                      color: Colors.blue[400],
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      _getCO2Value(
                                        item.name,
                                        item.quantity,
                                        item.unitType,
                                      ),
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: mainTextColor,
                                      ),
                                    ),
                                    Text(
                                      "de CO₂",
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            // Water impact card
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: cardBackgroundColor,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: Colors.grey.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.water_drop_outlined,
                                      size: 28,
                                      color: Colors.blue[700],
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      _getWaterValue(
                                        item.name,
                                        item.quantity,
                                        item.unitType,
                                      ),
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: mainTextColor,
                                      ),
                                    ),
                                    Text(
                                      "de agua",
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 5. Ideas de aprovechamiento ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ideas de aprovechamiento',
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._getRecipeIdeas(item.name)
                            .map(
                              (idea) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.restaurant_outlined,
                                      color: primaryGreen,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: Text(
                                        idea,
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
                            )
                            ,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 6. Botón de generar recetas ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 80.0),
              child: ElevatedButton.icon(
                icon: Icon(
                  Icons.auto_awesome_outlined,
                  size: 20,
                  color: Colors.white,
                ),
                label: Text('Generar recetas con IA'),
                onPressed: () => _generateRecipes(context, item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  textStyle: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets (Moved outside build) ---
  // ignore: unused_element
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

  // Métodos para impacto ambiental y reducción de desperdicio
  // ignore: unused_element
  String _getWaterImpact(String itemName, double quantity, String unitType) {
    // Valores de ejemplo - en una app real, estos valores vendrían de una base de datos
    Map<String, double> waterFootprint = {
      'manzana': 70, // litros por unidad
      'tomate': 13, // litros por unidad
      'lechuga': 130, // litros por kg
      'carne': 15400, // litros por kg
      'arroz': 2500, // litros por kg
      'papa': 290, // litros por kg
      'leche': 1000, // litros por litro
    };

    // Valor por defecto si no tenemos datos específicos
    double baseWaterFootprint = 300; // litros por kg/lt o por 10 unidades
    double impactMultiplier = 1.0;

    // Ajustar el multiplicador según la unidad
    if (unitType.toLowerCase() == 'unidades') {
      impactMultiplier = quantity / 10;
    } else if (unitType.toLowerCase() == 'kg' ||
        unitType.toLowerCase() == 'lt') {
      impactMultiplier = quantity;
    } else if (unitType.toLowerCase() == 'g' ||
        unitType.toLowerCase() == 'ml') {
      impactMultiplier = quantity / 1000;
    }

    // Buscar valor específico para el alimento (búsqueda simplificada)
    double specificFootprint = baseWaterFootprint;
    waterFootprint.forEach((food, footprint) {
      if (itemName.toLowerCase().contains(food)) {
        specificFootprint = footprint;
      }
    });

    double totalImpact = specificFootprint * impactMultiplier;

    return "Para producir este alimento se requirieron aproximadamente ${totalImpact.round()} litros de agua.";
  }

  // ignore: unused_element
  String _getCO2Impact(String itemName, double quantity, String unitType) {
    // Valores de ejemplo - en una app real, estos vendrían de una base de datos
    Map<String, double> co2Footprint = {
      'manzana': 0.08, // kg CO2 por unidad
      'tomate': 0.05, // kg CO2 por unidad
      'lechuga': 0.2, // kg CO2 por kg
      'carne': 27, // kg CO2 por kg
      'arroz': 2.7, // kg CO2 por kg
      'papa': 0.18, // kg CO2 por kg
      'leche': 1.39, // kg CO2 por litro
    };

    // Valor por defecto si no tenemos datos específicos
    double baseCO2Footprint = 0.5; // kg CO2 por kg/lt o por 10 unidades
    double impactMultiplier = 1.0;

    // Ajustar el multiplicador según la unidad
    if (unitType.toLowerCase() == 'unidades') {
      impactMultiplier = quantity / 10;
    } else if (unitType.toLowerCase() == 'kg' ||
        unitType.toLowerCase() == 'lt') {
      impactMultiplier = quantity;
    } else if (unitType.toLowerCase() == 'g' ||
        unitType.toLowerCase() == 'ml') {
      impactMultiplier = quantity / 1000;
    }

    // Buscar valor específico para el alimento (búsqueda simplificada)
    double specificFootprint = baseCO2Footprint;
    co2Footprint.forEach((food, footprint) {
      if (itemName.toLowerCase().contains(food)) {
        specificFootprint = footprint;
      }
    });

    double totalImpact = specificFootprint * impactMultiplier;

    return "Su producción generó aproximadamente ${totalImpact.toStringAsFixed(2)} kg de CO₂. Al consumirlo antes de que se eche a perder, evitas este impacto ambiental.";
  }

  // Métodos para obtener solo los valores numéricos para la nueva interfaz
  String _getCO2Value(String itemName, double quantity, String unitType) {
    // Valores de ejemplo - en una app real, estos vendrían de una base de datos
    Map<String, double> co2Footprint = {
      'manzana': 0.08, // kg CO2 por unidad
      'tomate': 0.05, // kg CO2 por unidad
      'lechuga': 0.2, // kg CO2 por kg
      'carne': 27, // kg CO2 por kg
      'arroz': 2.7, // kg CO2 por kg
      'papa': 0.18, // kg CO2 por kg
      'leche': 1.39, // kg CO2 por litro
    };

    // Valor por defecto si no tenemos datos específicos
    double baseCO2Footprint = 0.5; // kg CO2 por kg/lt o por 10 unidades
    double impactMultiplier = 1.0;

    // Ajustar el multiplicador según la unidad
    if (unitType.toLowerCase() == 'unidades') {
      impactMultiplier = quantity / 10;
    } else if (unitType.toLowerCase() == 'kg' ||
        unitType.toLowerCase() == 'lt') {
      impactMultiplier = quantity;
    } else if (unitType.toLowerCase() == 'g' ||
        unitType.toLowerCase() == 'ml') {
      impactMultiplier = quantity / 1000;
    }

    // Buscar valor específico para el alimento (búsqueda simplificada)
    double specificFootprint = baseCO2Footprint;
    co2Footprint.forEach((food, footprint) {
      if (itemName.toLowerCase().contains(food)) {
        specificFootprint = footprint;
      }
    });

    double totalImpact = specificFootprint * impactMultiplier;

    return "${totalImpact.toStringAsFixed(1)} kg";
  }

  String _getWaterValue(String itemName, double quantity, String unitType) {
    // Valores de ejemplo - en una app real, estos valores vendrían de una base de datos
    Map<String, double> waterFootprint = {
      'manzana': 70, // litros por unidad
      'tomate': 13, // litros por unidad
      'lechuga': 130, // litros por kg
      'carne': 15400, // litros por kg
      'arroz': 2500, // litros por kg
      'papa': 290, // litros por kg
      'leche': 1000, // litros por litro
    };

    // Valor por defecto si no tenemos datos específicos
    double baseWaterFootprint = 300; // litros por kg/lt o por 10 unidades
    double impactMultiplier = 1.0;

    // Ajustar el multiplicador según la unidad
    if (unitType.toLowerCase() == 'unidades') {
      impactMultiplier = quantity / 10;
    } else if (unitType.toLowerCase() == 'kg' ||
        unitType.toLowerCase() == 'lt') {
      impactMultiplier = quantity;
    } else if (unitType.toLowerCase() == 'g' ||
        unitType.toLowerCase() == 'ml') {
      impactMultiplier = quantity / 1000;
    }

    // Buscar valor específico para el alimento (búsqueda simplificada)
    double specificFootprint = baseWaterFootprint;
    waterFootprint.forEach((food, footprint) {
      if (itemName.toLowerCase().contains(food)) {
        specificFootprint = footprint;
      }
    });

    double totalImpact = specificFootprint * impactMultiplier;

    return "${totalImpact.round()} L";
  }

  List<String> _getRecipeIdeas(String itemName) {
    // En una app real, esto se conectaría a una API o base de datos de recetas
    Map<String, List<String>> recipeIdeas = {
      'manzana': [
        "Compota de manzana casera para acompañar desayunos",
        "Rodajas deshidratadas como snack saludable",
        "Añadir a ensaladas para un toque dulce y crujiente",
      ],
      'tomate': [
        "Salsa de tomate básica para pastas y pizzas",
        "Tomates secos en aceite de oliva para conservarlos más tiempo",
        "Gazpacho refrescante utilizando tomates maduros",
      ],
      'lechuga': [
        "Wraps de lechuga como alternativa baja en carbohidratos",
        "Añadir hojas marchitas a sopas o salteados",
        "Smoothies verdes nutritivos con hojas sobrantes",
      ],
      'carne': [
        "Congelar en porciones pequeñas para usar según necesidad",
        "Preparar caldo concentrado con huesos y restos",
        "Tacos o burritos con pequeñas cantidades de carne picada",
      ],
      'arroz': [
        "Arroz frito con verduras para aprovechar sobras",
        "Pudín de arroz dulce como postre económico",
        "Conservar en el congelador en porciones individuales",
      ],
      'papa': [
        "Tortilla española con patatas cocidas sobrantes",
        "Puré de patata congelado en porciones",
        "Papas bravas con salsas caseras",
      ],
      'leche': [
        "Yogur casero para aprovechar leche a punto de caducar",
        "Queso fresco casero sencillo",
        "Bechamel para congelar y usar en futuras recetas",
      ],
      // Valor por defecto para cualquier alimento
      'default': [
        "Congelar en porciones pequeñas para mayor duración",
        "Incluir en guisos o sopas donde se puedan mezclar varios ingredientes",
        "Buscar recetas de aprovechamiento específicas en la sección de recetas",
      ],
    };

    // Intentar encontrar ideas específicas para este alimento
    List<String> ideas = recipeIdeas['default']!;
    recipeIdeas.forEach((food, foodIdeas) {
      if (itemName.toLowerCase().contains(food)) {
        ideas = foodIdeas;
      }
    });

    return ideas;
  }

  void _generateRecipes(BuildContext context, InventoryItem item) {
    // En una app real, esto se conectaría a un servicio de IA que generaría recetas

    // Obtener 3 recetas diferentes para el ingrediente
    final List<Map<String, dynamic>> recipes = _getMultipleRecipes(item.name);

    // Mostrar un diálogo con las 3 recetas
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // PageController para navegar entre recetas
        final pageController = PageController();
        // Estado actual para indicador de página
        int currentPage = 0;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Recetas con ${item.name}'),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Indicador de página
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < recipes.length; i++)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  currentPage == i
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade300,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Carrusel de recetas
                    Expanded(
                      child: PageView.builder(
                        controller: pageController,
                        itemCount: recipes.length,
                        onPageChanged: (index) {
                          setState(() {
                            currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final recipe = recipes[index];
                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título
                                Text(
                                  recipe['title'],
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Complejidad y tiempo
                                Row(
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 16,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      recipe['time'],
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.restaurant_outlined,
                                      size: 16,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      recipe['difficulty'],
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Ingredientes
                                Text(
                                  'Ingredientes:',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...recipe['ingredients']
                                    .map<Widget>(
                                      (ingredient) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 4.0,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text('•  '),
                                            Expanded(
                                              child: Text(
                                                ingredient,
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                                const SizedBox(height: 16),
                                // Preparación
                                Text(
                                  'Preparación:',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...recipe['steps']
                                    .asMap()
                                    .entries
                                    .map<Widget>(
                                      (entry) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${entry.key + 1}. ',
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                entry.value,
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                                const SizedBox(height: 16),
                                // Nota ecológica
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.eco_outlined,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Esta receta te ayuda a aprovechar el ${item.name} antes de que se eche a perder, reduciendo el desperdicio de alimentos.',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cerrar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Receta guardada en favoritos'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Guardar receta'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _getMultipleRecipes(String itemName) {
    // Generar 3 recetas diferentes para el mismo ingrediente
    List<Map<String, dynamic>> recipes = [];

    // Recetas para manzana
    if (itemName.toLowerCase().contains('manzana')) {
      recipes.add({
        'title': 'Crumble de manzana con canela y avena',
        'difficulty': 'Fácil',
        'time': '45 min',
        'ingredients': [
          '3-4 manzanas medianas, peladas y cortadas en cubos',
          '1/2 taza de avena',
          '1/3 taza de harina',
          '1/4 taza de azúcar moreno',
          '1/2 cucharadita de canela',
          '80g de mantequilla fría en cubitos',
        ],
        'steps': [
          'Precalentar el horno a 180°C.',
          'Mezclar las manzanas con un poco de azúcar y canela en un recipiente para horno.',
          'En un bowl, mezclar la avena, harina, azúcar moreno y canela.',
          'Añadir la mantequilla fría y trabajar con los dedos hasta obtener una textura arenosa.',
          'Cubrir las manzanas con esta mezcla de forma uniforme.',
          'Hornear durante 30-35 minutos hasta que la superficie esté dorada.',
          'Dejar enfriar ligeramente antes de servir, acompañado de helado de vainilla si se desea.',
        ],
      });

      recipes.add({
        'title': 'Compota de manzana casera',
        'difficulty': 'Muy fácil',
        'time': '25 min',
        'ingredients': [
          '4-5 manzanas, peladas y cortadas en cubos',
          '2 cucharadas de azúcar (opcional)',
          '1 ramita de canela',
          '1 vaina de vainilla o 1/2 cucharadita de extracto',
          'Cáscara de limón (opcional)',
          '50ml de agua',
        ],
        'steps': [
          'Colocar todos los ingredientes en una olla con tapa.',
          'Cocinar a fuego medio-bajo durante 15-20 minutos, removiendo ocasionalmente.',
          'Retirar la ramita de canela y la cáscara de limón si se usaron.',
          'Para una textura más fina, triturar con una batidora.',
          'Dejar enfriar completamente y conservar en la nevera hasta 5 días.',
          'Ideal para desayunos, postres, o como acompañamiento.',
        ],
      });

      recipes.add({
        'title': 'Ensalada waldorf con manzana',
        'difficulty': 'Fácil',
        'time': '15 min',
        'ingredients': [
          '1 manzana, cortada en cubos pequeños',
          '2 tallos de apio, en rodajas finas',
          '1/2 taza de nueces, ligeramente tostadas',
          '1/4 taza de uvas pasas',
          '3 cucharadas de mayonesa',
          '1 cucharada de yogur natural',
          'Zumo de medio limón',
          'Sal y pimienta al gusto',
          'Hojas de lechuga para servir',
        ],
        'steps': [
          'Mezclar la mayonesa, el yogur y el zumo de limón en un bol grande.',
          'Incorporar la manzana, el apio, las nueces y las pasas.',
          'Sazonar con sal y pimienta al gusto.',
          'Refrigerar por 30 minutos antes de servir para que los sabores se integren.',
          'Servir sobre hojas de lechuga fresca.',
        ],
      });
    }
    // Recetas para tomate
    else if (itemName.toLowerCase().contains('tomate')) {
      recipes.add({
        'title': 'Salsa pomodoro casera con albahaca',
        'difficulty': 'Media',
        'time': '40 min',
        'ingredients': [
          '6-7 tomates maduros, pelados y troceados',
          '1 zanahoria rallada',
          '2 dientes de ajo picados',
          '1 cebolla mediana picada',
          'Albahaca fresca',
          '1 cucharadita de azúcar (opcional, para reducir acidez)',
          'Sal y pimienta al gusto',
          'Aceite de oliva virgen extra',
        ],
        'steps': [
          'En una cazuela a fuego medio, calentar aceite de oliva.',
          'Sofreír la cebolla y el ajo hasta que estén transparentes.',
          'Añadir la zanahoria rallada y cocinar por 2 minutos más.',
          'Incorporar los tomates y cocinar a fuego medio durante 10 minutos.',
          'Bajar el fuego y dejar reducir durante 20-25 minutos, removiendo ocasionalmente.',
          'Añadir la albahaca picada, sal, pimienta y azúcar si es necesario.',
          'Triturar hasta obtener la consistencia deseada y servir con pasta o como base para otras recetas.',
        ],
      });

      recipes.add({
        'title': 'Gazpacho andaluz tradicional',
        'difficulty': 'Fácil',
        'time': '15 min + 2h refrigeración',
        'ingredients': [
          '1 kg de tomates maduros',
          '1 pimiento verde',
          '1 pepino pequeño',
          '1 diente de ajo',
          '100g de pan del día anterior',
          '150ml de aceite de oliva',
          '2 cucharadas de vinagre de jerez',
          'Sal al gusto',
          'Agua fría',
        ],
        'steps': [
          'Lavar y trocear todas las verduras.',
          'Remojar el pan en agua durante unos minutos y escurrir.',
          'En una batidora o procesador, triturar todos los ingredientes excepto el aceite.',
          'Añadir el aceite poco a poco mientras se sigue triturando.',
          'Pasar por un colador para eliminar pieles y semillas (opcional).',
          'Refrigerar al menos 2 horas antes de servir.',
          'Acompañar con guarnición de pepino, pimiento y tomate picados en cubitos.',
        ],
      });

      recipes.add({
        'title': 'Tomates rellenos de atún',
        'difficulty': 'Fácil',
        'time': '20 min',
        'ingredients': [
          '4 tomates grandes y firmes',
          '2 latas de atún en aceite de oliva',
          '2 huevos duros picados',
          '4 cucharadas de mayonesa',
          '1 cebolleta picada finamente',
          '1 cucharada de alcaparras',
          'Perejil fresco picado',
          'Sal y pimienta',
          'Aceitunas para decorar',
        ],
        'steps': [
          'Cortar la parte superior de los tomates y vaciar el interior con una cuchara.',
          'Salar ligeramente el interior y colocarlos boca abajo para que suelten el agua.',
          'En un bol, mezclar el atún escurrido, los huevos picados, la cebolleta y las alcaparras.',
          'Añadir la mayonesa y mezclar bien. Sazonar con sal y pimienta.',
          'Rellenar los tomates con la mezcla y decorar con perejil y aceitunas.',
          'Refrigerar hasta el momento de servir.',
        ],
      });
    }
    // Recetas para lechuga
    else if (itemName.toLowerCase().contains('lechuga')) {
      recipes.add({
        'title': 'Ensalada mediterránea con vinagreta de limón',
        'difficulty': 'Muy fácil',
        'time': '15 min',
        'ingredients': [
          '1 lechuga lavada y troceada',
          '1 pepino en rodajas',
          '1 tomate en cubos',
          '1/2 cebolla roja en rodajas finas',
          '50g de queso feta desmenuzado',
          'Aceitunas negras',
          'Zumo de 1 limón',
          '3 cucharadas de aceite de oliva',
          'Sal y orégano',
        ],
        'steps': [
          'Preparar la vinagreta mezclando el zumo de limón, aceite, sal y orégano.',
          'En una ensaladera grande, combinar todos los vegetales.',
          'Añadir el queso feta y las aceitunas.',
          'Incorporar la vinagreta justo antes de servir y mezclar suavemente.',
          'Servir inmediatamente para mantener la frescura de los ingredientes.',
        ],
      });

      recipes.add({
        'title': 'Wraps de lechuga con pollo y aguacate',
        'difficulty': 'Fácil',
        'time': '25 min',
        'ingredients': [
          'Hojas grandes de lechuga (romana o iceberg)',
          '300g de pechuga de pollo, cocida y desmenuzada',
          '1 aguacate en rodajas',
          '1 zanahoria rallada',
          '1/2 taza de hummus',
          'Brotes de alfalfa',
          'Zumo de limón',
          'Sal y pimienta',
        ],
        'steps': [
          'Lavar y secar cuidadosamente las hojas de lechuga, manteniéndolas enteras.',
          'Mezclar el pollo desmenuzado con el hummus, sal y pimienta.',
          'Rociar las rodajas de aguacate con zumo de limón para evitar que se oxiden.',
          'Colocar una porción de la mezcla de pollo en cada hoja de lechuga.',
          'Añadir la zanahoria rallada, aguacate y brotes.',
          'Enrollar cada hoja como si fuera una tortilla, asegurando que queden cerrados.',
          'Servir inmediatamente o envolver en papel film si se van a llevar para almorzar fuera.',
        ],
      });

      recipes.add({
        'title': 'Sopa de lechuga reconfortante',
        'difficulty': 'Media',
        'time': '30 min',
        'ingredients': [
          '1 lechuga (incluso si está marchita)',
          '1 patata mediana en cubos',
          '1 cebolla picada',
          '2 dientes de ajo',
          '1 litro de caldo de verduras',
          '50ml de nata líquida (opcional)',
          'Nuez moscada',
          'Sal y pimienta',
          'Aceite de oliva',
        ],
        'steps': [
          'En una olla grande, sofreír la cebolla y el ajo en aceite hasta que estén transparentes.',
          'Añadir la patata y sofreír 2 minutos más.',
          'Incorporar la lechuga troceada y remover hasta que se marchite ligeramente.',
          'Verter el caldo, llevar a ebullición y luego bajar el fuego.',
          'Cocinar a fuego lento durante 15-20 minutos hasta que la patata esté tierna.',
          'Triturar con batidora hasta obtener una textura suave.',
          'Añadir la nata si se desea, sazonar con sal, pimienta y una pizca de nuez moscada.',
          'Calentar sin dejar hervir y servir con crutones o pan tostado.',
        ],
      });
    }
    // Recetas genéricas para cualquier ingrediente
    else {
      // Primera receta
      recipes.add({
        'title': 'Salteado rápido con $itemName',
        'difficulty': 'Fácil',
        'time': '20 min',
        'ingredients': [
          '$itemName (cantidad necesaria)',
          '1 cebolla mediana picada',
          '2 dientes de ajo picados',
          'Verduras variadas (pimiento, zanahoria, etc.)',
          'Salsa de soja',
          'Aceite de oliva o de sésamo',
          'Jengibre rallado (opcional)',
          'Semillas de sésamo para decorar',
        ],
        'steps': [
          'Preparar todos los ingredientes, lavando y picando según sea necesario.',
          'En un wok o sartén grande a fuego alto, calentar el aceite.',
          'Añadir el ajo y la cebolla, sofreír hasta que estén transparentes.',
          'Incorporar el $itemName y las verduras, saltear a fuego vivo durante 5-7 minutos.',
          'Añadir la salsa de soja y el jengibre si se usa.',
          'Cocinar hasta que todo esté al punto, evitando que se ablande demasiado.',
          'Servir inmediatamente decorado con semillas de sésamo.',
        ],
      });

      // Segunda receta
      recipes.add({
        'title': 'Guiso reconfortante de $itemName',
        'difficulty': 'Media',
        'time': '45 min',
        'ingredients': [
          '$itemName (cantidad necesaria)',
          'Cebolla, zanahoria y apio picados (base de sofrito)',
          '2 dientes de ajo',
          '1 lata de tomate triturado',
          'Caldo de verduras o pollo',
          'Hierbas aromáticas (tomillo, laurel)',
          'Patatas en cubos (opcional)',
          'Sal, pimienta y pimentón',
        ],
        'steps': [
          'Preparar un sofrito con la cebolla, zanahoria, apio y ajo en aceite de oliva.',
          'Añadir el $itemName y sofreír brevemente.',
          'Incorporar el tomate y cocinar a fuego medio durante 5 minutos.',
          'Verter el caldo hasta cubrir todos los ingredientes.',
          'Añadir las hierbas aromáticas y las patatas si se usan.',
          'Cocinar a fuego lento durante 30 minutos hasta que todo esté tierno.',
          'Sazonar con sal, pimienta y pimentón al gusto.',
          'Servir caliente con pan rústico.',
        ],
      });

      // Tercera receta
      recipes.add({
        'title': 'Tartaleta de $itemName al horno',
        'difficulty': 'Media-Alta',
        'time': '50 min',
        'ingredients': [
          '$itemName (cantidad necesaria)',
          'Masa quebrada (comprada o casera)',
          '3 huevos',
          '200ml de nata líquida o leche',
          '100g de queso rallado',
          'Hierbas aromáticas al gusto',
          'Sal y pimienta',
          'Nuez moscada (pizca)',
        ],
        'steps': [
          'Precalentar el horno a 180°C.',
          'Extender la masa en un molde para tartas y pinchar con un tenedor.',
          'Hornear la base durante 10 minutos (horneado ciego).',
          'Mientras tanto, batir los huevos con la nata, sal, pimienta y nuez moscada.',
          'Disponer el $itemName sobre la base de masa precocida.',
          'Añadir el queso rallado y las hierbas.',
          'Verter la mezcla de huevo y nata.',
          'Hornear durante 30-35 minutos hasta que cuaje y dore.',
          'Dejar reposar 10 minutos antes de desmoldar y servir.',
        ],
      });
    }

    return recipes;
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
