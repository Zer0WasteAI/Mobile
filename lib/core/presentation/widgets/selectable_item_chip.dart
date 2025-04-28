import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable chip widget for selection screens (allergies, diets, food types).
class SelectableItemChip extends StatelessWidget {
  final String label;
  final String? emoji;
  final bool isSelected;
  final bool isCustom;
  final bool isAddButton;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Color selectedColor; // Typically the primary color
  final Color defaultBackgroundColor;
  final Color defaultTextColor;
  final Color defaultBorderColor;

  const SelectableItemChip({
    super.key,
    required this.label,
    this.emoji,
    required this.isSelected,
    this.isCustom = false,
    this.isAddButton = false,
    this.onTap,
    this.onDelete,
    required this.selectedColor,
    required this.defaultBackgroundColor,
    required this.defaultTextColor,
    required this.defaultBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    // Determine styles based on state
    final Color effectiveBorderColor;
    final Color effectiveBackgroundColor;
    final Color effectiveTextColor;
    final double borderWidth;
    final bool showDeleteIcon = isCustom && !isAddButton;

    if (isAddButton) {
      effectiveBorderColor = selectedColor.withValues(alpha: 0.6); // Use primary color slightly faded
      effectiveBackgroundColor = defaultBackgroundColor;
      effectiveTextColor = selectedColor; // Use primary color for text
      borderWidth = 1.5;
      // Add a subtle dashed effect visually if possible without external packages
      // For now, just a solid border style or rely on color difference
    } else if (isSelected) {
      effectiveBorderColor = selectedColor;
      effectiveBackgroundColor = selectedColor.withValues(alpha: 0.15); // Subtle tint
      effectiveTextColor =
          defaultTextColor; // Keep default text color when selected inside
      borderWidth = 1.5;
    } else {
      effectiveBorderColor = defaultBorderColor;
      effectiveBackgroundColor = defaultBackgroundColor;
      effectiveTextColor = defaultTextColor;
      borderWidth = 1.0;
    }

    const radius = Radius.circular(16.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.all(radius),
        splashColor: selectedColor.withValues(alpha: 0.2),
        highlightColor: selectedColor.withValues(alpha: 0.1),
        child: Ink(
          padding: EdgeInsets.only(
            left:
                emoji != null || showDeleteIcon
                    ? 12.0
                    : 16.0, // Less padding if icons/delete
            right: showDeleteIcon ? 8.0 : 16.0, // Less padding if delete icon
            top: 10.0,
            bottom: 10.0,
          ),
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: const BorderRadius.all(radius),
            border: Border.all(color: effectiveBorderColor, width: borderWidth),
            boxShadow:
                isSelected || isAddButton || !showDeleteIcon && !isAddButton
                    ? []
                    : [
                      // Only show shadow on default, unselected items
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji != null && !isAddButton) ...[
                Text(emoji!, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
              ],
              // Add button uses its own icon essentially via label
              if (isAddButton) ...[
                Icon(Icons.add, size: 18, color: effectiveTextColor),
                const SizedBox(width: 4),
              ],
              Flexible(
                // Allow text label to wrap if needed, though unlikely with chips
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: effectiveTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showDeleteIcon) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: onDelete,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0), // Hit area for delete
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color:
                          isSelected
                              ? selectedColor.withValues(alpha: 0.8)
                              : defaultTextColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
