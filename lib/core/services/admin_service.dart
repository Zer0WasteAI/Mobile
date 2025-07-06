import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

/// Service for admin operations and system management
class AdminService {
  static AdminService? _instance;
  static AdminService get instance => _instance ??= AdminService._internal();

  late final Dio _dio;
  final AuthService _authService = AuthService.instance;
  
  // Callback para manejar errores de sesión
  static void Function(String)? _onSessionExpired;

  // Admin endpoints
  static const String _adminUsers = '/api/admin/users';
  static const String _adminSyncImages = '/api/admin/sync_images';
  static const String _adminStats = '/api/admin/stats';
  static const String _adminHealth = '/api/admin/health';
  static const String _systemStatus = '/status';

  AdminService._internal() {
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

  // ==================== USER MANAGEMENT ====================

  /// Get all users (Admin only)
  Future<Map<String, dynamic>> getUsers({
    int? page,
    int? limit,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      log('👥 Getting users list (Admin operation)');

      final response = await _dio.get(
        _adminUsers,
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
          if (search != null) 'search': search,
          if (sortBy != null) 'sort_by': sortBy,
          if (sortOrder != null) 'sort_order': sortOrder,
        },
      );

      log('✅ Users list retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get users error: $e');
      throw Exception('Get users error: ${e.toString()}');
    }
  }

  /// Get user details by ID (Admin only)
  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      log('👤 Getting user details for ID: $userId');

      final response = await _dio.get('$_adminUsers/$userId');

