/// Repository interface for recipe management
abstract class RecipeRepository {
  /// Generate recipes from current inventory using AI
  Future<List<Map<String, dynamic>>> generateRecipesFromInventory();

  /// Generate custom recipes with specific ingredients using AI
  Future<List<Map<String, dynamic>>> generateCustomRecipes({
    required List<String> ingredients,
    List<String>? preferences,
    int numRecipes = 2,
  });

  /// Save a recipe to user's favorites
  Future<Map<String, dynamic>> saveRecipe(Map<String, dynamic> recipeData);

  /// Get all saved/favorite recipes
  Future<Map<String, dynamic>> getSavedRecipes();
}
