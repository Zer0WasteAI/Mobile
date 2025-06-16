import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/recipes/application/states/recipe_state.dart';
import 'package:zer0_waste_ai/features/recipes/domain/enums/recipe_mode.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';

class RecipeCard extends ConsumerWidget {
  final Recipe recipe;
  final RecipeMode mode;

  const RecipeCard({required this.recipe, required this.mode, super.key});

  // Helper method to check if ingredient is available in inventory
  bool _isIngredientAvailable(String ingredient, WidgetRef ref) {
    final inventoryState = ref.watch(inventoryProvider);

    // Simple check: see if any inventory item name contains the ingredient name
    // This is a basic implementation - in a real app you'd want more sophisticated matching
    return inventoryState.items.any(
      (item) =>
          item.name.toLowerCase().contains(ingredient.toLowerCase()) ||
          ingredient.toLowerCase().contains(item.name.toLowerCase()),
    );
  }

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

    return Card(
      color: cardBackgroundColor,
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          // Navigate to Recipe Detail Screen
          _navigateToRecipeDetail(context, recipe);
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

              // --- Smart Mode Specific UI ---
              if (mode == RecipeMode.smartFromInventory) ...[
                // Ingredient availability indicator
                if (recipe.availableIngredientsCount != null &&
                    recipe.requiredIngredientsCount != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Tienes ${recipe.availableIngredientsCount} de ${recipe.requiredIngredientsCount} ingredientes',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: secondaryTextColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  // Ingredient chips preview (first few ingredients)
                  if (recipe.ingredients.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Wrap(
                        spacing: 4.0,
                        runSpacing: 4.0,
                        children:
                            recipe.ingredients
                                .take(3) // Show only first 3 ingredients
                                .map(
                                  (ingredient) => _buildIngredientChip(
                                    ingredient,
                                    _isIngredientAvailable(ingredient, ref),
                                    mainTextColor,
                                    secondaryTextColor,
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                ],
                // Expiring items warning
                if (recipe.usesExpiringItems)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Chip(
                      label: Text(
                        'Aprovecha ingredientes por vencer',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: expiringBadgeTextColor,
                        ),
                      ),
                      backgroundColor: expiringBadgeColor,
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
                  ),
              ],

              // --- Recipe metadata and action button ---
              Row(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 14,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${recipe.ingredients.length} ingredientes',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),
                  const Spacer(),
                  // View recipe button
                  TextButton(
                    onPressed: () => _navigateToRecipeDetail(context, recipe),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Ver receta',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to navigate to recipe detail
  void _navigateToRecipeDetail(BuildContext context, Recipe recipe) {
    // Convert Recipe to the format expected by RecipeDetailScreen
    final recipeData = {
      'name': recipe.name,
      'description': recipe.description,
      'emoji': recipe.emoji,
      'ingredients': recipe.ingredients,
      'time': '30 min', // Default time since not available in Recipe model
      'difficulty': 'Intermedio', // Default difficulty
      'type': 'principal',
      'tags': <String>[], // Empty tags for now
      'usesExpiringItems': recipe.usesExpiringItems,
      'dietType': 'Omnívora', // Default diet type
      'steps': [
        'Prepara todos los ingredientes antes de comenzar',
        'Sigue las instrucciones de la receta paso a paso',
        'Disfruta de tu comida recién preparada',
      ],
    };

    context.pushNamed('recipeDetail', extra: recipeData);
  }

  // Helper method to build ingredient availability chips
  Widget _buildIngredientChip(
    String ingredient,
    bool isAvailable,
    Color mainTextColor,
    Color secondaryTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            isAvailable
                ? AppColors.lightPrimary.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isAvailable
                  ? AppColors.lightPrimary.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            size: 12,
            color: isAvailable ? AppColors.lightPrimary : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            ingredient,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isAvailable ? mainTextColor : secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
