// ignore_for_file: unused_local_variable

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zer0_waste_ai/core/local_storage/hive_config.dart';
import 'package:zer0_waste_ai/core/local_storage/shared_prefs_helper.dart';
import 'package:zer0_waste_ai/core/navigation/app_router.dart';
import 'package:zer0_waste_ai/core/network/auth_interceptor.dart';
import 'package:zer0_waste_ai/core/theme/theme.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/login_provider.dart'
    as login;
import 'package:zer0_waste_ai/features/auth/presentation/providers/forgot_password_provider.dart';
import 'package:zer0_waste_ai/features/onboarding/domain/usecases/set_onboarding_seen_usecase.dart';
import 'package:zer0_waste_ai/features/onboarding/presentation/viewmodels/onboarding_controller.dart';
import 'package:zer0_waste_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zer0_waste_ai/core/services/api_service.dart';

// Provider for FlutterSecureStorage
final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Provider for Dio
final dioProvider = Provider<Dio>((ref) {
  final baseUrl =
      dotenv.env['BACKEND_BASE_URL'] ?? 'YOUR_FALLBACK_URL_IN_DIO_PROVIDER';
  if (baseUrl == 'YOUR_FALLBACK_URL_IN_DIO_PROVIDER') {
    // Consider logging a warning or throwing an error if the URL is critical
    log(
      "WARNING: BACKEND_BASE_URL not found in .env, using fallback in dioProvider.",
    );
  }
  final options = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10), // Example timeout
    receiveTimeout: const Duration(seconds: 10), // Example timeout
  );
  final dio = Dio(options);

  // Read dependencies for AuthInterceptor
  // Important: This creates a circular dependency if AuthRepository itself depends on Dio through this provider.
  // We need to be careful. AuthRepositoryImpl takes Dio instance, so it's okay for AuthRepository
  // provider to be read here IF AuthInterceptor needs AuthRepository for refresh logic.
  // However, the interceptor itself is being added to the Dio instance that AuthRepository will use.

  // To break potential cycle for initial setup or simplify:
  // One way is to pass callbacks or ensure dependencies are resolved carefully.
  // AuthInterceptor now takes AuthRepository and FlutterSecureStorage directly.
  // These will be resolved when dioProvider is first read.

  // Resolve dependencies for the interceptor:
  final secureStorage = ref.watch(flutterSecureStorageProvider);
  // The AuthRepository itself needs Dio. To avoid circular dependency (Dio -> Interceptor -> AuthRepo -> Dio),
  // AuthInterceptor should not try to resolve AuthRepository using ref.watch if AuthRepositoryProvider depends on this dioProvider.
  // This was addressed by making AuthInterceptor accept AuthRepository directly in its constructor.
  // The AuthRepository will be the one from the main container, which is configured with this Dio instance.

  // It's better to instantiate AuthInterceptor outside the dioProvider if it needs ref.read/watch for AuthRepository.
  // Let's assume AuthInterceptor is constructed when Dio is created, and its dependencies are passed then.

  // The instantiation of AuthInterceptor will be done in init and Dio instance passed to it.
  // This dioProvider will provide the Dio instance, and the interceptor will be added in init.
  // OR, we can do it here if we ensure correct dependency flow.

  // For the interceptor to use the *same* Dio instance for retries, it needs a Dio instance.
  // It seems we are passing _dio to AuthInterceptor now.

  // The below setup is problematic if authRepositoryProvider itself is building an AuthRepositoryImpl
  // that tries to read this dioProvider. We resolved AuthRepositoryImpl manually in init.
  // final authRepository = ref.watch(authRepositoryProvider);
  // dio.interceptors.add(AuthInterceptor(secureStorage, authRepository, dio));

  // The interceptor must be added *after* the container setup in init is complete
  // or the AuthRepository needs to be passed differently.
  // For now, the interceptor will be added in init after AuthRepository is created.

  // The interceptor must be added *after* the container setup in init is complete
  // or the AuthRepository needs to be passed differently.
  // For now, the interceptor will be added in init after AuthRepository is created.

  return dio;
});

/// Initialize all dependencies
class DependencyInjection {
  /// Initialize all services
  static Future<ProviderContainer> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Ensure .env is loaded (it should be loaded in main.dart already, but good for safety)
    // await dotenv.load(fileName: ".env"); // Already in main.dart

    // Initialize Hive
    await HiveService.init();

    // Initialize SharedPreferences
    final sharedPrefs = await SharedPreferences.getInstance();
    final sharedPrefsHelper = SharedPreferencesHelper(sharedPrefs);

    // Create an instance of FlutterSecureStorage
    const secureStorage = FlutterSecureStorage();

    // Temporary container to resolve initial dependencies for Dio and AuthRepository
    final tempOverrides = [
      flutterSecureStorageProvider.overrideWithValue(secureStorage),
      // We can't add dioProvider here if it tries to read authRepositoryProvider which isn't set yet.
    ];
    // If dioProvider needs to read authRepositoryProvider, we have a circular setup.
    // The interceptor needs authRepository, and authRepository needs dio (with the interceptor).

    // Let's create dependencies sequentially.
    // 1. Secure Storage (already done)
    // 2. Dio instance (without interceptor first)
    final baseUrl =
        dotenv.env['BACKEND_BASE_URL'] ?? 'YOUR_FALLBACK_URL_IN_DIO_PROVIDER';
    final baseDio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // 3. AuthRepository (uses ApiService internally, so we don't need to pass dio and secureStorage directly)
    final authRepository = AuthRepositoryImpl();

    // 4. Now create and add the AuthInterceptor to the Dio instance
    // The interceptor needs the same Dio instance to make .fetch() calls that go through the interceptor chain.
    final authInterceptor = AuthInterceptor(
      secureStorage,
      authRepository,
      baseDio,
      FirebaseAuth.instance,
      ApiService.instance,
    );
    baseDio.interceptors.add(authInterceptor);

    // 5. Create the final ProviderContainer
    final container = ProviderContainer(
      overrides: [
        sharedPrefsProvider.overrideWithValue(sharedPrefsHelper),
        flutterSecureStorageProvider.overrideWithValue(secureStorage),
        dioProvider.overrideWithValue(
          baseDio,
        ), // Provide the Dio instance that has the interceptor
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
    );

    return container;
  }
}

/// Global providers
class AppProviders {
  /// Router provider - using the complete router configuration with all routes
  static final router = Provider<GoRouter>(
    (ref) => AppRouter.createRouter(ref),
  );

  /// Theme provider
  static final theme = themeProvider;

  /// Settings box provider
  static final settingsBox = settingsBoxProvider;

  /// User box provider
  static final userBox = userBoxProvider;

  /// SharedPreferences provider
  static final sharedPrefs = sharedPrefsProvider;

  /// Auth repository provider
  static final authRepository = authRepositoryProvider;

  /// Login notifier provider
  static final loginNotifier = login.loginNotifierProvider;

  /// Register provider (refactored - now using combined provider)
  // static final register = registerProvider;

  /// Register form provider
  // static final registerForm = registerFormProvider;

  /// Register auth provider
  // static final registerAuth = registerAuthProvider;

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
