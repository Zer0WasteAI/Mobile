import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// API Service for ZeroWasteAI backend integration
class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._internal();

  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // API Endpoints
  static const String _authFirebaseSignIn = '/auth/firebase-signin';
  static const String _authRefresh = '/auth/refresh';
  static const String _authLogout = '/auth/logout';
  static const String _profileMe = '/profile/me';
  static const String _recognitionFoods = '/recognition/foods';
  static const String _recognitionIngredients = '/recognition/ingredients';
  static const String _recognitionBatch = '/recognition/batch';
  static const String _imageUpload = '/image_management/upload_image';
  static const String _imageSearchSimilar =
      '/image_management/search_similar_images';
  static const String _imageAssign = '/image_management/assign_image';

  // Reference Image Management endpoints
  static const String _referenceImageUpload = '/reference-images';
  static const String _referenceImageList = '/reference-images';
  static const String _referenceImageGet = '/reference-images';
  static const String _referenceImageDelete = '/reference-images';
  static const String _referenceImageUpdate = '/reference-images';

  // Secure Storage Keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  ApiService._internal() {
    _initializeDio();
  }

  void _initializeDio() {
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

    // Add token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip token for auth endpoints
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
          if (error.response?.statusCode == 401) {
            // Don't retry for auth endpoints
            if (error.requestOptions.path == _authRefresh ||
                error.requestOptions.path == _authFirebaseSignIn) {
              await clearTokens();
              return handler.reject(error);
            }

            try {
              final newAccessToken = await refreshTokens();
              if (newAccessToken != null) {
                // Retry original request with new token
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

    // Add logging interceptor
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

  // Token Management
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

  // Authentication
  Future<Map<String, dynamic>> firebaseSignIn(String firebaseIdToken) async {
    try {
      final response = await _dio.post(
        _authFirebaseSignIn,
        options: Options(headers: {'Authorization': 'Bearer $firebaseIdToken'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
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

  Future<void> logout() async {
    try {
      await _dio.post(_authLogout);
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await clearTokens();
    }
  }

  // Profile Management
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get(_profileMe);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Get profile error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await _dio.put(_profileMe, data: profileData);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Update profile error: ${e.toString()}');
    }
  }

  // Food Recognition
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

  // Ingredient Recognition
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

  // Batch Recognition
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

  // Image Management
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

  // Reference Image Management
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

  Future<Response> getReferenceImage(String imageId) async {
    try {
      final response = await _dio.get('$_referenceImageGet/$imageId');
      return response;
    } catch (e) {
      throw Exception('Reference image get error: ${e.toString()}');
    }
  }

  Future<Response> deleteReferenceImage(String imageId) async {
    try {
      final response = await _dio.delete('$_referenceImageDelete/$imageId');
      return response;
    } catch (e) {
      throw Exception('Reference image delete error: ${e.toString()}');
    }
  }

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

  // Utility method to handle API errors
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

  // Rate limit helper
  bool isRateLimited(DioException error) {
    return error.response?.statusCode == 429;
  }

  int? getRateLimitRetryAfter(DioException error) {
    if (error.response?.headers['retry-after'] != null) {
      return int.tryParse(error.response!.headers['retry-after']!.first);
    }
    return null;
  }
}
