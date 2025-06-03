import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/core/services/api_service.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';

/// INFO: State for favorite recipes with comprehensive status tracking
/// USAGE: Tracks loading, error states and sync status with backend
class FavoriteRecipesState {
  final List<Recipe> favoriteRecipes;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool isBackendSynced;
  final Set<String>
  savingRecipeIds; // Track which recipes are being saved/removed

  const FavoriteRecipesState({
    this.favoriteRecipes = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.isBackendSynced = false,
    this.savingRecipeIds = const {},
  });

  FavoriteRecipesState copyWith({
    List<Recipe>? favoriteRecipes,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool? isBackendSynced,
    Set<String>? savingRecipeIds,
  }) {
    return FavoriteRecipesState(
      favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      isBackendSynced: isBackendSynced ?? this.isBackendSynced,
      savingRecipeIds: savingRecipeIds ?? this.savingRecipeIds,
    );
  }

  /// Check if a recipe is currently being saved/removed
  bool isRecipeSaving(String recipeId) {
    return savingRecipeIds.contains(recipeId);
  }

  /// Check if a recipe is favorited
  bool isFavorite(String recipeId) {
    return favoriteRecipes.any((recipe) => recipe.id == recipeId);
  }

  /// Get favorite count
  int get favoriteCount => favoriteRecipes.length;
}

/// INFO: Favorite recipes notifier with backend integration
/// USAGE: Manages complete favorite recipes with backend synchronization
class FavoriteRecipesNotifier extends StateNotifier<FavoriteRecipesState> {
  final ApiService _apiService;
  final Ref _ref;

  FavoriteRecipesNotifier(this._apiService, this._ref)
    : super(const FavoriteRecipesState()) {
    _initializeFavorites();
  }

  /// Initialize favorites from backend
  Future<void> _initializeFavorites() async {
    // Check if user is authenticated before loading
    final authState = _ref.read(authControllerProvider);
    if (!authState.hasValue || authState.value == null) return;

    await loadFavoritesFromBackend();
  }

  /// INFO: Load favorite recipes from backend API
  /// USAGE: Fetches all saved/favorite recipes from the backend
  Future<void> loadFavoritesFromBackend() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getSavedRecipes();

      // Parse the response and convert to Recipe objects
      List<Recipe> favorites = [];

      if (response['recipes'] != null) {
        final recipesData = response['recipes'] as List;
        favorites =
            recipesData
                .map((recipeData) => _parseRecipeFromBackend(recipeData))
                .toList();
      }

