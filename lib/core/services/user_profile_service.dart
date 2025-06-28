import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

/// Service for user profile operations
class UserProfileService {
  static UserProfileService? _instance;
  static UserProfileService get instance => _instance ??= UserProfileService._internal();

  late final Dio _dio;
  final AuthService _authService = AuthService.instance;

  // User profile endpoints
  static const String _userProfile = '/api/user/profile';

  UserProfileService._internal() {
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

  // ==================== PROFILE OPERATIONS ====================

  /// Get user profile information
  Future<Map<String, dynamic>> getProfile() async {
    try {
      log('👤 Getting user profile');

      final response = await _dio.get(_userProfile);

      log('✅ User profile retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get profile error: $e');
      throw Exception('Get profile error: ${e.toString()}');
    }
  }

  /// Update user profile information
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      log('📝 Updating user profile');

      final response = await _dio.put(_userProfile, data: profileData);

      log('✅ User profile updated successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Update profile error: $e');
      throw Exception('Update profile error: ${e.toString()}');
    }
  }

  /// Update specific profile field
  Future<Map<String, dynamic>> updateProfileField(String field, dynamic value) async {
    try {
      log('📝 Updating profile field: $field');

      final response = await _dio.patch(
        _userProfile,
        data: {field: value},
      );

      log('✅ Profile field updated successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Update profile field error: $e');
      throw Exception('Update profile field error: ${e.toString()}');
    }
  }

  /// Update user preferences
  Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> preferences) async {
    try {
      log('⚙️ Updating user preferences');

      final response = await _dio.put(
        '$_userProfile/preferences',
        data: preferences,
      );

      log('✅ User preferences updated successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Update preferences error: $e');
      throw Exception('Update preferences error: ${e.toString()}');
    }
  }

  /// Update user dietary restrictions
  Future<Map<String, dynamic>> updateDietaryRestrictions(List<String> restrictions) async {
    try {
      log('🥗 Updating dietary restrictions');

      final response = await _dio.put(
        '$_userProfile/dietary-restrictions',
        data: {'dietary_restrictions': restrictions},
      );

      log('✅ Dietary restrictions updated successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Update dietary restrictions error: $e');
      throw Exception('Update dietary restrictions error: ${e.toString()}');
    }
  }

  /// Update cooking level
  Future<Map<String, dynamic>> updateCookingLevel(String level) async {
    try {
      log('👨‍🍳 Updating cooking level: $level');

      final response = await _dio.put(
        '$_userProfile/cooking-level',
        data: {'cooking_level': level},
      );

      log('✅ Cooking level updated successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Update cooking level error: $e');
      throw Exception('Update cooking level error: ${e.toString()}');
    }
  }

  /// Update profile picture
  Future<Map<String, dynamic>> updateProfilePicture(String imageUrl) async {
    try {
      log('📸 Updating profile picture');

      final response = await _dio.put(
        '$_userProfile/picture',
        data: {'profile_picture': imageUrl},
      );

      log('✅ Profile picture updated successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Update profile picture error: $e');
      throw Exception('Update profile picture error: ${e.toString()}');
    }
  }

  // ==================== PROFILE STATISTICS ====================

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      log('📊 Getting user statistics');

      final response = await _dio.get('$_userProfile/statistics');

      log('✅ User statistics retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get user statistics error: $e');
      throw Exception('Get user statistics error: ${e.toString()}');
    }
  }

  /// Get user activity summary
  Future<Map<String, dynamic>> getActivitySummary() async {
    try {
      log('📈 Getting user activity summary');

      final response = await _dio.get('$_userProfile/activity');

      log('✅ User activity summary retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get activity summary error: $e');
      throw Exception('Get activity summary error: ${e.toString()}');
    }
  }

  /// Get user achievements
  Future<Map<String, dynamic>> getUserAchievements() async {
    try {
      log('🏆 Getting user achievements');

      final response = await _dio.get('$_userProfile/achievements');

      log('✅ User achievements retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get user achievements error: $e');
      throw Exception('Get user achievements error: ${e.toString()}');
    }
  }

  // ==================== ACCOUNT MANAGEMENT ====================

  /// Delete user account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      log('🗑️ Deleting user account');

      final response = await _dio.delete(_userProfile);

      log('✅ User account deleted successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Delete account error: $e');
      throw Exception('Delete account error: ${e.toString()}');
    }
  }

  /// Export user data
  Future<Map<String, dynamic>> exportUserData() async {
    try {
      log('📤 Exporting user data');

      final response = await _dio.get('$_userProfile/export');

      log('✅ User data exported successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Export user data error: $e');
      throw Exception('Export user data error: ${e.toString()}');
    }
  }

  /// Request data deletion (GDPR compliance)
  Future<Map<String, dynamic>> requestDataDeletion() async {
    try {
      log('🔒 Requesting data deletion (GDPR)');

      final response = await _dio.post('$_userProfile/delete-request');

      log('✅ Data deletion request submitted successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Request data deletion error: $e');
      throw Exception('Request data deletion error: ${e.toString()}');
    }
  }

  // ==================== PRIVACY SETTINGS ====================

  /// Update privacy settings
  Future<Map<String, dynamic>> updatePrivacySettings(Map<String, dynamic> settings) async {
    try {
      log('🔒 Updating privacy settings');

      final response = await _dio.put(
        '$_userProfile/privacy',
        data: settings,
      );

      log('✅ Privacy settings updated successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Update privacy settings error: $e');
      throw Exception('Update privacy settings error: ${e.toString()}');
    }
  }

  /// Get privacy settings
  Future<Map<String, dynamic>> getPrivacySettings() async {
    try {
      log('🔒 Getting privacy settings');

      final response = await _dio.get('$_userProfile/privacy');

      log('✅ Privacy settings retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get privacy settings error: $e');
      throw Exception('Get privacy settings error: ${e.toString()}');
    }
  }

  // ==================== NOTIFICATION PREFERENCES ====================

  /// Update notification preferences
  Future<Map<String, dynamic>> updateNotificationPreferences(Map<String, dynamic> preferences) async {
    try {
      log('🔔 Updating notification preferences');

      final response = await _dio.put(
        '$_userProfile/notifications',
        data: preferences,
      );

      log('✅ Notification preferences updated successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Update notification preferences error: $e');
      throw Exception('Update notification preferences error: ${e.toString()}');
    }
  }

  /// Get notification preferences
  Future<Map<String, dynamic>> getNotificationPreferences() async {
    try {
      log('🔔 Getting notification preferences');

      final response = await _dio.get('$_userProfile/notifications');

      log('✅ Notification preferences retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get notification preferences error: $e');
      throw Exception('Get notification preferences error: ${e.toString()}');
    }
  }
}