import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_providers.dart';
import 'recipe_dialog_manager.dart';

/// Builder for recipe cards and grids
class RecipeCardBuilder {
  /// Build a grid view of recipe cards
  static Widget buildRecipeGrid(
    List<MealPlan> recipes, 
    WidgetRef ref,
    {bool selectionMode = false,
    Function(MealPlan)? onRecipeSelected}
  ) {
    if (recipes.isEmpty) {
      return _buildEmptyState(
        'No se encontraron recetas',
        'Intenta con otros filtros o agrega tus propias recetas',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return buildRecipeCard(
          recipe, 
          ref,
          selectionMode: selectionMode,
          onRecipeSelected: onRecipeSelected,
        );
      },
    );
  }

  /// Build a single recipe card
  static Widget buildRecipeCard(
    MealPlan recipe, 
    WidgetRef ref,
    {bool selectionMode = false,
    Function(MealPlan)? onRecipeSelected}
  ) {
    return GestureDetector(
      onTap: () {
        // Si estamos en modo selección, llamar al callback con la receta seleccionada
        if (selectionMode && onRecipeSelected != null) {
          onRecipeSelected(recipe);
        } else {
          // Si no, mostrar detalles
          final context = ref.context;
          RecipeDialogManager.showRecipeDetails(context, recipe, ref);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe image and type badge
            _buildRecipeHeader(recipe, ref),
            
            // Recipe content
            Expanded(
              child: _buildRecipeContent(recipe, ref),
            ),
            
            // Recipe actions
            _buildRecipeActions(recipe, ref, selectionMode),
          ],
        ),
      ),
    );
  }

  /// Build empty state widget
  static Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Build recipe header with image and type badge
  static Widget _buildRecipeHeader(MealPlan recipe, WidgetRef ref) {
    return Stack(
      children: [
        // Recipe image container
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: recipe.type.color.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Center(
            child: Icon(
              recipe.type.icon,
              size: 40,
              color: recipe.type.color,
            ),
          ),
        ),
        
        // Type badge
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: recipe.type.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              recipe.type.name,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        // Favorite button
        Positioned(
          top: 8,
          right: 8,
          child: _buildFavoriteButton(recipe, ref),
        ),
      ],
    );
  }

  /// Build recipe content with name, description, and stats
  static Widget _buildRecipeContent(MealPlan recipe, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe name
          Text(
            recipe.name,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 6),
          
          // Recipe description or category
          Text(
            recipe.description ?? 'Deliciosa receta casera',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const Spacer(),
          
          // Recipe stats
          _buildRecipeStats(recipe),
        ],
      ),
    );
  }

  /// Build recipe statistics row
  static Widget _buildRecipeStats(MealPlan recipe) {
    return Row(
      children: [
        // Cooking time
        _buildStatItem(
          Icons.access_time,
          recipe.cookingTime != null ? '${recipe.cookingTime}min' : '30min',
        ),
        
        const SizedBox(width: 12),
        
        // Servings
        _buildStatItem(
          Icons.people,
          recipe.servings != null ? '${recipe.servings}' : '2',
        ),
        
        const Spacer(),
        
        // Calories
        if (recipe.calories != null)
          _buildStatItem(
            Icons.local_fire_department,
            '${recipe.calories}',
            color: Colors.orange,
          ),
      ],
    );
  }

  /// Build a single stat item
  static Widget _buildStatItem(IconData icon, String value, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: color ?? Colors.grey.shade600,
        ),
        const SizedBox(width: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: color ?? Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Build favorite button
  static Widget _buildFavoriteButton(MealPlan recipe, WidgetRef ref) {
    final isFavorite = ref.watch(favoriteRecipesProvider).contains(recipe);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () {
          if (isFavorite) {
            ref.read(favoriteRecipesProvider.notifier).removeFavorite(recipe);
          } else {
            ref.read(favoriteRecipesProvider.notifier).addFavorite(recipe);
          }
        },
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : Colors.grey.shade600,
          size: 18,
        ),
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(
          minWidth: 28,
          minHeight: 28,
        ),
      ),
    );
  }

  /// Build recipe actions (bottom section)
  static Widget _buildRecipeActions(
    MealPlan recipe, 
    WidgetRef ref, 
    bool selectionMode
  ) {
    if (selectionMode) {
      return Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFA5).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Seleccionar',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00BFA5),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Quick info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.difficulty ?? 'Fácil',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _getDifficultyColor(recipe.difficulty),
                  ),
                ),
                if (recipe.rating != null)
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 10,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        recipe.rating!.toStringAsFixed(1),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Add to plan button
          GestureDetector(
            onTap: () {
              final context = ref.context;
              RecipeDialogManager.showAddToPlanDialog(context, recipe, ref);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF00BFA5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.add,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get color for difficulty level
  static Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'fácil':
        return Colors.green;
      case 'medio':
        return Colors.orange;
      case 'difícil':
        return Colors.red;
      default:
        return Colors.green;
    }
  }
}