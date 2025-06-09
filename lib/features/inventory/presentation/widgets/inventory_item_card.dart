// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/storage_type.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/expiration_status.dart';
import 'package:zer0_waste_ai/core/utils/date_extensions.dart'; // Import the extension
import 'package:zer0_waste_ai/features/inventory/presentation/widgets/expired_item_actions_bottom_sheet.dart';
// Import ItemCategory
import 'package:zer0_waste_ai/features/inventory/presentation/screens/inventory_screen.dart'; // Import for _showQuantityEditDialog

class InventoryItemCard extends ConsumerWidget {
  final InventoryItem item;
  final bool isHighlighted;
  final List<InventoryItem> allBatchesForIngredient;

  const InventoryItemCard({
    super.key,
    required this.item,
    required this.allBatchesForIngredient,
    this.isHighlighted = false,
  });

  // Define colors based on the design system
  static const Color mainTextColor = Color(0xFF3A3A3A);
  static const Color secondaryTextColor = Color(0xFF70605A);
  static const Color expirationWarningColor = Color(0xFFFFE066);
  static const Color primaryColor = Color(0xFF00B894);
  static const Color defaultCardBackground = Colors.white;
  static const Color highlightCardBackground = Color(
    0xFFE6F9F0,
  ); // Color de fondo para elementos destacados
  static const Color cardBorderColor = Color(0xFFE0E0E0); // Soft grey border

  Color _getExpirationBadgeColor(DateTime? expirationDate) {
    if (expirationDate == null) return Colors.transparent;
    final now = DateTime.now();
    final expirationDay = DateUtils.dateOnly(expirationDate);
    final today = DateUtils.dateOnly(now);
    final differenceInDays = expirationDay.difference(today).inDays;

    if (differenceInDays < 0) return AppColors.error.withValues(alpha: 0.15);
    if (differenceInDays <= 3) {
      return expirationWarningColor.withValues(alpha: 0.3);
    }
    return Colors.transparent;
  }

