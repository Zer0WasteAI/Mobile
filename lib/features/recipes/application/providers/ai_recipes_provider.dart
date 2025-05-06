import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';

class AIRecipesNotifier extends StateNotifier<List<Recipe>> {
  AIRecipesNotifier() : super([]);

  /// Añade múltiples recetas generadas por IA a la lista
  void addGeneratedRecipes(List<Recipe> recipes) {
    // Crear nuevas recetas con flag de generada por IA
    final aiTaggedRecipes =
        recipes.map((recipe) {
          // Asegurarse de que la categoría "Generado por IA" esté incluida
          final updatedCategories = [...recipe.categories];
          if (!updatedCategories.contains('Generado por IA')) {
            updatedCategories.add('Generado por IA');
          }

          return Recipe(
            id: recipe.id,
            name: recipe.name,
            description: recipe.description,
            emoji: recipe.emoji,
            ingredients: recipe.ingredients,
            requiredIngredientsCount: recipe.requiredIngredientsCount,
            availableIngredientsCount: recipe.availableIngredientsCount,
            usesExpiringItems: true, // Siempre true para recetas generadas
            cookingTime: recipe.cookingTime,
            difficulty: recipe.difficulty,
            dietType: recipe.dietType,
            categories: updatedCategories,
          );
        }).toList();

    // Actualizar el estado con todas las recetas
    state = [...state, ...aiTaggedRecipes];
  }

  /// Elimina una receta generada por ID
  void removeRecipe(String id) {
    state = state.where((recipe) => recipe.id != id).toList();
  }

  /// Marca una receta como favorita
  void toggleFavorite(String id) {
    state =
        state.map((recipe) {
          if (recipe.id == id) {
            // Aquí necesitaríamos añadir un campo isFavorite al modelo Recipe
            // Por ahora simulamos con la categoría
            final updatedCategories = [...recipe.categories];
            if (updatedCategories.contains('Favorito')) {
              updatedCategories.remove('Favorito');
            } else {
              updatedCategories.add('Favorito');
            }

            return Recipe(
              id: recipe.id,
              name: recipe.name,
              description: recipe.description,
              emoji: recipe.emoji,
              ingredients: recipe.ingredients,
              requiredIngredientsCount: recipe.requiredIngredientsCount,
              availableIngredientsCount: recipe.availableIngredientsCount,
              usesExpiringItems: recipe.usesExpiringItems,
              cookingTime: recipe.cookingTime,
              difficulty: recipe.difficulty,
              dietType: recipe.dietType,
              categories: updatedCategories,
            );
          }
          return recipe;
        }).toList();
  }

  /// Limpia todas las recetas generadas
  void clearAll() {
    state = [];
  }
}

/// Provider para las recetas generadas por IA
final aiRecipesProvider =
    StateNotifierProvider<AIRecipesNotifier, List<Recipe>>((ref) {
      return AIRecipesNotifier();
    });

/// Provider para las recetas favoritas (entre las generadas por IA)
final favoriteAIRecipesProvider = Provider<List<Recipe>>((ref) {
  final recipes = ref.watch(aiRecipesProvider);
  return recipes
      .where((recipe) => recipe.categories.contains('Favorito'))
      .toList();
});

/// Provider para filtrar las recetas generadas por categoría específica
final filteredAIRecipesProvider = Provider.family<List<Recipe>, String>((
  ref,
  category,
) {
  final recipes = ref.watch(aiRecipesProvider);
  return recipes
      .where((recipe) => recipe.categories.contains(category))
      .toList();
});
