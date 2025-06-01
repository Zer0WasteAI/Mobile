/// INFO: Repository interface for AI-powered recipe management
/// ADVICE: This defines the contract for all recipe-related operations
/// USAGE: Implement this interface to create different recipe data sources
abstract class RecipeRepository {
  /// INFO: Generate recipes using AI based on current inventory items
  /// ADVICE: AI analyzes your inventory and suggests optimal recipes to reduce waste
  /// RETURNS: List of generated recipe objects with ingredients, instructions, etc.
  Future<List<Map<String, dynamic>>> generateRecipesFromInventory();

  /// INFO: Generate custom recipes with specific ingredients using AI
  /// USAGE: Specify ingredients you want to use and any dietary preferences
  /// ADVICE: Use preferences like ["vegetarian", "gluten-free", "low-calorie"]
  /// RETURNS: List of custom recipe objects
  Future<List<Map<String, dynamic>>> generateCustomRecipes({
    required List<String> ingredients,
    List<String>? preferences,
    int numRecipes = 2,
  });

  /// INFO: Save a recipe to user's favorites collection
  /// USAGE: Pass complete recipe object to save for later access
  /// RETURNS: Confirmation with saved recipe data
  Future<Map<String, dynamic>> saveRecipe(Map<String, dynamic> recipeData);

  /// INFO: Get all user's saved/favorite recipes
  /// RETURNS: Map containing array of saved recipes
  Future<Map<String, dynamic>> getSavedRecipes();
}
