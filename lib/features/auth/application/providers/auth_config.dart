// ignore_for_file: constant_identifier_names

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// INFO: Configuration for authentication backend
/// USAGE: Set USE_BACKEND_AUTH to true to enable real backend integration
/// ADVICE: Keep false for development/testing, true for production
class AuthConfig {
  static const bool USE_BACKEND_AUTH = true; // Set to true to use real backend
  static const bool ENABLE_GOOGLE_SIGNIN = true;

  /// INFO: Apple Sign In is automatically enabled only on iOS devices
  /// The UI will show Apple button only on iOS platform using Platform.isIOS
  static const bool ENABLE_APPLE_SIGNIN = true;
  static const bool ENABLE_FACEBOOK_SIGNIN = false; // Requires additional setup

  // INFO: Debug flags for authentication flow
  static const bool DEBUG_AUTH_FLOW = true;
  static const bool DEBUG_TOKEN_STORAGE = true;
  static const bool DEBUG_BACKEND_INTEGRATION = true;
}

/// INFO: Provider for auth configuration
/// USAGE: Use to check auth settings across the app
final authConfigProvider = Provider<AuthConfig>((ref) {
  return AuthConfig();
});
