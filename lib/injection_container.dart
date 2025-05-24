import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zer0_waste_ai/core/local_storage/hive_config.dart';
import 'package:zer0_waste_ai/core/local_storage/shared_prefs_helper.dart';
import 'package:zer0_waste_ai/core/navigation/app_router.dart';
import 'package:zer0_waste_ai/core/theme/theme.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/login_provider.dart'
    as login;
import 'package:zer0_waste_ai/features/auth/presentation/providers/register_provider.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/forgot_password_provider.dart';
import 'package:zer0_waste_ai/features/onboarding/domain/usecases/set_onboarding_seen_usecase.dart';
import 'package:zer0_waste_ai/features/onboarding/presentation/viewmodels/onboarding_controller.dart';
import 'package:zer0_waste_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:zer0_waste_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';

/// Initialize all dependencies
class DependencyInjection {
  /// Initialize all services
  static Future<ProviderContainer> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Hive
    await HiveService.init();

    // Initialize SharedPreferences
    final sharedPrefs = await SharedPreferences.getInstance();
    final sharedPrefsHelper = SharedPreferencesHelper(sharedPrefs);

    // Create ProviderContainer with overrides
    final container = ProviderContainer(
      overrides: [
        // Override the SharedPreferencesHelper provider
        sharedPrefsProvider.overrideWithValue(sharedPrefsHelper),
        // Register AuthRepository
        authRepositoryProvider.overrideWithValue(AuthRepositoryImpl()),
      ],
    );

    return container;
  }
}

/// Global providers
class AppProviders {
  /// Router provider
  static final router = routerProvider;

  /// Theme provider
  static final theme = themeProvider;

  /// Settings box provider
  static final settingsBox = settingsBoxProvider;

  /// User box provider
  static final userBox = userBoxProvider;

  /// SharedPreferences provider
  static final sharedPrefs = sharedPrefsProvider;

  /// Auth API provider
  static final authApi = login.authApiProvider;

  /// Auth repository provider
  static final authRepository = authRepositoryProvider;

  /// Login notifier provider
  static final loginNotifier = login.loginNotifierProvider;

  /// Register provider (refactored - now using combined provider)
  static final register = registerProvider;

  /// Register form provider
  static final registerForm = registerFormProvider;

  /// Register auth provider
  static final registerAuth = registerAuthProvider;

  /// Forgot password provider
  static final forgotPasswordNotifier = forgotPasswordProvider;

  /// Onboarding seen provider
  static final onboardingSeen = onboardingSeenProvider;

  /// Set onboarding seen use case provider
  static final setOnboardingSeenUseCase = setOnboardingSeenUseCaseProvider;

  /// Get onboarding seen use case provider
  static final getOnboardingSeenUseCase = getOnboardingSeenUseCaseProvider;

  /// Onboarding controller provider
  static final onboardingController = onboardingControllerProvider;
}
