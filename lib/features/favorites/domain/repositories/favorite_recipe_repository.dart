import '../models/favorite_recipe_model.dart';

abstract class FavoriteRecipeRepository {
  Future<void> addFavorite(FavoriteRecipe favoriteRecipe);
  Future<void> removeFavorite(String recipeId, String userId);
  Future<bool> isFavorite(String recipeId, String userId);
  Future<List<FavoriteRecipe>> getFavorites(String userId);
  Future<void> updateFavorite(FavoriteRecipe favoriteRecipe);
}