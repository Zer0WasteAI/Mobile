import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for SecureTokenService
final secureTokenServiceProvider = Provider<SecureTokenService>((ref) {
  return SecureTokenService();
});

/// Service for managing secure token storage
class SecureTokenService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Token storage keys
  static const String _accessTokenKey = 'jwt_access_token';
  static const String _refreshTokenKey = 'jwt_refresh_token';
  static const String _tokenExpirationKey = 'jwt_token_expiration';

  /// Store access and refresh tokens securely
  Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
    int? expiresIn,
  }) async {
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
      if (expiresIn != null)
        _secureStorage.write(
          key: _tokenExpirationKey,
          value:
              DateTime.now()
                  .add(Duration(seconds: expiresIn))
                  .millisecondsSinceEpoch
                  .toString(),
        ),
    ]);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// Check if access token is expired
  Future<bool> isAccessTokenExpired() async {
    final expirationString = await _secureStorage.read(
      key: _tokenExpirationKey,
    );
    if (expirationString == null) return true;

    final expiration = DateTime.fromMillisecondsSinceEpoch(
      int.parse(expirationString),
    );
    return DateTime.now().isAfter(expiration);
  }

  /// Check if tokens exist and are valid
  Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    final isExpired = await isAccessTokenExpired();

    return accessToken != null && refreshToken != null && !isExpired;
  }

  /// Clear all stored tokens
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _tokenExpirationKey),
    ]);
  }

  /// Clear all secure storage (for debugging/logout)
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }

  /// Get all stored keys (for debugging)
  Future<Map<String, String>> getAllTokens() async {
    return await _secureStorage.readAll();
  }
}
