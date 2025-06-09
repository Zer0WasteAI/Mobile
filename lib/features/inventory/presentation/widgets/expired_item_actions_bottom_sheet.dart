import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';

class ExpiredItemActionsBottomSheet extends ConsumerWidget {
  final InventoryItem expiredItem;
  final VoidCallback? onActionCompleted;

  const ExpiredItemActionsBottomSheet({
    super.key,
    required this.expiredItem,
    this.onActionCompleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const Color primaryColor = Color(0xFF00B894);
    const Color dangerColor = Color(0xFFE74C3C);
    const Color warningColor = Color(0xFFF39C12);
    const Color mainTextColor = Color(0xFF3A3A3A);
    const Color secondaryTextColor = Color(0xFF70605A);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.error_outline, color: dangerColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${expiredItem.name} ha expirado',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: mainTextColor,
                      ),
                    ),
                    Text(
                      '¿Qué quieres hacer con este item?',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action Options
          _buildActionOption(
            context: context,
            icon: Icons.restaurant_outlined,
            title: 'Lo usé antes de que expirara',
            subtitle: 'Marcarlo como consumido',
            color: primaryColor,
            onTap: () => _handleMarkAsUsed(context, ref),
          ),

          const SizedBox(height: 12),

          _buildActionOption(
            context: context,
            icon: Icons.delete_outline,
            title: 'Descartar del inventario',
            subtitle: 'Eliminar porque ya no es seguro',
            color: dangerColor,
            onTap: () => _handleDiscard(context, ref),
          ),

          const SizedBox(height: 12),

          _buildActionOption(
            context: context,
            icon: Icons.schedule_outlined,
            title: 'Extender fecha (aún está bueno)',
            subtitle: 'Cambiar fecha de vencimiento',
            color: warningColor,
            onTap: () => _handleExtendDate(context, ref),
          ),

          const SizedBox(height: 12),

          _buildActionOption(
            context: context,
            icon: Icons.eco_outlined,
            title: 'Compostar/Reciclar',
            subtitle: 'Eliminar pero registrar como compostado',
            color: Colors.green.shade600,
            onTap: () => _handleCompost(context, ref),
          ),

          const SizedBox(height: 24),

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3A3A3A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF70605A),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _handleMarkAsUsed(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop();

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Eliminar del inventario y registrar como "usado" (backend + local)
      await ref.read(inventoryRealProvider.notifier).removeItem(expiredItem.id);

      if (context.mounted) {
        Navigator.of(context).pop(); // Hide loading

        // Mostrar mensaje de confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${expiredItem.name} marcado como consumido'),
            backgroundColor: const Color(0xFF00B894),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      onActionCompleted?.call();
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Hide loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handleDiscard(BuildContext context, WidgetRef ref) {
    // Mostrar confirmación
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Confirmar descarte',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            content: Text(
              '¿Estás seguro de que quieres eliminar ${expiredItem.name} del inventario?',
              style: GoogleFonts.inter(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar', style: GoogleFonts.inter()),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close dialog

                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (context) =>
                            const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    await ref
                        .read(inventoryRealProvider.notifier)
                        .removeItem(expiredItem.id);

                    if (context.mounted) {
                      Navigator.of(context).pop(); // Hide loading
                      Navigator.of(context).pop(); // Close bottom sheet

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '🗑️ ${expiredItem.name} eliminado del inventario',
                          ),
                          backgroundColor: const Color(0xFFE74C3C),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }

                    onActionCompleted?.call();
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop(); // Hide loading
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE74C3C),
                  foregroundColor: Colors.white,
                ),
                child: Text('Eliminar', style: GoogleFonts.inter()),
              ),
            ],
          ),
    );
  }

  void _handleExtendDate(BuildContext context, WidgetRef ref) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Nueva fecha de vencimiento',
    );

    if (selectedDate != null) {
      // Use the real backend provider for persistence
      await ref
          .read(inventoryRealProvider.notifier)
          .updateExpirationDateInBackend(expiredItem.id, selectedDate);

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📅 Fecha de ${expiredItem.name} actualizada'),
          backgroundColor: const Color(0xFFF39C12),
          duration: const Duration(seconds: 3),
        ),
      );

      onActionCompleted?.call();
    }
  }

  void _handleCompost(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop();

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Eliminar del inventario con mensaje específico de compostaje (backend + local)
      await ref.read(inventoryRealProvider.notifier).removeItem(expiredItem.id);

      if (context.mounted) {
        Navigator.of(context).pop(); // Hide loading

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🌱 ${expiredItem.name} marcado para compostaje'),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Tips de compostaje',
              textColor: Colors.white,
              onPressed: () {
                // Aquí podrías abrir una página con tips de compostaje
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text(
                          'Tips de Compostaje',
                          style: GoogleFonts.inter(),
                        ),
                        content: Text(
                          'Los restos de ${expiredItem.name} pueden ser compostados para crear abono natural. '
                          'Recuerda mantener un balance entre materiales verdes y marrones.',
                          style: GoogleFonts.inter(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Entendido',
                              style: GoogleFonts.inter(),
                            ),
                          ),
                        ],
                      ),
                );
              },
            ),
          ),
        );
      }

      onActionCompleted?.call();
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Hide loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
