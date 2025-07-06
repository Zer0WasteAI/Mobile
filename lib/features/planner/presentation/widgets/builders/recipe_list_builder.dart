import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_providers.dart';

class RecipeListBuilder {
  static Widget buildRecipeList(
    BuildContext context,
    StateSetter setState,
    List<MealPlan> recipes,
    MealPlan? selectedMeal,
    Function(MealPlan) onSelect,
    WidgetRef ref,
  ) {
    if (recipes.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        final isSelected = selectedMeal?.id == recipe.id;

        return _buildRecipeItem(
          context,
          recipe,
          isSelected,
          onSelect,
          ref,
          setState,
        );
      },
    );
  }

  static Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No hay recetas disponibles',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otros filtros o añade tus propias recetas',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Widget _buildRecipeItem(
    BuildContext context,
    MealPlan recipe,
    bool isSelected,
    Function(MealPlan) onSelect,
    WidgetRef ref,
    StateSetter setState,
  ) {
    return InkWell(
      onTap: () => onSelect(recipe),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF00BFA5).withValues(alpha: 0.1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00BFA5) : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildRecipeImage(recipe),
            const SizedBox(width: 16),
            Expanded(child: _buildRecipeInfo(recipe)),
            _buildRecipeAction(recipe, isSelected, ref, setState),
          ],
        ),
      ),
    );
  }

  static Widget _buildRecipeImage(MealPlan recipe) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
        image: DecorationImage(
          image: AssetImage(recipe.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  static Widget _buildRecipeInfo(MealPlan recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRecipeType(recipe),
        const SizedBox(height: 4),
        _buildRecipeName(recipe),
        const SizedBox(height: 4),
        _buildRecipeDetails(recipe),
      ],
    );
  }

  static Widget _buildRecipeType(MealPlan recipe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: recipe.type.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        recipe.type.name,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: recipe.type.color,
        ),
      ),
    );
  }

  static Widget _buildRecipeName(MealPlan recipe) {
    return Text(
      recipe.name,
      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  static Widget _buildRecipeDetails(MealPlan recipe) {
    return Row(
      children: [
        // Tiempo
        Icon(Icons.schedule, size: 12, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          '${recipe.prepTimeMinutes} min',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 8),
        // Calorías
        Icon(
          Icons.local_fire_department,
          size: 12,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          '${recipe.calories} kcal',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
        ),
        // Favorito
        if (recipe.isFavorite)
          Row(
            children: [
              const SizedBox(width: 8),
              Icon(Icons.favorite, size: 12, color: Colors.red),
            ],
          ),
      ],
    );
  }

  static Widget _buildRecipeAction(
    MealPlan recipe,
    bool isSelected,
    WidgetRef ref,
    StateSetter setState,
  ) {
    if (isSelected) {
      return Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF00BFA5),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      );
    } else {
      return IconButton(
        icon: Icon(
          recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: recipe.isFavorite ? Colors.red : Colors.grey,
          size: 18,
        ),
        onPressed: () {
          // Toggle favorito
          ref.read(allRecipesProvider.notifier).toggleFavorite(recipe.id);
          setState(() {}); // Actualizar UI
        },
      );
    }
  }
}
