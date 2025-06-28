import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

/// Service for recipe management operations
class RecipeService {
  static RecipeService? _instance;
  static RecipeService get instance => _instance ??= RecipeService._internal();

  late final Dio _dio;
  final AuthService _authService = AuthService.instance;

  // Recipe endpoints
  static const String _recipesGenerate = '/api/recipes/generate';
  static const String _recipesGenerateFromInventory = '/api/recipes/generate-from-inventory';
  static const String _recipesGenerateCustom = '/api/recipes/generate-custom';
  static const String _recipesSave = '/api/recipes/save';
  static const String _recipesSaved = '/api/recipes/saved';
  static const String _recipesAll = '/api/recipes/all';
  static const String _recipesDefault = '/api/recipes/default';
  static const String _recipesDelete = '/api/recipes/delete';

  // Timeout constants for AI operations
  static const Duration _aiProcessingTimeout = Duration(minutes: 3);
  static const Duration _uploadTimeout = Duration(minutes: 2);

  RecipeService._internal() {
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

  // ==================== RECIPE GENERATION ====================

  /// Generate recipes from current inventory
  Future<Map<String, dynamic>> generateRecipesFromInventory() async {
    try {
      log('🍳 Generating recipes from inventory...');

      final response = await _dio.post(
        _recipesGenerateFromInventory,
        data: {},
        options: Options(
          receiveTimeout: _aiProcessingTimeout,
          sendTimeout: _uploadTimeout,
          validateStatus: (status) {
            // Accept 200-299 status codes
            return status != null && status >= 200 && status < 300;
          },
        ),
      );

      log('✅ Recipe generation from inventory successful');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Recipe generation from inventory error: $e');
      throw Exception('Generate recipes from inventory error: ${e.toString()}');
    }
  }

  /// Generate custom recipes with specific ingredients and preferences
  Future<Map<String, dynamic>> generateCustomRecipes({
    required List<String> ingredients,
    List<String>? preferences,
    List<String>? recipeCategories,
    int numRecipes = 2,
  }) async {
    try {
      log('🍳 Generating custom recipes for ${ingredients.length} ingredients');

      final response = await _dio.post(
        _recipesGenerateCustom,
        data: {
          'ingredients': ingredients,
          if (preferences != null) 'preferences': preferences,
          if (recipeCategories != null) 'recipe_categories': recipeCategories,
          'num_recipes': numRecipes,
        },
        options: Options(
          receiveTimeout: _aiProcessingTimeout,
          sendTimeout: _uploadTimeout,
        ),
      );

      log('✅ Custom recipe generation successful');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Generate custom recipes error: $e');
      throw Exception('Generate custom recipes error: ${e.toString()}');
    }
  }

  /// Generate recipe with specific parameters
  Future<Map<String, dynamic>> generateRecipe({
    required List<String> ingredients,
    String? mealType,
    String? cuisine,
    String? difficulty,
    int? servings,
    List<String>? dietaryRestrictions,
  }) async {
    try {
      log('🍳 Generating recipe with specific parameters');

      final response = await _dio.post(
        _recipesGenerate,
        data: {
          'ingredients': ingredients,
          if (mealType != null) 'meal_type': mealType,
          if (cuisine != null) 'cuisine': cuisine,
          if (difficulty != null) 'difficulty': difficulty,
          if (servings != null) 'servings': servings,
          if (dietaryRestrictions != null) 'dietary_restrictions': dietaryRestrictions,
        },
        options: Options(
          receiveTimeout: _aiProcessingTimeout,
          sendTimeout: _uploadTimeout,
        ),
      );

      log('✅ Recipe generation successful');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Generate recipe error: $e');
      throw Exception('Generate recipe error: ${e.toString()}');
    }
  }

  // ==================== RECIPE MANAGEMENT ====================

  /// Save a generated or custom recipe to user's collection
  Future<Map<String, dynamic>> saveRecipe(Map<String, dynamic> recipeData) async {
    try {
      log('💾 Saving recipe: ${recipeData['title'] ?? 'Unknown'}');

      final response = await _dio.post(_recipesSave, data: recipeData);

      log('✅ Recipe saved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Save recipe error: $e');
      throw Exception('Save recipe error: ${e.toString()}');
    }
  }

  /// Get all user's saved/favorite recipes
  Future<Map<String, dynamic>> getSavedRecipes() async {
    try {
      log('📚 Getting saved recipes');

      final response = await _dio.get(_recipesSaved);

      log('✅ Saved recipes retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get saved recipes error: $e');
      throw Exception('Get saved recipes error: ${e.toString()}');
    }
  }

  /// Get all available recipes (public + user's)
  Future<Map<String, dynamic>> getAllRecipes() async {
    try {
      log('📚 Getting all recipes');

      final response = await _dio.get(_recipesAll);

      log('✅ All recipes retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get all recipes error: $e');
      throw Exception('Get all recipes error: ${e.toString()}');
    }
  }

  /// Get default/curated recipes available to all users
  /// This endpoint does NOT require authentication
  Future<Map<String, dynamic>> getDefaultRecipes({String? category}) async {
    try {
      log('📚 Getting default recipes${category != null ? ' for category: $category' : ''}');

      final queryParams = <String, dynamic>{};
      if (category != null) {
        queryParams['category'] = category;
      }

      final response = await _dio.get(
        _recipesDefault,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      log('✅ Default recipes retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get default recipes error: $e');
      throw Exception('Get default recipes error: ${e.toString()}');
    }
  }

  /// Delete a recipe from user's collection
  Future<Map<String, dynamic>> deleteRecipe(String recipeTitle) async {
    try {
      log('🗑️ Deleting recipe: $recipeTitle');

      final response = await _dio.delete(
        _recipesDelete,
        data: {'recipe_title': recipeTitle},
      );

      log('✅ Recipe deleted successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Delete recipe error: $e');
      throw Exception('Delete recipe error: ${e.toString()}');
    }
  }

  // ==================== RECIPE SEARCH & FILTERING ====================

  /// Search recipes by query
  Future<Map<String, dynamic>> searchRecipes({
    required String query,
    String? category,
    List<String>? ingredients,
    List<String>? dietaryRestrictions,
    int? maxPrepTime,
    String? difficulty,
  }) async {
    try {
      log('🔍 Searching recipes: $query');

      final response = await _dio.get(
        _recipesAll,
        queryParameters: {
          'search': query,
          if (category != null) 'category': category,
          if (ingredients != null) 'ingredients': ingredients.join(','),
          if (dietaryRestrictions != null) 'dietary_restrictions': dietaryRestrictions.join(','),
          if (maxPrepTime != null) 'max_prep_time': maxPrepTime,
          if (difficulty != null) 'difficulty': difficulty,
        },
      );

      log('✅ Recipe search completed successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Search recipes error: $e');
      throw Exception('Search recipes error: ${e.toString()}');
    }
  }

  /// Get recipes by category
  Future<Map<String, dynamic>> getRecipesByCategory(String category) async {
    try {
      log('📚 Getting recipes by category: $category');

      final response = await _dio.get(
        _recipesAll,
        queryParameters: {'category': category},
      );

      log('✅ Recipes by category retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get recipes by category error: $e');
      throw Exception('Get recipes by category error: ${e.toString()}');
    }
  }

  /// Get recipes with specific ingredients
  Future<Map<String, dynamic>> getRecipesWithIngredients(List<String> ingredients) async {
    try {
      log('🔍 Getting recipes with ingredients: ${ingredients.join(', ')}');

      final response = await _dio.get(
        _recipesAll,
        queryParameters: {'ingredients': ingredients.join(',')},
      );

      log('✅ Recipes with ingredients retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get recipes with ingredients error: $e');
      throw Exception('Get recipes with ingredients error: ${e.toString()}');
    }
  }

  // ==================== RECIPE RECOMMENDATIONS ====================

  /// Get recipe recommendations based on user preferences
  Future<Map<String, dynamic>> getRecipeRecommendations({
    int limit = 10,
    String? mealType,
    List<String>? excludeIngredients,
  }) async {
    try {
      log('💡 Getting recipe recommendations');

      final response = await _dio.get(
        '$_recipesAll/recommendations',
        queryParameters: {
          'limit': limit,
          if (mealType != null) 'meal_type': mealType,
          if (excludeIngredients != null) 'exclude_ingredients': excludeIngredients.join(','),
        },
      );

      log('✅ Recipe recommendations retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get recipe recommendations error: $e');
      throw Exception('Get recipe recommendations error: ${e.toString()}');
    }
  }

  /// Get trending recipes
  Future<Map<String, dynamic>> getTrendingRecipes({int limit = 10}) async {
    try {
      log('🔥 Getting trending recipes');

      final response = await _dio.get(
        '$_recipesAll/trending',
        queryParameters: {'limit': limit},
      );

      log('✅ Trending recipes retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get trending recipes error: $e');
      throw Exception('Get trending recipes error: ${e.toString()}');
    }
  }

  /// Get recently added recipes
  Future<Map<String, dynamic>> getRecentRecipes({int limit = 10}) async {
    try {
      log('🆕 Getting recent recipes');

      final response = await _dio.get(
        '$_recipesAll/recent',
        queryParameters: {'limit': limit},
      );

      log('✅ Recent recipes retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get recent recipes error: $e');
      throw Exception('Get recent recipes error: ${e.toString()}');
    }
  }
}