      log('✅ User details retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get user by ID error: $e');
      throw Exception('Get user by ID error: ${e.toString()}');
    }
  }

  /// Update user status (Admin only)
  Future<Map<String, dynamic>> updateUserStatus(
    String userId,
    String status, // 'active', 'suspended', 'banned'
  ) async {
    try {
      log('📝 Updating user status: $userId to $status');

      final response = await _dio.put(
        '$_adminUsers/$userId/status',
        data: {'status': status},
      );

      log('✅ User status updated successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Update user status error: $e');
      throw Exception('Update user status error: ${e.toString()}');
    }
  }

  /// Delete user account (Admin only)
  Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      log('🗑️ Deleting user account: $userId');

      final response = await _dio.delete('$_adminUsers/$userId');

      log('✅ User account deleted successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Delete user error: $e');
      throw Exception('Delete user error: ${e.toString()}');
    }
  }

  // ==================== SYSTEM MANAGEMENT ====================

  /// Sync images with external sources (Admin only)
  Future<Map<String, dynamic>> syncImages() async {
    try {
      log('🔄 Starting image synchronization (Admin operation)');

      final response = await _dio.post(_adminSyncImages);

      log('✅ Image synchronization completed successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Sync images error: $e');
      throw Exception('Sync images error: ${e.toString()}');
    }
  }

  /// Get system statistics (Admin only)
  Future<Map<String, dynamic>> getSystemStats() async {
    try {
      log('📊 Getting system statistics (Admin operation)');

      final response = await _dio.get(_adminStats);

      log('✅ System statistics retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get system stats error: $e');
      throw Exception('Get system stats error: ${e.toString()}');
    }
  }

  /// Get system health status (Admin only)
  Future<Map<String, dynamic>> getSystemHealth() async {
    try {
      log('🏥 Getting system health status (Admin operation)');

      final response = await _dio.get(_adminHealth);

      log('✅ System health status retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get system health error: $e');
      throw Exception('Get system health error: ${e.toString()}');
    }
  }

  /// Get general system status (Public endpoint)
  Future<Map<String, dynamic>> getSystemStatus() async {
    try {
      log('📡 Getting system status');

      final response = await _dio.get(_systemStatus);

      log('✅ System status retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get system status error: $e');
      throw Exception('Get system status error: ${e.toString()}');
    }
  }

  // ==================== CONTENT MANAGEMENT ====================

  /// Moderate content (Admin only)
  Future<Map<String, dynamic>> moderateContent(
    String contentId,
    String contentType, // 'recipe', 'review', 'image'
    String action, // 'approve', 'reject', 'flag'
    String? reason,
  ) async {
    try {
      log('🛡️ Moderating content: $contentId ($contentType) - $action');

      final response = await _dio.post(
        '/api/admin/moderate',
        data: {
          'content_id': contentId,
          'content_type': contentType,
          'action': action,
          if (reason != null) 'reason': reason,
        },
      );

      log('✅ Content moderation completed successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Moderate content error: $e');
      throw Exception('Moderate content error: ${e.toString()}');
    }
  }

  /// Get pending content for moderation (Admin only)
  Future<Map<String, dynamic>> getPendingContent({
    String? contentType,
    int? limit,
  }) async {
    try {
      log('📋 Getting pending content for moderation');

      final response = await _dio.get(
        '/api/admin/pending-content',
        queryParameters: {
          if (contentType != null) 'content_type': contentType,
          if (limit != null) 'limit': limit,
        },
      );

      log('✅ Pending content retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get pending content error: $e');
      throw Exception('Get pending content error: ${e.toString()}');
    }
  }

  // ==================== ANALYTICS & REPORTING ====================

  /// Get user analytics (Admin only)
  Future<Map<String, dynamic>> getUserAnalytics({
    String? period, // 'daily', 'weekly', 'monthly'
    String? startDate,
    String? endDate,
  }) async {
    try {
      log('📈 Getting user analytics');

      final response = await _dio.get(
        '/api/admin/analytics/users',
        queryParameters: {
          if (period != null) 'period': period,
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        },
      );

      log('✅ User analytics retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get user analytics error: $e');
      throw Exception('Get user analytics error: ${e.toString()}');
    }
  }

  /// Get usage analytics (Admin only)
  Future<Map<String, dynamic>> getUsageAnalytics({
    String? feature, // 'recognition', 'recipes', 'inventory'
    String? period,
    String? startDate,
    String? endDate,
  }) async {
    try {
      log('📊 Getting usage analytics');

      final response = await _dio.get(
        '/api/admin/analytics/usage',
        queryParameters: {
          if (feature != null) 'feature': feature,
          if (period != null) 'period': period,
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        },
      );

      log('✅ Usage analytics retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get usage analytics error: $e');
      throw Exception('Get usage analytics error: ${e.toString()}');
    }
  }

  /// Export analytics report (Admin only)
  Future<Map<String, dynamic>> exportAnalyticsReport({
    required String reportType, // 'users', 'usage', 'content'
    String? format, // 'csv', 'json', 'pdf'
    String? startDate,
    String? endDate,
  }) async {
    try {
      log('📤 Exporting analytics report: $reportType');

      final response = await _dio.post(
        '/api/admin/analytics/export',
        data: {
          'report_type': reportType,
          if (format != null) 'format': format,
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        },
      );

      log('✅ Analytics report exported successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Export analytics report error: $e');
      throw Exception('Export analytics report error: ${e.toString()}');
    }
  }

  // ==================== SYSTEM MAINTENANCE ====================

  /// Perform system maintenance (Admin only)
  Future<Map<String, dynamic>> performMaintenance(
    String maintenanceType, // 'cleanup', 'optimize', 'backup'
  ) async {
    try {
      log('🔧 Performing system maintenance: $maintenanceType');

      final response = await _dio.post(
        '/api/admin/maintenance',
        data: {'maintenance_type': maintenanceType},
      );

      log('✅ System maintenance completed successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Perform maintenance error: $e');
      throw Exception('Perform maintenance error: ${e.toString()}');
    }
  }

  /// Clear system cache (Admin only)
  Future<Map<String, dynamic>> clearCache({String? cacheType}) async {
    try {
      log('🗑️ Clearing system cache${cacheType != null ? ': $cacheType' : ''}');

      final response = await _dio.post(
        '/api/admin/cache/clear',
        data: {
          if (cacheType != null) 'cache_type': cacheType,
        },
      );

      log('✅ System cache cleared successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Clear cache error: $e');
      throw Exception('Clear cache error: ${e.toString()}');
    }
  }

  /// Get system logs (Admin only)
  Future<Map<String, dynamic>> getSystemLogs({
    String? level, // 'error', 'warning', 'info', 'debug'
    String? startDate,
    String? endDate,
    int? limit,
  }) async {
    try {
      log('📝 Getting system logs');

      final response = await _dio.get(
        '/api/admin/logs',
        queryParameters: {
          if (level != null) 'level': level,
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
          if (limit != null) 'limit': limit,
        },
      );

      log('✅ System logs retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get system logs error: $e');
      throw Exception('Get system logs error: ${e.toString()}');
    }
  }
}