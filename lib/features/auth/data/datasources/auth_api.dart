import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:zer0_waste_ai/features/auth/data/models/user_model.dart';
import 'package:zer0_waste_ai/features/auth/data/models/user_preferences_model.dart';

/// Authentication API interface
abstract class AuthApi {
  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword(String email, String password);

  /// Register with email, password and name
  Future<UserModel> registerWithEmailAndPassword(
    String name,
    String email,
    String password, {
    String? phone,
  });

  /// Sign in with Google
  Future<UserModel> signInWithGoogle();

  /// Sign in with Facebook
  Future<UserModel> signInWithFacebook();

  /// Sign in with Apple
  Future<UserModel> signInWithApple();

  /// Sign out
  Future<void> signOut();

  /// Get current user
  Future<UserModel?> getCurrentUser();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /*
  /// Verify reset code
  Future<bool> verifyResetCode(String email, String code);

  /// Reset password with code
  Future<void> resetPassword(String email, String code, String newPassword);
  */
}

/// Mock implementation of AuthApi
class MockAuthApi implements AuthApi {
  /// Mock user
  final _mockUser = const UserModel(
    id: 'mock-user-id',
    email: 'user@example.com',
    displayName: 'Mock User',
    photoURL: 'https://via.placeholder.com/150',
  );

  /// Mock delay for simulating network requests
  final _delay = const Duration(milliseconds: 1500);

  /// Current user
  UserModel? _currentUser;

  /// Map of email to reset code
  final Map<String, String> _resetCodes = {};

  /// Map of email to verification attempts
  final Map<String, int> _verificationAttempts = {};

  @override
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // Simulate network delay
    await Future.delayed(_delay);

    // Validate credentials (simple validation for mock)
    if (email.isEmpty || !email.contains('@') || password.length < 6) {
      throw Exception('Invalid credentials');
    }

    // Set current user
    _currentUser = _mockUser;

    return _mockUser;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    // Simulate network delay
    await Future.delayed(_delay);

    // Set current user
    _currentUser = _mockUser.copyWith(
      id: 'google-user-id',
      displayName: 'Google User',
    );

    return _currentUser!;
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    // Simulate network delay
    await Future.delayed(_delay);

    // Set current user
    _currentUser = _mockUser.copyWith(
      id: 'facebook-user-id',
      displayName: 'Facebook User',
    );

    return _currentUser!;
  }

  @override
  Future<UserModel> signInWithApple() async {
    // Simulate network delay
    await Future.delayed(_delay);

    // Set current user
    _currentUser = _mockUser.copyWith(
      id: 'apple-user-id',
      displayName: 'Apple User',
    );

    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    // Simulate network delay
    await Future.delayed(_delay);

    // Clear current user
    _currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // Simulate network delay
    await Future.delayed(_delay);

    return _currentUser;
  }

  @override
  Future<UserModel> registerWithEmailAndPassword(
    String name,
    String email,
    String password, {
    String? phone,
  }) async {
    // Simulate network delay
    await Future.delayed(_delay);

    // Validate inputs (simple validation for mock)
    if (name.isEmpty || name.split(' ').length < 2) {
      throw Exception('Name must contain at least first and last name');
    }

    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Invalid email');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Para pruebas: Simular que algunos correos ya están registrados con proveedores sociales
    if (email.toLowerCase().contains('google')) {
      throw Exception(
        'Este correo ya está registrado con Google. '
        'Por favor, inicia sesión usando ese método.',
      );
    } else if (email.toLowerCase().contains('facebook')) {
      throw Exception(
        'Este correo ya está registrado con Facebook. '
        'Por favor, inicia sesión usando ese método.',
      );
    } else if (email.toLowerCase().contains('apple')) {
      throw Exception(
        'Este correo ya está registrado con Apple. '
        'Por favor, inicia sesión usando ese método.',
      );
    }

    // Create and set current user
    _currentUser = _mockUser.copyWith(
      id: 'registered-user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: name,
    );

    return _currentUser!;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // Simulate network delay
    await Future.delayed(_delay);

    // Simple validation
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Invalid email for password reset');
    }

    // Generate a mock reset code (e.g., 6 digits)
    final resetCode = List.generate(6, (_) => math.Random().nextInt(10)).join();
    _resetCodes[email] = resetCode;
    _verificationAttempts[email] = 0; // Reset attempts

    // In a real scenario, an email would be sent here
    if (kDebugMode) {
      print(
        'MockAuthApi: Password reset email sent to $email with code $resetCode',
      );
  }
  }

  /*
  @override
  Future<bool> verifyResetCode(String email, String code) async {
    // Simulate network delay
    await Future.delayed(_delay);

    // Check if email exists and attempts are not exhausted
    if (!_resetCodes.containsKey(email) ||
        (_verificationAttempts[email] ?? 0) >= 5) {
      if (kDebugMode) {
        print(
          'MockAuthApi: No reset code for $email or too many attempts - attempts: ${_verificationAttempts[email]}',
        );
      }
      throw Exception('Invalid or expired reset code, or too many attempts.');
    }

    // Validate code
    if (_resetCodes[email] == code) {
      if (kDebugMode) {
        print('MockAuthApi: Reset code $code for $email verified successfully.');
      }
      _verificationAttempts[email] =
          (_verificationAttempts[email] ?? 0) + 1; // Increment attempts
      return true;
    } else {
      _verificationAttempts[email] =
          (_verificationAttempts[email] ?? 0) + 1; // Increment attempts
      if (kDebugMode) {
        print(
          'MockAuthApi: Invalid reset code $code for $email. Attempt ${_verificationAttempts[email]}',
        );
    }
      return false;
    }
  }

  @override
  Future<void> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    // Simulate network delay
    await Future.delayed(_delay);

    // Validate code (in a real scenario, this might involve a server check)
    final isCodeValid = await verifyResetCode(email, code);
    if (!isCodeValid) {
      throw Exception('Invalid or expired reset code for password reset.');
    }

    // Validate new password (simple validation for mock)
    if (newPassword.length < 6) {
      throw Exception('New password must be at least 6 characters long.');
    }

    // In a real scenario, the password would be updated here
    if (kDebugMode) {
      print(
        'MockAuthApi: Password for $email reset successfully with new password: $newPassword',
      );
    }
    // Clear the reset code after successful reset
    _resetCodes.remove(email);
    _verificationAttempts.remove(email);
  }
  */
}

/// Extension methods for UserModel
extension UserModelExtension on UserModel {
  /// Create a copy of this UserModel with some fields replaced
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    String? phone,
    bool? emailVerified,
    List<String>? favoriteRecipes,
    UserPreferencesModel? prefs,
    bool? initialPreferencesCompleted,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? needsAdditionalInfo,
    String? providerId,
    String? accessToken,
    String? refreshToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phone: phone ?? this.phone,
      emailVerified: emailVerified ?? this.emailVerified,
      favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
      prefs: prefs ?? this.prefs,
      initialPreferencesCompleted:
          initialPreferencesCompleted ?? this.initialPreferencesCompleted,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      needsAdditionalInfo: needsAdditionalInfo ?? this.needsAdditionalInfo,
      providerId: providerId ?? this.providerId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
