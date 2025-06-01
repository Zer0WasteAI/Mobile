import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/core/services/api_service.dart';
import 'package:zer0_waste_ai/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:zer0_waste_ai/features/inventory/data/repositories/inventory_repository_impl.dart';

/// Provider for the inventory repository
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl();
});

/// Provider for inventory backend operations
final inventoryBackendProvider = Provider<InventoryBackendNotifier>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return InventoryBackendNotifier(repository);
});

/// Notifier for inventory backend operations
class InventoryBackendNotifier {
  final InventoryRepository _repository;

  InventoryBackendNotifier(this._repository);

  /// Add ingredients to the backend inventory
  Future<void> addIngredients(List<Map<String, dynamic>> ingredients) async {
    await _repository.addIngredients(ingredients);
  }

  /// Get full inventory from backend
  Future<Map<String, dynamic>> getInventory() async {
    return await _repository.getInventory();
  }

  /// Update ingredient in backend
  Future<void> updateIngredient(
    String name,
    String addedAt,
    Map<String, dynamic> updateData,
  ) async {
    await _repository.updateIngredient(name, addedAt, updateData);
  }

  /// Delete ingredient from backend
  Future<void> deleteIngredient(String name, String addedAt) async {
    await _repository.deleteIngredient(name, addedAt);
  }

  /// Get expiring items from backend
  Future<List<String>> getExpiringItems(int days) async {
    return await _repository.getExpiringItems(days);
  }
}
