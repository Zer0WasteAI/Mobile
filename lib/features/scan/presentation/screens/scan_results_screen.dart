// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/item_category.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/storage_type.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';
import 'package:zer0_waste_ai/features/inventory/presentation/screens/add_inventory_item_screen.dart';
import 'package:zer0_waste_ai/features/scan/application/providers/scan_results_provider.dart';
import 'package:zer0_waste_ai/features/scan/presentation/screens/add_scan_item_screen.dart'; // For ScanItemType
import 'package:zer0_waste_ai/features/scan/presentation/widgets/recognized_item_card.dart';
import 'package:zer0_waste_ai/features/scan/domain/models/recognized_item.dart';
import 'dart:developer';

// Assume Uuid instance is available or create one
final _uuid = Uuid();

class ScanResultsScreen extends ConsumerWidget {
  // Now expects the raw JSON data list and itemType
  final List<Map<String, dynamic>> initialJsonData;
  final ScanItemType itemType;

  const ScanResultsScreen({
    super.key,
    required this.initialJsonData,
    required this.itemType,
  });

  static const String routeName = 'scan_results';
  static const String routePath = '/scan/results';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the family provider, passing the initial JSON data list
    final itemsState = ref.watch(scanResultsProvider(initialJsonData));
    final itemsNotifier = ref.read(
      scanResultsProvider(initialJsonData).notifier,
    );

    // Determine if the add button should be enabled
    final bool canAdd = itemsState.any((item) => item.quantity > 0);

    // Get theme and colors
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color backgroundColor = const Color(0xFFFAF9F6);
    final Color mainTextColor = const Color(0xFF3A3A3A);
    final Color primaryColor = const Color(0xFF00B894);
    final Color onPrimaryColor = Colors.white;
    final Color secondaryTextColor = const Color(0xFF70605A);

