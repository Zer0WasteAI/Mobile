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
        side: BorderSide(color: outlineColor, width: 0.5),
      ),
      color: cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Image
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
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
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
                  // Optional: Display Expiry Date
                  if (item.expiryDate != null && item.expiryDate!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Caduca: ${item.expiryDate}', // TODO: Format date properly
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color:
                              colorScheme
                                  .secondary, // Use secondary color for expiry
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  QuantitySelector(
                    quantity: item.quantity,
                    onIncrement: onIncrement,
                    onDecrement: onDecrement,
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
