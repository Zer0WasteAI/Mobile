import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:zer0_waste_ai/features/auth/data/models/user_model.dart';

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

  /// Verify reset code
  Future<bool> verifyResetCode(String email, String code);

  /// Reset password with code
  Future<void> resetPassword(String email, String code, String newPassword);
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

    // Validate email (simple validation for mock)
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Invalid email');
    }

    // Generate a 6-digit code
    final code =
        (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();

    // Store the code for this email
    _resetCodes[email] = code;

    // Reset verification attempts
    _verificationAttempts[email] = 0;

    // In a real implementation, this would send an email
    debugPrint('Password reset code $code sent to $email');
  }

  @override
  Future<bool> verifyResetCode(String email, String code) async {
    // Simulate network delay
    await Future.delayed(_delay);

    // Validate email
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Invalid email');
    }

    // Check if a reset code exists for this email
    if (!_resetCodes.containsKey(email)) {
      throw Exception('No reset code requested for this email');
    }

    // Increment verification attempts
    _verificationAttempts[email] = (_verificationAttempts[email] ?? 0) + 1;

    // Check if too many attempts
    if (_verificationAttempts[email]! > 3) {
      // Clear the reset code after too many attempts
      _resetCodes.remove(email);
      throw Exception('Too many verification attempts');
    }

    // Check if the code matches
    return _resetCodes[email] == code;
  }

  @override
  Future<void> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    // Simulate network delay
    await Future.delayed(_delay);

    // Validate email
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Invalid email');
    }

    // Validate new password
    if (newPassword.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Check if a reset code exists for this email
    if (!_resetCodes.containsKey(email)) {
      throw Exception('No reset code requested for this email');
    }

    // Verify the code first
    final isCodeValid = await verifyResetCode(email, code);
    if (!isCodeValid) {
      throw Exception('Invalid reset code');
    }

    // Reset successful, clear the reset code
    _resetCodes.remove(email);
    _verificationAttempts.remove(email);

    // In a real implementation, this would update the user's password
    debugPrint('Password reset successful for $email');
  }
}

/// Extension methods for UserModel
extension UserModelExtension on UserModel {
  /// Create a copy of this UserModel with some fields replaced
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
    );
  }
}
