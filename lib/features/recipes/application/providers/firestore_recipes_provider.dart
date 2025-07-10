import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/recipes/data/repositories/ai_recipe_firestore_repository.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';

// Provider for the AI Recipe Firestore Repository
final aiRecipeFirestoreRepositoryProvider =
    Provider<AIRecipeFirestoreRepository>((ref) {
      return AIRecipeFirestoreRepository();
    });

// State for storing Firestore recipes
class FirestoreRecipesState {
  final List<Recipe> recipes;
  final bool isLoading;
  final String? error;

  FirestoreRecipesState({
    this.recipes = const [],
    this.isLoading = false,
    this.error,
  });

  FirestoreRecipesState copyWith({
    List<Recipe>? recipes,
    bool? isLoading,
    String? error,
  }) {
    return FirestoreRecipesState(
      recipes: recipes ?? this.recipes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier for managing Firestore recipes
class FirestoreRecipesNotifier extends StateNotifier<FirestoreRecipesState> {
  final AIRecipeFirestoreRepository _repository;

  FirestoreRecipesNotifier(this._repository) : super(FirestoreRecipesState()) {
    // Load recipes when created
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final recipes = await _repository.getUserRecipes();
      state = state.copyWith(recipes: recipes, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load recipes: $e',
        isLoading: false,
      );
    }
  }

  Future<void> saveRecipe(Recipe recipe) async {
    try {
      final recipeId = await _repository.saveRecipe(recipe);

      // If the recipe was saved successfully, add it to the state
      if (recipeId.isNotEmpty) {
        final updatedRecipe = recipe.copyWith(id: recipeId);
        state = state.copyWith(recipes: [...state.recipes, updatedRecipe]);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to save recipe: $e');
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      await _repository.deleteRecipe(recipeId);

      // Remove the recipe from the state
      final updatedRecipes =
          state.recipes.where((recipe) => recipe.id != recipeId).toList();
      state = state.copyWith(recipes: updatedRecipes);
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete recipe: $e');
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      await _repository.updateRecipe(recipe);

      // Update the recipe in the state
      final index = state.recipes.indexWhere((r) => r.id == recipe.id);
      if (index >= 0) {
        final updatedRecipes = [...state.recipes];
        updatedRecipes[index] = recipe;
        state = state.copyWith(recipes: updatedRecipes);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to update recipe: $e');
    }
  }
}

// Provider for the FirestoreRecipesNotifier
final firestoreRecipesProvider =
    StateNotifierProvider<FirestoreRecipesNotifier, FirestoreRecipesState>((
      ref,
    ) {
      final repository = ref.watch(aiRecipeFirestoreRepositoryProvider);
      return FirestoreRecipesNotifier(repository);
    });

// Convenience provider for accessing just the recipes
final firestoreRecipesListProvider = Provider<List<Recipe>>((ref) {
  return ref.watch(firestoreRecipesProvider).recipes;
});

// Provider for checking if recipes are loading
final isLoadingFirestoreRecipesProvider = Provider<bool>((ref) {
  return ref.watch(firestoreRecipesProvider).isLoading;
});

// Provider for any errors
final firestoreRecipesErrorProvider = Provider<String?>((ref) {
  return ref.watch(firestoreRecipesProvider).error;
});
