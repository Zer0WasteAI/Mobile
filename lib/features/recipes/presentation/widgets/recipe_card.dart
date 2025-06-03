import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/recipes/application/states/recipe_state.dart';
import 'package:zer0_waste_ai/features/recipes/domain/enums/recipe_mode.dart';

class RecipeCard extends ConsumerWidget {
  final Recipe recipe;
  final RecipeMode mode;

  const RecipeCard({required this.recipe, required this.mode, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    // --- Theme-aware Colors (use AppColors from core) ---
    // ignore: unused_local_variable
    final Color primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final Color mainTextColor =
        isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final Color secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final Color cardBackgroundColor =
        isDark
            ? AppColors.darkSurface
            : AppColors
                .lightBackground; // Use lightBackground as light surface fallback
    // Use warning colors from core
    final Color expiringBadgeColor =
        isDark
            ? AppColors.warningTextDark.withValues(alpha: 0.2)
            : AppColors.warningTextLight.withValues(alpha: 0.15);
    final Color expiringBadgeTextColor =
        isDark ? AppColors.warningTextDark : AppColors.warningTextLight;
    // ------------------------- //

    // TODO: Implement the full card UI based on the design spec

    return Card(
      color: cardBackgroundColor,
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to Recipe Detail Screen
          log('Navigate to detail for ${recipe.name}');
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    recipe.emoji,
                    style: const TextStyle(fontSize: 32),
                  ), // Placeholder for image/emoji
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recipe.name,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: mainTextColor, // Use derived color
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                recipe.description, // Short description if available
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: secondaryTextColor, // Use derived color
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // TODO: Implement Ingredient Chips (✓ / ✗) - Needs inventory check
              // TODO: Implement "Tienes X de Y ingredientes" text for smart mode
              // TODO: Implement "Ver receta" button or ensure InkWell covers it

              // --- Smart Mode Specific UI ---
              if (mode == RecipeMode.smartFromInventory) ...[
                if (recipe.availableIngredientsCount != null &&
                    recipe.requiredIngredientsCount != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      'Tienes ${recipe.availableIngredientsCount} de ${recipe.requiredIngredientsCount} ingredientes',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: secondaryTextColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                if (recipe.usesExpiringItems)
                  Chip(
                    label: Text(
                      'Aprovecha ingredientes por vencer',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: expiringBadgeTextColor, // Use derived color
                      ),
                    ),
                    backgroundColor: expiringBadgeColor, // Use derived color
                    avatar: Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: expiringBadgeTextColor,
                    ),
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
              ],

              // --- Explore Mode Specific UI (Placeholder) ---
              // if (mode == RecipeMode.explore)
              //   Text(
              //     'Explore Mode Placeholder',
              //     style: GoogleFonts.inter(fontSize: 12, color: Colors.green),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
