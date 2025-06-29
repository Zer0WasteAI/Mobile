import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

/// Service for AI image recognition operations
class RecognitionService {
  static RecognitionService? _instance;
  static RecognitionService get instance => _instance ??= RecognitionService._internal();

  late final Dio _dio;
  final AuthService _authService = AuthService.instance;
  
  // Callback para manejar errores de sesión
  static void Function(String)? _onSessionExpired;

  // Recognition endpoints
  static const String _recognitionFoods = '/api/recognition/foods';
  static const String _recognitionIngredients = '/api/recognition/ingredients';
  static const String _recognitionIngredientsAsync = '/api/recognition/ingredients/async';
  static const String _recognitionStatus = '/api/recognition/status';
  static const String _recognitionIngredientsComplete = '/api/recognition/ingredients/complete';
  static const String _recognitionBatch = '/api/recognition/batch';
  static const String _recognitionImagesStatus = '/api/recognition/images/status';
  static const String _recognitionById = '/api/recognition/recognition';
  static const String _recognitionHistory = '/api/recognition/history';
  static const String _recognitionFeedback = '/api/recognition/feedback';

  // Timeout constants for AI operations
  static const Duration _aiProcessingTimeout = Duration(minutes: 3);
  static const Duration _uploadTimeout = Duration(minutes: 2);

  RecognitionService._internal() {
    _initializeDio();
  }
  
