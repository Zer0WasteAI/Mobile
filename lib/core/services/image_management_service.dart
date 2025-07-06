import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

/// Service for image upload and management operations
class ImageManagementService {
  static ImageManagementService? _instance;
  static ImageManagementService get instance => _instance ??= ImageManagementService._internal();

  late final Dio _dio;
  final AuthService _authService = AuthService.instance;
  
  // Callback para manejar errores de sesión
  static void Function(String)? _onSessionExpired;

  // Image management endpoints
  static const String _imageUpload = '/api/image_management/upload_image';
  static const String _imageSearchSimilar = '/api/image_management/search_similar_images';
  static const String _imageAssign = '/api/image_management/assign_image';
  static const String _imageStatus = '/api/images/status';

  // Reference image management endpoints
  static const String _referenceImageUpload = '/api/reference-images';
  static const String _referenceImageList = '/api/reference-images';
  static const String _referenceImageGet = '/api/reference-images';
  static const String _referenceImageDelete = '/api/reference-images';
  static const String _referenceImageUpdate = '/api/reference-images';

  // Upload timeout
  static const Duration _uploadTimeout = Duration(minutes: 2);

  ImageManagementService._internal() {
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

  // ==================== IMAGE UPLOAD ====================

  /// Upload image with retry logic for authentication
  Future<Map<String, dynamic>> uploadImage({
    required File imageFile,
    required String itemName,
    required String imageType, // "food", "ingredient", "default"
    Map<String, dynamic>? metadata,
  }) async {
    int retryCount = 0;
    const maxRetries = 2;

    while (retryCount <= maxRetries) {
      try {
        log('📸 Uploading image: $itemName (type: $imageType, attempt: ${retryCount + 1})');

        // Create fresh FormData for each attempt to avoid "already finalized" errors
        final formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
          'item_name': itemName,
          'image_type': imageType,
          if (metadata != null) ...metadata,
        });

        final response = await _dio.post(
          _imageUpload,
          data: formData,
          options: Options(
            headers: {'Content-Type': 'multipart/form-data'},
            sendTimeout: _uploadTimeout,
            receiveTimeout: _uploadTimeout,
          ),
        );

        log('✅ Image upload successful');
        return response.data as Map<String, dynamic>;
      } on DioException catch (e) {
        // Handle 401 errors specifically for this upload
        if (e.response?.statusCode == 401 && retryCount < maxRetries) {
          log('🔄 Upload failed with 401, attempting token refresh... (attempt ${retryCount + 1}/$maxRetries)');

          try {
            // Try normal token refresh
            final newAccessToken = await _authService.refreshTokens();
            if (newAccessToken != null) {
              log('✅ Token refresh successful, retrying upload...');
              retryCount++;
              continue; // Retry with new token
            }
          } catch (refreshError) {
            log('❌ Token refresh failed: $refreshError');
          }

          log('❌ Token refresh failed for upload');
          await _authService.clearTokens();
        }

        // Re-throw the exception if not a 401 or if retries exhausted
        log('❌ Image upload error: ${e.toString()}');
        throw Exception('Image upload error: ${e.toString()}');
      } catch (e) {
        log('❌ Image upload error: $e');
        throw Exception('Image upload error: ${e.toString()}');
      }
    }

