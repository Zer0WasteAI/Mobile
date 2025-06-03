import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zer0_waste_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:zer0_waste_ai/core/services/api_service.dart';

// It's generally better to have these constants in a shared location or accessed via the repository/storage service.
// For simplicity in this step, they are defined here. Consider refactoring them.
const String _accessTokenKey = 'access_token';
const String _refreshTokenKey = 'refresh_token';
const String _refreshEndpointPath = '/api/auth/refresh';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final AuthRepository _authRepository;
  final Dio _dio;
  final FirebaseAuth _firebaseAuth;
  final ApiService _apiService;

  // Track if we're already performing auto-relogin to prevent loops
  bool _isPerformingAutoRelogin = false;

  AuthInterceptor(
    this._secureStorage,
    this._authRepository,
    this._dio,
    this._firebaseAuth,
    this._apiService,
  );

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    log('🔍 AuthInterceptor: Processing request to ${options.path}');
    log('🔍 AuthInterceptor: Full URI: ${options.uri}');

    // Do not add Authorization header to the refresh token request itself
    // or to auth endpoints that don't require our app's access token (like firebase-signin)
    if (options.path == _refreshEndpointPath ||
        options.path == '/api/auth/firebase-signin' ||
        options.path == '/auth/firebase-signin') {
      log('🔓 AuthInterceptor: Skipping token injection for ${options.path}');
      return handler.next(options);
    }

    // Try to get access token
    final accessToken = await _secureStorage.read(key: _accessTokenKey);

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
      log('🔑 AuthInterceptor: JWT token injected for ${options.path}');
    } else {
      log('⚠️ AuthInterceptor: No access token found for ${options.path}');

      // If no access token, try auto-relogin before making the request
      if (!_isPerformingAutoRelogin) {
        final reloginSuccess = await _performAutoRelogin();
        if (reloginSuccess) {
          final newToken = await _secureStorage.read(key: _accessTokenKey);
          if (newToken != null) {
            options.headers['Authorization'] = 'Bearer $newToken';
            log(
              '🔑 AuthInterceptor: Auto-relogin successful, JWT token injected',
            );
          }
        }
      }
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Avoid an infinite loop if the refresh token request itself fails with 401
      if (err.requestOptions.path == _refreshEndpointPath) {
        log(
          '💥 AuthInterceptor: CRITICAL - Refresh token request failed with 401. Attempting auto-relogin...',
        );

        // Try auto-relogin as last resort
        if (!_isPerformingAutoRelogin) {
          final reloginSuccess = await _performAutoRelogin();
          if (reloginSuccess) {
            log(
              '✅ AuthInterceptor: Auto-relogin successful after refresh failure',
            );
            return await _retryOriginalRequest(err, handler);
          }
        }

        log(
          '❌ AuthInterceptor: Auto-relogin also failed - user logout required',
        );
        return handler.next(err);
      }

      log(
        '🔄 AuthInterceptor: 401 detected for ${err.requestOptions.path} - initiating token recovery...',
      );

      try {
        // Step 1: Try normal token refresh first
        log('🔄 Step 1: Attempting normal token refresh...');
        await _authRepository.refreshApplicationTokens();

        log(
          '✅ AuthInterceptor: Token refresh successful - retrying original request...',
        );
        return await _retryOriginalRequest(err, handler);
      } catch (refreshError) {
        log('❌ AuthInterceptor: Token refresh failed: $refreshError');

        // Step 2: Try auto-relogin if refresh failed
        if (!_isPerformingAutoRelogin) {
          log('🔄 Step 2: Attempting auto-relogin...');
          final reloginSuccess = await _performAutoRelogin();

          if (reloginSuccess) {
            log(
              '✅ AuthInterceptor: Auto-relogin successful - retrying original request...',
            );
            return await _retryOriginalRequest(err, handler);
          }
        }

        log('❌ AuthInterceptor: Both refresh and auto-relogin failed');
        return handler.next(err);
      }
    }
    return handler.next(err);
  }

  /// Performs automatic re-login using Firebase current user
  Future<bool> _performAutoRelogin() async {
    if (_isPerformingAutoRelogin) {
      log('⚠️ AuthInterceptor: Auto-relogin already in progress, skipping...');
      return false;
    }

    _isPerformingAutoRelogin = true;
    try {
      log('🔄 AuthInterceptor: Starting auto-relogin process...');

      // Check if Firebase user is still signed in
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        log('❌ AuthInterceptor: No Firebase user found - cannot auto-relogin');
        return false;
      }

      log('👤 AuthInterceptor: Firebase user found: ${firebaseUser.email}');

      // Get fresh Firebase ID token
      log('🔍 Getting fresh Firebase ID token...');
      final firebaseIdToken = await firebaseUser.getIdToken(
        true,
      ); // force refresh

      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        log('❌ AuthInterceptor: Failed to get Firebase ID token');
        return false;
      }

      // Exchange Firebase token for backend JWT tokens
      log('🔄 Exchanging Firebase token for backend tokens...');
      final backendResponse = await _apiService.firebaseSignIn(firebaseIdToken);

      log('✅ AuthInterceptor: Auto-relogin successful! New tokens obtained');
      return true;
    } catch (e) {
      log('❌ AuthInterceptor: Auto-relogin failed: $e');
      return false;
    } finally {
      _isPerformingAutoRelogin = false;
    }
  }

  /// Retries the original request with new token
  Future<void> _retryOriginalRequest(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Re-fetch the new access token as it's updated in secure storage
    final newAccessToken = await _secureStorage.read(key: _accessTokenKey);

    if (newAccessToken == null) {
      log(
        '💥 AuthInterceptor: CRITICAL - New access token is null after successful auth. This should not happen.',
      );
      return handler.next(err);
    }

    // Update the authorization header of the original request
    final originalRequestOptions = err.requestOptions;
    originalRequestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

    // Retry the original request with the new token
    try {
      final response = await _dio.fetch(originalRequestOptions);
      log(
        '🎉 AuthInterceptor: Original request ${originalRequestOptions.path} retried successfully with new token!',
      );
      return handler.resolve(response);
    } catch (retryError) {
      log('❌ AuthInterceptor: Retry of original request failed: $retryError');
      return handler.next(err);
    }
  }
}