      state = state.copyWith(
        favoriteRecipes: favorites,
        isLoading: false,
        isBackendSynced: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar recetas favoritas: ${e.toString()}',
        isBackendSynced: false,
      );
    }
  }

  /// INFO: Save a recipe to favorites
  /// USAGE: Add a recipe to the user's favorites collection
  Future<bool> saveRecipeToFavorites(Recipe recipe) async {
    // Add to loading set for UI feedback
    state = state.copyWith(
      savingRecipeIds: {...state.savingRecipeIds, recipe.id},
      error: null,
    );

    try {
      // Prepare recipe data for backend
      final recipeData = _prepareRecipeForBackend(recipe);

      // Save to backend
      await _apiService.saveRecipe(recipeData);

      // Update local state
      final updatedFavorites = [...state.favoriteRecipes, recipe];

      state = state.copyWith(
        favoriteRecipes: updatedFavorites,
        savingRecipeIds: {...state.savingRecipeIds}..remove(recipe.id),
        isBackendSynced: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        savingRecipeIds: {...state.savingRecipeIds}..remove(recipe.id),
        error: 'Error al guardar receta: ${e.toString()}',
        isBackendSynced: false,
      );
      return false;
    }
  }

  /// INFO: Remove a recipe from favorites
  /// USAGE: Remove a recipe from the user's favorites collection
  Future<bool> removeRecipeFromFavorites(String recipeId) async {
    // Add to loading set for UI feedback
    state = state.copyWith(
      savingRecipeIds: {...state.savingRecipeIds, recipeId},
      error: null,
    );

    try {
      // TODO: Implement delete endpoint in backend if available
      // For now, we'll simulate success since the API docs don't show a delete favorite endpoint

      // Update local state
      final updatedFavorites =
          state.favoriteRecipes
              .where((recipe) => recipe.id != recipeId)
              .toList();

      state = state.copyWith(
        favoriteRecipes: updatedFavorites,
        savingRecipeIds: {...state.savingRecipeIds}..remove(recipeId),
        isBackendSynced: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        savingRecipeIds: {...state.savingRecipeIds}..remove(recipeId),
        error: 'Error al eliminar receta: ${e.toString()}',
        isBackendSynced: false,
      );
      return false;
    }
  }

  /// INFO: Toggle favorite status for a recipe
  /// USAGE: Add to favorites if not favorited, remove if already favorited
  Future<bool> toggleFavorite(Recipe recipe) async {
    if (state.isFavorite(recipe.id)) {
      return await removeRecipeFromFavorites(recipe.id);
    } else {
      return await saveRecipeToFavorites(recipe);
    }
  }

  /// INFO: Check if a recipe is favorited
  /// USAGE: Use for UI state (heart icon, etc.)
  bool isRecipeFavorited(String recipeId) {
    return state.isFavorite(recipeId);
  }

  /// INFO: Get recipes by category from favorites
  /// USAGE: Filter favorite recipes by specific categories
  List<Recipe> getFavoritesByCategory(String category) {
    return state.favoriteRecipes
        .where((recipe) => recipe.categories.contains(category))
        .toList();
  }

  /// INFO: Search within favorite recipes
  /// USAGE: Find favorite recipes matching a search query
  List<Recipe> searchFavorites(String query) {
    if (query.isEmpty) return state.favoriteRecipes;

    return state.favoriteRecipes
        .where((recipe) => recipe.matchesSearch(query))
        .toList();
  }

  /// INFO: Get favorites sorted by different criteria
  /// USAGE: Sort favorites by name, date added, cooking time, etc.
  List<Recipe> getSortedFavorites({
    SortCriteria sortBy = SortCriteria.name,
    bool ascending = true,
  }) {
    final favorites = [...state.favoriteRecipes];

    switch (sortBy) {
      case SortCriteria.name:
        favorites.sort(
          (a, b) =>
              ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name),
        );
        break;
      case SortCriteria.cookingTime:
        favorites.sort(
          (a, b) =>
              ascending
                  ? a.cookingTime.compareTo(b.cookingTime)
                  : b.cookingTime.compareTo(a.cookingTime),
        );
        break;
      case SortCriteria.difficulty:
        final difficultyOrder = {'Fácil': 1, 'Medio': 2, 'Difícil': 3};
        favorites.sort((a, b) {
          final aValue = difficultyOrder[a.difficulty] ?? 0;
          final bValue = difficultyOrder[b.difficulty] ?? 0;
          return ascending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        });
        break;
    }

    return favorites;
  }

  /// INFO: Refresh favorites from backend
  /// USAGE: Force refresh to ensure data is up-to-date
  Future<void> refresh() async {
    await loadFavoritesFromBackend();
  }

  /// INFO: Clear all local favorites (for logout)
  /// USAGE: Call when user logs out to clear favorites
  void clearFavorites() {
    state = const FavoriteRecipesState();
  }

  // Helper methods

  /// Parse recipe data from backend response
  Recipe _parseRecipeFromBackend(Map<String, dynamic> data) {
    return Recipe(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      emoji: data['emoji']?.toString() ?? '🍽️',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      requiredIngredientsCount: data['required_ingredients_count'] ?? 0,
      availableIngredientsCount: data['available_ingredients_count'] ?? 0,
      usesExpiringItems: data['uses_expiring_items'] ?? false,
      cookingTime: data['cooking_time'] ?? 30,
      difficulty: data['difficulty']?.toString() ?? 'Medio',
      dietType: data['diet_type']?.toString() ?? 'Omnívora',
      categories: List<String>.from(data['categories'] ?? ['Favoritas']),
    );
  }

  /// Prepare recipe data for backend API
  Map<String, dynamic> _prepareRecipeForBackend(Recipe recipe) {
    return {
      'id': recipe.id,
      'name': recipe.name,
      'description': recipe.description,
      'emoji': recipe.emoji,
      'ingredients': recipe.ingredients,
      'required_ingredients_count': recipe.requiredIngredientsCount,
      'available_ingredients_count': recipe.availableIngredientsCount,
      'uses_expiring_items': recipe.usesExpiringItems,
      'cooking_time': recipe.cookingTime,
      'difficulty': recipe.difficulty,
      'diet_type': recipe.dietType,
      'categories': recipe.categories,
      'saved_at': DateTime.now().toIso8601String(),
    };
  }
}

/// Sort criteria for favorite recipes
enum SortCriteria { name, cookingTime, difficulty }

/// INFO: Main favorite recipes provider
/// USAGE: Use ref.watch(favoriteRecipesProvider) to get current favorites state
final favoriteRecipesProvider =
    StateNotifierProvider<FavoriteRecipesNotifier, FavoriteRecipesState>((ref) {
      final apiService = ApiService.instance;
      return FavoriteRecipesNotifier(apiService, ref);
    });

/// INFO: Convenient providers for specific favorite recipe data
/// ADVICE: Use these for easier access to specific information

final favoriteRecipesListProvider = Provider<List<Recipe>>((ref) {
  return ref.watch(favoriteRecipesProvider).favoriteRecipes;
});

final isFavoritesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(favoriteRecipesProvider).isLoading;
});

final favoritesErrorProvider = Provider<String?>((ref) {
  return ref.watch(favoriteRecipesProvider).error;
});

final favoriteCountProvider = Provider<int>((ref) {
  return ref.watch(favoriteRecipesProvider).favoriteCount;
});

final isFavoritesBackendSyncedProvider = Provider<bool>((ref) {
  return ref.watch(favoriteRecipesProvider).isBackendSynced;
});

/// Provider to check if a specific recipe is favorited
final isRecipeFavoritedProvider = Provider.family<bool, String>((
  ref,
  recipeId,
) {
  return ref.watch(favoriteRecipesProvider).isFavorite(recipeId);
});

/// Provider to check if a recipe is currently being saved/removed
final isRecipeSavingProvider = Provider.family<bool, String>((ref, recipeId) {
  return ref.watch(favoriteRecipesProvider).isRecipeSaving(recipeId);
});
