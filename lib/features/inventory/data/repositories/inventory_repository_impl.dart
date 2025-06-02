import 'package:zer0_waste_ai/core/services/api_service.dart';
import 'package:zer0_waste_ai/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';

/// INFO: Implementation of InventoryRepository using ZeroWasteAI backend
/// ADVICE: This repository bridges the domain layer with the API service
/// USAGE: Use this through the inventoryRepositoryProvider
class InventoryRepositoryImpl implements InventoryRepository {
  final ApiService _apiService;

  InventoryRepositoryImpl({ApiService? apiService})
    : _apiService = apiService ?? ApiService.instance;

  @override
  Future<void> addIngredients(List<Map<String, dynamic>> ingredients) async {
    try {
      await _apiService.addIngredients(ingredients);
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
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
      // INFO: Convert API errors to domain-friendly error messages
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
      // ADVICE: Use name + addedAt as composite key for unique identification
      await _apiService.updateIngredient(name, addedAt, updateData);
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to update ingredient: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<void> deleteIngredient(String name, String addedAt) async {
    try {
      // ADVICE: Use name + addedAt as composite key for unique identification
      await _apiService.deleteIngredient(name, addedAt);
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to delete ingredient: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getExpiringItems(int days) async {
    try {
      // INFO: API returns complete response with expiring_items array and metadata
      return await _apiService.getExpiringItems(days);
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to get expiring items: ${_apiService.getErrorMessage(e)}',
      );
    }
  }
}
