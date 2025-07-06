import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart'; // Assuming AppColors exists

class QuantitySelector extends StatelessWidget {
  final double quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final String? unit; // Add unit parameter

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.unit, // Optional unit (e.g., 'gramos', 'unidades')
  });

  // Define button style constants
  static const double _buttonSize = 32.0;
  static const double _iconSize = 18.0;
  static final BorderRadius _borderRadius = BorderRadius.circular(8.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    // Use theme colors for consistency
    final Color buttonBackgroundColor =
        theme.colorScheme.surfaceContainerHighest;
    final Color iconColor =
        isDark
            ? AppColors.darkSecondaryText.withValues(alpha: 0.7)
            : AppColors.lightSecondaryText.withValues(alpha: 0.7); // Muted icon
    final Color disabledIconColor = iconColor.withValues(alpha: 0.4);
    final Color quantityTextColor =
        isDark ? AppColors.darkMainText : AppColors.lightMainText;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Decrement Button
        SizedBox(
          width: _buttonSize,
          height: _buttonSize,
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: _iconSize,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              FontAwesomeIcons.minus,
              // Disable color if quantity is at minimum
              color:
                  quantity > _getMinimumQuantity(unit)
                      ? iconColor
                      : disabledIconColor,
            ),
            style: IconButton.styleFrom(
              backgroundColor: buttonBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: _borderRadius),
              disabledBackgroundColor: buttonBackgroundColor.withValues(
                alpha: 0.7,
              ),
            ),
            // Disable onPressed if quantity is at minimum
            onPressed:
                quantity > _getMinimumQuantity(unit) ? onDecrement : null,
          ),
        ),

        // Quantity Text with Unit
        Container(
          constraints: const BoxConstraints(
            minWidth: 60,
          ), // Dynamic width for text + unit
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: quantityTextColor,
              ),
              children: [
                TextSpan(text: _formatQuantity(quantity, unit)),
                if (unit != null && unit!.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: quantityTextColor.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Increment Button
        SizedBox(
          width: _buttonSize,
          height: _buttonSize,
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: _iconSize,
            visualDensity: VisualDensity.compact,
            icon: Icon(FontAwesomeIcons.plus, color: iconColor),
            style: IconButton.styleFrom(
              backgroundColor: buttonBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: _borderRadius),
            ),
            onPressed: onIncrement,
          ),
        ),
      ],
    );
  }

  // Helper method to get minimum quantity based on unit type
  double _getMinimumQuantity(String? unit) {
    if (unit == null) return 1.0;
    switch (unit.toLowerCase()) {
      case 'kg':
      case 'g':
      case 'lt':
      case 'ml':
      case 'gramos':
      case 'kilogramos':
      case 'litros':
      case 'mililitros':
        return 0.1;
      case 'unidades':
      case 'unidad':
      default:
        return 1.0;
    }
  }

  // Helper method to format quantity display
  String _formatQuantity(double quantity, String? unit) {
    if (unit == null) return quantity.toString();

    switch (unit.toLowerCase()) {
      case 'unidades':
      case 'unidad':
        return quantity.toInt().toString(); // Show units as integer
      default:
        // For kg, g, lt, ml, show one decimal place if not whole
        if (quantity == quantity.truncateToDouble()) {
          return quantity.toInt().toString(); // 5.0 becomes "5"
        } else {
          return quantity.toStringAsFixed(1); // 5.1 becomes "5.1"
        }
    }
  }
}
