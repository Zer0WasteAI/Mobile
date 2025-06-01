import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zer0_waste_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:zer0_waste_ai/injection_container.dart'; // For flutterSecureStorageProvider

// It's generally better to have these constants in a shared location or accessed via the repository/storage service.
// For simplicity in this step, they are defined here. Consider refactoring them.
const String _accessTokenKey = 'access_token';
const String _refreshTokenKey =
    'refresh_token'; // Not directly used in this interceptor but good to be aware of
const String _refreshEndpointPath =
    '/api/auth/refresh'; // Path for the refresh token endpoint

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final AuthRepository
  _authRepository; // Changed from Ref to direct AuthRepository
  final Dio _dio; // Dio instance to retry requests

  AuthInterceptor(this._secureStorage, this._authRepository, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Do not add Authorization header to the refresh token request itself
    // or to auth endpoints that don't require our app's access token (like firebase-signin)
    if (options.path == _refreshEndpointPath ||
        options.path == '/api/auth/firebase-signin') {
      print('AuthInterceptor: Skipping token for ${options.path}');
      return handler.next(options);
    }

    final accessToken = await _secureStorage.read(key: _accessTokenKey);

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
      print('AuthInterceptor: Token added for ${options.path}');
    } else {
      print('AuthInterceptor: No access token found for ${options.path}');
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Avoid an infinite loop if the refresh token request itself fails with 401
      if (err.requestOptions.path == _refreshEndpointPath) {
        print(
          'AuthInterceptor: Refresh token request failed with 401. Critical error / Logout needed.',
        );
        // Here you should typically trigger a global logout event/state change.
        // For now, we pass the error to prevent loops.
        return handler.next(err);
      }

      print(
        'AuthInterceptor: Access token likely expired (401). Attempting to refresh for ${err.requestOptions.path}',
      );

      try {
        // Use the injected _authRepository directly
        await _authRepository.refreshApplicationTokens();

        print(
          'AuthInterceptor: Tokens refreshed successfully. Retrying original request to ${err.requestOptions.path}',
        );

        // Re-fetch the new access token as it's updated in secure storage
        final newAccessToken = await _secureStorage.read(key: _accessTokenKey);

        if (newAccessToken == null) {
          print(
            'AuthInterceptor: New access token is null after refresh. This should not happen.',
          );
          // Trigger logout or handle as critical failure
          return handler.next(err); // Pass original error
        }

        // Update the authorization header of the original request
        final originalRequestOptions = err.requestOptions;
        originalRequestOptions.headers['Authorization'] =
            'Bearer $newAccessToken';

        // Retry the original request with the new token
        // Use the original _dio instance to ensure all interceptors are applied (e.g., logging)
        final response = await _dio.fetch(originalRequestOptions);
        print(
          'AuthInterceptor: Original request retried successfully with new token.',
        );
        return handler.resolve(response);
      } catch (e) {
        print(
          'AuthInterceptor: Exception during token refresh or retry process: $e',
        );
        // Pass original error if refresh process itself throws an exception
        return handler.next(err);
      }
    }
    return handler.next(err);
  }
}
