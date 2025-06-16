import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:math' as math;
import 'dart:convert' as convert;
import 'dart:convert' show utf8;
import 'dart:convert' show base64Url;

/// INFO: Complete API Service for ZeroWasteAI backend integration
/// ADVICE: This service handles all 23 endpoints from the real API documentation
/// WARNING: Always ensure proper error handling when using these methods
class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._internal();

  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // INFO: API Endpoints - All 23 endpoints from real documentation
  static const String _authFirebaseSignIn = '/api/auth/firebase-signin';
  static const String _authRefresh = '/api/auth/refresh';
  static const String _authLogout = '/api/auth/logout';

  // INFO: Updated profile endpoints to match real API structure
  static const String _userProfile = '/api/user/profile';

  static const String _recognitionFoods = '/api/recognition/foods';
  static const String _recognitionIngredients = '/api/recognition/ingredients';
  static const String _recognitionIngredientsComplete =
      '/api/recognition/ingredients/complete';
  static const String _recognitionBatch = '/api/recognition/batch';
  static const String _recognitionImagesStatus =
      '/api/recognition/images/status';
  static const String _recognitionById = '/api/recognition/recognition';
  static const String _imageUpload = '/api/image_management/upload_image';
  static const String _imageSearchSimilar =
      '/api/image_management/search_similar_images';
  static const String _imageAssign = '/api/image_management/assign_image';

  // INFO: Reference Image Management endpoints
  static const String _referenceImageUpload = '/api/reference-images';
  static const String _referenceImageList = '/api/reference-images';
  static const String _referenceImageGet = '/api/reference-images';
  static const String _referenceImageDelete = '/api/reference-images';
  static const String _referenceImageUpdate = '/api/reference-images';

  // INFO: NEW - Inventory Management endpoints (15 endpoints)
  static const String _inventoryItems = '/api/inventory';
  static const String _inventoryIngredients = '/api/inventory/ingredients';
  static const String _inventoryComplete = '/api/inventory/complete';
  static const String _inventorySimple = '/api/inventory/simple';
  static const String _inventoryExpiring = '/api/inventory/expiring';
  static const String _inventoryIngredientDetail = '/api/inventory/ingredients';
  static const String _inventoryFoodDetail = '/api/inventory/foods';
  static const String _inventoryFromRecognition =
      '/api/inventory/ingredients/from-recognition';
  static const String _inventoryAddItem = '/api/inventory/add_item';
  static const String _inventoryUploadImage = '/api/inventory/upload_image';
  static const String _inventoryIngredientsList =
      '/api/inventory/ingredients/list';

  // INFO: Recipe Management endpoints (6 endpoints)
  static const String _recipesGenerate = '/api/recipes/generate';
  static const String _recipesGenerateFromInventory =
      '/api/recipes/generate-from-inventory';
  static const String _recipesGenerateCustom = '/api/recipes/generate-custom';
  static const String _recipesSave = '/api/recipes/save';
  static const String _recipesSaved = '/api/recipes/saved';
  static const String _recipesAll = '/api/recipes/all';
  static const String _recipesDelete = '/api/recipes/delete';

  // INFO: NEW - Admin endpoints (5 endpoints)
  static const String _adminUsers = '/api/admin/users';
  static const String _adminSyncImages = '/api/admin/sync_images';
  static const String _adminStats = '/api/admin/stats';
  static const String _adminHealth = '/api/admin/health';

  // INFO: NEW - Meal Planning endpoints (2 endpoints)
  static const String _planGenerate = '/api/plan/generate';
  static const String _planHistory = '/api/plan/history';

  // INFO: NEW - Recognition additional endpoints (2 endpoints)
  static const String _recognitionHistory = '/api/recognition/history';
  static const String _recognitionFeedback = '/api/recognition/feedback';

  // INFO: NEW - Image status endpoint
  static const String _imageStatus = '/api/images/status';

  // INFO: NEW - Status endpoint
  static const String _systemStatus = '/status';

  // INFO: Secure Storage Keys for JWT tokens
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  ApiService._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    // INFO: Base URL from environment or default to localhost
    final baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? 'http://127.0.0.1:3000';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(
          seconds: 30,
        ), // Default timeout for normal operations
        sendTimeout: const Duration(
          seconds: 30,
        ), // AI operations use longer timeouts in specific methods
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
            log('🔑 ApiService: JWT token injected for ${options.path}');
          } else {
            log('⚠️ ApiService: No access token found for ${options.path}');
            // Try auto-relogin before making the request
            final reloginSuccess = await _performAutoRelogin();
            if (reloginSuccess) {
              final newToken = await getAccessToken();
              if (newToken != null) {
                options.headers['Authorization'] = 'Bearer $newToken';
                log(
                  '🔑 ApiService: Auto-relogin successful, JWT token injected',
                );
              }
            }
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

            // Skip automatic retry for image upload endpoints - they handle their own retries
            if (error.requestOptions.path == _imageUpload) {
              log(
                '🔄 ApiService: Skipping automatic retry for image upload - handled by method',
              );
              return handler.reject(error);
            }

            log(
              '🔄 ApiService: 401 detected for ${error.requestOptions.path} - initiating token recovery...',
            );

            try {
              // Step 1: Try normal token refresh first
              log('🔄 Step 1: Attempting normal token refresh...');
              final newAccessToken = await refreshTokens();
              if (newAccessToken != null) {
                // INFO: Recreate request options to avoid FormData finalization issue
                final newOptions = _recreateRequestOptions(
                  error.requestOptions,
                );
                newOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                final response = await _dio.fetch(newOptions);
                log('✅ ApiService: Token refresh successful - request retried');
                return handler.resolve(response);
              }
            } catch (refreshError) {
              log('❌ ApiService: Token refresh failed: $refreshError');
            }

            // Step 2: Try auto-relogin if refresh failed
            log('🔄 Step 2: Attempting auto-relogin...');
            final reloginSuccess = await _performAutoRelogin();
            if (reloginSuccess) {
              final newToken = await getAccessToken();
              if (newToken != null) {
                // INFO: Recreate request options to avoid FormData finalization issue
                final newOptions = _recreateRequestOptions(
                  error.requestOptions,
                );
                newOptions.headers['Authorization'] = 'Bearer $newToken';
                final response = await _dio.fetch(newOptions);
                log('✅ ApiService: Auto-relogin successful - request retried');
                return handler.resolve(response);
              }
            }

            log('❌ ApiService: Both refresh and auto-relogin failed');
            await clearTokens();
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
          log('API Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          log(
            'API Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          log(
            'API Error: ${error.response?.statusCode} ${error.requestOptions.path}',
          );
          log('Error Data: ${error.response?.data}');
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
    log('🔐 Storing JWT tokens securely...');
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    log('✅ JWT tokens stored successfully in secure storage');
  }

  Future<String?> getAccessToken() async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    if (token != null) {
      log('🔑 Access token retrieved from secure storage');
    } else {
      log('⚠️ No access token found in secure storage');
    }
    return token;
  }

  Future<String?> getRefreshToken() async {
    final token = await _secureStorage.read(key: _refreshTokenKey);
    if (token != null) {
      log('🔄 Refresh token retrieved from secure storage');
    } else {
      log('⚠️ No refresh token found in secure storage');
    }
    return token;
  }

  Future<void> clearTokens() async {
    log('🗑️ Clearing stored JWT tokens...');
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    log('✅ JWT tokens cleared from secure storage');
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
      log('🔍 Initiating Firebase token exchange with backend...');

      // INFO: Debug Firebase token structure (without exposing the token)
      final tokenParts = firebaseIdToken.split('.');
      log(
        '🔧 Firebase token has ${tokenParts.length} parts (should be 3 for JWT)',
      );
      log('🔧 Token length: ${firebaseIdToken.length} characters');
      log(
        '🔧 Token starts with: ${firebaseIdToken.substring(0, math.min(20, firebaseIdToken.length))}...',
      );

      // INFO: Validate basic JWT structure
      if (tokenParts.length != 3) {
        log('❌ Invalid Firebase token structure - not a valid JWT!');
        throw Exception('Invalid Firebase token structure');
      }

      try {
        // INFO: Try to decode the header to verify it's a valid JWT
        final header = tokenParts[0];
        final headerBytes = base64Url.decode(
          header + '=' * (4 - header.length % 4),
        );
        final headerJson = utf8.decode(headerBytes);
        log('🔧 JWT Header: $headerJson');

        // INFO: Try to decode the payload to see project info
        final payload = tokenParts[1];
        final payloadBytes = base64Url.decode(
          payload + '=' * (4 - payload.length % 4),
        );
        final payloadJson = utf8.decode(payloadBytes);
        final payloadData =
            convert.jsonDecode(payloadJson) as Map<String, dynamic>;

        log('🔧 JWT Payload key info:');
        log('   - iss (issuer): ${payloadData['iss']}');
        log('   - aud (audience): ${payloadData['aud']}');
        log('   - sub (user ID): ${payloadData['sub']}');
        log(
          '   - exp (expires): ${payloadData['exp']} (${DateTime.fromMillisecondsSinceEpoch((payloadData['exp'] as int) * 1000)})',
        );
        log(
          '   - iat (issued at): ${payloadData['iat']} (${DateTime.fromMillisecondsSinceEpoch((payloadData['iat'] as int) * 1000)})',
        );
        if (payloadData.containsKey('firebase')) {
          log('   - firebase: ${payloadData['firebase']}');
        }
      } catch (e) {
        log('⚠️ Could not decode JWT header/payload: $e');
      }

      log('🌐 Sending request to: $_authFirebaseSignIn');
      log(
        '🔑 Authorization header: Bearer [FIREBASE_TOKEN_${firebaseIdToken.length}_CHARS]',
      );

      final response = await _dio.post(
        _authFirebaseSignIn,
        options: Options(headers: {'Authorization': 'Bearer $firebaseIdToken'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        log('✅ Backend response received with JWT tokens');
        log('📊 Token expires in: ${data['expires_in']} seconds');

        // INFO: Automatically store tokens for future use
        await storeTokens(
          accessToken: data['access_token'] as String,
          refreshToken: data['refresh_token'] as String,
        );
        log('🎉 Firebase token exchange completed successfully');
        return data;
      }
      log('❌ Unexpected response code: ${response.statusCode}');
      throw Exception(
        'Firebase sign in failed with status: ${response.statusCode}',
      );
    } catch (e) {
      log('❌ Firebase token exchange failed: ${e.toString()}');

      // INFO: If it's a DioException, log more details
      if (e is DioException) {
        log('🔍 Request URL: ${e.requestOptions.uri}');
        log('🔍 Request method: ${e.requestOptions.method}');
        log('🔍 Request headers: ${e.requestOptions.headers}');
        if (e.response != null) {
          log('🔍 Response status: ${e.response!.statusCode}');
          log('🔍 Response data: ${e.response!.data}');
          log('🔍 Response headers: ${e.response!.headers}');
        }
      }

      throw Exception('Firebase sign in error: ${e.toString()}');
    }
  }

  /// INFO: Refresh JWT tokens with automatic rotation
  /// NOTE: Called automatically by interceptor on 401 errors
  Future<String?> refreshTokens() async {
    try {
      log('🔄 Initiating token refresh...');
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        log('❌ No refresh token available for refresh');
        return null;
      }

      log('🔍 Sending refresh request to backend...');
      final response = await _dio.post(
        _authRefresh,
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String;
        final newRefreshToken = data['refresh_token'] as String;

        log('✅ New tokens received from backend');
        log('📊 New token expires in: ${data['expires_in']} seconds');

        // INFO: Store new tokens automatically
        await storeTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        log('🎉 Token refresh completed successfully');
        return newAccessToken;
      }
      log(
        '❌ Token refresh failed - invalid response code: ${response.statusCode}',
      );
      return null;
    } catch (e) {
      log('❌ Token refresh error: $e');
      return null;
    }
  }

  /// INFO: Secure logout with token blacklisting
  /// ADVICE: Always call this when user logs out
  Future<void> logout() async {
    try {
      await _dio.post(_authLogout);
    } catch (e) {
      log('Logout error: $e');
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
      // Use longer timeout for AI recognition operations
      final response = await _dio.post(
        _recognitionFoods,
        data: {'images_paths': imagePaths},
        options: Options(
          receiveTimeout: const Duration(
            minutes: 3,
          ), // 3 minutes for AI processing
          sendTimeout: const Duration(minutes: 1), // 1 minute for upload
        ),
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
      // Use longer timeout for AI recognition operations
      final response = await _dio.post(
        _recognitionIngredients,
        data: {'images_paths': imagePaths},
        options: Options(
          receiveTimeout: const Duration(
            minutes: 3,
          ), // 3 minutes for AI processing
          sendTimeout: const Duration(minutes: 1), // 1 minute for upload
        ),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Ingredient recognition error: ${e.toString()}');
    }
  }

  /// INFO: Batch recognition for mixed content (ingredients + foods)
  Future<Map<String, dynamic>> recognizeBatch(List<String> imagePaths) async {
    try {
      // Use longer timeout for AI recognition operations
      final response = await _dio.post(
        _recognitionBatch,
        data: {'images_paths': imagePaths},
        options: Options(
          receiveTimeout: const Duration(
            minutes: 3,
          ), // 3 minutes for AI processing
          sendTimeout: const Duration(minutes: 1), // 1 minute for upload
        ),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Batch recognition error: ${e.toString()}');
    }
  }

  /// INFO: Get recognition history
  /// ADVICE: Shows past recognition sessions with all detected items
  Future<Map<String, dynamic>> getRecognitionHistory() async {
    try {
      final response = await _dio.get(_recognitionHistory);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get recognition history error: ${e.toString()}');
    }
  }

  /// INFO: Submit feedback on recognition results
  /// USAGE: Helps improve AI recognition accuracy
  Future<Map<String, dynamic>> submitRecognitionFeedback({
    required String recognitionId,
    required String feedback,
  }) async {
    try {
      final response = await _dio.post(
        _recognitionFeedback,
        data: {'recognition_id': recognitionId, 'feedback': feedback},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Submit recognition feedback error: ${e.toString()}');
    }
  }

  /// INFO: Complete ingredient recognition with environmental impact and utilization ideas
  /// BASED ON: POST /api/recognition/ingredients/complete endpoint
  Future<Map<String, dynamic>> recognizeIngredientsComplete(
    List<String> imagePaths,
  ) async {
    try {
      final response = await _dio.post(
        _recognitionIngredientsComplete,
        data: {'images_paths': imagePaths},
        options: Options(
          receiveTimeout: const Duration(minutes: 3),
          sendTimeout: const Duration(minutes: 1),
        ),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Complete ingredient recognition error: ${e.toString()}');
    }
  }

  /// INFO: Check image generation status specifically for recognition
  /// BASED ON: GET /api/recognition/images/status/{task_id} endpoint
  Future<Map<String, dynamic>> getRecognitionImageStatus(String taskId) async {
    try {
      final response = await _dio.get('$_recognitionImagesStatus/$taskId');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get recognition image status error: ${e.toString()}');
    }
  }

  /// INFO: Get recognition with updated image paths
  /// BASED ON: GET /api/recognition/recognition/{recognition_id}/images endpoint
  Future<Map<String, dynamic>> getRecognitionImages(
    String recognitionId,
  ) async {
    try {
      final response = await _dio.get(
        '$_recognitionById/$recognitionId/images',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get recognition images error: ${e.toString()}');
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
    int retryCount = 0;
    const maxRetries = 2;

    while (retryCount <= maxRetries) {
      try {
        // Create fresh FormData for each attempt to avoid "already finalized" errors
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
      } on DioException catch (e) {
        // Handle 401 errors specifically for this upload
        if (e.response?.statusCode == 401 && retryCount < maxRetries) {
          log(
            '🔄 Upload failed with 401, attempting token refresh... (attempt ${retryCount + 1}/$maxRetries)',
          );

          try {
            // Step 1: Try normal token refresh
            final newAccessToken = await refreshTokens();
            if (newAccessToken != null) {
              log('✅ Token refresh successful, retrying upload...');
              retryCount++;
              continue; // Retry with new token
            }
          } catch (refreshError) {
            log('❌ Token refresh failed: $refreshError');
          }

          // Step 2: Try auto-relogin if refresh failed
          final reloginSuccess = await _performAutoRelogin();
          if (reloginSuccess) {
            log('✅ Auto-relogin successful, retrying upload...');
            retryCount++;
            continue; // Retry with new token
          }

          log('❌ Both refresh and auto-relogin failed for upload');
          await clearTokens();
        }

        // Re-throw the exception if not a 401 or if retries exhausted
        throw Exception('Image upload error: ${getErrorMessage(e)}');
      } catch (e) {
        throw Exception('Image upload error: ${e.toString()}');
      }
    }

    throw Exception('Image upload failed after $maxRetries retries');
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

  /// INFO: Check image processing status
  /// USAGE: Monitor the status of background image generation tasks
  Future<Map<String, dynamic>> getImageStatus(String? taskId) async {
    try {
      final url = taskId != null ? '$_imageStatus/$taskId' : _imageStatus;
      final response = await _dio.get(url);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get image status error: ${e.toString()}');
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

  /// INFO: Add multiple ingredients to user's inventory (bulk operation)
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

  /// INFO: Add single item to inventory (as specified in README)
  /// USAGE: Add individual item from recognition results to inventory
  Future<Map<String, dynamic>> addInventoryItem(
    Map<String, dynamic> item,
  ) async {
    try {
      final response = await _dio.post(_inventoryItems, data: item);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Add inventory item error: ${e.toString()}');
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

  /// INFO: Get simplified inventory compatible with recognition format
  Future<Map<String, dynamic>> getInventorySimple() async {
    try {
      final response = await _dio.get(_inventorySimple);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get simple inventory error: ${e.toString()}');
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

  /// INFO: Update item by ID (as specified in README.md)
  /// USAGE: Update any inventory item using its unique ID
  Future<Map<String, dynamic>> updateInventoryItem(
    String itemId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _dio.put(
        '$_inventoryItems/$itemId',
        data: updateData,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Update inventory item error: ${e.toString()}');
    }
  }

  /// INFO: Delete item by ID (as specified in README.md)
  /// USAGE: Delete any inventory item using its unique ID
  Future<Map<String, dynamic>> deleteInventoryItem(String itemId) async {
    try {
      final response = await _dio.delete('$_inventoryItems/$itemId');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Delete inventory item error: ${e.toString()}');
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

  /// INFO: Get complete inventory with environmental impact and utilization ideas
  /// USAGE: Enriched inventory with AI-generated insights
  Future<Map<String, dynamic>> getInventoryComplete() async {
    try {
      final response = await _dio.get(_inventoryComplete);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get complete inventory error: ${e.toString()}');
    }
  }

  /// INFO: Add ingredients from recognition results
  /// USAGE: Add ingredients directly from AI recognition with environmental data
  Future<Map<String, dynamic>> addIngredientsFromRecognition(
    List<Map<String, dynamic>> ingredients,
  ) async {
    try {
      final response = await _dio.post(
        _inventoryFromRecognition,
        data: {'ingredients': ingredients},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception(
        'Add ingredients from recognition error: ${e.toString()}',
      );
    }
  }

  /// INFO: Update ingredient quantity only
  /// USAGE: Quick quantity update for specific ingredient stack
  Future<Map<String, dynamic>> updateIngredientQuantity(
    String ingredientName,
    String addedAt,
    double newQuantity,
  ) async {
    try {
      final encodedName = Uri.encodeComponent(ingredientName);
      final encodedDate = Uri.encodeComponent(addedAt);
      final response = await _dio.patch(
        '$_inventoryIngredients/$encodedName/$encodedDate/quantity',
        data: {'new_quantity': newQuantity},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Update ingredient quantity error: ${e.toString()}');
    }
  }

  /// INFO: Delete complete ingredient (all stacks)
  /// USAGE: Remove all stacks of an ingredient from inventory
  Future<Map<String, dynamic>> deleteCompleteIngredient(
    String ingredientName,
  ) async {
    try {
      final encodedName = Uri.encodeComponent(ingredientName);
      final response = await _dio.delete('$_inventoryIngredients/$encodedName');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Delete complete ingredient error: ${e.toString()}');
    }
  }

  /// INFO: Mark ingredient as consumed
  /// USAGE: Track ingredient consumption with details
  Future<Map<String, dynamic>> markIngredientConsumed(
    String ingredientName,
    String addedAt, {
    required double consumedQuantity,
    String? consumptionReason,
    String? recipeUsed,
  }) async {
    try {
      final encodedName = Uri.encodeComponent(ingredientName);
      final encodedDate = Uri.encodeComponent(addedAt);
      final response = await _dio.post(
        '$_inventoryIngredients/$encodedName/$encodedDate/consume',
        data: {
          'consumed_quantity': consumedQuantity,
          if (consumptionReason != null)
            'consumption_reason': consumptionReason,
          if (recipeUsed != null) 'recipe_used': recipeUsed,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Mark ingredient consumed error: ${e.toString()}');
    }
  }

  /// INFO: Get simplified list of ingredient names
  /// USAGE: Quick access to all ingredient names in inventory
  Future<Map<String, dynamic>> getIngredientsList() async {
    try {
      final response = await _dio.get(_inventoryIngredientsList);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get ingredients list error: ${e.toString()}');
    }
  }

  /// INFO: Add single item with advanced options
  /// USAGE: Add individual item with detailed configuration
  Future<Map<String, dynamic>> addSingleInventoryItem({
    required String itemType,
    required Map<String, dynamic> itemData,
  }) async {
    try {
      final response = await _dio.post(
        _inventoryAddItem,
        data: {'item_type': itemType, 'item_data': itemData},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Add single inventory item error: ${e.toString()}');
    }
  }

  /// INFO: Upload inventory image
  /// USAGE: Upload reference image for inventory items
  Future<Map<String, dynamic>> uploadInventoryImage({
    required File imageFile,
    required String itemName,
    String imageType = 'ingredient',
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        'item_name': itemName,
        'image_type': imageType,
      });

      final response = await _dio.post(
        _inventoryUploadImage,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Upload inventory image error: ${e.toString()}');
    }
  }

  // INFO: ===== RECIPE MANAGEMENT ENDPOINTS (6/6) =====
  // ADVICE: AI-powered recipe generation and management

  /// INFO: Generate recipes using current inventory items
  /// ADVICE: AI analyzes your inventory and suggests optimal recipes
  /// RETURNS: Complete response with generated_recipes, inventory_utilization, and images info
  Future<Map<String, dynamic>> generateRecipesFromInventory() async {
    try {
      // Use longer timeout for AI recipe generation operations
      final response = await _dio.post(
        _recipesGenerateFromInventory,
        data: {},
        options: Options(
          receiveTimeout: const Duration(
            minutes: 2,
          ), // 2 minutes for AI processing
          sendTimeout: const Duration(seconds: 30), // 30 seconds for upload
        ),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Generate recipes from inventory error: ${e.toString()}');
    }
  }

  /// INFO: Generate custom recipes with specific ingredients and preferences
  /// USAGE: Specify ingredients, dietary preferences, categories, and number of recipes
  /// RETURNS: Complete response with generated_recipes and images info
  Future<Map<String, dynamic>> generateCustomRecipes({
    required List<String> ingredients,
    List<String>? preferences,
    List<String>? recipeCategories,
    int numRecipes = 2,
  }) async {
    try {
      // Use longer timeout for AI recipe generation operations
      final response = await _dio.post(
        _recipesGenerateCustom,
        data: {
          'ingredients': ingredients,
          if (preferences != null) 'preferences': preferences,
          if (recipeCategories != null) 'recipe_categories': recipeCategories,
          'num_recipes': numRecipes,
        },
        options: Options(
          receiveTimeout: const Duration(
            minutes: 2,
          ), // 2 minutes for AI processing
          sendTimeout: const Duration(seconds: 30), // 30 seconds for upload
        ),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Generate custom recipes error: ${e.toString()}');
    }
  }

  /// INFO: Save a generated or custom recipe to user's collection
  /// USAGE: Save complete recipe data including ingredients, instructions, and metadata
  /// RETURNS: Saved recipe with UID and timestamp
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
  /// USAGE: Retrieve user's personal recipe collection
  /// RETURNS: Array of saved recipes with metadata and count
  Future<Map<String, dynamic>> getSavedRecipes() async {
    try {
      final response = await _dio.get(_recipesSaved);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get saved recipes error: ${e.toString()}');
    }
  }

  /// INFO: Get all available recipes (public + user's)
  /// USAGE: Retrieve complete recipe database for browsing
  /// RETURNS: Array of all recipes with count
  Future<Map<String, dynamic>> getAllRecipes() async {
    try {
      final response = await _dio.get(_recipesAll);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get all recipes error: ${e.toString()}');
    }
  }

  /// INFO: Delete a user's saved recipe
  /// USAGE: Remove recipe from user's collection by title
  /// RETURNS: Confirmation message
  Future<Map<String, dynamic>> deleteRecipe(String recipeTitle) async {
    try {
      final response = await _dio.delete(
        _recipesDelete,
        data: {'title': recipeTitle},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Delete recipe error: ${e.toString()}');
    }
  }

  // INFO: ===== MEAL PLANNING ENDPOINTS (2/2) =====
  // ADVICE: AI-powered meal planning and history management

  /// INFO: Generate meal plan based on available ingredients
  /// ADVICE: AI analyzes your inventory and suggests optimal meal plans
  Future<Map<String, dynamic>> generateMealPlan({
    required List<Map<String, dynamic>> ingredients,
  }) async {
    try {
      // Use longer timeout for AI meal planning operations
      final response = await _dio.post(
        _planGenerate,
        data: {'ingredients': ingredients},
        options: Options(
          receiveTimeout: const Duration(
            minutes: 2,
          ), // 2 minutes for AI processing
          sendTimeout: const Duration(seconds: 30), // 30 seconds for upload
        ),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Generate meal plan error: ${e.toString()}');
    }
  }

  /// INFO: Get meal planning history
  /// USAGE: Retrieve past meal plans and their execution status
  Future<Map<String, dynamic>> getMealPlanHistory() async {
    try {
      final response = await _dio.get(_planHistory);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get meal plan history error: ${e.toString()}');
    }
  }

  // INFO: ===== INVENTORY DETAIL ENDPOINTS (2/2) =====
  // ADVICE: Get detailed information about specific inventory items

  /// INFO: Get detailed information about a specific ingredient
  /// USAGE: Get comprehensive ingredient details including environmental impact, utilization ideas
  /// ADVICE: ingredientName should be URL-encoded for special characters
  /// IMPORTANT: Returns detailed ingredient information with AI-generated insights
  Future<Map<String, dynamic>> getIngredientDetail(
    String ingredientName,
  ) async {
    try {
      final encodedName = Uri.encodeComponent(ingredientName);
      final response = await _dio.get(
        '$_inventoryIngredientDetail/$encodedName/detail',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get ingredient detail error: ${e.toString()}');
    }
  }

  /// INFO: Get detailed information about a specific food item
  /// USAGE: Get nutritional analysis, consumption ideas, storage advice
  /// ADVICE: foodName should be URL-encoded, addedAt should be ISO 8601 format
  /// IMPORTANT: Multiple food items can have the same name, use addedAt as unique identifier
  Future<Map<String, dynamic>> getFoodDetail(
    String foodName,
    String addedAt,
  ) async {
    try {
      final encodedName = Uri.encodeComponent(foodName);
      final encodedDate = Uri.encodeComponent(addedAt);
      final response = await _dio.get(
        '$_inventoryFoodDetail/$encodedName/$encodedDate/detail',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get food detail error: ${e.toString()}');
    }
  }

  /// INFO: Mark a food item as consumed in the backend
  /// USAGE: Track food consumption for environmental impact and inventory management
  /// IMPORTANT: Use exact foodName and addedAt from the food item for unique identification
  /// RETURNS: Consumption tracking data including remaining portions and environmental impact
  Future<Map<String, dynamic>> markFoodAsConsumed(
    String foodName,
    String addedAt, {
    double? portions,
  }) async {
    try {
      final encodedName = Uri.encodeComponent(foodName);
      final encodedDate = Uri.encodeComponent(addedAt);
      final response = await _dio.post(
        '$_inventoryFoodDetail/$encodedName/$encodedDate/consume',
        data: portions != null ? {'portions': portions} : {},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Mark food as consumed error: ${e.toString()}');
    }
  }

  // INFO: ===== RECIPE GENERATION ENDPOINTS (1/1) =====
  // ADVICE: Generate recipes based on available inventory ingredients

  /// INFO: Generate a recipe based on available inventory ingredients
  /// USAGE: Send list of ingredients from user's inventory to get AI-generated recipe
  /// ADVICE: Include all relevant ingredient details for better recipe generation
  /// IMPORTANT: Ingredients should include quantity, type_unit, and expiration info
  /// RETURNS: Complete recipe with ingredients list and cooking instructions
  Future<Map<String, dynamic>> generateRecipe(
    List<Map<String, dynamic>> ingredients,
  ) async {
    try {
      final response = await _dio.post(
        _recipesGenerate,
        data: {'ingredients': ingredients},
        options: Options(
          sendTimeout: const Duration(
            minutes: 2,
          ), // AI generation can take time
          receiveTimeout: const Duration(minutes: 2),
        ),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Generate recipe error: ${e.toString()}');
    }
  }

  // INFO: ===== ADMIN ENDPOINTS (5/5) =====
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

  /// INFO: Get system statistics
  /// WARNING: Admin only - system metrics and usage stats
  Future<Map<String, dynamic>> getSystemStats() async {
    try {
      final response = await _dio.get(_adminStats);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get system stats error: ${e.toString()}');
    }
  }

  /// INFO: Get system health status
  /// WARNING: Admin only - comprehensive health monitoring
  Future<Map<String, dynamic>> getSystemHealth() async {
    try {
      final response = await _dio.get(_adminHealth);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get system health error: ${e.toString()}');
    }
  }

  // INFO: ===== STATUS ENDPOINTS (1/1) =====
  // ADVICE: Public status endpoints for system monitoring

  /// INFO: Get public system status
  /// USAGE: Check if the API is operational and responsive
  Future<Map<String, dynamic>> getSystemStatus() async {
    try {
      final response = await _dio.get(_systemStatus);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get system status error: ${e.toString()}');
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

  Future<bool> _performAutoRelogin() async {
    try {
      log('🔄 ApiService: Starting auto-relogin process...');

      // Check if Firebase user is still signed in
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        log('❌ ApiService: No Firebase user found - cannot auto-relogin');
        return false;
      }

      log('👤 ApiService: Firebase user found: ${firebaseUser.email}');

      // Get fresh Firebase ID token
      log('🔍 Getting fresh Firebase ID token...');
      final firebaseIdToken = await firebaseUser.getIdToken(
        true,
      ); // force refresh

      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        log('❌ ApiService: Failed to get Firebase ID token');
        return false;
      }

      // Exchange Firebase token for backend JWT tokens using the same method
      log('🔄 Exchanging Firebase token for backend tokens...');
      // ignore: unused_local_variable
      final backendResponse = await firebaseSignIn(firebaseIdToken);

      log('✅ ApiService: Auto-relogin successful! New tokens obtained');
      return true;
    } catch (e) {
      log('❌ ApiService: Auto-relogin failed: $e');
      return false;
    }
  }

  // ===== HELPER METHODS =====

  /// Recreates FormData for retry requests to avoid "FormData already finalized" error
  RequestOptions _recreateRequestOptions(RequestOptions options) {
    final newOptions = RequestOptions(
      path: options.path,
      method: options.method,
      baseUrl: options.baseUrl,
      queryParameters: options.queryParameters,
      headers: Map<String, dynamic>.from(options.headers),
      extra: options.extra,
      responseType: options.responseType,
      contentType: options.contentType,
      validateStatus: options.validateStatus,
      receiveDataWhenStatusError: options.receiveDataWhenStatusError,
      followRedirects: options.followRedirects,
      maxRedirects: options.maxRedirects,
      requestEncoder: options.requestEncoder,
      responseDecoder: options.responseDecoder,
      listFormat: options.listFormat,
    );

    // If the original request had FormData, try to recreate it
    if (options.data is FormData) {
      try {
        final originalFormData = options.data as FormData;
        final newFormData = FormData();

        // Copy all fields
        for (final field in originalFormData.fields) {
          newFormData.fields.add(MapEntry(field.key, field.value));
        }

        // Try to clone files
        for (final fileEntry in originalFormData.files) {
          final clonedFile = fileEntry.value.clone();
          newFormData.files.add(MapEntry(fileEntry.key, clonedFile));
        }

        newOptions.data = newFormData;
        log('🔧 FormData recreated successfully for retry request');
      } catch (e) {
        log('❌ Failed to recreate FormData: $e');
        log('⚠️ Returning original request options - retry may fail');
        // Return original request options - this will likely fail with the
        // "MultipartFile already finalized" error, but that's better than
        // creating an invalid request
        return options;
      }
    } else {
      newOptions.data = options.data;
    }

    return newOptions;
  }
}
