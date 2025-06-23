/// INFO: Repository interface for inventory management operations
/// ADVICE: This defines the contract for all inventory-related operations
/// USAGE: Implement this interface to create different inventory data sources
abstract class InventoryRepository {
  /// INFO: Add multiple ingredients to the user's inventory
  /// USAGE: Pass array of ingredient maps with name, quantity, expiry_date, etc.
  Future<void> addIngredients(List<Map<String, dynamic>> ingredients);

  /// INFO: Add single item to inventory (from recognition results)
  /// USAGE: Add individual item recognized from camera to user's inventory
  /// RETURNS: Map with added item data including ID and timestamps
  Future<Map<String, dynamic>> addInventoryItem(Map<String, dynamic> item);

  /// INFO: Get the complete user inventory with all stored items
  /// RETURNS: Map containing inventory data structure from backend
  Future<Map<String, dynamic>> getInventory();

  /// INFO: Get simplified inventory compatible with recognition format
  /// RETURNS: Map containing simplified inventory in recognition-compatible format
  Future<Map<String, dynamic>> getInventorySimple();

  /// INFO: Update a specific ingredient using composite key
  /// ADVICE: Use name + addedAt to uniquely identify the ingredient
  /// USAGE: updateData should contain fields to update (quantity, expiry_date, etc.)
  Future<void> updateIngredient(
    String name,
    String addedAt,
    Map<String, dynamic> updateData,
  );

  /// INFO: Delete a specific ingredient from inventory
  /// ADVICE: Use name + addedAt as composite key for unique identification
  Future<void> deleteIngredient(String name, String addedAt);

  /// INFO: Update inventory item by ID (universal method)
  /// USAGE: Update any inventory item (food or ingredient) using its unique ID
  Future<void> updateInventoryItem(
    String itemId,
    Map<String, dynamic> updateData,
  );

  /// INFO: Delete inventory item by ID (universal method)
  /// USAGE: Delete any inventory item (food or ingredient) using its unique ID
  Future<void> deleteInventoryItem(String itemId);

  /// INFO: Get items that will expire within the specified number of days
  /// USAGE: Use days=7 to get items expiring this week
  /// RETURNS: Complete response object with expiring_items array and metadata
  Future<Map<String, dynamic>> getExpiringItems(int days);

  /// INFO: Get detailed information about a specific ingredient
  /// USAGE: Get stacks, environmental impact, utilization ideas, consumption advice
  /// ADVICE: ingredientName should be URL-encoded if it contains special characters
  /// RETURNS: Complete ingredient detail with all enhanced AI-generated data
  Future<Map<String, dynamic>> getIngredientDetail(String ingredientName);

  /// INFO: Get detailed information about a specific food item
  /// USAGE: Get nutritional analysis, consumption ideas, storage advice
  /// ADVICE: foodName should be URL-encoded, addedAt should be ISO 8601 format
  /// IMPORTANT: Multiple food items can have the same name, use addedAt as unique identifier
  /// RETURNS: Complete food detail with all enhanced AI-generated data
  Future<Map<String, dynamic>> getFoodDetail(String foodName, String addedAt);

  /// INFO: Mark a food item as consumed
  /// USAGE: Track food consumption for environmental impact and inventory management
  /// ADVICE: foodName should be URL-encoded, addedAt should be ISO 8601 format
  /// IMPORTANT: Use exact foodName and addedAt from the food item for unique identification
  /// RETURNS: Consumption tracking data including remaining portions and environmental impact
  Future<Map<String, dynamic>> markFoodAsConsumed(
    String foodName,
    String addedAt, {
    double? portions,
  });

  /// INFO: Generate a recipe based on available inventory ingredients
  /// USAGE: Send list of ingredients from user's inventory to get AI-generated recipe
  /// ADVICE: Include all relevant ingredient details for better recipe generation
  /// IMPORTANT: Ingredients should include quantity, type_unit, and expiration info
  /// RETURNS: Complete recipe with ingredients list and cooking instructions
  Future<Map<String, dynamic>> generateRecipe(
    List<Map<String, dynamic>> ingredients,
  );

  /// INFO: Get complete inventory with environmental impact and utilization ideas
  /// USAGE: Enriched inventory with AI-generated insights
  Future<Map<String, dynamic>> getInventoryComplete();

  /// INFO: Add ingredients from recognition results
  /// USAGE: Add ingredients directly from AI recognition with environmental data
  Future<Map<String, dynamic>> addIngredientsFromRecognition(
    List<Map<String, dynamic>> ingredients,
  );

  /// INFO: Update ingredient quantity only
  /// USAGE: Quick quantity update for specific ingredient stack
  Future<Map<String, dynamic>> updateIngredientQuantity(
    String ingredientName,
    String addedAt,
    double newQuantity,
  );

  /// INFO: Update food quantity only
  /// USAGE: Quick quantity update for specific food stack
  Future<Map<String, dynamic>> updateFoodQuantity(
    String foodName,
    String addedAt,
    double newQuantity,
  );

  /// INFO: Delete complete ingredient (all stacks)
  /// USAGE: Remove all stacks of an ingredient from inventory
  Future<Map<String, dynamic>> deleteCompleteIngredient(String ingredientName);

  /// INFO: Mark ingredient as consumed
  /// USAGE: Track ingredient consumption with details
  Future<Map<String, dynamic>> markIngredientConsumed(
    String ingredientName,
    String addedAt, {
    required double consumedQuantity,
    String? consumptionReason,
    String? recipeUsed,
  });

  /// INFO: Get simplified list of ingredient names
  /// USAGE: Quick access to all ingredient names in inventory
  Future<Map<String, dynamic>> getIngredientsList();

  /// INFO: Add single item with advanced options
  /// USAGE: Add individual item with detailed configuration
  Future<Map<String, dynamic>> addSingleInventoryItem({
    required String itemType,
    required Map<String, dynamic> itemData,
  });
}
