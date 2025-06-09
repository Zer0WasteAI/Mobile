import 'package:zer0_waste_ai/core/services/api_service.dart';
import 'package:zer0_waste_ai/features/inventory/domain/repositories/inventory_repository.dart';

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
  Future<Map<String, dynamic>> addInventoryItem(
    Map<String, dynamic> item,
  ) async {
    try {
      return await _apiService.addInventoryItem(item);
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to add inventory item: ${_apiService.getErrorMessage(e)}',
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
  Future<Map<String, dynamic>> getInventorySimple() async {
    try {
      return await _apiService.getInventorySimple();
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to get simple inventory: ${_apiService.getErrorMessage(e)}',
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
  Future<void> updateInventoryItem(
    String itemId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      // INFO: Universal method for updating any inventory item by ID
      await _apiService.updateInventoryItem(itemId, updateData);
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to update inventory item: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<void> deleteInventoryItem(String itemId) async {
    try {
      // INFO: Universal method for deleting any inventory item by ID
      await _apiService.deleteInventoryItem(itemId);
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to delete inventory item: ${_apiService.getErrorMessage(e)}',
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

  @override
  Future<Map<String, dynamic>> getIngredientDetail(
    String ingredientName,
  ) async {
    try {
      // INFO: Get comprehensive ingredient details including AI-generated insights
      return await _apiService.getIngredientDetail(ingredientName);
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to get ingredient detail: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getFoodDetail(
    String foodName,
    String addedAt,
  ) async {
    try {
      // INFO: Get comprehensive food details including AI-generated insights
      // IMPORTANT: Use both foodName and addedAt to identify unique food items
      return await _apiService.getFoodDetail(foodName, addedAt);
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to get food detail: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> markFoodAsConsumed(
    String foodName,
    String addedAt, {
    double? portions,
  }) async {
    try {
      // INFO: Mark food as consumed for tracking environmental impact
      // IMPORTANT: Use both foodName and addedAt to identify unique food items
      return await _apiService.markFoodAsConsumed(
        foodName,
        addedAt,
        portions: portions,
      );
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to mark food as consumed: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> generateRecipe(
    List<Map<String, dynamic>> ingredients,
  ) async {
    try {
      // INFO: Generate AI-powered recipe based on available ingredients
      // IMPORTANT: Include all relevant ingredient details for better recipe generation
      return await _apiService.generateRecipe(ingredients);
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to generate recipe: ${_apiService.getErrorMessage(e)}',
      );
    }
  }
}
