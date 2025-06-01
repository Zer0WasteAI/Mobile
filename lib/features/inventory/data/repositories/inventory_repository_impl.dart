import 'package:zer0_waste_ai/core/services/api_service.dart';
import 'package:zer0_waste_ai/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';

/// Implementation of InventoryRepository using ZeroWasteAI backend
class InventoryRepositoryImpl implements InventoryRepository {
  final ApiService _apiService;

  InventoryRepositoryImpl({ApiService? apiService})
    : _apiService = apiService ?? ApiService.instance;

  @override
  Future<void> addIngredients(List<Map<String, dynamic>> ingredients) async {
    try {
      await _apiService.addIngredients(ingredients);
    } catch (e) {
      throw Exception(
        'Failed to add ingredients: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getInventory() async {
    try {
      return await _apiService.getInventory();
    } catch (e) {
      throw Exception(
        'Failed to get inventory: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<void> updateIngredient(
    String name,
    String addedAt,
    Map<String, dynamic> updateData,
  ) async {
    try {
      await _apiService.updateIngredient(name, addedAt, updateData);
    } catch (e) {
      throw Exception(
        'Failed to update ingredient: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<void> deleteIngredient(String name, String addedAt) async {
    try {
      await _apiService.deleteIngredient(name, addedAt);
    } catch (e) {
      throw Exception(
        'Failed to delete ingredient: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<List<String>> getExpiringItems(int days) async {
    try {
      final response = await _apiService.getExpiringItems(days);
      return List<String>.from(response['expiring_items'] ?? []);
    } catch (e) {
      throw Exception(
        'Failed to get expiring items: ${_apiService.getErrorMessage(e)}',
      );
    }
  }
}