    throw Exception('Image upload failed after $maxRetries retries');
  }

  /// Upload multiple images
  Future<List<Map<String, dynamic>>> uploadMultipleImages({
    required List<File> imageFiles,
    required String itemName,
    required String imageType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      log('📸 Uploading ${imageFiles.length} images for: $itemName');

      final results = <Map<String, dynamic>>[];
      
      for (int i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        try {
          final result = await uploadImage(
            imageFile: file,
            itemName: '${itemName}_${i + 1}',
            imageType: imageType,
            metadata: metadata,
          );
          results.add(result);
        } catch (e) {
          log('⚠️ Failed to upload image ${i + 1}: $e');
          results.add({'error': e.toString(), 'index': i});
        }
      }

      log('✅ Multiple image upload completed: ${results.length} results');
      return results;
    } catch (e) {
      log('❌ Upload multiple images error: $e');
      throw Exception('Upload multiple images error: ${e.toString()}');
    }
  }

  // ==================== IMAGE SEARCH ====================

  /// Search for similar images by item name
  Future<List<Map<String, dynamic>>> searchSimilarImages(String itemName) async {
    try {
      log('🔍 Searching similar images for: $itemName');

      final response = await _dio.post(
        _imageSearchSimilar,
        data: {'item_name': itemName},
      );

      log('✅ Similar images search completed');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      log('❌ Search similar images error: $e');
      throw Exception('Search similar images error: ${e.toString()}');
    }
  }

  /// Search images with filters
  Future<List<Map<String, dynamic>>> searchImagesWithFilters({
    required String query,
    String? imageType,
    String? category,
    int? limit,
  }) async {
    try {
      log('🔍 Searching images with filters: $query');

      final response = await _dio.post(
        _imageSearchSimilar,
        data: {
          'item_name': query,
          if (imageType != null) 'image_type': imageType,
          if (category != null) 'category': category,
          if (limit != null) 'limit': limit,
        },
      );

      log('✅ Filtered image search completed');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      log('❌ Search images with filters error: $e');
      throw Exception('Search images with filters error: ${e.toString()}');
    }
  }

  // ==================== IMAGE ASSIGNMENT ====================

  /// Assign reference image to an item
  Future<void> assignImage(String itemName, String imagePath) async {
    try {
      log('🔗 Assigning image to item: $itemName');

      await _dio.post(
        _imageAssign,
        data: {
          'item_name': itemName,
          'image_path': imagePath,
        },
      );

      log('✅ Image assignment successful');
    } catch (e) {
      log('❌ Assign image error: $e');
      throw Exception('Assign image error: ${e.toString()}');
    }
  }

  /// Assign multiple images to an item
  Future<void> assignMultipleImages(String itemName, List<String> imagePaths) async {
    try {
      log('🔗 Assigning ${imagePaths.length} images to item: $itemName');

      await _dio.post(
        _imageAssign,
        data: {
          'item_name': itemName,
          'image_paths': imagePaths,
        },
      );

      log('✅ Multiple image assignment successful');
    } catch (e) {
      log('❌ Assign multiple images error: $e');
      throw Exception('Assign multiple images error: ${e.toString()}');
    }
  }

  // ==================== IMAGE STATUS ====================

  /// Check image processing status
  Future<Map<String, dynamic>> getImageStatus(String? taskId) async {
    try {
      log('📊 Getting image status${taskId != null ? ' for task: $taskId' : ''}');

      final url = taskId != null ? '$_imageStatus/$taskId' : _imageStatus;
      final response = await _dio.get(url);

      log('✅ Image status retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get image status error: $e');
      throw Exception('Get image status error: ${e.toString()}');
    }
  }

  /// Check multiple image statuses
  Future<Map<String, dynamic>> getMultipleImageStatuses(List<String> taskIds) async {
    try {
      log('📊 Getting status for ${taskIds.length} image tasks');

      final results = <String, Map<String, dynamic>>{};
      
      for (final taskId in taskIds) {
        try {
          final status = await getImageStatus(taskId);
          results[taskId] = status;
        } catch (e) {
          log('⚠️ Failed to get status for task: $taskId - $e');
          results[taskId] = {'error': e.toString()};
        }
      }

      log('✅ Multiple image statuses retrieved');
      return {'results': results, 'total_processed': taskIds.length};
    } catch (e) {
      log('❌ Get multiple image statuses error: $e');
      throw Exception('Get multiple image statuses error: ${e.toString()}');
    }
  }

  // ==================== REFERENCE IMAGE MANAGEMENT ====================

  /// Upload reference image for AI training (Admin only)
  Future<Response> uploadReferenceImage(FormData formData) async {
    try {
      log('📸 Uploading reference image (admin operation)');

      final response = await _dio.post(
        _referenceImageUpload,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: _uploadTimeout,
          receiveTimeout: _uploadTimeout,
        ),
      );

      log('✅ Reference image upload successful');
      return response;
    } catch (e) {
      log('❌ Reference image upload error: $e');
      throw Exception('Reference image upload error: ${e.toString()}');
    }
  }

  /// Get list of reference images
  Future<Response> getReferenceImages({
    int? page,
    int? limit,
    String? category,
    String? imageType,
  }) async {
    try {
      log('📚 Getting reference images list');

      final response = await _dio.get(
        _referenceImageList,
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
          if (category != null) 'category': category,
          if (imageType != null) 'image_type': imageType,
        },
      );

      log('✅ Reference images list retrieved successfully');
      return response;
    } catch (e) {
      log('❌ Get reference images error: $e');
      throw Exception('Get reference images error: ${e.toString()}');
    }
  }

  /// Get specific reference image
  Future<Response> getReferenceImage(String imageId) async {
    try {
      log('🔍 Getting reference image: $imageId');

      final response = await _dio.get('$_referenceImageGet/$imageId');

      log('✅ Reference image retrieved successfully');
      return response;
    } catch (e) {
      log('❌ Get reference image error: $e');
      throw Exception('Get reference image error: ${e.toString()}');
    }
  }

  /// Delete reference image
  Future<Response> deleteReferenceImage(String imageId) async {
    try {
      log('🗑️ Deleting reference image: $imageId');

      final response = await _dio.delete('$_referenceImageDelete/$imageId');

      log('✅ Reference image deleted successfully');
      return response;
    } catch (e) {
      log('❌ Delete reference image error: $e');
      throw Exception('Delete reference image error: ${e.toString()}');
    }
  }

  /// Update reference image metadata
  Future<Response> updateReferenceImage(
    String imageId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      log('📝 Updating reference image: $imageId');

      final response = await _dio.put(
        '$_referenceImageUpdate/$imageId',
        data: updateData,
      );

      log('✅ Reference image updated successfully');
      return response;
    } catch (e) {
      log('❌ Update reference image error: $e');
      throw Exception('Update reference image error: ${e.toString()}');
    }
  }

  // ==================== HELPER METHODS ====================

  /// Validate image file
  bool validateImageFile(File imageFile) {
    // Check file exists
    if (!imageFile.existsSync()) {
      return false;
    }

    // Check file size (max 10MB)
    final fileSizeInMB = imageFile.lengthSync() / (1024 * 1024);
    if (fileSizeInMB > 10) {
      return false;
    }

    // Check file extension
    final extension = imageFile.path.split('.').last.toLowerCase();
    const allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
    
    return allowedExtensions.contains(extension);
  }

  /// Get file size in MB
  double getFileSizeInMB(File file) {
    return file.lengthSync() / (1024 * 1024);
  }

  /// Get file extension
  String getFileExtension(File file) {
    return file.path.split('.').last.toLowerCase();
  }
}