import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart'; // Assuming AppColors exists
import 'package:zer0_waste_ai/features/scan/domain/models/recognized_item.dart';
import 'package:zer0_waste_ai/features/scan/presentation/widgets/quantity_selector.dart';

class RecognizedItemCard extends StatelessWidget {
  final RecognizedItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove; // Callback to remove the item entirely

  const RecognizedItemCard({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    // Define colors based on theme
    final Color cardBackgroundColor = colorScheme.surface;
    final Color mainTextColor =
        isDark ? AppColors.darkMainText : AppColors.lightMainText;
    // final Color secondaryTextColor = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final Color outlineColor = colorScheme.outline;
    final Color removeIconColor = colorScheme.error;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color:
              item.allergyAlert
                  ? colorScheme.error.withValues(alpha: 0.5)
                  : outlineColor,
          width: item.allergyAlert ? 1.5 : 0.5,
        ),
      ),
      color:
          item.allergyAlert
              ? colorScheme.errorContainer.withValues(alpha: 0.1)
              : cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Image with optional allergy overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child:
                        item.imageUrl != null && item.imageUrl!.isNotEmpty
                            ? Image.network(
                              item.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => const Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.grey,
                                  ),
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                  ),
                                );
                              },
                            )
                            : Icon(
                              Icons.fastfood,
                              color: outlineColor,
                              size: 30,
                            ), // Placeholder icon
                  ),
                ),
                // Allergy alert indicator
                if (item.allergyAlert)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.warning,
                        color: colorScheme.onError,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Name and Quantity Selector
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: mainTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Allergy warning text
                  if (item.allergyAlert && item.allergens.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: colorScheme.error,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Contiene: ${item.allergens.join(', ')}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Display Expiry Date with additional information
                  if (item.expiryDate != null && item.expiryDate!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: colorScheme.secondary,
                            fontStyle: FontStyle.italic,
                          ),
                          children: [
                            const TextSpan(text: 'Caduca: '),
                            TextSpan(
                              text: item.expiryDate!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // Add expiration time and time unit in parentheses
                            if (item.expirationTime != null &&
                                item.timeUnit != null)
                              TextSpan(
                                text:
                                    ' (${item.expirationTime} ${item.timeUnit})',
                                style: TextStyle(
                                  color: colorScheme.secondary.withValues(
                                    alpha: 0.8,
                                  ),
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  QuantitySelector(
                    quantity: item.quantity,
                    onIncrement: onIncrement,
                    onDecrement: onDecrement,
                    unit: item.typeUnit,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Remove Button
            IconButton(
              icon: Icon(FontAwesomeIcons.trash, color: removeIconColor),
              iconSize: 20,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              tooltip: 'Eliminar este ítem',
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
