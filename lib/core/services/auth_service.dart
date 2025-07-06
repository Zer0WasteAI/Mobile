import 'dart:developer';
import 'dart:math' as math;
import 'dart:convert' as convert;
import 'dart:convert' show utf8;
import 'dart:convert' show base64Url;

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Excepción personalizada para sesiones expiradas
class SessionExpiredException implements Exception {
  final String message;
  const SessionExpiredException(this.message);
  
  @override
  String toString() => message;
}

/// Authentication service for Firebase token exchange and JWT management
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._internal();

  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Authentication endpoints
  static const String _authFirebaseSignIn = '/api/auth/firebase-signin';
  static const String _authRefresh = '/api/auth/refresh';
  static const String _authLogout = '/api/auth/logout';

  // Secure Storage Keys for JWT tokens
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  AuthService._internal() {
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

    // Add request/response interceptors for debugging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => log(obj.toString()),
      ),
    );
  }

  // ==================== TOKEN MANAGEMENT ====================

  /// Store JWT tokens securely
  Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    log('🔐 Storing JWT tokens securely...');
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    log('✅ JWT tokens stored successfully in secure storage');
  }

  /// Get access token from secure storage
  Future<String?> getAccessToken() async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    if (token != null) {
      log('🔑 Access token retrieved from secure storage');
    } else {
      log('⚠️ No access token found in secure storage');
    }
    return token;
  }

  /// Get refresh token from secure storage
  Future<String?> getRefreshToken() async {
    final token = await _secureStorage.read(key: _refreshTokenKey);
    if (token != null) {
      log('🔄 Refresh token retrieved from secure storage');
    } else {
      log('⚠️ No refresh token found in secure storage');
    }
    return token;
  }

  /// Clear all stored tokens
  Future<void> clearTokens() async {
    log('🗑️ Clearing stored JWT tokens...');
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    log('✅ JWT tokens cleared from secure storage');
  }

  /// Check if valid tokens exist
  Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  // ==================== AUTHENTICATION ENDPOINTS ====================

  /// Exchange Firebase ID Token for application JWT tokens
  Future<Map<String, dynamic>> firebaseSignIn(String firebaseIdToken) async {
    try {
      log('🔍 Initiating Firebase token exchange with backend...');

      // Debug Firebase token structure (without exposing the token)
      final tokenParts = firebaseIdToken.split('.');
      log('🔧 Firebase token has ${tokenParts.length} parts (should be 3 for JWT)');
      log('🔧 Token length: ${firebaseIdToken.length} characters');
      log('🔧 Token starts with: ${firebaseIdToken.substring(0, math.min(20, firebaseIdToken.length))}...');

      // Validate basic JWT structure
      if (tokenParts.length != 3) {
        log('❌ Invalid Firebase token structure - not a valid JWT!');
        throw Exception('Invalid Firebase token structure');
      }

      try {
        // Try to decode the header to verify it's a valid JWT
        final header = tokenParts[0];
        final headerBytes = base64Url.decode(
          header + '=' * (4 - header.length % 4),
        );
        final headerJson = utf8.decode(headerBytes);
        log('🔧 JWT Header: $headerJson');

        // Try to decode the payload to see project info
        final payload = tokenParts[1];
        final payloadBytes = base64Url.decode(
          payload + '=' * (4 - payload.length % 4),
        );
        final payloadJson = utf8.decode(payloadBytes);
        final payloadData = convert.jsonDecode(payloadJson) as Map<String, dynamic>;

        log('🔧 JWT Payload key info:');
        log('   - iss (issuer): ${payloadData['iss']}');
        log('   - aud (audience): ${payloadData['aud']}');
        log('   - sub (user ID): ${payloadData['sub']}');
        log('   - exp (expires): ${payloadData['exp']} (${DateTime.fromMillisecondsSinceEpoch((payloadData['exp'] as int) * 1000)})');
        log('   - iat (issued at): ${payloadData['iat']} (${DateTime.fromMillisecondsSinceEpoch((payloadData['iat'] as int) * 1000)})');
        if (payloadData.containsKey('firebase')) {
          log('   - firebase: ${payloadData['firebase']}');
        }
      } catch (e) {
        log('⚠️ Could not decode JWT header/payload: $e');
      }

      log('🌐 Sending request to: $_authFirebaseSignIn');
      log('🔑 Authorization header: Bearer [FIREBASE_TOKEN_${firebaseIdToken.length}_CHARS]');

      final response = await _dio.post(
        _authFirebaseSignIn,
        options: Options(headers: {'Authorization': 'Bearer $firebaseIdToken'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        log('✅ Backend response received with JWT tokens');
        log('📊 Token expires in: ${data['expires_in']} seconds');

        // Automatically store tokens for future use
        await storeTokens(
          accessToken: data['access_token'] as String,
          refreshToken: data['refresh_token'] as String,
        );
        log('🎉 Firebase token exchange completed successfully');
        return data;
      }
      log('❌ Unexpected response code: ${response.statusCode}');
      throw Exception('Firebase sign in failed with status: ${response.statusCode}');
    } catch (e) {
      log('❌ Firebase token exchange failed: ${e.toString()}');

      // If it's a DioException, log more details
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

  /// Refresh JWT tokens with automatic rotation
  Future<String?> refreshTokens() async {
    try {
      log('🔄 Initiating token refresh...');
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        log('❌ No refresh token available for refresh');
        throw SessionExpiredException('No refresh token available');
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

        // Store new tokens automatically
        await storeTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        log('🎉 Token refresh completed successfully');
        return newAccessToken;
      }
      log('❌ Token refresh failed - invalid response code: ${response.statusCode}');
      throw SessionExpiredException('Token refresh failed with status: ${response.statusCode}');
    } catch (e) {
      log('❌ Token refresh error: $e');
      
      // If it's a 401 error, both refresh and access tokens are invalid
      // This means we need a fresh Firebase ID token to get new JWT tokens
      if (e is DioException && e.response?.statusCode == 401) {
        log('🔄 JWT refresh failed - Firebase re-authentication required');
        await clearTokens();
        throw SessionExpiredException('Su sesión con el servidor ha expirado. Necesita volver a autenticarse con Firebase.');
      }
      
      // If it's already a SessionExpiredException, re-throw it
      if (e is SessionExpiredException) {
        await clearTokens();
        rethrow;
      }
      
      throw SessionExpiredException('Error al renovar la sesión: ${e.toString()}');
    }
  }

  /// Secure logout with token blacklisting
  Future<void> logout() async {
    try {
      log('🔄 Initiating secure logout...');
      final accessToken = await getAccessToken();
      
      if (accessToken != null) {
        await _dio.post(
          _authLogout,
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );
        log('✅ Logout request sent to backend');
      }
    } catch (e) {
      log('⚠️ Logout request failed: $e');
      // Continue with local cleanup even if backend request fails
    } finally {
      // Always clear local tokens
      await clearTokens();
      log('✅ Local logout completed');
    }
  }

  /// Get authorization header with current access token
  Future<Map<String, String>?> getAuthHeaders() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return null;
    
    return {'Authorization': 'Bearer $accessToken'};
  }

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated() async {
    return await hasValidTokens();
  }
}