  Color _getExpirationTextColor(DateTime? expirationDate) {
    if (expirationDate == null) return secondaryTextColor;
    final now = DateTime.now();
    final expirationDay = DateUtils.dateOnly(expirationDate);
    final today = DateUtils.dateOnly(now);
    final differenceInDays = expirationDay.difference(today).inDays;

    if (differenceInDays < 0) return AppColors.error;
    if (differenceInDays <= 3) return Colors.orange.shade900;
    return secondaryTextColor;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the new extension method directly
    final expirationStatusText = item.expirationDate.formatExpirationStatus();
    final expirationBadgeColor = _getExpirationBadgeColor(item.expirationDate);
    final expirationTextColor = _getExpirationTextColor(item.expirationDate);

    final textTheme = Theme.of(context).textTheme;

    // Get screen width to help with responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate approximate width for middle column (adjust as needed)
    final middleColumnWidth =
        screenWidth - 150; // Reserve space for image and quantity

    return Stack(
      children: [
        // Tarjeta principal del ítem
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          decoration: BoxDecoration(
            color:
                isHighlighted ? highlightCardBackground : defaultCardBackground,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color:
                  isHighlighted
                      ? primaryColor.withValues(alpha: 0.8)
                      : cardBorderColor,
              width: isHighlighted ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isHighlighted
                        ? primaryColor.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.08),
                spreadRadius: isHighlighted ? 2 : 1,
                blurRadius: isHighlighted ? 6 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 10.0,
            ), // Reduced horizontal padding
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Image/Emoji with real image support
                SizedBox(
                  width: 36, // Reduced width
                  height: 36, // Reduced height
                  child: _buildItemImage(item),
                ),
                const SizedBox(width: 8.0), // Reduced spacing
                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row for Item Name and Batch Selector Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 15, // Smaller font
                                color: mainTextColor,
                              ),
                              maxLines: 1, // Only one line to save space
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Show indicator for multiple batches
                          if (allBatchesForIngredient.length > 1)
                            GestureDetector(
                              onTap: () {
                                // Call the batch selector dialog function
                                showBatchSelectorDialog(
                                  context,
                                  item,
                                  allBatchesForIngredient,
                                  ref,
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(left: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: primaryColor.withValues(alpha: 0.3),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${allBatchesForIngredient.length}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'lotes',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      size: 14,
                                      color: primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4.0), // Reduced spacing
                      // Expiration date info
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12, // Smaller icon
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 2.0), // Smaller spacing
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4, // Smaller padding
                                vertical: 1, // Smaller padding
                              ),
                              decoration: BoxDecoration(
                                color: expirationBadgeColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                expirationStatusText, // Use the formatted text
                                style: GoogleFonts.inter(
                                  fontSize: 10.0, // Smaller font
                                  color: expirationTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 3.0), // Small spacing between rows
                      // Storage info
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.storageType.icon,
                            size: 12, // Smaller icon
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 2.0), // Smaller spacing
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4, // Smaller padding
                                vertical: 1, // Smaller padding
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Colors.grey.shade100, // Simple grey badge
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item
                                    .storageType
                                    .displayName, // Show name from enum
                                style: GoogleFonts.inter(
                                  fontSize: 10.0, // Smaller font
                                  fontWeight: FontWeight.w500,
                                  color: secondaryTextColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6.0), // Further reduced spacing
                // Quantity Display with Edit Button - Make more compact
                GestureDetector(
                  onTap: () {
                    // Call the dialog function from the screen
                    showQuantityEditDialog(context, item, ref);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, // Minimal padding
                      vertical: 4.0, // Minimal padding
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Value and unit in one row
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatQuantity(item.quantity, item.unitType),
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0, // Smaller font
                                color: mainTextColor,
                              ),
                            ),
                            const SizedBox(width: 1), // Minimal spacing
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 30),
                              child: Text(
                                item.unitType,
                                style: GoogleFonts.inter(
                                  fontSize: 10.0, // Smaller font
                                  color: secondaryTextColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        // Edit icon below, not beside
                        Icon(
                          Icons.edit,
                          size: 11, // Smaller icon
                          color: primaryColor.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Etiqueta "Nuevo" animada
        if (isHighlighted)
          Positioned(top: 0, right: 0, child: PulsingNewBadge()),

        // Botón de acciones para items expirados
        if (_isItemExpired(item))
          Positioned(
            top: 8,
            left: 8,
            child: _buildExpiredActionButton(context),
          ),
      ],
    );
  }

  // Helper to check if item is expired
  bool _isItemExpired(InventoryItem item) {
    if (item.expirationDate == null) return false;
    final status = ExpirationStatusExtension.fromDate(item.expirationDate);
    return status == ExpirationStatus.expired;
  }

  // Helper to build expired action button
  Widget _buildExpiredActionButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder:
              (context) => ExpiredItemActionsBottomSheet(
                expiredItem: item,
                onActionCompleted: () {
                  // Refresh the parent view if needed
                },
              ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.warning_outlined,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  // Helper to build item image with fallback to emoji
  Widget _buildItemImage(InventoryItem item) {
    // If item has a real image URL and it's not null
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          item.imageUrl!,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // If image fails to load, show emoji as fallback
            return Center(
              child: Text(item.image, style: const TextStyle(fontSize: 24)),
            );
          },
        ),
      );
    } else {
      // No image URL available, show emoji
      return Center(
        child: Text(item.image, style: const TextStyle(fontSize: 24)),
      );
    }
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

  // Helper to get minimum quantity based on unit type
  // ignore: unused_element
  double _getMinimumQuantity(String unitType) {
    switch (unitType.toLowerCase()) {
      case 'kg':
      case 'g':
      case 'lt':
      case 'ml':
        return 0.1;
      case 'unidades':
      default:
        return 1.0;
    }
  }
}

/// Widget que muestra una etiqueta "Nuevo" con efecto pulsante
class PulsingNewBadge extends StatefulWidget {
  const PulsingNewBadge({super.key});

  @override
  State<PulsingNewBadge> createState() => _PulsingNewBadgeState();
}

class _PulsingNewBadgeState extends State<PulsingNewBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar la animación pulsante
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Animación de escala suave
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5252), // Rojo brillante
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Nuevo',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
