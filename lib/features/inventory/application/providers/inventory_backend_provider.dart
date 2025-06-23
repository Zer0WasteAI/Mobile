import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:zer0_waste_ai/features/inventory/data/repositories/inventory_repository_impl.dart';

/// INFO: Provider for the inventory repository implementation
/// USAGE: Use ref.watch(inventoryRepositoryProvider) to get repository instance
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl();
});

/// INFO: Provider for inventory backend operations notifier
/// USAGE: Use ref.watch(inventoryBackendProvider) to get notifier instance
final inventoryBackendProvider = Provider<InventoryBackendNotifier>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return InventoryBackendNotifier(repository);
});

/// INFO: Notifier class for inventory backend operations
/// ADVICE: This provides a clean interface for UI to interact with inventory
/// USAGE: Access through inventoryBackendProvider to perform inventory operations
class InventoryBackendNotifier {
  final InventoryRepository _repository;

  InventoryBackendNotifier(this._repository);

  /// INFO: Add multiple ingredients to the backend inventory
  /// USAGE: Pass ingredient objects with name, quantity, expiry_date, etc.
  Future<void> addIngredients(List<Map<String, dynamic>> ingredients) async {
    await _repository.addIngredients(ingredients);
  }

  /// INFO: Add single item to inventory from recognition results
  /// USAGE: Pass recognized item data and get back created inventory item
  /// RETURNS: Map with created item data including ID and timestamps
  Future<Map<String, dynamic>> addInventoryItem(
    Map<String, dynamic> item,
  ) async {
    return await _repository.addInventoryItem(item);
  }

  /// INFO: Get complete inventory from backend
  /// RETURNS: Map containing full inventory structure
  Future<Map<String, dynamic>> getInventory() async {
    return await _repository.getInventory();
  }

  /// INFO: Get simplified inventory compatible with recognition format
  /// RETURNS: Map containing simplified inventory structure
  Future<Map<String, dynamic>> getInventorySimple() async {
    return await _repository.getInventorySimple();
  }

  /// INFO: Update specific ingredient in backend inventory
  /// ADVICE: Use name + addedAt as composite key for identification
  Future<void> updateIngredient(
    String name,
    String addedAt,
    Map<String, dynamic> updateData,
  ) async {
    await _repository.updateIngredient(name, addedAt, updateData);
  }

  /// INFO: Delete specific ingredient from backend inventory
  /// ADVICE: Use name + addedAt as composite key for identification
  Future<void> deleteIngredient(String name, String addedAt) async {
    await _repository.deleteIngredient(name, addedAt);
  }

  /// INFO: Update inventory item by ID (universal method for foods/ingredients)
  /// USAGE: Update any inventory item using its unique ID in the backend
  Future<void> updateInventoryItem(
    String itemId,
    Map<String, dynamic> updateData,
  ) async {
    await _repository.updateInventoryItem(itemId, updateData);
  }

  /// INFO: Delete inventory item by ID (universal method for foods/ingredients)
  /// USAGE: Delete any inventory item using its unique ID from the backend
  Future<void> deleteInventoryItem(String itemId) async {
    print('🗑️ BACKEND: Starting deleteInventoryItem for ID: $itemId');
    try {
      await _repository.deleteInventoryItem(itemId);
      print('🗑️ BACKEND: Successfully deleted item: $itemId');
    } catch (e) {
      print('🗑️ BACKEND: Error deleting item: $e');
      rethrow;
    }
  }

  /// INFO: Get ingredients expiring within specified days from backend
  /// USAGE: Call with days=7 to get items expiring this week
  /// RETURNS: Complete response object with expiring_items array and metadata
  Future<Map<String, dynamic>> getExpiringItems(int days) async {
    return await _repository.getExpiringItems(days);
  }

  /// INFO: Get detailed information about a specific ingredient from backend
  /// USAGE: Get comprehensive ingredient data including AI-generated insights
  /// RETURNS: Complete ingredient detail with stacks, environmental impact, etc.
  Future<Map<String, dynamic>> getIngredientDetail(
    String ingredientName,
  ) async {
    return await _repository.getIngredientDetail(ingredientName);
  }

