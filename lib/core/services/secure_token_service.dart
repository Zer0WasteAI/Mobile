import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// INFO: Provider for SecureTokenService singleton
/// USAGE: Use ref.watch(secureTokenServiceProvider) to get service instance
final secureTokenServiceProvider = Provider<SecureTokenService>((ref) {
  return SecureTokenService();
});

/// INFO: Service for managing secure JWT token storage
/// ADVICE: Handles all token operations securely using encrypted storage
/// WARNING: Never store tokens in regular SharedPreferences or plain storage
class SecureTokenService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // INFO: Token storage keys for secure storage
  static const String _accessTokenKey = 'jwt_access_token';
  static const String _refreshTokenKey = 'jwt_refresh_token';
  static const String _tokenExpirationKey = 'jwt_token_expiration';

  /// INFO: Store JWT tokens securely with optional expiration
  /// USAGE: Call after successful backend authentication
  /// ADVICE: expiresIn should be in seconds (typically 3600 for 1 hour)
  Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
    int? expiresIn,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);

    if (expiresIn != null) {
      // INFO: Calculate and store expiration timestamp
      final expirationTime = DateTime.now().add(Duration(seconds: expiresIn));
      await _secureStorage.write(
        key: _tokenExpirationKey,
        value: expirationTime.millisecondsSinceEpoch.toString(),
      );
    }
  }

  /// INFO: Get stored access token
  /// RETURNS: Access token string or null if not found
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  /// INFO: Get stored refresh token
  /// RETURNS: Refresh token string or null if not found
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// INFO: Check if access token is expired
  /// RETURNS: true if token is expired or no expiration stored
  /// ADVICE: Always check this before using access token
  Future<bool> isAccessTokenExpired() async {
    final expirationString = await _secureStorage.read(
      key: _tokenExpirationKey,
    );
    if (expirationString == null) return true;

    final expirationTime = DateTime.fromMillisecondsSinceEpoch(
      int.parse(expirationString),
    );

    // INFO: Add 30 second buffer to avoid edge cases
    return DateTime.now().isAfter(
      expirationTime.subtract(Duration(seconds: 30)),
    );
  }

  /// INFO: Check if user has valid stored tokens
  /// RETURNS: true if both access and refresh tokens exist
  /// NOTE: Does not validate token expiration
  Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  /// INFO: Clear all stored tokens
  /// USAGE: Call during logout or when tokens are invalid
  /// ADVICE: Always call this when user logs out
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _tokenExpirationKey);
  }

  /// INFO: Get token expiration time
  /// RETURNS: DateTime of token expiration or null if not set
  Future<DateTime?> getTokenExpiration() async {
    final expirationString = await _secureStorage.read(
      key: _tokenExpirationKey,
    );
    if (expirationString == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(int.parse(expirationString));
  }

  /// INFO: Get time remaining until token expires
  /// RETURNS: Duration until expiration or null if no expiration set
  /// USAGE: Use to show user when they need to re-authenticate
  Future<Duration?> getTimeUntilExpiration() async {
    final expiration = await getTokenExpiration();
    if (expiration == null) return null;

    final now = DateTime.now();
    if (now.isAfter(expiration)) return Duration.zero;

    return expiration.difference(now);
  }

  /// INFO: Check if tokens need refresh (within 5 minutes of expiry)
  /// RETURNS: true if tokens should be refreshed proactively
  /// ADVICE: Use this to refresh tokens before they expire
  Future<bool> shouldRefreshTokens() async {
    final expiration = await getTokenExpiration();
    if (expiration == null) return true;

    final refreshThreshold = expiration.subtract(Duration(minutes: 5));
    return DateTime.now().isAfter(refreshThreshold);
  }
}
