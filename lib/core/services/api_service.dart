import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// INFO: Complete API Service for ZeroWasteAI backend integration
/// ADVICE: This service handles all 23 endpoints from the real API documentation
/// WARNING: Always ensure proper error handling when using these methods
class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._internal();

  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // INFO: API Endpoints - All 23 endpoints from real documentation
  static const String _authFirebaseSignIn = '/auth/firebase-signin';
  static const String _authRefresh = '/auth/refresh';
  static const String _authLogout = '/auth/logout';

  // INFO: Updated profile endpoints to match real API structure
  static const String _userProfile = '/user/profile';

  static const String _recognitionFoods = '/recognition/foods';
  static const String _recognitionIngredients = '/recognition/ingredients';
  static const String _recognitionBatch = '/recognition/batch';
  static const String _imageUpload = '/image_management/upload_image';
  static const String _imageSearchSimilar =
      '/image_management/search_similar_images';
  static const String _imageAssign = '/image_management/assign_image';

  // INFO: Reference Image Management endpoints
  static const String _referenceImageUpload = '/reference-images';
  static const String _referenceImageList = '/reference-images';
  static const String _referenceImageGet = '/reference-images';
  static const String _referenceImageDelete = '/reference-images';
  static const String _referenceImageUpdate = '/reference-images';

  // INFO: NEW - Inventory Management endpoints (5 endpoints)
  static const String _inventoryItems = '/inventory';
  static const String _inventoryIngredients = '/inventory/ingredients';
  static const String _inventoryExpiring = '/inventory/expiring';

  // INFO: NEW - Recipe Management endpoints (4 endpoints)
  static const String _recipesGenerateFromInventory =
      '/recipes/generate-from-inventory';
  static const String _recipesGenerateCustom = '/recipes/generate-custom';
  static const String _recipesSave = '/recipes/save';
  static const String _recipesSaved = '/recipes/saved';

  // INFO: NEW - Admin endpoints (2 endpoints)
  static const String _adminUsers = '/admin/users';
  static const String _adminSyncImages = '/admin/sync_images';

  // INFO: Secure Storage Keys for JWT tokens
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  ApiService._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    // INFO: Base URL from environment or default to localhost
    // TODO: Update BACKEND_BASE_URL in .env for production
    final baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? 'http://localhost:3000';

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

    // INFO: Add automatic JWT token injection and refresh interceptor
    // ADVICE: This handles all authentication automatically
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // INFO: Skip token for auth endpoints (they use Firebase tokens)
          if (options.path == _authFirebaseSignIn ||
              options.path == _authRefresh) {
            return handler.next(options);
          }

          final accessToken = await getAccessToken();
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // INFO: Automatic token refresh on 401 errors
          if (error.response?.statusCode == 401) {
            // WARNING: Don't retry for auth endpoints to avoid infinite loops
            if (error.requestOptions.path == _authRefresh ||
                error.requestOptions.path == _authFirebaseSignIn) {
              await clearTokens();
              return handler.reject(error);
            }

            try {
              final newAccessToken = await refreshTokens();
              if (newAccessToken != null) {
                // INFO: Retry original request with new token
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              }
            } catch (e) {
              await clearTokens();
            }
          }
          handler.next(error);
        },
      ),
    );

    // INFO: Add logging interceptor for debugging
    // TODO: Remove in production or add debug flag
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('API Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            'API Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          print(
            'API Error: ${error.response?.statusCode} ${error.requestOptions.path}',
          );
          print('Error Data: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );
  }

  // INFO: ===== TOKEN MANAGEMENT METHODS =====
  // ADVICE: These handle secure JWT token storage automatically

  Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  // INFO: ===== AUTHENTICATION ENDPOINTS (3/3) =====
  // ADVICE: These match the real API documentation exactly

  /// INFO: Exchange Firebase ID Token for application JWT tokens
  /// USAGE: Call after successful Firebase authentication
  Future<Map<String, dynamic>> firebaseSignIn(String firebaseIdToken) async {
    try {
      final response = await _dio.post(
        _authFirebaseSignIn,
        options: Options(headers: {'Authorization': 'Bearer $firebaseIdToken'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        // INFO: Automatically store tokens for future use
        await storeTokens(
          accessToken: data['access_token'] as String,
          refreshToken: data['refresh_token'] as String,
        );
        return data;
      }
      throw Exception('Firebase sign in failed');
    } catch (e) {
      throw Exception('Firebase sign in error: ${e.toString()}');
    }
  }

  /// INFO: Refresh JWT tokens with automatic rotation
  /// NOTE: Called automatically by interceptor on 401 errors
  Future<String?> refreshTokens() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return null;

      final response = await _dio.post(
        _authRefresh,
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String;
        final newRefreshToken = data['refresh_token'] as String;

        // INFO: Store new tokens automatically
        await storeTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        return newAccessToken;
      }
      return null;
    } catch (e) {
      print('Token refresh error: $e');
      return null;
    }
  }

  /// INFO: Secure logout with token blacklisting
  /// ADVICE: Always call this when user logs out
  Future<void> logout() async {
    try {
      await _dio.post(_authLogout);
    } catch (e) {
      print('Logout error: $e');
    } finally {
      // INFO: Always clear tokens even if server call fails
      await clearTokens();
    }
  }

  // INFO: ===== USER PROFILE ENDPOINTS (2/2) =====

  /// INFO: Get complete user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get(_userProfile);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get profile error: ${e.toString()}');
    }
  }

  /// INFO: Update user profile with new data
  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await _dio.put(_userProfile, data: profileData);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Update profile error: ${e.toString()}');
    }
  }

  // INFO: ===== FOOD RECOGNITION ENDPOINTS (3/3) =====
  // ADVICE: All methods expect arrays of image paths from Firebase Storage

  /// INFO: AI recognition of prepared foods/dishes
  Future<Map<String, dynamic>> recognizeFoods(List<String> imagePaths) async {
    try {
      final response = await _dio.post(
        _recognitionFoods,
        data: {'images_paths': imagePaths},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Food recognition error: ${e.toString()}');
    }
  }

  /// INFO: AI recognition of individual ingredients
  Future<Map<String, dynamic>> recognizeIngredients(
    List<String> imagePaths,
  ) async {
    try {
      final response = await _dio.post(
        _recognitionIngredients,
        data: {'images_paths': imagePaths},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Ingredient recognition error: ${e.toString()}');
    }
  }

  /// INFO: Batch recognition for mixed content (ingredients + foods)
  Future<Map<String, dynamic>> recognizeBatch(List<String> imagePaths) async {
    try {
      final response = await _dio.post(
        _recognitionBatch,
        data: {'images_paths': imagePaths},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Batch recognition error: ${e.toString()}');
    }
  }

  // INFO: ===== IMAGE MANAGEMENT ENDPOINTS (3/3) =====

  /// INFO: Upload image to Firebase Storage
  /// ADVICE: Use imageType: "food", "ingredient", or "default"
  Future<Map<String, dynamic>> uploadImage({
    required File imageFile,
    required String itemName,
    required String imageType, // "food", "ingredient", "default"
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path),
        'item_name': itemName,
        'image_type': imageType,
      });

      final response = await _dio.post(
        _imageUpload,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Image upload error: ${e.toString()}');
    }
  }

  /// INFO: Search for similar images by item name
  Future<List<Map<String, dynamic>>> searchSimilarImages(
    String itemName,
  ) async {
    try {
      final response = await _dio.post(
        _imageSearchSimilar,
        data: {'item_name': itemName},
      );
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Search similar images error: ${e.toString()}');
    }
  }

  /// INFO: Assign reference image to an item
  Future<Map<String, dynamic>> assignImage(String itemName) async {
    try {
      final response = await _dio.post(
        _imageAssign,
        data: {'item_name': itemName},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Assign image error: ${e.toString()}');
    }
  }

  // INFO: ===== REFERENCE IMAGE MANAGEMENT ENDPOINTS (5/5) =====
  // ADVICE: These are for admin management of reference images

  /// INFO: Upload reference image for AI training
  /// WARNING: Admin only endpoint
  Future<Response> uploadReferenceImage(FormData formData) async {
    try {
      final response = await _dio.post(
        _referenceImageUpload,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      return response;
    } catch (e) {
      throw Exception('Reference image upload error: ${e.toString()}');
    }
  }

  /// INFO: Get paginated list of reference images
  Future<Response> getReferenceImages(
    String? category,
    String? label,
    int page,
    int perPage,
  ) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'per_page': perPage};
      if (category != null) queryParams['category'] = category;
      if (label != null) queryParams['label'] = label;

      final response = await _dio.get(
        _referenceImageList,
        queryParameters: queryParams,
      );
      return response;
    } catch (e) {
      throw Exception('Reference image list error: ${e.toString()}');
    }
  }

  /// INFO: Get specific reference image by ID
  Future<Response> getReferenceImage(String imageId) async {
    try {
      final response = await _dio.get('$_referenceImageGet/$imageId');
      return response;
    } catch (e) {
      throw Exception('Reference image get error: ${e.toString()}');
    }
  }

  /// INFO: Delete reference image by ID
  /// WARNING: Admin only endpoint
  Future<Response> deleteReferenceImage(String imageId) async {
    try {
      final response = await _dio.delete('$_referenceImageDelete/$imageId');
      return response;
    } catch (e) {
      throw Exception('Reference image delete error: ${e.toString()}');
    }
  }

  /// INFO: Update reference image metadata
  /// WARNING: Admin only endpoint
  Future<Response> updateReferenceImage(
    String imageId,
    String? label,
    String? category,
  ) async {
    try {
      final updateData = <String, dynamic>{};
      if (label != null) updateData['label'] = label;
      if (category != null) updateData['category'] = category;

      final response = await _dio.put(
        '$_referenceImageUpdate/$imageId',
        data: updateData,
      );
      return response;
    } catch (e) {
      throw Exception('Reference image update error: ${e.toString()}');
    }
  }

  // INFO: ===== INVENTORY MANAGEMENT ENDPOINTS (5/5) =====
  // ADVICE: Core feature for managing user's food inventory

  /// INFO: Add multiple ingredients to user's inventory
  /// USAGE: Pass array of ingredient objects with name, quantity, expiry, etc.
  Future<Map<String, dynamic>> addIngredients(
    List<Map<String, dynamic>> ingredients,
  ) async {
    try {
      final response = await _dio.post(
        _inventoryIngredients,
        data: {'ingredients': ingredients},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Add ingredients error: ${e.toString()}');
    }
  }

  /// INFO: Get complete user inventory with all items
  Future<Map<String, dynamic>> getInventory() async {
    try {
      final response = await _dio.get(_inventoryItems);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get inventory error: ${e.toString()}');
    }
  }

  /// INFO: Update specific ingredient by name and added date
  /// ADVICE: Use name and addedAt as composite key for unique identification
  Future<Map<String, dynamic>> updateIngredient(
    String name,
    String addedAt,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _dio.put(
        '$_inventoryIngredients/$name/$addedAt',
        data: updateData,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Update ingredient error: ${e.toString()}');
    }
  }

  /// INFO: Delete specific ingredient from inventory
  /// ADVICE: Use name and addedAt as composite key
  Future<Map<String, dynamic>> deleteIngredient(
    String name,
    String addedAt,
  ) async {
    try {
      final response = await _dio.delete(
        '$_inventoryIngredients/$name/$addedAt',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Delete ingredient error: ${e.toString()}');
    }
  }

  /// INFO: Get items expiring within specified days
  /// USAGE: Use days=7 for items expiring this week
  Future<Map<String, dynamic>> getExpiringItems(int days) async {
    try {
      final response = await _dio.get('$_inventoryExpiring?days=$days');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get expiring items error: ${e.toString()}');
    }
  }

  // INFO: ===== RECIPE MANAGEMENT ENDPOINTS (4/4) =====
  // ADVICE: AI-powered recipe generation and management

  /// INFO: Generate recipes using current inventory items
  /// ADVICE: AI analyzes your inventory and suggests optimal recipes
  Future<List<Map<String, dynamic>>> generateRecipesFromInventory() async {
    try {
      final response = await _dio.post(_recipesGenerateFromInventory, data: {});
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Generate recipes from inventory error: ${e.toString()}');
    }
  }

  /// INFO: Generate custom recipes with specific ingredients
  /// USAGE: Specify ingredients you want to use, dietary preferences, etc.
  Future<List<Map<String, dynamic>>> generateCustomRecipes({
    required List<String> ingredients,
    List<String>? preferences,
    int numRecipes = 2,
  }) async {
    try {
      final response = await _dio.post(
        _recipesGenerateCustom,
        data: {
          'ingredients': ingredients,
          if (preferences != null) 'preferences': preferences,
          'num_recipes': numRecipes,
        },
      );
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Generate custom recipes error: ${e.toString()}');
    }
  }

  /// INFO: Save a recipe to user's favorites collection
  Future<Map<String, dynamic>> saveRecipe(
    Map<String, dynamic> recipeData,
  ) async {
    try {
      final response = await _dio.post(_recipesSave, data: recipeData);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Save recipe error: ${e.toString()}');
    }
  }

  /// INFO: Get all user's saved/favorite recipes
  Future<Map<String, dynamic>> getSavedRecipes() async {
    try {
      final response = await _dio.get(_recipesSaved);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get saved recipes error: ${e.toString()}');
    }
  }

  // INFO: ===== ADMIN ENDPOINTS (2/2) =====
  // WARNING: These require admin role permissions

  /// INFO: Get all users in the system
  /// WARNING: Admin only - requires admin role
  Future<Map<String, dynamic>> getUsers() async {
    try {
      final response = await _dio.get(_adminUsers);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get users error: ${e.toString()}');
    }
  }

  /// INFO: Synchronize reference images database
  /// WARNING: Admin only - maintenance operation
  Future<Map<String, dynamic>> syncImages() async {
    try {
      final response = await _dio.post(_adminSyncImages);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Sync images error: ${e.toString()}');
    }
  }

  // INFO: ===== UTILITY METHODS =====
  // ADVICE: Helper methods for error handling and debugging

  /// INFO: Extract meaningful error messages from API responses
  /// USAGE: Use in catch blocks to get user-friendly error messages
  String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data is Map) {
        final errorData = error.response!.data as Map<String, dynamic>;
        if (errorData.containsKey('error')) {
          return errorData['error'] as String;
        }
        if (errorData.containsKey('message')) {
          return errorData['message'] as String;
        }
      }

      // INFO: Provide user-friendly messages for common HTTP status codes
      switch (error.response?.statusCode) {
        case 400:
          return 'Datos de solicitud inválidos';
        case 401:
          return 'No autorizado. Por favor, inicia sesión nuevamente';
        case 403:
          return 'Acceso denegado';
        case 404:
          return 'Recurso no encontrado';
        case 409:
          return 'Conflicto: el recurso ya existe';
        case 429:
          return 'Demasiadas solicitudes. Intenta de nuevo más tarde';
        case 500:
        case 502:
        case 503:
        case 504:
          return 'Error del servidor. Intenta de nuevo más tarde';
        default:
          return 'Error de conexión';
      }
    }
    return error.toString();
  }

  /// INFO: Check if the error is due to rate limiting
  /// ADVICE: Use this to implement retry logic with backoff
  bool isRateLimited(DioException error) {
    return error.response?.statusCode == 429;
  }

  /// INFO: Get retry delay from rate limit headers
  /// USAGE: Use with isRateLimited() to implement proper retry timing
  int? getRateLimitRetryAfter(DioException error) {
    if (error.response?.headers['retry-after'] != null) {
      return int.tryParse(error.response!.headers['retry-after']!.first);
    }
    return null;
  }
}
