import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/storage_type.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';
import 'package:intl/date_symbol_data_local.dart';

class InventoryItemCard extends ConsumerWidget {
  final InventoryItem item;
  final bool isHighlighted;

  const InventoryItemCard({
    super.key,
    required this.item,
    this.isHighlighted = false,
  });

  // Define colors based on the design system
  static const Color mainTextColor = Color(0xFF3A3A3A);
  static const Color secondaryTextColor = Color(0xFF70605A);
  static const Color expirationWarningColor = Color(0xFFFFE066);
  static const Color primaryColor = Color(0xFF00B894);
  static const Color defaultCardBackground = Colors.white;
  static const Color highlightCardBackground = Color(0xFFE6F9F0);
  static const Color cardBorderColor = Color(0xFFE0E0E0); // Soft grey border

  String _getExpirationStatus(DateTime? expirationDate) {
    if (expirationDate == null) return 'Sin fecha';
    final now = DateTime.now();
    // Calculate difference, ensuring we compare date parts only for 'days left'
    final expirationDay = DateUtils.dateOnly(expirationDate);
    final today = DateUtils.dateOnly(now);
    final differenceInDays = expirationDay.difference(today).inDays;

    if (differenceInDays < 0) return 'Vencido';
    // If it expires today (differenceInDays is 0) or tomorrow (differenceInDays is 1) up to the threshold
    if (differenceInDays <= 3) {
      // Show '1 día' if it expires today or tomorrow but hasn't passed yet.
      final displayDays = differenceInDays == 0 ? 1 : differenceInDays;
      return 'Vence pronto ($displayDays días)';
    }

    return DateFormat('dd/MM/yy').format(expirationDate); // Shorter format
  }

  Color _getExpirationBadgeColor(DateTime? expirationDate) {
    if (expirationDate == null) return Colors.transparent;
    final now = DateTime.now();
    final expirationDay = DateUtils.dateOnly(expirationDate);
    final today = DateUtils.dateOnly(now);
    final differenceInDays = expirationDay.difference(today).inDays;

    if (differenceInDays < 0) return AppColors.error.withOpacity(0.15);
    if (differenceInDays <= 3) return expirationWarningColor.withOpacity(0.3);
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
    final expirationStatus = _getExpirationStatus(item.expirationDate);
    final expirationBadgeColor = _getExpirationBadgeColor(item.expirationDate);
    final expirationTextColor = _getExpirationTextColor(item.expirationDate);

    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: isHighlighted ? highlightCardBackground : defaultCardBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color:
              isHighlighted ? primaryColor.withOpacity(0.5) : cardBorderColor,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Row(
          children: [
            // Image/Emoji
            SizedBox(
              width: 40, // Slightly smaller image area
              height: 40,
              child: Center(
                child: Text(
                  item.image, // Display emoji directly
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16, // Corresponds roughly to titleMedium
                      color: mainTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5.0),
                  // Expiration and Storage Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 4.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: expirationBadgeColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          expirationStatus,
                          style: GoogleFonts.inter(
                            fontSize: 12.0,
                            color: expirationTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Storage Badge (using icon + text maybe? Or just text?)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 3.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100, // Simple grey badge
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          item.storageType.displayName, // Show name from enum
                          style: GoogleFonts.inter(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w500,
                            color:
                                secondaryTextColor, // Dark text on light grey
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0),
            // Quantity Adjuster
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 28, // Slightly smaller buttons
                  width: 28,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.add_circle,
                      color: primaryColor,
                      size: 24,
                    ),
                    onPressed: () {
                      ref
                          .read(inventoryProvider.notifier)
                          .incrementQuantity(item.id);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2.0,
                  ), // Add padding around number
                  child: Text(
                    item.quantity.toString(),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: mainTextColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 28,
                  width: 28,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.remove_circle,
                      color:
                          item.quantity > 1
                              ? primaryColor
                              : Colors.grey.shade400,
                      size: 24,
                    ),
                    onPressed:
                        item.quantity > 1
                            ? () {
                              ref
                                  .read(inventoryProvider.notifier)
                                  .decrementQuantity(item.id);
                            }
                            : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
