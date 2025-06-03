import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer';

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
    log('🔐 SecureTokenService: Storing JWT tokens...');
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);

    if (expiresIn != null) {
      // INFO: Calculate and store expiration timestamp
      final expirationTime = DateTime.now().add(Duration(seconds: expiresIn));
      await _secureStorage.write(
        key: _tokenExpirationKey,
        value: expirationTime.millisecondsSinceEpoch.toString(),
      );
      log('📊 Token expiration set for: ${expirationTime.toIso8601String()}');
      log(
        '⏰ Token valid for: $expiresIn seconds (${(expiresIn / 60).toStringAsFixed(1)} minutes)',
      );
    } else {
      log('⚠️ No expiration time provided for tokens');
    }
    log('✅ SecureTokenService: JWT tokens stored successfully');
  }

  /// INFO: Get stored access token
  /// RETURNS: Access token string or null if not found
  Future<String?> getAccessToken() async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    if (token != null) {
      log('🔑 SecureTokenService: Access token retrieved');

      // Check if token is expired
      final isExpired = await isAccessTokenExpired();
      if (isExpired) {
        log('⚠️ Retrieved access token is EXPIRED');
      } else {
        final timeUntilExpiry = await getTimeUntilExpiration();
        if (timeUntilExpiry != null) {
          log(
            '⏰ Access token expires in: ${timeUntilExpiry.inMinutes} minutes',
          );
        }
      }
    } else {
      log('❌ SecureTokenService: No access token found');
    }
    return token;
  }

  /// INFO: Get stored refresh token
  /// RETURNS: Refresh token string or null if not found
  Future<String?> getRefreshToken() async {
    final token = await _secureStorage.read(key: _refreshTokenKey);
    if (token != null) {
      log('🔄 SecureTokenService: Refresh token retrieved');
    } else {
      log('❌ SecureTokenService: No refresh token found');
    }
    return token;
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
    log('🔍 SecureTokenService: Checking for valid tokens...');
    final accessToken = await _secureStorage.read(key: _accessTokenKey);
    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    final hasTokens = accessToken != null && refreshToken != null;

    if (hasTokens) {
      log('✅ SecureTokenService: Valid tokens found');
      final isExpired = await isAccessTokenExpired();
      if (isExpired) {
        log('⚠️ Access token is expired - refresh needed');
      } else {
        log('🎉 Access token is still valid');
      }
    } else {
      log('❌ SecureTokenService: No valid tokens found');
    }

    return hasTokens;
  }

  /// INFO: Clear all stored tokens
  /// USAGE: Call during logout or when tokens are invalid
  /// ADVICE: Always call this when user logs out
  Future<void> clearTokens() async {
    log('🗑️ SecureTokenService: Clearing all stored tokens...');
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _tokenExpirationKey);
    log('✅ SecureTokenService: All tokens cleared successfully');
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
    log('🔍 SecureTokenService: Checking if tokens need refresh...');
    final expiration = await getTokenExpiration();
    if (expiration == null) {
      log('⚠️ No expiration time found - refresh recommended');
      return true;
    }

    final refreshThreshold = expiration.subtract(Duration(minutes: 5));
    final shouldRefresh = DateTime.now().isAfter(refreshThreshold);

    if (shouldRefresh) {
      final timeRemaining = expiration.difference(DateTime.now());
      log(
        '🔄 Token refresh needed - expires in ${timeRemaining.inMinutes} minutes',
      );
    } else {
      final timeUntilRefresh = refreshThreshold.difference(DateTime.now());
      log('⏰ Next refresh check in ${timeUntilRefresh.inMinutes} minutes');
    }

    return shouldRefresh;
  }
}
