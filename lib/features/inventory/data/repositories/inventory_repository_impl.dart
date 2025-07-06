import 'dart:developer';

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
    log('🗑️ REPOSITORY: Starting deleteInventoryItem for ID: $itemId');
    try {
      // INFO: Universal method for deleting any inventory item by ID
      log('🗑️ REPOSITORY: Calling API service deleteInventoryItem');
      final result = await _apiService.deleteInventoryItem(itemId);
      log('🗑️ REPOSITORY: API call successful, result: $result');
    } catch (e) {
      log('🗑️ REPOSITORY: API call failed: $e');
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
      // Use current time as addedAt since it's required by the API
      final currentTime = DateTime.now().toIso8601String();
      return await _apiService.getIngredientDetail(ingredientName, currentTime);
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
      final ingredientNames =
          ingredients.map((i) => i['name'] as String? ?? '').toList();
      return await _apiService.generateRecipe(ingredients: ingredientNames);
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to generate recipe: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getInventoryComplete() async {
    try {
      return await _apiService.getInventoryComplete();
    } catch (e) {
      throw Exception(
        'Failed to get complete inventory: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> addIngredientsFromRecognition(
    List<Map<String, dynamic>> ingredients,
  ) async {
    try {
      // Extract recognition ID and ingredient names from the data
      final recognitionId =
          ingredients.isNotEmpty
              ? (ingredients.first['recognitionId'] as String? ?? 'default')
              : 'default';
      final ingredientNames =
          ingredients.map((i) => i['name'] as String? ?? '').toList();

      return await _apiService.addIngredientsFromRecognition(
        recognitionId,
        ingredientNames,
      );
    } catch (e) {
      throw Exception(
        'Failed to add ingredients from recognition: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> addFoodsFromRecognition(
    List<Map<String, dynamic>> foods,
  ) async {
    try {
      // Extract recognition ID and food names from the data
      final recognitionId =
          foods.isNotEmpty
              ? (foods.first['recognitionId'] as String? ?? 'default')
              : 'default';
      final foodNames = foods.map((f) => f['name'] as String? ?? '').toList();

      return await _apiService.addFoodsFromRecognition(
        recognitionId,
        foodNames,
      );
    } catch (e) {
      throw Exception(
        'Failed to add foods from recognition: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> updateIngredientQuantity(
    String ingredientName,
    String addedAt,
    double newQuantity,
  ) async {
    try {
      return await _apiService.updateIngredientQuantity(
        ingredientName,
        addedAt,
        newQuantity,
        'pieces', // Default unit
      );
    } catch (e) {
      throw Exception(
        'Failed to update ingredient quantity: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> updateFoodQuantity(
    String foodName,
    String addedAt,
    double newQuantity,
  ) async {
    try {
      return await _apiService.updateFoodQuantity(
        foodName,
        addedAt,
        newQuantity,
        'portions', // Default unit
      );
    } catch (e) {
      throw Exception(
        'Failed to update food quantity: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> deleteCompleteIngredient(
    String ingredientName,
  ) async {
    try {
      return await _apiService.deleteCompleteIngredient(
        ingredientName,
        DateTime.now().toIso8601String(), // Current time as addedAt
      );
    } catch (e) {
      throw Exception(
        'Failed to delete complete ingredient: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> markIngredientConsumed(
    String ingredientName,
    String addedAt, {
    required double consumedQuantity,
    String? consumptionReason,
    String? recipeUsed,
  }) async {
    try {
      return await _apiService.markIngredientConsumed(
        ingredientName,
        addedAt,
        consumedQuantity,
        'pieces', // Default unit
      );
    } catch (e) {
      throw Exception(
        'Failed to mark ingredient consumed: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getIngredientsList() async {
    try {
      return await _apiService.getIngredientsList();
    } catch (e) {
      throw Exception(
        'Failed to get ingredients list: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> addSingleInventoryItem({
    required String itemType,
    required Map<String, dynamic> itemData,
  }) async {
    try {
      return await _apiService.addSingleInventoryItem(
        name: itemData['name'] as String,
        category: itemData['category'] as String,
        quantity: itemData['quantity'] as double?,
        unit: itemData['unit'] as String?,
        expirationDate: itemData['expirationDate'] as String?,
      );
    } catch (e) {
      throw Exception(
        'Failed to add single inventory item: ${_apiService.getErrorMessage(e)}',
      );
    }
  }
}