  /// INFO: Get detailed information about a specific food item from backend
  /// USAGE: Get comprehensive food data including nutritional analysis, consumption ideas
  /// IMPORTANT: Use both foodName and addedAt to identify unique food items
  /// RETURNS: Complete food detail with nutritional data, storage advice, etc.
  Future<Map<String, dynamic>> getFoodDetail(
    String foodName,
    String addedAt,
  ) async {
    return await _repository.getFoodDetail(foodName, addedAt);
  }

  /// INFO: Mark a food item as consumed in the backend
  /// USAGE: Track food consumption for environmental impact and inventory management
  /// IMPORTANT: Use exact foodName and addedAt from the food item for unique identification
  /// RETURNS: Consumption tracking data including remaining portions and environmental impact
  Future<Map<String, dynamic>> markFoodAsConsumed(
    String foodName,
    String addedAt, {
    double? portions,
  }) async {
    return await _repository.markFoodAsConsumed(
      foodName,
      addedAt,
      portions: portions,
    );
  }

  /// INFO: Generate a recipe based on available inventory ingredients
  /// USAGE: Send list of ingredients from user's inventory to get AI-generated recipe
  /// ADVICE: Include all relevant ingredient details for better recipe generation
  /// IMPORTANT: Ingredients should include quantity, type_unit, and expiration info
  /// RETURNS: Complete recipe with ingredients list and cooking instructions
  Future<Map<String, dynamic>> generateRecipe(
    List<Map<String, dynamic>> ingredients,
  ) async {
    return await _repository.generateRecipe(ingredients);
  }

  /// INFO: Get complete inventory with environmental impact and utilization ideas
  /// USAGE: Enriched inventory with AI-generated insights
  Future<Map<String, dynamic>> getInventoryComplete() async {
    return await _repository.getInventoryComplete();
  }

  /// INFO: Add ingredients from recognition results
  /// USAGE: Add ingredients directly from AI recognition with environmental data
  Future<Map<String, dynamic>> addIngredientsFromRecognition(
    List<Map<String, dynamic>> ingredients,
  ) async {
    return await _repository.addIngredientsFromRecognition(ingredients);
  }

  /// INFO: Update ingredient quantity only
  /// USAGE: Quick quantity update for specific ingredient stack
  Future<Map<String, dynamic>> updateIngredientQuantity(
    String ingredientName,
    String addedAt,
    double newQuantity,
  ) async {
    return await _repository.updateIngredientQuantity(
      ingredientName,
      addedAt,
      newQuantity,
    );
  }

  /// INFO: Update food quantity only
  /// USAGE: Quick quantity update for specific food stack
  Future<Map<String, dynamic>> updateFoodQuantity(
    String foodName,
    String addedAt,
    double newQuantity,
  ) async {
    return await _repository.updateFoodQuantity(foodName, addedAt, newQuantity);
  }

  /// INFO: Delete complete ingredient (all stacks)
  /// USAGE: Remove all stacks of an ingredient from inventory
  Future<Map<String, dynamic>> deleteCompleteIngredient(
    String ingredientName,
  ) async {
    return await _repository.deleteCompleteIngredient(ingredientName);
  }

  /// INFO: Mark ingredient as consumed
  /// USAGE: Track ingredient consumption with details
  Future<Map<String, dynamic>> markIngredientConsumed(
    String ingredientName,
    String addedAt, {
    required double consumedQuantity,
    String? consumptionReason,
    String? recipeUsed,
  }) async {
    return await _repository.markIngredientConsumed(
      ingredientName,
      addedAt,
      consumedQuantity: consumedQuantity,
      consumptionReason: consumptionReason,
      recipeUsed: recipeUsed,
    );
  }

  /// INFO: Get simplified list of ingredient names
  /// USAGE: Quick access to all ingredient names in inventory
  Future<Map<String, dynamic>> getIngredientsList() async {
    return await _repository.getIngredientsList();
  }

  /// INFO: Add single item with advanced options
  /// USAGE: Add individual item with detailed configuration
  Future<Map<String, dynamic>> addSingleInventoryItem({
    required String itemType,
    required Map<String, dynamic> itemData,
  }) async {
    return await _repository.addSingleInventoryItem(
      itemType: itemType,
      itemData: itemData,
    );
  }
}
