import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

/// Service for inventory management operations
class InventoryService {
  static InventoryService? _instance;
  static InventoryService get instance => _instance ??= InventoryService._internal();

  late final Dio _dio;
  final AuthService _authService = AuthService.instance;

  // Inventory endpoints
  static const String _inventoryItems = '/api/inventory';
  static const String _inventoryIngredients = '/api/inventory/ingredients';
  static const String _inventoryComplete = '/api/inventory/complete';
  static const String _inventorySimple = '/api/inventory/simple';
  static const String _inventoryExpiring = '/api/inventory/expiring';
  static const String _inventoryIngredientDetail = '/api/inventory/ingredients';
  static const String _inventoryFoodDetail = '/api/inventory/foods';
  static const String _inventoryFromRecognition = '/api/inventory/ingredients/from-recognition';
  static const String _inventoryFoodsFromRecognition = '/api/inventory/foods/from-recognition';
  static const String _inventoryAddItem = '/api/inventory/add_item';
  static const String _inventoryUploadImage = '/api/inventory/upload_image';
  static const String _inventoryIngredientsList = '/api/inventory/ingredients/list';

  InventoryService._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    final baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? 'http://127.0.0.1:3000';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add authentication interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final authHeaders = await _authService.getAuthHeaders();
          if (authHeaders != null) {
            options.headers.addAll(authHeaders);
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Try to refresh token
            final newToken = await _authService.refreshTokens();
            if (newToken != null) {
              // Retry the request with new token
              final authHeaders = await _authService.getAuthHeaders();
              if (authHeaders != null) {
                error.requestOptions.headers.addAll(authHeaders);
                final response = await _dio.fetch(error.requestOptions);
                handler.resolve(response);
                return;
              }
            }
          }
          handler.next(error);
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => log(obj.toString()),
      ),
    );
  }

  // ==================== INVENTORY OPERATIONS ====================

  /// Get complete user inventory with all items
  Future<Map<String, dynamic>> getInventory() async {
    try {
      log('📦 Getting complete inventory');
      
      final response = await _dio.get(_inventoryItems);
      
      log('✅ Complete inventory retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get inventory error: $e');
      throw Exception('Get inventory error: ${e.toString()}');
    }
  }

  /// Get simplified inventory compatible with recognition format
  Future<Map<String, dynamic>> getInventorySimple() async {
    try {
      log('📦 Getting simplified inventory');
      
      final response = await _dio.get(_inventorySimple);
      
      log('✅ Simplified inventory retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get simple inventory error: $e');
      throw Exception('Get simple inventory error: ${e.toString()}');
    }
  }

  /// Get complete inventory with full details
  Future<Map<String, dynamic>> getInventoryComplete() async {
    try {
      log('📦 Getting complete inventory with full details');
      
      final response = await _dio.get(_inventoryComplete);
      
      log('✅ Complete inventory with details retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get complete inventory error: $e');
      throw Exception('Get complete inventory error: ${e.toString()}');
    }
  }

  /// Get expiring items within specified days
  Future<Map<String, dynamic>> getExpiringItems(int days) async {
    try {
      log('⏰ Getting items expiring within $days days');
      
      final response = await _dio.get('$_inventoryExpiring?days=$days');
      
      log('✅ Expiring items retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get expiring items error: $e');
      throw Exception('Get expiring items error: ${e.toString()}');
    }
  }

  // ==================== INGREDIENT OPERATIONS ====================

  /// Add multiple ingredients to inventory
  Future<Map<String, dynamic>> addIngredients(List<Map<String, dynamic>> ingredients) async {
    try {
      log('➕ Adding ${ingredients.length} ingredients to inventory');
      
      final response = await _dio.post(
        _inventoryIngredients,
        data: {'ingredients': ingredients},
      );
      
      log('✅ Ingredients added successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Add ingredients error: $e');
      throw Exception('Add ingredients error: ${e.toString()}');
    }
  }

  /// Add ingredients from recognition results
  Future<Map<String, dynamic>> addIngredientsFromRecognition(
    String recognitionId,
    List<String> selectedIngredients,
  ) async {
    try {
      log('🔍 Adding ingredients from recognition: $recognitionId');
      
      final response = await _dio.post(
        _inventoryFromRecognition,
        data: {
          'recognition_id': recognitionId,
          'selected_ingredients': selectedIngredients,
        },
      );
      
      log('✅ Ingredients from recognition added successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Add ingredients from recognition error: $e');
      throw Exception('Add ingredients from recognition error: ${e.toString()}');
    }
  }

  /// Add foods from recognition results
  Future<Map<String, dynamic>> addFoodsFromRecognition(
    String recognitionId,
    List<String> selectedFoods,
  ) async {
    try {
      log('🔍 Adding foods from recognition: $recognitionId');
      
      final response = await _dio.post(
        _inventoryFoodsFromRecognition,
        data: {
          'recognition_id': recognitionId,
          'selected_foods': selectedFoods,
        },
      );
      
      log('✅ Foods from recognition added successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Add foods from recognition error: $e');
      throw Exception('Add foods from recognition error: ${e.toString()}');
    }
  }

  /// Update specific ingredient by name and added date
  Future<Map<String, dynamic>> updateIngredient(
    String name,
    String addedAt,
    Map<String, dynamic> updateData,
  ) async {
    try {
      log('📝 Updating ingredient: $name (added: $addedAt)');
      
      final response = await _dio.put(
        '$_inventoryIngredients/$name/$addedAt',
        data: updateData,
      );
      
      log('✅ Ingredient updated successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Update ingredient error: $e');
      throw Exception('Update ingredient error: ${e.toString()}');
    }
  }

  /// Update ingredient quantity
  Future<Map<String, dynamic>> updateIngredientQuantity(
    String name,
    String addedAt,
    double newQuantity,
    String unit,
  ) async {
    try {
      log('📊 Updating ingredient quantity: $name to $newQuantity $unit');
      
      final response = await _dio.put(
        '$_inventoryIngredients/$name/$addedAt/quantity',
        data: {
          'quantity': newQuantity,
          'unit': unit,
        },
      );
      
      log('✅ Ingredient quantity updated successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Update ingredient quantity error: $e');
      throw Exception('Update ingredient quantity error: ${e.toString()}');
    }
  }

  /// Update ingredient expiration date
  Future<Map<String, dynamic>> updateIngredientExpirationDate(
    String name,
    String addedAt,
    String newExpirationDate,
  ) async {
    try {
      log('📅 Updating ingredient expiration date: $name to $newExpirationDate');
      
      final response = await _dio.put(
        '$_inventoryIngredients/$name/$addedAt/expiration',
        data: {'expiration_date': newExpirationDate},
      );
      
      log('✅ Ingredient expiration date updated successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Update ingredient expiration date error: $e');
      throw Exception('Update ingredient expiration date error: ${e.toString()}');
    }
  }

  /// Mark ingredient as consumed
  Future<Map<String, dynamic>> markIngredientConsumed(
    String name,
    String addedAt,
    double consumedQuantity,
    String unit,
  ) async {
    try {
      log('✅ Marking ingredient as consumed: $name ($consumedQuantity $unit)');
      
      final response = await _dio.post(
        '$_inventoryIngredients/$name/$addedAt/consume',
        data: {
          'consumed_quantity': consumedQuantity,
          'unit': unit,
          'consumed_at': DateTime.now().toIso8601String(),
        },
      );
      
      log('✅ Ingredient marked as consumed successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Mark ingredient consumed error: $e');
      throw Exception('Mark ingredient consumed error: ${e.toString()}');
    }
  }

  /// Delete specific ingredient from inventory
  Future<Map<String, dynamic>> deleteIngredient(String name, String addedAt) async {
    log('🗑️ Starting DELETE ingredient request');
    log('🗑️ Name: "$name"');
    log('🗑️ AddedAt: "$addedAt"');

    // Ensure proper URL encoding
    final encodedName = Uri.encodeComponent(name);
    final encodedTimestamp = Uri.encodeComponent(addedAt);
    final endpoint = '$_inventoryIngredients/$encodedName/$encodedTimestamp';

    log('🗑️ Encoded endpoint: $endpoint');

    try {
      final response = await _dio.delete(endpoint);
      log('🗑️ DELETE request successful');
      log('🗑️ Response status: ${response.statusCode}');
      log('🗑️ Response data: ${response.data}');

      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('🗑️ DELETE request failed: $e');
      log('🗑️ Error type: ${e.runtimeType}');

      if (e is DioException) {
        log('🗑️ DioException details:');
        log('  - Status code: ${e.response?.statusCode}');
        log('  - Response data: ${e.response?.data}');
        log('  - Message: ${e.message}');
        log('  - Request URL: ${e.requestOptions.uri}');
      }

      throw Exception('Delete ingredient error: ${e.toString()}');
    }
  }

  /// Delete complete ingredient entry
  Future<Map<String, dynamic>> deleteCompleteIngredient(String name, String addedAt) async {
    try {
      log('🗑️ Deleting complete ingredient: $name (added: $addedAt)');
      
      final response = await _dio.delete('$_inventoryIngredients/$name/$addedAt/complete');
      
      log('✅ Complete ingredient deleted successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Delete complete ingredient error: $e');
      throw Exception('Delete complete ingredient error: ${e.toString()}');
    }
  }

  /// Get ingredient detail
  Future<Map<String, dynamic>> getIngredientDetail(String name, String addedAt) async {
    try {
      log('🔍 Getting ingredient detail: $name (added: $addedAt)');
      
      final response = await _dio.get('$_inventoryIngredientDetail/$name/$addedAt');
      
      log('✅ Ingredient detail retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get ingredient detail error: $e');
      throw Exception('Get ingredient detail error: ${e.toString()}');
    }
  }

  /// Get ingredients list
  Future<Map<String, dynamic>> getIngredientsList() async {
    try {
      log('📋 Getting ingredients list');
      
      final response = await _dio.get(_inventoryIngredientsList);
      
      log('✅ Ingredients list retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get ingredients list error: $e');
      throw Exception('Get ingredients list error: ${e.toString()}');
    }
  }

  // ==================== GENERAL ITEM OPERATIONS ====================

  /// Add single item to inventory (general items)
  Future<Map<String, dynamic>> addInventoryItem(Map<String, dynamic> item) async {
    try {
      log('➕ Adding inventory item: ${item['name'] ?? 'Unknown'}');
      
      final response = await _dio.post(_inventoryItems, data: item);
      
      log('✅ Inventory item added successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Add inventory item error: $e');
      throw Exception('Add inventory item error: ${e.toString()}');
    }
  }

  /// Add single inventory item with specific parameters
  Future<Map<String, dynamic>> addSingleInventoryItem({
    required String name,
    required String category,
    double? quantity,
    String? unit,
    String? expirationDate,
    String? imageUrl,
  }) async {
    try {
      log('➕ Adding single inventory item: $name');
      
      final response = await _dio.post(
        _inventoryAddItem,
        data: {
          'name': name,
          'category': category,
          if (quantity != null) 'quantity': quantity,
          if (unit != null) 'unit': unit,
          if (expirationDate != null) 'expiration_date': expirationDate,
          if (imageUrl != null) 'image_url': imageUrl,
        },
      );
      
      log('✅ Single inventory item added successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Add single inventory item error: $e');
      throw Exception('Add single inventory item error: ${e.toString()}');
    }
  }

  /// Update inventory item
  Future<Map<String, dynamic>> updateInventoryItem(
    String itemId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      log('📝 Updating inventory item: $itemId');
      
      final response = await _dio.put(
        '$_inventoryItems/$itemId',
        data: updateData,
      );
      
      log('✅ Inventory item updated successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Update inventory item error: $e');
      throw Exception('Update inventory item error: ${e.toString()}');
    }
  }

  /// Update food quantity
  Future<Map<String, dynamic>> updateFoodQuantity(
    String name,
    String addedAt,
    double newQuantity,
    String unit,
  ) async {
    try {
      log('📊 Updating food quantity: $name to $newQuantity $unit');
      
      final response = await _dio.put(
        '$_inventoryFoodDetail/$name/$addedAt/quantity',
        data: {
          'quantity': newQuantity,
          'unit': unit,
        },
      );
      
      log('✅ Food quantity updated successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Update food quantity error: $e');
      throw Exception('Update food quantity error: ${e.toString()}');
    }
  }

  /// Mark food as consumed
  Future<Map<String, dynamic>> markFoodAsConsumed(
    String name,
    String addedAt,
    double consumedQuantity,
    String unit,
  ) async {
    try {
      log('✅ Marking food as consumed: $name ($consumedQuantity $unit)');
      
      final response = await _dio.post(
        '$_inventoryFoodDetail/$name/$addedAt/consume',
        data: {
          'consumed_quantity': consumedQuantity,
          'unit': unit,
          'consumed_at': DateTime.now().toIso8601String(),
        },
      );
      
      log('✅ Food marked as consumed successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Mark food consumed error: $e');
      throw Exception('Mark food consumed error: ${e.toString()}');
    }
  }

  /// Delete inventory item
  Future<Map<String, dynamic>> deleteInventoryItem(String itemId) async {
    try {
      log('🗑️ Deleting inventory item: $itemId');
      
      final response = await _dio.delete('$_inventoryItems/$itemId');
      
      log('✅ Inventory item deleted successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Delete inventory item error: $e');
      throw Exception('Delete inventory item error: ${e.toString()}');
    }
  }

  /// Get food detail
  Future<Map<String, dynamic>> getFoodDetail(String name, String addedAt) async {
    try {
      log('🔍 Getting food detail: $name (added: $addedAt)');
      
      final response = await _dio.get('$_inventoryFoodDetail/$name/$addedAt');
      
      log('✅ Food detail retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get food detail error: $e');
      throw Exception('Get food detail error: ${e.toString()}');
    }
  }

  // ==================== IMAGE OPERATIONS ====================

  /// Upload inventory image
  Future<Map<String, dynamic>> uploadInventoryImage({
    required String filePath,
    String? itemName,
    String? category,
  }) async {
    try {
      log('📸 Uploading inventory image');
      
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
        if (itemName != null) 'item_name': itemName,
        if (category != null) 'category': category,
      });

      final response = await _dio.post(
        _inventoryUploadImage,
        data: formData,
        options: Options(
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );
      
      log('✅ Inventory image uploaded successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Upload inventory image error: $e');
      throw Exception('Upload inventory image error: ${e.toString()}');
    }
  }
}