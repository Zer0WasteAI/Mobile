/// INFO: Repository interface for AI-powered recipe management
/// ADVICE: This defines the contract for all recipe-related operations
/// USAGE: Implement this interface to create different recipe data sources
abstract class RecipeRepository {
  /// INFO: Generate recipes using AI based on current inventory items
  /// ADVICE: AI analyzes your inventory and suggests optimal recipes to reduce waste
  /// RETURNS: Complete response with generated_recipes, inventory_utilization, and images info
  Future<Map<String, dynamic>> generateRecipesFromInventory();

  /// INFO: Generate custom recipes with specific ingredients and preferences using AI
  /// USAGE: Specify ingredients, dietary preferences, categories, and number of recipes
  /// ADVICE: Use preferences like ["vegetarian", "gluten-free", "low-calorie"]
  /// RETURNS: Complete response with generated_recipes and images info
  Future<Map<String, dynamic>> generateCustomRecipes({
    required List<String> ingredients,
    List<String>? preferences,
    List<String>? recipeCategories,
    int numRecipes = 2,
  });

  /// INFO: Save a generated or custom recipe to user's collection
  /// USAGE: Save complete recipe data including ingredients, instructions, and metadata
  /// RETURNS: Saved recipe with UID and timestamp
  Future<Map<String, dynamic>> saveRecipe(Map<String, dynamic> recipeData);

  /// INFO: Get all user's saved/favorite recipes
  /// USAGE: Retrieve user's personal recipe collection
  /// RETURNS: Array of saved recipes with metadata and count
  Future<Map<String, dynamic>> getSavedRecipes();

  /// INFO: Get all available recipes (public + user's)
  /// USAGE: Retrieve complete recipe database for browsing
  /// RETURNS: Array of all recipes with count
  Future<Map<String, dynamic>> getAllRecipes();

  /// INFO: Get default/curated recipes available for all users
  /// USAGE: Retrieve curated recipe collection with optional category filter
  /// RETURNS: Array of default recipes with count
  Future<Map<String, dynamic>> getDefaultRecipes({String? category});

  /// INFO: Delete a user's saved recipe
  /// USAGE: Remove recipe from user's collection by title
  /// RETURNS: Confirmation message
  Future<Map<String, dynamic>> deleteRecipe(String recipeTitle);
}
