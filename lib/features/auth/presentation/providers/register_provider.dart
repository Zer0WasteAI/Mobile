import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/auth/domain/entities/user_entity.dart';
import 'package:zer0_waste_ai/features/auth/domain/usecases/register_usecase.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/login_provider.dart';
import 'package:zer0_waste_ai/features/auth/presentation/viewmodels/register_controller.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';

class _NotPassed {
  const _NotPassed();
}

/// Register state
class RegisterState {
  /// Full name
  final String name;

  /// Email
  final String email;

  /// Password
  final String password;

  /// Confirm password
  final String confirmPassword;

  /// Name error message
  final String? nameError;

  /// Email error message
  final String? emailError;

  /// Password error message
  final String? passwordError;

  /// Confirm password error message
  final String? confirmPasswordError;

  final bool isLoading;

  /// Is form valid
  bool get isValid =>
      nameError == null &&
      emailError == null &&
      passwordError == null &&
      confirmPasswordError == null &&
      name.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty;

  /// Constructor
  const RegisterState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.nameError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.isLoading = false,
  });

  /// Copy with
  RegisterState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    Object? nameError = const _NotPassed(),
    Object? emailError = const _NotPassed(),
    Object? passwordError = const _NotPassed(),
    Object? confirmPasswordError = const _NotPassed(),
    bool? isLoading,
  }) {
    return RegisterState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      nameError:
          nameError is _NotPassed ? this.nameError : nameError as String?,
      emailError:
          emailError is _NotPassed ? this.emailError : emailError as String?,
      passwordError:
          passwordError is _NotPassed
              ? this.passwordError
              : passwordError as String?,
      confirmPasswordError:
          confirmPasswordError is _NotPassed
              ? this.confirmPasswordError
              : confirmPasswordError as String?,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Register notifier
class RegisterNotifier extends AutoDisposeAsyncNotifier<UserEntity?> {
  /// Register controller
  late final RegisterController _controller;

  /// Register state
  RegisterState _registerState = const RegisterState();

  /// Get register state
  RegisterState get registerState => _registerState;

  @override
  Future<UserEntity?> build() async {
    // Initialize controller
    _controller = ref.watch(registerControllerProvider);

    // Return null initially (no user registered)
    return null;
  }

  /// Update name
  void updateName(String name) {
    final isValid = _controller.isValidName(name);
    _registerState = _registerState.copyWith(
      name: name,
      nameError:
          isValid
              ? null
              : 'Por favor, ingresa tu nombre completo (nombre y apellido)',
    );
    ref.notifyListeners();
  }

  /// Update email
  void updateEmail(String email) {
    final isValid = _controller.isValidEmail(email);
    _registerState = _registerState.copyWith(
      email: email,
      emailError:
          isValid ? null : 'Por favor, ingresa un correo electrónico válido',
    );
    ref.notifyListeners();
  }

  /// Update password
  void updatePassword(String password) {
    final passwordError = _controller.validatePassword(password);
    final doMatch = _controller.doPasswordsMatch(
      password,
      _registerState.confirmPassword,
    );

    _registerState = _registerState.copyWith(
      password: password,
      passwordError: passwordError,
      confirmPasswordError:
          _registerState.confirmPassword.isEmpty
              ? null
              : (doMatch ? null : 'Las contraseñas no coinciden'),
    );
    ref.notifyListeners();
  }

  /// Update confirm password
  void updateConfirmPassword(String confirmPassword) {
    final doMatch = _controller.doPasswordsMatch(
      _registerState.password,
      confirmPassword,
    );
    _registerState = _registerState.copyWith(
      confirmPassword: confirmPassword,
      confirmPasswordError: doMatch ? null : 'Las contraseñas no coinciden',
    );
    ref.notifyListeners();
  }

  /// Register with email and password
  Future<void> register() async {
    if (!_registerState.isValid) return;

    state = const AsyncValue.loading();
    _registerState = _registerState.copyWith(isLoading: true);

    state = await AsyncValue.guard(() async {
      final user = await _controller.register(
        _registerState.name,
        _registerState.email,
        _registerState.password,
      );
      _registerState = _registerState.copyWith(isLoading: false);
      return user;
    });

    if (state.hasError) {
      _registerState = _registerState.copyWith(isLoading: false);
    }
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

/// Register use case provider
final registerUseCaseProvider = Provider.autoDispose<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

/// Register controller provider
final registerControllerProvider = Provider.autoDispose<RegisterController>((
  ref,
) {
  return RegisterController(
    registerUseCase: ref.watch(registerUseCaseProvider),
    googleLoginUseCase: ref.watch(googleLoginUseCaseProvider),
    facebookLoginUseCase: ref.watch(facebookLoginUseCaseProvider),
    appleLoginUseCase: ref.watch(appleLoginUseCaseProvider),
  );
});

/// Register notifier provider
final registerNotifierProvider =
    AsyncNotifierProvider.autoDispose<RegisterNotifier, UserEntity?>(() {
      return RegisterNotifier();
    });

/// Register state provider
final registerStateProvider = Provider.autoDispose<RegisterState>((ref) {
  return ref.watch(registerNotifierProvider.notifier).registerState;
});
