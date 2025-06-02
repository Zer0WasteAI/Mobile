/// INFO: Repository interface for inventory management operations
/// ADVICE: This defines the contract for all inventory-related operations
/// USAGE: Implement this interface to create different inventory data sources
abstract class InventoryRepository {
  /// INFO: Add multiple ingredients to the user's inventory
  /// USAGE: Pass array of ingredient maps with name, quantity, expiry_date, etc.
  Future<void> addIngredients(List<Map<String, dynamic>> ingredients);

  /// INFO: Get the complete user inventory with all stored items
  /// RETURNS: Map containing inventory data structure from backend
  Future<Map<String, dynamic>> getInventory();

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

  /// INFO: Get items that will expire within the specified number of days
  /// USAGE: Use days=7 to get items expiring this week
  /// RETURNS: Complete response object with expiring_items array and metadata
  Future<Map<String, dynamic>> getExpiringItems(int days);
}
