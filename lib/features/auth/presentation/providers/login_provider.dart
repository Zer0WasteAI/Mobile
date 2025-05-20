import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/auth/data/datasources/auth_api.dart';
import 'package:zer0_waste_ai/features/auth/data/models/user_model.dart';
import 'package:zer0_waste_ai/features/auth/domain/entities/user_entity.dart';
import 'package:zer0_waste_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:zer0_waste_ai/features/auth/domain/usecases/login_usecase.dart';
import 'package:zer0_waste_ai/features/auth/presentation/viewmodels/login_controller.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart'; // Importamos el provider de auth

/// Login state
class LoginState {
  /// Email
  final String email;

  /// Password
  final String password;

  /// Email error message
  final String? emailError;

  /// Password error message
  final String? passwordError;

  /// Is form valid
  bool get isValid =>
      email.isNotEmpty &&
      password.isNotEmpty &&
      emailError == null &&
      passwordError == null;

  /// Constructor
  const LoginState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
  });

  /// Copy with
  LoginState copyWith({
    String? email,
    String? password,
    Object? emailError = const _NotPassed(),
    Object? passwordError = const _NotPassed(),
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError:
          emailError is _NotPassed ? this.emailError : emailError as String?,
      passwordError:
          passwordError is _NotPassed
              ? this.passwordError
              : passwordError as String?,
    );
  }
}

class _NotPassed {
  const _NotPassed();
}

/// Login notifier
class LoginNotifier extends AutoDisposeAsyncNotifier<UserEntity?> {
  /// Login controller
  late final LoginController _controller;

  /// Login state
  LoginState _loginState = const LoginState();

  /// Get login state
  LoginState get loginState => _loginState;

  @override
  Future<UserEntity?> build() async {
    // Initialize controller
    _controller = ref.watch(loginControllerProvider);

    // Return null initially (no user logged in)
    return null;
  }

  /// Update email
  void updateEmail(String email) {
    // Create a new state with updated email and validated error message
    String? errorMessage;
    if (email.isEmpty) {
      errorMessage = 'El correo electrónico es obligatorio';
    } else if (!_controller.isValidEmail(email)) {
      errorMessage = 'Por favor, ingresa un correo electrónico válido';
    } else {
      errorMessage = null;
    }

    // Update the state with the new values
    _loginState = _loginState.copyWith(email: email, emailError: errorMessage);

    ref.notifyListeners();
  }

  /// Update password
  void updatePassword(String password) {
    // Create a new state with updated password and validated error message
    String? errorMessage;
    if (password.isEmpty) {
      errorMessage = 'La contraseña es obligatoria';
    } else {
      errorMessage = _controller.validatePassword(password);
    }

    // Update the state with the new values
    _loginState = _loginState.copyWith(
      password: password,
      passwordError: errorMessage,
    );

    ref.notifyListeners();
  }

  /// Login with email and password
  Future<void> login() async {
    if (!_loginState.isValid) return;

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      return await _controller.login(_loginState.email, _loginState.password);
    });
  }

  /// Login with Google
  Future<void> loginWithGoogle() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      return await _controller.loginWithGoogle();
    });
  }

  /// Login with Facebook
  Future<void> loginWithFacebook() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      return await _controller.loginWithFacebook();
    });
  }

  /// Login with Apple
  Future<void> loginWithApple() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      return await _controller.loginWithApple();
    });
  }
}

/// Auth API provider para desarrollo
final authApiProvider = Provider<AuthApi>((ref) {
  // Nota: Este provider está solo para desarrollo
  // En producción se debería usar la implementación real
  return MockAuthApi();
});

// No sobreescribimos authRepositoryProvider aquí
// para permitir que se use la implementación real desde injection_container.dart

/// A mock implementation of AuthRepository that uses AuthApi

class MockAuthRepository implements AuthRepository {
  final AuthApi _authApi;

