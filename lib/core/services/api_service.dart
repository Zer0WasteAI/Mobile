import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:convert' as convert;
import 'dart:convert' show utf8;
import 'dart:convert' show base64Url;

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// INFO: Complete API Service for ZeroWasteAI backend integration
/// COVERAGE: This service handles 67+ endpoints from the MCP backend
/// FEATURES: JWT authentication, automatic token refresh, error handling, standardized timeouts
/// WARNING: Always ensure proper error handling when using these methods
/// LAST UPDATED: Corrected duplicates, standardized timeouts, fixed URL patterns
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
  static const String _recognitionIngredientsAsync =
      '/api/recognition/ingredients/async';
  static const String _recognitionStatus = '/api/recognition/status';
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
  static const String _inventoryFoodsFromRecognition =
      '/api/inventory/foods/from-recognition';
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
  static const String _recipesDefault = '/api/recipes/default';
  static const String _recipesDelete = '/api/recipes/delete';

  // INFO: NEW - Admin endpoints (5 endpoints)
  static const String _adminUsers = '/api/admin/users';
  static const String _adminSyncImages = '/api/admin/sync_images';
  static const String _adminStats = '/api/admin/stats';
  static const String _adminHealth = '/api/admin/health';

  // INFO: NEW - Meal Planning endpoints (8 endpoints)
  static const String _planGenerate = '/api/plan/generate';
  static const String _planHistory = '/api/plan/history';
  static const String _planningSave = '/api/planning/save';
  static const String _planningUpdate = '/api/planning/update';
  static const String _planningGet = '/api/planning/get';
  static const String _planningAll = '/api/planning/all';
  static const String _planningDates = '/api/planning/dates';
  static const String _planningDelete = '/api/planning/delete';

  // INFO: NEW - Environmental Savings endpoints (5 endpoints)
  static const String _envSavingsCalculateFromTitle =
      '/api/environmental_savings/calculate/from-title';
  static const String _envSavingsCalculateFromUid =
      '/api/environmental_savings/calculate/from-uid';
  static const String _envSavingsCalculations =
      '/api/environmental_savings/calculations';
  static const String _envSavingsCalculationsByStatus =
      '/api/environmental_savings/calculations/status';
  static const String _envSavingsSummary = '/api/environmental_savings/summary';
  static const String _envSavingsUpdateCalculation =
      '/api/environmental_savings/calculations';

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

  // INFO: Standardized Timeout Constants
  static const Duration _aiProcessingTimeout = Duration(minutes: 3);
  static const Duration _uploadTimeout = Duration(minutes: 2);
  // ignore: unused_field
  static const Duration _standardTimeout = Duration(seconds: 30);

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
          // INFO: Automatic token refresh on 401 errors ONLY
          if (error.response?.statusCode == 401) {
            // WARNING: Don't retry for auth endpoints to avoid infinite loops
            if (error.requestOptions.path == _authRefresh ||
                error.requestOptions.path == _authFirebaseSignIn) {
              await clearTokens();
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
                try {
                  // INFO: Recreate request options to avoid FormData finalization issue
                  final newOptions = _recreateRequestOptions(
                    error.requestOptions,
                  );
                  newOptions.headers['Authorization'] =
                      'Bearer $newAccessToken';
                  final response = await _dio.fetch(newOptions);
                  log(
                    '✅ ApiService: Token refresh successful - request retried',
                  );
                  return handler.resolve(response);
                } catch (recreateError) {
                  // Check if the retry error is also a 401 (token still invalid)
                  if (recreateError is DioException &&
                      recreateError.response?.statusCode == 401) {
                    log(
                      '🔄 ApiService: Retry still got 401 - trying auto-relogin...',
                    );
                    // Continue to auto-relogin step
                  } else {
                    // If it's not a 401, it means token refresh worked but there's another error
                    log(
                      '✅ ApiService: Token refresh succeeded, but request failed for other reason: $recreateError',
                    );
                    return handler.reject(recreateError as DioException);
                  }
                }
              }
            } catch (refreshError) {
              log('❌ ApiService: Token refresh failed: $refreshError');
            }

            // Step 2: Try auto-relogin if refresh failed or retry still got 401
            log('🔄 Step 2: Attempting auto-relogin...');
            final reloginSuccess = await _performAutoRelogin();
            if (reloginSuccess) {
              final newToken = await getAccessToken();
              if (newToken != null) {
                try {
                  // INFO: Recreate request options to avoid FormData finalization issue
                  final newOptions = _recreateRequestOptions(
                    error.requestOptions,
                  );
                  newOptions.headers['Authorization'] = 'Bearer $newToken';
                  final response = await _dio.fetch(newOptions);
                  log(
                    '✅ ApiService: Auto-relogin successful - request retried',
                  );
                  return handler.resolve(response);
                } catch (recreateError) {
                  log(
                    '❌ ApiService: Cannot recreate request after auto-relogin: $recreateError',
                  );
                  // Check if it's a FormData issue vs other errors
                  if (recreateError.toString().contains('FormData') ||
                      recreateError.toString().contains('finalized')) {
                    final friendlyError = DioException(
                      requestOptions: error.requestOptions,
                      response: error.response,
                      type: DioExceptionType.unknown,
                      error:
                          'Tu sesión expiró durante la operación. Por favor, intenta nuevamente desde el inicio.',
                    );
                    return handler.reject(friendlyError);
                  } else {
                    // Pass through other errors as-is (404, 500, etc.)
                    return handler.reject(recreateError as DioException);
                  }
                }
              }
            }

            log('❌ ApiService: Both refresh and auto-relogin failed');
            await clearTokens();
          }
          // INFO: For non-401 errors, pass them through without token refresh attempts
          handler.next(error);
        },
      ),
    );

    // INFO: Add logging interceptor for debugging (only in debug mode)
    if (kDebugMode) {
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
      // Use standardized timeout for AI recognition operations
      final response = await _dio.post(
        _recognitionFoods,
        data: {'images_paths': imagePaths},
        options: Options(
          receiveTimeout: _aiProcessingTimeout,
          sendTimeout: _uploadTimeout,
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
          receiveTimeout: _aiProcessingTimeout,
          sendTimeout: _uploadTimeout,
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
  Future<void> assignImage(String itemName, String imagePath) async {
    try {
      await _dio.post(
        _imageAssign,
        data: {'item_name': itemName, 'image_path': imagePath},
      );
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
  /// ENDPOINT: POST /api/inventory/ingredients (for bulk ingredients)
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

  /// INFO: Add single item to inventory (general items)
  /// USAGE: Add individual item from recognition results to inventory
  /// ENDPOINT: POST /api/inventory (for general items)
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
    log('🗑️ API: Starting DELETE ingredient request');
    log('🗑️ API: Name: "$name"');
    log('🗑️ API: AddedAt: "$addedAt"');

    // Ensure proper URL encoding
    final encodedName = Uri.encodeComponent(name);
    final encodedTimestamp = Uri.encodeComponent(addedAt);
    final endpoint = '$_inventoryIngredients/$encodedName/$encodedTimestamp';

    log('🗑️ API: Encoded endpoint: $endpoint');

    try {
      final response = await _dio.delete(endpoint);
      log('🗑️ API: DELETE request successful');
      log('🗑️ API: Response status: ${response.statusCode}');
      log('🗑️ API: Response data: ${response.data}');

      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('🗑️ API: DELETE request failed: $e');
      log('🗑️ API: Error type: ${e.runtimeType}');

      if (e is DioException) {
        log('🗑️ API: DioException details:');
        log('  - Status code: ${e.response?.statusCode}');
        log('  - Response data: ${e.response?.data}');
        log('  - Message: ${e.message}');
        log('  - Request URL: ${e.requestOptions.uri}');
      }

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
    log('🗑️ API: Starting DELETE request for item: $itemId');
    log('🗑️ API: Endpoint: $_inventoryItems/$itemId');

    try {
      final response = await _dio.delete('$_inventoryItems/$itemId');
      log('🗑️ API: DELETE request successful');
      log('🗑️ API: Response status: ${response.statusCode}');
      log('🗑️ API: Response data: ${response.data}');

      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('🗑️ API: DELETE request failed: $e');
      log('🗑️ API: Error type: ${e.runtimeType}');

      if (e is DioException) {
        log('🗑️ API: DioException details:');
        log('  - Status code: ${e.response?.statusCode}');
        log('  - Response data: ${e.response?.data}');
        log('  - Message: ${e.message}');
      }

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

  /// USAGE: Add foods directly from AI recognition
  /// NEW: Specific endpoint for adding recognized foods to inventory
  Future<Map<String, dynamic>> addFoodsFromRecognition(
    List<Map<String, dynamic>> foods,
  ) async {
    try {
      final response = await _dio.post(
        _inventoryFoodsFromRecognition, // Use specific foods endpoint
        data: {'foods': foods},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Add foods from recognition error: ${e.toString()}');
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
        data: {'quantity': newQuantity},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Update ingredient quantity error: ${e.toString()}');
    }
  }

  /// INFO: Update food quantity only
  /// USAGE: Quick quantity update for specific food stack
  Future<Map<String, dynamic>> updateFoodQuantity(
    String foodName,
    String addedAt,
    double newQuantity,
  ) async {
    try {
      final encodedName = Uri.encodeComponent(foodName);
      final encodedDate = Uri.encodeComponent(addedAt);
      final response = await _dio.patch(
        '$_inventoryFoodDetail/$encodedName/$encodedDate/quantity',
        data: {'serving_quantity': newQuantity},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Update food quantity error: ${e.toString()}');
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

  /// INFO: Update expiration date for specific ingredient
  /// USAGE: Update expiration date for ingredient by name
  /// RETURNS: Updated ingredient data
  Future<Map<String, dynamic>> updateIngredientExpirationDate(
    String ingredientName,
    String newExpirationDate,
  ) async {
    try {
      final encodedName = Uri.encodeComponent(ingredientName);
      final response = await _dio.put(
        '$_inventoryIngredients/$encodedName/expiration',
        data: {'expiration_date': newExpirationDate},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Update ingredient expiration error: ${e.toString()}');
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

  /// INFO: Add single item with advanced options (PUT operation)
  /// USAGE: Add individual item with detailed configuration
  /// ENDPOINT: PUT /api/inventory/add_item (for advanced item configuration)
  Future<Map<String, dynamic>> addSingleInventoryItem({
    required String itemType,
    required Map<String, dynamic> itemData,
  }) async {
    try {
      final response = await _dio.put(
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
  /// 🚀 OPTIMIZED: Increased timeout for complex AI operations
  Future<Map<String, dynamic>> generateRecipesFromInventory() async {
    try {
      log('📡 API: Starting recipe generation from inventory...');

      // Use standardized timeout for AI recipe generation operations
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

      log('✅ API: Recipe generation successful - ${response.statusCode}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ API: Recipe generation error - $e');
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
      // Use standardized timeout for AI recipe generation operations
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

  /// INFO: Get default/curated recipes available to all users
  /// USAGE: Retrieve curated recipe collection, optionally filtered by category
  /// RETURNS: Array of default recipes with categories summary
  /// NOTE: This endpoint does NOT require authentication
  Future<Map<String, dynamic>> getDefaultRecipes({String? category}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      final response = await _dio.get(
        _recipesDefault,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get default recipes error: ${e.toString()}');
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

  /// INFO: Generate recipe based on specific ingredients list (used by inventory module)
  /// USAGE: Generate recipe with specific ingredients from inventory
  /// ENDPOINT: POST /api/recipes/generate
  /// RETURNS: Generated recipe data
  Future<Map<String, dynamic>> generateRecipe(
    List<Map<String, dynamic>> ingredients,
  ) async {
    try {
      final response = await _dio.post(
        _recipesGenerate,
        data: {'ingredients': ingredients},
        options: Options(
          receiveTimeout: _aiProcessingTimeout,
          sendTimeout: _uploadTimeout,
        ),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Generate recipe error: ${e.toString()}');
    }
  }

  // INFO: ===== MEAL PLANNING ENDPOINTS (8/8) =====
  // ADVICE: AI-powered meal planning and complete meal plan management

  /// INFO: Generate meal plan based on available ingredients
  /// ADVICE: AI analyzes your inventory and suggests optimal meal plans
  Future<Map<String, dynamic>> generateMealPlan({
    required List<Map<String, dynamic>> ingredients,
  }) async {
    try {
      // Use standardized timeout for AI meal planning operations
      final response = await _dio.post(
        _planGenerate,
        data: {'ingredients': ingredients},
        options: Options(
          receiveTimeout: _aiProcessingTimeout,
          sendTimeout: _uploadTimeout,
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

  /// INFO: Save meal plan for a specific date
  /// USAGE: Save complete meal plan with breakfast, lunch, dinner for a date
  /// RETURNS: Saved meal plan with UID and total calories
  Future<Map<String, dynamic>> saveMealPlan({
    required String date,
    required Map<String, dynamic> meals,
  }) async {
    try {
      final response = await _dio.post(
        _planningSave,
        data: {'date': date, 'meals': meals},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Save meal plan error: ${e.toString()}');
    }
  }

  /// INFO: Update existing meal plan
  /// USAGE: Update meal plan for a specific date with new meal data
  /// RETURNS: Updated meal plan with modifications
  Future<Map<String, dynamic>> updateMealPlan({
    required String date,
    required Map<String, dynamic> meals,
  }) async {
    try {
      final response = await _dio.put(
        _planningUpdate,
        data: {'date': date, 'meals': meals},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Update meal plan error: ${e.toString()}');
    }
  }

  /// INFO: Get meal plan by specific date
  /// USAGE: Retrieve meal plan for a specific date (YYYY-MM-DD format)
  /// RETURNS: Meal plan with breakfast, lunch, dinner and total calories
  Future<Map<String, dynamic>> getMealPlanByDate(String date) async {
    try {
      final response = await _dio.get(
        _planningGet,
        queryParameters: {'date': date},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get meal plan by date error: ${e.toString()}');
    }
  }

  /// INFO: Get all user's meal plans
  /// USAGE: Retrieve all meal plans created by the user
  /// RETURNS: Array of all meal plans with metadata
  Future<Map<String, dynamic>> getAllMealPlans() async {
    try {
      final response = await _dio.get(_planningAll);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get all meal plans error: ${e.toString()}');
    }
  }

  /// INFO: Get list of dates with existing meal plans
  /// USAGE: Get dates that have meal plans for calendar/navigation purposes
  /// RETURNS: Array of dates in YYYY-MM-DD format
  Future<Map<String, dynamic>> getMealPlanDates() async {
    try {
      final response = await _dio.get(_planningDates);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get meal plan dates error: ${e.toString()}');
    }
  }

  /// INFO: Delete meal plan for specific date
  /// USAGE: Remove meal plan for a specific date
  /// RETURNS: Confirmation message
  Future<Map<String, dynamic>> deleteMealPlan(String date) async {
    try {
      final response = await _dio.delete('$_planningDelete/$date');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Delete meal plan error: ${e.toString()}');
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

  // INFO: ===== ADDITIONAL RECOGNITION ENDPOINTS =====

  /// INFO: Get recognition task status by task ID
  /// USAGE: Monitor the progress of async recognition tasks
  /// RETURNS: Task status information including progress and results
  Future<Map<String, dynamic>> getRecognitionStatus(String taskId) async {
    try {
      final response = await _dio.get('$_recognitionStatus/$taskId');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get recognition status error: ${e.toString()}');
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

  // INFO: =================================================================
  // INFO: Environmental Savings API
  // INFO: =================================================================

  /// Calculates the environmental impact of a recipe from its title.
  Future<Map<String, dynamic>> calculateImpactFromTitle(String title) async {
    try {
      final response = await _dio.post(
        _envSavingsCalculateFromTitle,
        data: {'title': title},
      );
      return response.data;
    } on DioException catch (e) {
      log('Error calculating impact from title: $e');

      // Handle specific case when recipe is not found
      if (e.response?.statusCode == 404) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        if (errorData != null && errorData.containsKey('error')) {
          final errorMessage = errorData['error'] as String;
          log('🔍 Recipe not found in database: $errorMessage');
          throw Exception(
            'Esta receta no está disponible para el cálculo de impacto ambiental. Es posible que sea una receta personalizada.',
          );
        }
        throw Exception(
          'Esta receta no está disponible para el cálculo de impacto ambiental.',
        );
      }

      throw Exception(getErrorMessage(e));
    }
  }

  /// Calculates the environmental impact of a recipe from its UID.
  Future<Map<String, dynamic>> calculateImpactFromUid(String recipeUid) async {
    try {
      final response = await _dio.post(
        '$_envSavingsCalculateFromUid/$recipeUid',
      );
      return response.data;
    } on DioException catch (e) {
      log('Error calculating impact from UID: $e');
      throw Exception(getErrorMessage(e));
    }
  }

  /// Gets the complete history of environmental calculations for the user.
  Future<Map<String, dynamic>> getAllCalculations() async {
    try {
      final response = await _dio.get(_envSavingsCalculations);
      return response.data;
    } on DioException catch (e) {
      log('Error getting all calculations: $e');
      throw Exception(getErrorMessage(e));
    }
  }

  /// Filters environmental calculations by cooking status.
  Future<Map<String, dynamic>> getCalculationsByStatus(bool isCooked) async {
    try {
      final response = await _dio.get(
        _envSavingsCalculationsByStatus,
        queryParameters: {'is_cooked': isCooked},
      );
      return response.data;
    } on DioException catch (e) {
      log('Error getting calculations by status: $e');
      throw Exception(getErrorMessage(e));
    }
  }

  /// Gets the total environmental impact summary for the user.
  Future<Map<String, dynamic>> getImpactSummary() async {
    try {
      final response = await _dio.get(_envSavingsSummary);
      return response.data;
    } on DioException catch (e) {
      log('Error getting impact summary: $e');
      throw Exception(getErrorMessage(e));
    }
  }

  /// Updates the status of an environmental calculation.
  Future<Map<String, dynamic>> updateCalculationStatus(
    String recipeUid,
    bool isCooked,
  ) async {
    try {
      final response = await _dio.patch(
        '$_envSavingsUpdateCalculation/$recipeUid',
        data: {'is_cooked': isCooked},
      );
      return response.data;
    } on DioException catch (e) {
      log('Error updating calculation status: $e');
      throw Exception(getErrorMessage(e));
    }
  }

  // INFO: =================================================================
  // INFO: Helper and Error Handling
  // INFO: =================================================================

  /// INFO: Extract user-friendly error messages from API responses
  /// USAGE: Use in catch blocks to get clean, user-friendly error messages
  /// LOGS: Technical details are logged separately for debugging
  String getErrorMessage(dynamic error) {
    // Log technical details for developers
    log('🔍 Technical Error Details: $error');

    if (error is DioException) {
      // Log additional technical info
      log('🔍 DioException Type: ${error.type}');
      log('🔍 Status Code: ${error.response?.statusCode}');
      log('🔍 Response Data: ${error.response?.data}');
      log('🔍 Request Path: ${error.requestOptions.path}');

      // Check for specific server error messages first
      if (error.response?.data is Map) {
        final errorData = error.response!.data as Map<String, dynamic>;

        // Look for server-provided error message
        String? serverMessage;
        if (errorData.containsKey('error')) {
          serverMessage = errorData['error'] as String?;
        } else if (errorData.containsKey('message')) {
          serverMessage = errorData['message'] as String?;
        }

        if (serverMessage != null && serverMessage.isNotEmpty) {
          log('🔍 Server Message: $serverMessage');

          // Convert technical server messages to user-friendly ones
          if (serverMessage.toLowerCase().contains('not found') ||
              serverMessage.toLowerCase().contains('no encontr')) {
            return 'El elemento que buscas no está disponible en este momento.';
          }

          if (serverMessage.toLowerCase().contains('expired') ||
              serverMessage.toLowerCase().contains('invalid token') ||
              serverMessage.toLowerCase().contains('unauthorized')) {
            return 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.';
          }

          if (serverMessage.toLowerCase().contains('validation') ||
              serverMessage.toLowerCase().contains('invalid') ||
              serverMessage.toLowerCase().contains('required')) {
            return 'Algunos datos no son válidos. Por favor, revisa la información e intenta nuevamente.';
          }

          // If server message is already user-friendly, return it
          if (!serverMessage.contains('Exception') &&
              !serverMessage.contains('Error:') &&
              !serverMessage.contains('Stack trace') &&
              serverMessage.length < 100) {
            return serverMessage;
          }
        }
      }

      // Handle different types of connection errors
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'La conexión está tardando demasiado. Verifica tu internet e intenta nuevamente.';
        case DioExceptionType.sendTimeout:
          return 'Error al enviar datos. Verifica tu conexión e intenta nuevamente.';
        case DioExceptionType.receiveTimeout:
          return 'El servidor está tardando en responder. Intenta nuevamente en unos momentos.';
        case DioExceptionType.connectionError:
          return 'No se pudo conectar al servidor. Verifica tu conexión a internet.';
        case DioExceptionType.cancel:
          return 'La operación fue cancelada.';
        default:
          break;
      }

      // Handle HTTP status codes with user-friendly messages
      switch (error.response?.statusCode) {
        case 400:
          return 'Los datos enviados no son válidos. Por favor, revisa la información.';
        case 401:
          return 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.';
        case 403:
          return 'No tienes permisos para realizar esta acción.';
        case 404:
          return 'El contenido que buscas no está disponible en este momento.';
        case 409:
          return 'Ya existe un elemento similar. Por favor, verifica la información.';
        case 422:
          return 'Algunos datos no son correctos. Por favor, revisa la información.';
        case 429:
          return 'Has realizado demasiadas solicitudes. Por favor, espera un momento e intenta nuevamente.';
        case 500:
          return 'Ocurrió un problema en nuestros servidores. Estamos trabajando para solucionarlo.';
        case 502:
          return 'El servidor no está disponible temporalmente. Intenta nuevamente en unos minutos.';
        case 503:
          return 'El servicio no está disponible en este momento. Intenta más tarde.';
        case 504:
          return 'El servidor está tardando en responder. Intenta nuevamente.';
        default:
          return 'Ocurrió un problema de conexión. Verifica tu internet e intenta nuevamente.';
      }
    }

    // For non-DioException errors, provide a generic friendly message
    String errorString = error.toString();
    log('🔍 Non-DioException Error: $errorString');

    // Filter out technical details from generic errors
    if (errorString.contains('Exception:')) {
      errorString = errorString.replaceAll('Exception:', '').trim();
    }

    // If it still looks technical, provide a generic message
    if (errorString.contains('Stack trace') ||
        errorString.contains('dart:') ||
        errorString.contains('package:') ||
        errorString.length > 200) {
      return 'Ocurrió un problema inesperado. Por favor, intenta nuevamente.';
    }

    return errorString.isNotEmpty
        ? errorString
        : 'Ocurrió un problema inesperado. Por favor, intenta nuevamente.';
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
      sendTimeout: options.sendTimeout,
      receiveTimeout: options.receiveTimeout,
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

        // Try to recreate files - this is tricky with MultipartFile
        for (final fileEntry in originalFormData.files) {
          try {
            // Try to clone the file if possible
            final clonedFile = fileEntry.value.clone();
            newFormData.files.add(MapEntry(fileEntry.key, clonedFile));
          } catch (cloneError) {
            log('⚠️ Could not clone file ${fileEntry.key}: $cloneError');
            // If cloning fails, we can't recreate the FormData properly
            // Return null to indicate the request cannot be retried
            log('❌ Cannot retry FormData request - file already finalized');
            throw Exception('Cannot retry multipart request - file finalized');
          }
        }

        newOptions.data = newFormData;
        log('🔧 FormData recreated successfully for retry request');
      } catch (e) {
        log('❌ Failed to recreate FormData: $e');
        // For FormData requests that can't be recreated, we need to fail gracefully
        // This prevents infinite retry loops with finalized files
        throw Exception('Cannot retry request with finalized FormData: $e');
      }
    } else {
      newOptions.data = options.data;
    }

    return newOptions;
  }

  /// INFO: Start async ingredient recognition (CORRECTED)
  /// USAGE: Uploads image first, then starts async recognition with URLs
  /// RETURNS: Initial task data including task_id
  Future<Map<String, dynamic>> recognizeIngredientsAsync(File imageFile) async {
    try {
      log('🔄 Step 1: Uploading image first...');

      // Step 1: Upload the image first to get URL
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        'item_name': 'scan_${DateTime.now().millisecondsSinceEpoch}',
        'image_type': 'ingredient',
      });

      final uploadResponse = await _dio.post(
        _imageUpload,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      final imageUrl = uploadResponse.data['image']['image_path'] as String;
      log('✅ Image uploaded successfully: $imageUrl');

      // Step 2: Call async recognition with JSON and URLs
      log('🔄 Step 2: Starting async recognition with URL...');
      final asyncResponse = await _dio.post(
        _recognitionIngredientsAsync,
        data: {
          'images_paths': [imageUrl], // ✅ CORRECTED: Array of URLs in JSON
        },
        options: Options(
          headers: {
            'Content-Type':
                'application/json', // ✅ CORRECTED: JSON content type
          },
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      log('✅ Async recognition task created: ${asyncResponse.data['task_id']}');
      return asyncResponse.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Async ingredients recognition error: $e');
      throw Exception('Async ingredients recognition error: ${e.toString()}');
    }
  }

  /// INFO: Check recognition task status
  /// USAGE: Poll this endpoint with a task_id to get progress
  /// RETURNS: Task status and result when completed
  Future<Map<String, dynamic>> checkRecognitionStatus(String taskId) async {
    try {
      log('🔍 Checking status for task: $taskId');
      final response = await _dio.get('$_recognitionStatus/$taskId');

      final responseData = response.data as Map<String, dynamic>;
      final status = responseData['status'] as String?;
      final progress = responseData['progress_percentage'] as int?;

      log('📊 Status Response: $status (${progress ?? 0}%)');

      // Log when completed to see if we have image URLs
      if (status == 'completed') {
        final resultData = responseData['result_data'] as Map<String, dynamic>?;
        if (resultData != null && resultData.containsKey('ingredients')) {
          final ingredients = resultData['ingredients'] as List;
          log('🖼️ Found ${ingredients.length} ingredients with images:');
          for (int i = 0; i < ingredients.length; i++) {
            final ingredient = ingredients[i] as Map<String, dynamic>;
            final name = ingredient['name'] as String?;
            final imagePath = ingredient['image_path'] as String?;
            log('   ${i + 1}. $name: ${imagePath ?? "NO IMAGE"}');
          }
        }
      }

      return responseData;
    } catch (e) {
      log('❌ Check recognition status error: $e');
      throw Exception('Check recognition status error: ${e.toString()}');
    }
  }

  /// ✨ NEW: Simplified ingredient recognition with immediate response
  /// USAGE: Upload images first, then get immediate results with background image generation
  /// RETURNS: Complete recognition result with data and image status
  Future<Map<String, dynamic>> recognizeIngredientsSimplified(
    List<File> imageFiles,
  ) async {
    try {
      log(
        '🚀 [SIMPLIFIED] Starting recognition with ${imageFiles.length} images',
      );

      // Step 1: Upload all images first
      List<String> imageUrls = [];
      for (int i = 0; i < imageFiles.length; i++) {
        log('📤 [SIMPLIFIED] Uploading image ${i + 1}/${imageFiles.length}');

        final formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(
            imageFiles[i].path,
            filename: imageFiles[i].path.split('/').last,
          ),
          'item_name': 'scan_${DateTime.now().millisecondsSinceEpoch}_$i',
          'image_type': 'ingredient',
        });

        final uploadResponse = await _dio.post(
          _imageUpload,
          data: formData,
          options: Options(
            contentType: 'multipart/form-data',
            sendTimeout: const Duration(minutes: 2),
            receiveTimeout: const Duration(minutes: 2),
          ),
        );

        final imageUrl = uploadResponse.data['image']['image_path'] as String;
        imageUrls.add(imageUrl);
        log('✅ [SIMPLIFIED] Image ${i + 1} uploaded: $imageUrl');
      }

      // Step 2: Call simplified recognition endpoint with immediate response
      log(
        '🔄 [SIMPLIFIED] Starting recognition with ${imageUrls.length} URLs...',
      );
      final recognitionResponse = await _dio.post(
        _recognitionIngredients, // Using the simplified endpoint
        data: {'images_paths': imageUrls},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(minutes: 3),
          receiveTimeout: const Duration(minutes: 3),
        ),
      );

      log('✅ [SIMPLIFIED] Recognition completed successfully!');
      final result = recognitionResponse.data as Map<String, dynamic>;

      // Log the response structure for debugging
      log('📋 [SIMPLIFIED] Response keys: ${result.keys.toList()}');
      if (result.containsKey('ingredients')) {
        final ingredients = result['ingredients'] as List;
        log('🖼️ [SIMPLIFIED] Found ${ingredients.length} ingredients');
        for (int i = 0; i < ingredients.length; i++) {
          final ingredient = ingredients[i] as Map<String, dynamic>;
          final name = ingredient['name'] as String?;
          final imagePath = ingredient['image_path'] as String?;
          final imageStatus = ingredient['image_status'] as String?;
          log('   ${i + 1}. $name: $imagePath (status: $imageStatus)');
        }
      }

      return result;
    } catch (e) {
      log('❌ [SIMPLIFIED] Recognition error: $e');
      throw Exception('Simplified recognition error: ${e.toString()}');
    }
  }

  /// ✨ NEW: Check image generation status for a recognition
  /// USAGE: Call this periodically to check if images are ready
  /// RETURNS: Updated recognition data with current image status
  Future<Map<String, dynamic>> checkRecognitionImages(
    String recognitionId,
  ) async {
    try {
      log('🔍 [SIMPLIFIED] Checking images for recognition: $recognitionId');
      final response = await _dio.get(
        '$_recognitionById/$recognitionId/images',
      );

      final result = response.data as Map<String, dynamic>;
      log('📊 [SIMPLIFIED] Images status response received');
      log('🔍 [SIMPLIFIED] Response keys: ${result.keys.toList()}');
      log('🔍 [SIMPLIFIED] Full response: $result');

      if (result.containsKey('ingredients')) {
        final ingredients = result['ingredients'] as List;
        log('🖼️ [SIMPLIFIED] Updated ${ingredients.length} ingredients');
        int readyCount = 0;
        for (int i = 0; i < ingredients.length; i++) {
          final ingredient = ingredients[i] as Map<String, dynamic>;
          final name = ingredient['name'] as String?;
          final imagePath = ingredient['image_path'] as String?;
          final imageStatus = ingredient['image_status'] as String?;
          log('   ${i + 1}. $name:');
          log('      📷 image_path: $imagePath');
          log('      📊 image_status: $imageStatus');

          if (imageStatus == 'ready' || imageStatus == 'generated') {
            readyCount++;
          }
        }
        log('✅ [SIMPLIFIED] $readyCount/${ingredients.length} images ready');
      }

      return result;
    } catch (e) {
      log('❌ [SIMPLIFIED] Check images error: $e');
      throw Exception('Check images error: ${e.toString()}');
    }
  }

  /// ✨ NEW: Simplified food recognition with immediate response
  /// USAGE: Upload images first, then get immediate results with background image generation
  /// RETURNS: Complete recognition result with data and image status
  Future<Map<String, dynamic>> recognizeFoodsSimplified(
    List<File> imageFiles,
  ) async {
    try {
      log(
        '🚀 [SIMPLIFIED FOODS] Starting recognition with ${imageFiles.length} images',
      );

      // Step 1: Upload all images first
      List<String> imageUrls = [];
      for (int i = 0; i < imageFiles.length; i++) {
        log(
          '📤 [SIMPLIFIED FOODS] Uploading image ${i + 1}/${imageFiles.length}',
        );

        final formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(
            imageFiles[i].path,
            filename: imageFiles[i].path.split('/').last,
          ),
          'item_name': 'food_scan_${DateTime.now().millisecondsSinceEpoch}_$i',
          'image_type': 'food',
        });

        final uploadResponse = await _dio.post(
          _imageUpload,
          data: formData,
          options: Options(
            contentType: 'multipart/form-data',
            sendTimeout: const Duration(minutes: 2),
            receiveTimeout: const Duration(minutes: 2),
          ),
        );

        final imageUrl = uploadResponse.data['image']['image_path'] as String;
        imageUrls.add(imageUrl);
        log('✅ [SIMPLIFIED FOODS] Image ${i + 1} uploaded: $imageUrl');
      }

      // Step 2: Call simplified food recognition endpoint with immediate response
      log(
        '🔄 [SIMPLIFIED FOODS] Starting recognition with ${imageUrls.length} URLs...',
      );
      final recognitionResponse = await _dio.post(
        _recognitionFoods, // Using the simplified endpoint
        data: {'images_paths': imageUrls},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(minutes: 3),
          receiveTimeout: const Duration(minutes: 3),
        ),
      );

      log('✅ [SIMPLIFIED FOODS] Recognition completed successfully!');
      final result = recognitionResponse.data as Map<String, dynamic>;

      // Log the response structure for debugging
      log('📋 [SIMPLIFIED FOODS] Response keys: ${result.keys.toList()}');
      if (result.containsKey('foods')) {
        final foods = result['foods'] as List;
        log('🖼️ [SIMPLIFIED FOODS] Found ${foods.length} foods');
        for (int i = 0; i < foods.length; i++) {
          final food = foods[i] as Map<String, dynamic>;
          final name = food['name'] as String?;
          final imagePath = food['image_path'] as String?;
          final imageStatus = food['image_status'] as String?;
          log('   ${i + 1}. $name: $imagePath (status: $imageStatus)');
        }
      }

      return result;
    } catch (e) {
      log('❌ [SIMPLIFIED FOODS] Recognition error: $e');
      throw Exception('Simplified food recognition error: ${e.toString()}');
    }
  }

  /// ✨ NEW: Check food image generation status for a recognition
  /// USAGE: Call this periodically to check if food images are ready
  /// RETURNS: Updated recognition data with current image status
  Future<Map<String, dynamic>> checkFoodRecognitionImages(
    String recognitionId,
  ) async {
    try {
      log(
        '🔍 [SIMPLIFIED FOODS] Checking images for food recognition: $recognitionId',
      );
      final response = await _dio.get(
        '$_recognitionById/$recognitionId/images',
      );

      final result = response.data as Map<String, dynamic>;
      log('📊 [SIMPLIFIED FOODS] Images status response received');
      log('🔍 [SIMPLIFIED FOODS] Response keys: ${result.keys.toList()}');
      log('🔍 [SIMPLIFIED FOODS] Full response: $result');

      if (result.containsKey('foods')) {
        final foods = result['foods'] as List;
        log('🖼️ [SIMPLIFIED FOODS] Updated ${foods.length} foods');
        int readyCount = 0;
        for (int i = 0; i < foods.length; i++) {
          final food = foods[i] as Map<String, dynamic>;
          final name = food['name'] as String?;
          final imagePath = food['image_path'] as String?;
          final imageStatus = food['image_status'] as String?;
          log('   ${i + 1}. $name:');
          log('      📷 image_path: $imagePath');
          log('      📊 image_status: $imageStatus');

          if (imageStatus == 'ready' || imageStatus == 'generated') {
            readyCount++;
          }
        }
        log('✅ [SIMPLIFIED FOODS] $readyCount/${foods.length} images ready');
      }

      return result;
    } catch (e) {
      log('❌ [SIMPLIFIED FOODS] Check food images error: $e');
      throw Exception('Check food images error: ${e.toString()}');
    }
  }

  /// ✨ NEW: Get food recognition by ID with updated images
  /// USAGE: Call this to get the complete recognition data with updated images
  /// RETURNS: Complete recognition result with updated image URLs
  Future<Map<String, dynamic>> getFoodRecognitionById(
    String recognitionId,
  ) async {
    try {
      log(
        '🔍 [SIMPLIFIED FOODS] Getting food recognition by ID: $recognitionId',
      );
      final response = await _dio.get('$_recognitionById/$recognitionId');

      final result = response.data as Map<String, dynamic>;
      log('📊 [SIMPLIFIED FOODS] Recognition data received');
      log('🔍 [SIMPLIFIED FOODS] Response keys: ${result.keys.toList()}');

      if (result.containsKey('foods')) {
        final foods = result['foods'] as List;
        log(
          '🖼️ [SIMPLIFIED FOODS] Found ${foods.length} foods with updated data',
        );
        for (int i = 0; i < foods.length; i++) {
          final food = foods[i] as Map<String, dynamic>;
          final name = food['name'] as String?;
          final imagePath = food['image_path'] as String?;
          final imageStatus = food['image_status'] as String?;
          log('   ${i + 1}. $name:');
          log('      📷 image_path: $imagePath');
          log('      📊 image_status: $imageStatus');
        }
      }

      return result;
    } catch (e) {
      log('❌ [SIMPLIFIED FOODS] Get recognition by ID error: $e');
      throw Exception('Get food recognition by ID error: ${e.toString()}');
    }
  }

  /// Save recipe history entry
  Future<Map<String, dynamic>> saveRecipeHistory(
    Map<String, dynamic> historyData,
  ) async {
    try {
      final response = await _dio.post('/recipes/history', data: historyData);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get recipe history
  Future<Map<String, dynamic>> getRecipeHistory() async {
    try {
      final response = await _dio.get('/recipes/history');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Helper method to handle API errors
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final response = error.response;
      if (response != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Exception(data['message']);
        }
        return Exception('API Error: ${response.statusCode}');
      }
      return Exception('Network Error: ${error.message}');
    }
    return Exception('Unexpected Error: $error');
  }
}
