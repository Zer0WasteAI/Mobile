/// Repository interface for inventory management
abstract class InventoryRepository {
  /// Add ingredients to the inventory
  Future<void> addIngredients(List<Map<String, dynamic>> ingredients);

  /// Get the complete inventory
  Future<Map<String, dynamic>> getInventory();

  /// Update a specific ingredient
  Future<void> updateIngredient(
    String name,
    String addedAt,
    Map<String, dynamic> updateData,
  );

  /// Delete a specific ingredient
  Future<void> deleteIngredient(String name, String addedAt);

  /// Get items that are expiring within the specified number of days
  Future<List<String>> getExpiringItems(int days);
}