  /// Configurar callback para manejar errores de sesión
  static void setSessionExpiredCallback(void Function(String) callback) {
    _onSessionExpired = callback;
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
            try {
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
            } catch (refreshError) {
              log('❌ Token refresh failed in interceptor: $refreshError');
              
              // If it's a session expired error, trigger logout callback
              if (refreshError is SessionExpiredException) {
                log('🚪 Session expired - triggering logout callback');
                _onSessionExpired?.call(refreshError.message);
                
                // Still reject the request with a clear error
                handler.reject(DioException(
                  requestOptions: error.requestOptions,
                  error: refreshError,
                  type: DioExceptionType.unknown,
                ));
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

  // ==================== FOOD RECOGNITION ====================

  /// Recognize foods from multiple images
  Future<Map<String, dynamic>> recognizeFoods(List<String> imagePaths) async {
    try {
      log('🔍 Starting food recognition for ${imagePaths.length} images');
      
      final response = await _dio.post(
        _recognitionFoods,
        data: {'images_paths': imagePaths},
        options: Options(
          receiveTimeout: _aiProcessingTimeout,
          sendTimeout: _uploadTimeout,
        ),
      );
      
      log('✅ Food recognition completed successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Food recognition error: $e');
      throw Exception('Food recognition error: ${e.toString()}');
    }
  }

  /// Simplified food recognition
  Future<Map<String, dynamic>> recognizeFoodsSimplified(List<String> imagePaths) async {
    try {
      log('🔍 Starting simplified food recognition for ${imagePaths.length} images');
      
      final response = await _dio.post(
        _recognitionFoods,
        data: {'images_paths': imagePaths, 'simplified': true},
        options: Options(
          receiveTimeout: _aiProcessingTimeout,
          sendTimeout: _uploadTimeout,
        ),
      );
      
      log('✅ Simplified food recognition completed successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Simplified food recognition error: $e');
      throw Exception('Simplified food recognition error: ${e.toString()}');
    }
  }

  // ==================== INGREDIENT RECOGNITION ====================

  /// Recognize ingredients from multiple images
  Future<Map<String, dynamic>> recognizeIngredients(List<String> imagePaths) async {
    try {
      log('🔍 Starting ingredient recognition for ${imagePaths.length} images');
      
      final response = await _dio.post(
        _recognitionIngredients,
        data: {'images_paths': imagePaths},
        options: Options(
          receiveTimeout: _aiProcessingTimeout,
          sendTimeout: _uploadTimeout,
        ),
      );
      
      log('✅ Ingredient recognition completed successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Ingredient recognition error: $e');
      throw Exception('Ingredient recognition error: ${e.toString()}');
    }
  }

  /// Asynchronous ingredient recognition for large images
  Future<Map<String, dynamic>> recognizeIngredientsAsync(File imageFile) async {
    try {
      log('🔍 Starting async ingredient recognition');
      
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        _recognitionIngredientsAsync,
        data: formData,
        options: Options(
          receiveTimeout: _uploadTimeout,
          sendTimeout: _uploadTimeout,
        ),
      );
      
      log('✅ Async ingredient recognition task started');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Async ingredient recognition error: $e');
      throw Exception('Async ingredient recognition error: ${e.toString()}');
    }
  }

  /// Complete ingredient recognition with environmental impact
  Future<Map<String, dynamic>> recognizeIngredientsComplete(List<String> imagePaths) async {
    try {
      log('🔍 Starting complete ingredient recognition for ${imagePaths.length} images');
      
      final response = await _dio.post(
        _recognitionIngredientsComplete,
        data: {'images_paths': imagePaths},
        options: Options(
          receiveTimeout: _aiProcessingTimeout,
          sendTimeout: _uploadTimeout,
        ),
      );
      
      log('✅ Complete ingredient recognition finished successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Complete ingredient recognition error: $e');
      throw Exception('Complete ingredient recognition error: ${e.toString()}');
    }
  }

  /// Simplified ingredient recognition
  Future<Map<String, dynamic>> recognizeIngredientsSimplified(List<String> imagePaths) async {
    try {
      log('🔍 Starting simplified ingredient recognition for ${imagePaths.length} images');
      
      final response = await _dio.post(
        _recognitionIngredients,
        data: {'images_paths': imagePaths, 'simplified': true},
        options: Options(
          receiveTimeout: _aiProcessingTimeout,
          sendTimeout: _uploadTimeout,
        ),
      );
      
      log('✅ Simplified ingredient recognition completed successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Simplified ingredient recognition error: $e');
      throw Exception('Simplified ingredient recognition error: ${e.toString()}');
    }
  }

  // ==================== BATCH RECOGNITION ====================

  /// Batch recognition for mixed content (ingredients + foods)
  Future<Map<String, dynamic>> recognizeBatch(List<String> imagePaths) async {
    try {
      log('🔍 Starting batch recognition for ${imagePaths.length} images');
      
      final response = await _dio.post(
        _recognitionBatch,
        data: {'images_paths': imagePaths},
        options: Options(
          receiveTimeout: _aiProcessingTimeout,
          sendTimeout: _uploadTimeout,
        ),
      );
      
      log('✅ Batch recognition completed successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Batch recognition error: $e');
      throw Exception('Batch recognition error: ${e.toString()}');
    }
  }

  // ==================== STATUS CHECKING ====================

  /// Check recognition task status
  Future<Map<String, dynamic>> getRecognitionStatus(String taskId) async {
    try {
      log('🔍 Checking recognition status for task: $taskId');
      
      final response = await _dio.get('$_recognitionStatus/$taskId');
      
      log('✅ Recognition status retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Recognition status error: $e');
      throw Exception('Recognition status error: ${e.toString()}');
    }
  }

  /// Check recognition task status (alternative method)
  Future<Map<String, dynamic>> checkRecognitionStatus(String taskId) async {
    try {
      log('🔍 Checking recognition task status: $taskId');
      
      final response = await _dio.get('$_recognitionStatus/$taskId');
      
      final data = response.data as Map<String, dynamic>;
      log('📊 Task status: ${data['status']}');
      
      return data;
    } catch (e) {
      log('❌ Check recognition status error: $e');
      throw Exception('Check recognition status error: ${e.toString()}');
    }
  }

  /// Get recognition image status
  Future<Map<String, dynamic>> getRecognitionImageStatus(String taskId) async {
    try {
      log('🔍 Getting recognition image status for task: $taskId');
      
      final response = await _dio.get('$_recognitionImagesStatus/$taskId');
      
      log('✅ Recognition image status retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Recognition image status error: $e');
      throw Exception('Recognition image status error: ${e.toString()}');
    }
  }

  /// Check recognition images status
  Future<Map<String, dynamic>> checkRecognitionImages(String taskId) async {
    try {
      log('🔍 Checking recognition images for task: $taskId');
      
      final response = await _dio.get('$_recognitionImagesStatus/$taskId');
      
      final data = response.data as Map<String, dynamic>;
      log('📊 Images status: ${data['status']}');
      
      return data;
    } catch (e) {
      log('❌ Check recognition images error: $e');
      throw Exception('Check recognition images error: ${e.toString()}');
    }
  }

  /// Check food recognition images status
  Future<Map<String, dynamic>> checkFoodRecognitionImages(String taskId) async {
    try {
      log('🔍 Checking food recognition images for task: $taskId');
      
      final response = await _dio.get('$_recognitionImagesStatus/$taskId');
      
      final data = response.data as Map<String, dynamic>;
      log('📊 Food recognition images status: ${data['status']}');
      
      return data;
    } catch (e) {
      log('❌ Check food recognition images error: $e');
      throw Exception('Check food recognition images error: ${e.toString()}');
    }
  }

  // ==================== RECOGNITION DATA ====================

  /// Get recognition by ID
  Future<Map<String, dynamic>> getRecognitionById(String recognitionId) async {
    try {
      log('🔍 Getting recognition by ID: $recognitionId');
      
      final response = await _dio.get('$_recognitionById/$recognitionId');
      
      log('✅ Recognition data retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get recognition by ID error: $e');
      throw Exception('Get recognition by ID error: ${e.toString()}');
    }
  }

  /// Get food recognition by ID
  Future<Map<String, dynamic>> getFoodRecognitionById(String recognitionId) async {
    try {
      log('🔍 Getting food recognition by ID: $recognitionId');
      
      final response = await _dio.get('$_recognitionById/$recognitionId');
      
      final data = response.data as Map<String, dynamic>;
      log('✅ Food recognition data retrieved successfully');
      
      return data;
    } catch (e) {
      log('❌ Get food recognition by ID error: $e');
      throw Exception('Get food recognition by ID error: ${e.toString()}');
    }
  }

  /// Get recognition images
  Future<Map<String, dynamic>> getRecognitionImages(String taskId, {String? imageType}) async {
    try {
      log('🔍 Getting recognition images for task: $taskId');
      
      final queryParams = <String, dynamic>{'task_id': taskId};
      if (imageType != null) {
        queryParams['image_type'] = imageType;
      }
      
      final response = await _dio.get(
        _recognitionImagesStatus,
        queryParameters: queryParams,
      );
      
      log('✅ Recognition images retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get recognition images error: $e');
      throw Exception('Get recognition images error: ${e.toString()}');
    }
  }

  // ==================== HISTORY & FEEDBACK ====================

  /// Get recognition history
  Future<Map<String, dynamic>> getRecognitionHistory() async {
    try {
      log('🔍 Getting recognition history');
      
      final response = await _dio.get(_recognitionHistory);
      
      log('✅ Recognition history retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get recognition history error: $e');
      throw Exception('Get recognition history error: ${e.toString()}');
    }
  }

  /// Submit feedback on recognition results
  Future<Map<String, dynamic>> submitRecognitionFeedback({
    required String recognitionId,
    required String feedback,
  }) async {
    try {
      log('🔍 Submitting recognition feedback for ID: $recognitionId');
      
      final response = await _dio.post(
        _recognitionFeedback,
        data: {
          'recognition_id': recognitionId,
          'feedback': feedback,
        },
      );
      
      log('✅ Recognition feedback submitted successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Submit recognition feedback error: $e');
      throw Exception('Submit recognition feedback error: ${e.toString()}');
    }
  }
}