import 'package:zer0_waste_ai/features/auth/domain/entities/user_entity.dart';
import 'package:zer0_waste_ai/features/auth/domain/usecases/login_usecase.dart';

/// Login controller
class LoginController {
  /// Email/password login use case
  final LoginUseCase loginUseCase;

  /// Google login use case
  final GoogleLoginUseCase googleLoginUseCase;

  /// Facebook login use case
  final FacebookLoginUseCase facebookLoginUseCase;

  /// Apple login use case
  final AppleLoginUseCase appleLoginUseCase;

  /// Constructor
  const LoginController({
    required this.loginUseCase,
    required this.googleLoginUseCase,
    required this.facebookLoginUseCase,
    required this.appleLoginUseCase,
  });

  /// Login with email and password
  Future<UserEntity> login(String email, String password) async {
    // Return a mock user for UI navigation without functionality
    return UserEntity(
      id: 'mock-user-id',
      email: email,
      displayName: 'UI Navigation User',
      photoUrl: 'https://via.placeholder.com/150',
    );
  }

  /// Login with Google
  Future<UserEntity> loginWithGoogle() async {
    // Return a mock user for UI navigation without functionality
    return UserEntity(
      id: 'google-user-id',
      email: 'google@example.com',
      displayName: 'Google User',
      photoUrl: 'https://via.placeholder.com/150',
    );
  }

  /// Login with Facebook
  Future<UserEntity> loginWithFacebook() async {
    // Return a mock user for UI navigation without functionality
    return UserEntity(
      id: 'facebook-user-id',
      email: 'facebook@example.com',
      displayName: 'Facebook User',
      photoUrl: 'https://via.placeholder.com/150',
    );
  }

  /// Login with Apple
  Future<UserEntity> loginWithApple() async {
    // Return a mock user for UI navigation without functionality
    return UserEntity(
      id: 'apple-user-id',
      email: 'apple@example.com',
      displayName: 'Apple User',
      photoUrl: 'https://via.placeholder.com/150',
    );
  }

  /// Validate email
  bool isValidEmail(String email) {
    if (email.isEmpty) return false;

    // Simple email validation regex
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  /// Validate password
  String? validatePassword(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (!RegExp(r'[A-Z]').hasMatch(password)) return 'Password must contain at least one uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(password)) return 'Password must contain at least one lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(password)) return 'Password must contain at least one number';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return 'Password must contain at least one special character';
    return null;
  }
}
