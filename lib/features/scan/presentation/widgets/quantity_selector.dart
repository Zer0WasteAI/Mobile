import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart'; // Assuming AppColors exists

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
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
              // Disable color if quantity is 1 or less
              color: quantity > 1 ? iconColor : disabledIconColor,
            ),
            style: IconButton.styleFrom(
              backgroundColor: buttonBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: _borderRadius),
              disabledBackgroundColor: buttonBackgroundColor.withOpacity(0.7),
            ),
            // Disable onPressed if quantity is 1 or less
            onPressed: quantity > 1 ? onDecrement : null,
          ),
        ),

        // Quantity Text
        Container(
          width: 40, // Fixed width for the number display
          alignment: Alignment.center,
          child: Text(
            quantity.toString(),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: quantityTextColor,
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
}