  MockAuthRepository(this._authApi);

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) {
    return _authApi.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) {
    return _authApi.registerWithEmailAndPassword(displayName, email, password);
  }

  @override
  Future<UserModel> signInWithGoogle() {
    return _authApi.signInWithGoogle();
  }

  @override
  Future<UserModel> signInWithFacebook() {
    return _authApi.signInWithFacebook();
  }

  @override
  Future<UserModel> signInWithApple() {
    return _authApi.signInWithApple();
  }

  @override
  Future<void> signOut() {
    return _authApi.signOut();
  }

  @override
  UserModel? get currentUser {
    // For mock purposes, return null
    return null;
  }

  @override
  Stream<UserModel?> get authStateChanges {
    // For mock purposes, return a stream that emits once from getCurrentUser()
    return Stream.fromFuture(_authApi.getCurrentUser());
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _authApi.sendPasswordResetEmail(email);
  }

  @override
  Future<bool> verifyResetCode(String email, String code) {
    return _authApi.verifyResetCode(email, code);
  }

  @override
  Future<void> resetPassword(String email, String code, String newPassword) {
    return _authApi.resetPassword(email, code, newPassword);
  }

  @override
  Future<void> updateUserProfile({String? displayName, String? photoURL}) {
    // Not implemented in the mock
    return Future.value();
  }

  @override
  Future<void> deleteAccount() {
    // Not implemented in the mock
    return Future.value();
  }

  @override
  Future<bool> isFirstTimeUser(String userId) {
    // For mock purposes, always return true to ensure users go through onboarding
    return Future.value(true);
  }

  @override
  Future<void> markOnboardingCompleted(String userId) {
    // For mock purposes, do nothing
    return Future.value();
  }

  @override
  Future<void> sendVerificationEmail() {
    // Para propósitos de prueba, no hace nada
    return Future.value();
  }

  @override
  Future<bool> isEmailVerified() {
    // Verificar si hay un usuario autenticado antes de devolver el resultado
    final user = currentUser;
    if (user == null) {
      return Future.value(false);
    }
    // Para propósitos de desarrollo, implementar una verificación real aquí
    // En este caso estamos simulando que el usuario necesita verificar su email
    return Future.value(false);
  }

  @override
  Future<void> reloadUser() {
    // Para propósitos de prueba, no hace nada
    return Future.value();
  }

  @override
  Future<void> saveUserAllergies(List<String> allergies) {
    // For mock purposes, do nothing
    return Future.value();
  }

  @override
  Future<void> saveUserCookingLevel(String cookingLevel) {
    // For mock purposes, do nothing
    return Future.value();
  }

  @override
  Future<void> saveUserPreferredFoodTypes(List<String> foodTypes) {
    // For mock purposes, do nothing
    return Future.value();
  }

  @override
  Future<void> saveUserSpecialDiets(List<String> specialDiets) {
    // For mock purposes, do nothing
    return Future.value();
  }

  @override
  Future<void> markInitialPreferencesCompleted() {
    // For mock purposes, do nothing
    return Future.value();
  }

  @override
  Future<bool> hasCompletedInitialPreferences() {
    // For mock purposes, always return false to ensure users go through preferences setup
    return Future.value(false);
  }

  @override
  Future<void> saveUserAllergyItems(List<Map<String, dynamic>> allergyItems) {
    // For mock purposes, do nothing
    return Future.value();
  }

  @override
  Future<void> saveUserSpecialDietItems(List<Map<String, dynamic>> dietItems) {
    // For mock purposes, do nothing
    return Future.value();
  }

  @override
  Future<void> saveUserPreferredFoodTypeItems(
    List<Map<String, dynamic>> foodTypeItems,
  ) {
    // For mock purposes, do nothing
    return Future.value();
  }

  @override
  Future<UserModel> updateUserAfterAppleSignIn(
    String displayName,
    String email,
  ) {
    // For mock purposes, return a user with the provided information
    return Future.value(
      UserModel(
        id: 'apple-user-id',
        email: email,
        displayName: displayName,
        photoURL: 'https://via.placeholder.com/150',
        needsAdditionalInfo: false,
        providerId: 'apple.com',
      ),
    );
  }

  @override
  Future<UserModel?> getCurrentUserWithFirestore() {
    // Para propósitos de prueba, devolver el mismo resultado que currentUser
    return _authApi.getCurrentUser();
  }
}

/// Login use case provider
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

/// Google login use case provider
final googleLoginUseCaseProvider = Provider<GoogleLoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GoogleLoginUseCase(repository);
});

/// Facebook login use case provider
final facebookLoginUseCaseProvider = Provider<FacebookLoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return FacebookLoginUseCase(repository);
});

/// Apple login use case provider
final appleLoginUseCaseProvider = Provider<AppleLoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AppleLoginUseCase(repository);
});

/// Login controller provider
final loginControllerProvider = Provider<LoginController>((ref) {
  return LoginController(
    loginUseCase: ref.watch(loginUseCaseProvider),
    googleLoginUseCase: ref.watch(googleLoginUseCaseProvider),
    facebookLoginUseCase: ref.watch(facebookLoginUseCaseProvider),
    appleLoginUseCase: ref.watch(appleLoginUseCaseProvider),
  );
});

/// Login notifier provider
final loginNotifierProvider =
    AsyncNotifierProvider.autoDispose<LoginNotifier, UserEntity?>(() {
      return LoginNotifier();
    });

/// Login state provider
final loginStateProvider = Provider.autoDispose<LoginState>((ref) {
  return ref.watch(loginNotifierProvider.notifier).loginState;
});
