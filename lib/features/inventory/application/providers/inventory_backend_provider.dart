import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/core/services/api_service.dart';
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

  /// INFO: Get complete inventory from backend
  /// RETURNS: Map containing full inventory structure
  Future<Map<String, dynamic>> getInventory() async {
    return await _repository.getInventory();
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

  /// INFO: Get ingredients expiring within specified days from backend
  /// USAGE: Call with days=7 to get items expiring this week
  /// RETURNS: Complete response object with expiring_items array and metadata
  Future<Map<String, dynamic>> getExpiringItems(int days) async {
    return await _repository.getExpiringItems(days);
  }
}