    final String title =
        itemType == ScanItemType.food
            ? "Comidas Reconocidas"
            : "Ingredientes Reconocidos";

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: mainTextColor,
            // Use a headline style if available, otherwise adjust size
            fontSize:
                Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)
                    .fontSize ??
                22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0,
        iconTheme: IconThemeData(color: mainTextColor), // Back button color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(), // Simple pop for now
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Allergy Alert Banner
            _buildAllergyBanner(itemsState, colorScheme, context),

            Expanded(
              child:
                  itemsState.isEmpty
                      ? _buildNoResultsFound(context)
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        itemCount: itemsState.length,
                        itemBuilder: (context, index) {
                          final item = itemsState[index];
                          return RecognizedItemCard(
                            item: item,
                            onIncrement:
                                () => itemsNotifier.incrementQuantity(item.id),
                            onDecrement:
                                () => itemsNotifier.decrementQuantity(item.id),
                            onRemove: () => itemsNotifier.removeItem(item.id),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          itemsState.isEmpty
              ? null
              : Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
                child: ElevatedButton.icon(
                  icon: const Icon(
                    FontAwesomeIcons.squarePlus,
                    size: 20,
                  ), // Cart icon
                  label: const Text('Agregar al inventario'),
                  onPressed:
                      canAdd
                          ? () async {
                            final itemsToAddRaw = itemsNotifier.getItemsToAdd();

                            // Map RecognizedItem to InventoryItem
                            final List<InventoryItem> itemsToAddInventory =
                                itemsToAddRaw.map((recognizedItem) {
                                  // Determine category based on ScanItemType
                                  final ItemCategory category =
                                      itemType == ScanItemType.food
                                          ? ItemCategory.food
                                          : ItemCategory.ingredient;

                                  // Parse storage type from recognition result
                                  StorageType storageType =
                                      StorageType.dry; // default
                                  if (recognizedItem.storageType != null) {
                                    switch (recognizedItem.storageType
                                        ?.toLowerCase()) {
                                      case 'refrigerated':
                                      case 'refrigerado':
                                        storageType = StorageType.refrigerated;
                                        break;
                                      case 'frozen':
                                      case 'congelado':
                                        storageType = StorageType.frozen;
                                        break;
                                      case 'dry':
                                      case 'seco':
                                        storageType = StorageType.dry;
                                        break;
                                      default:
                                        storageType = StorageType.dry;
                                    }
                                  }

                                  // Parse expiration date from recognition result
                                  DateTime? expirationDate;
                                  if (recognizedItem.expiryDate != null &&
                                      recognizedItem.expiryDate!.isNotEmpty) {
                                    try {
                                      expirationDate = DateTime.parse(
                                        recognizedItem.expiryDate!,
                                      );
                                    } catch (e) {
                                      log(
                                        'Error parsing expiration date: ${recognizedItem.expiryDate} - $e',
                                      );
                                      expirationDate = null;
                                    }
                                  }

                                  return InventoryItem(
                                    id: _uuid.v4(), // Generate a unique ID
                                    name: recognizedItem.name,
                                    image:
                                        recognizedItem.name.isNotEmpty
                                            ? recognizedItem.name[0]
                                            : '❓', // Use first letter or default emoji
                                    quantity:
                                        recognizedItem.quantity.toDouble(),
                                    category: category,
                                    storageType:
                                        storageType, // Use parsed storage type
                                    addedDate: DateTime.now(),
                                    unitType:
                                        recognizedItem.typeUnit ??
                                        'unidades', // Use recognition unit type
                                    expirationDate:
                                        expirationDate, // Use parsed expiration date
                                    tips:
                                        recognizedItem
                                            .tips, // Use recognition tips
                                    // imageUrl: recognizedItem.imageUrl, // Use this if actual image URL available
                                  );
                                }).toList();

                            try {
                              // Use real backend inventory provider to add items
                              await ref
                                  .read(inventoryRealProvider.notifier)
                                  .addIngredientsToBackend(itemsToAddInventory);

                              // Show success feedback
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Ingredientes agregados al inventario exitosamente',
                                    ),
                                    backgroundColor: primaryColor,
                                  ),
                                );

                                // Navigate to inventory screen
                                context.go('/inventory');
                              }
                            } catch (e) {
                              // Show error feedback
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error al agregar al inventario: ${e.toString()}',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                          : null, // Disable button if no items have quantity > 0
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: onPrimaryColor,
                    disabledBackgroundColor: primaryColor.withValues(
                      alpha: 0.5,
                    ),
                    minimumSize: const Size(
                      double.infinity,
                      52, // Set a fixed height
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildNoResultsFound(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              'No se reconocieron ítems',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3A3A3A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Prueba con otra imagen o agrega los productos manualmente para continuar.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF70605A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.push(AddInventoryItemScreen.routePath);
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Agregar manualmente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B894),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                context.pop();
              },
              icon: const Icon(Icons.arrow_back, size: 20),
              label: const Text('Volver a intentar'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF70605A),
                textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergyBanner(
    List<RecognizedItem> itemsState,
    ColorScheme colorScheme,
    BuildContext context,
  ) {
    // Filter items that have allergy alerts
    final allergenicItems =
        itemsState.where((item) => item.allergyAlert).toList();

    if (allergenicItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final allergenCount = allergenicItems.length;
    final uniqueAllergens =
        allergenicItems.expand((item) => item.allergens).toSet().toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Warning icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.error,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning, color: colorScheme.onError, size: 16),
            ),
            const SizedBox(width: 12),

            // Alert text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ ALERTA DE ALERGIA',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    allergenCount == 1
                        ? 'Detectado 1 ingrediente alergénico'
                        : 'Detectados $allergenCount ingredientes alergénicos',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  if (uniqueAllergens.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Contiene: ${uniqueAllergens.join(', ')}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: colorScheme.error.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Info button (optional - for showing more details)
            IconButton(
              onPressed: () {
                _showAllergyDetailsDialog(
                  context,
                  allergenicItems,
                  colorScheme,
                );
              },
              icon: Icon(
                Icons.info_outline,
                color: colorScheme.error,
                size: 20,
              ),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  void _showAllergyDetailsDialog(
    BuildContext context,
    List<RecognizedItem> allergenicItems,
    ColorScheme colorScheme,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  'Alertas de Alergia',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.error,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Los siguientes ingredientes contienen alérgenos a los que podrías ser sensible:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...allergenicItems.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.error.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: colorScheme.error,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Contiene: ${item.allergens.join(', ')}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: colorScheme.error,
                                    fontWeight: FontWeight.w500,
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
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Entendido',
                  style: GoogleFonts.inter(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
