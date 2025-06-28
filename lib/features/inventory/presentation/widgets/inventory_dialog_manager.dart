import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/app_dialog.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';
import 'package:zer0_waste_ai/features/inventory/presentation/widgets/mark_consumed_dialog.dart';

/// Manager for all inventory-related dialogs
class InventoryDialogManager {
  /// Show dialog to mark item as consumed
  static void showMarkConsumedDialog(
    BuildContext context,
    InventoryItem item,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) => MarkConsumedDialog(item: item),
    );
  }

  /// Show dialog to edit item quantity
  static Future<void> showQuantityEditDialog(
    BuildContext context,
    InventoryItem item,
    WidgetRef ref,
  ) async {
    final formKey = GlobalKey<FormState>(debugLabel: 'editQuantity_${item.id}');
    final inventoryNotifier = ref.read(inventoryRealProvider.notifier);

    final TextEditingController quantityController = TextEditingController(
      text: _formatQuantityForEditing(item.quantity, item.unitType),
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final inputFillColor = isDark ? Colors.grey.shade800 : const Color(0xFFF5F5F5);

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AppDialog(
              emoji: item.image.isNotEmpty ? item.image : '🍲',
              title: 'Editar Cantidad',
              subtitle: item.name,
              primaryAction: ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() == true) {
                    final newQuantity = double.parse(quantityController.text);
                    
                    if (newQuantity != item.quantity) {
                      try {
                        await inventoryNotifier.updateItemQuantityQuick(item.id, newQuantity);
                        
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Cantidad de ${item.name} actualizada a ${_formatQuantityForEditing(newQuantity, item.unitType)} ${item.unitType}',
                              ),
                              backgroundColor: Colors.green[600],
                            ),
                          );
                        }
                      } catch (e) {
                        log('Error updating quantity: $e');
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al actualizar la cantidad: $e'),
                              backgroundColor: Colors.red[600],
                            ),
                          );
                        }
                      }
                    } else {
                      Navigator.of(dialogContext).pop();
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  'Guardar',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
              secondaryAction: TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                  ),
                ),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Ingresa la nueva cantidad',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Custom quantity input field
                    Container(
                      decoration: BoxDecoration(
                        color: inputFillColor,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Decrement button
                          _buildQuantityButton(
                            icon: Icons.remove_circle,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              bottomLeft: Radius.circular(16.0),
                            ),
                            onTap: () {
                              final currentVal = double.tryParse(quantityController.text) ?? item.quantity;
                              final step = inventoryNotifier.getQuantityStep(item.unitType);
                              final min = inventoryNotifier.getMinimumQuantity(item.unitType);
                              final newVal = ((currentVal * 10 - step * 10).round() / 10.0).clamp(min, double.infinity);
                              stfSetState(() {
                                quantityController.text = _formatQuantityForEditing(newVal, item.unitType);
                              });
                            },
                            colorScheme: colorScheme,
                          ),

                          // Vertical divider
                          Container(
                            height: 30,
                            width: 1,
                            color: colorScheme.primary.withValues(alpha: 0.2),
                          ),

                          // Text field
                          Expanded(
                            child: TextFormField(
                              controller: quantityController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              autofocus: true,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '0',
                                suffix: Text(
                                  item.unitType,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingresa una cantidad';
                                }
                                final double? enteredQuantity = double.tryParse(value);
                                if (enteredQuantity == null) {
                                  return 'Número inválido';
                                }
                                final minQuantity = inventoryNotifier.getMinimumQuantity(item.unitType);
                                if (enteredQuantity < minQuantity) {
                                  return 'Mínimo: ${_formatQuantityForEditing(minQuantity, item.unitType)} ${item.unitType}';
                                }
                                return null;
                              },
                            ),
                          ),

                          // Vertical divider
                          Container(
                            height: 30,
                            width: 1,
                            color: colorScheme.primary.withValues(alpha: 0.2),
                          ),

                          // Increment button
                          _buildQuantityButton(
                            icon: Icons.add_circle,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(16.0),
                              bottomRight: Radius.circular(16.0),
                            ),
                            onTap: () {
                              final currentVal = double.tryParse(quantityController.text) ?? item.quantity;
                              final step = inventoryNotifier.getQuantityStep(item.unitType);
                              final newVal = ((currentVal * 10 + step * 10).round() / 10.0);
                              stfSetState(() {
                                quantityController.text = _formatQuantityForEditing(newVal, item.unitType);
                              });
                            },
                            colorScheme: colorScheme,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24.0),

                    // Information text
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              'Usa los botones + y - para ajustar la cantidad rápidamente',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Show confirmation dialog for item deletion
  static Future<bool> showDeleteConfirmationDialog(
    BuildContext context,
    InventoryItem item,
    WidgetRef ref,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Text(
                item.image.isNotEmpty ? item.image : '🍲',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Eliminar ${item.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            '¿Estás seguro de que quieres eliminar este alimento de tu inventario? Esta acción no se puede deshacer.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    ) ?? false;

    if (result) {
      await _deleteItemWithLoading(context, item, ref);
    }

    return result;
  }

  // Private helper methods

  /// Build quantity adjustment button
  static Widget _buildQuantityButton({
    required IconData icon,
    required BorderRadius borderRadius,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14.0),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 28,
          ),
        ),
      ),
    );
  }

  /// Delete item with loading dialog
  static Future<void> _deleteItemWithLoading(
    BuildContext context,
    InventoryItem item,
    WidgetRef ref,
  ) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show loading dialog
    navigator.push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        barrierDismissible: false,
        pageBuilder: (context, _, _) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Eliminando ${item.name}...',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      log('Starting deletion process for item: ${item.id}');
      await ref.read(inventoryRealProvider.notifier).removeItem(item.id);
      log('Item successfully removed from backend');

      // Hide loading dialog
      navigator.pop();

      // Show success message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${item.name} eliminado del inventario',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      log('Failed to delete item: $e');

      // Hide loading dialog
      navigator.pop();

      // Show error message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Error al eliminar ${item.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red[600],
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  /// Format quantity for editing based on unit type
  static String _formatQuantityForEditing(double quantity, String unitType) {
    if (unitType == 'unidades' || unitType == 'u') {
      return quantity.toInt().toString();
    } else {
      if (quantity == quantity.roundToDouble()) {
        return quantity.toInt().toString();
      } else {
        return quantity.toStringAsFixed(1);
      }
    }
  }
}