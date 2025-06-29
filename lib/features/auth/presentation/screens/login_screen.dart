import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/core/widgets/error_handler.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/animated_logo.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/login_form.dart';
import 'package:zer0_waste_ai/features/profile/presentation/screens/allergy_selector_screen.dart';
import 'package:zer0_waste_ai/features/profile/application/providers/user_profile_provider.dart';
import 'package:zer0_waste_ai/core/services/auth_service.dart';

/// Login screen
class LoginScreen extends ConsumerStatefulWidget {
  /// Constructor
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String? _sessionExpiredMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Handle auth state changes - including session expired errors
    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      state.when(
        data: (user) async {
          if (user != null) {
            // Clear any session expired message on successful login
            setState(() {
              _sessionExpiredMessage = null;
            });
            
            // Check if this is the user's first time logging in
            final userProfileState = ref.read(userProfileProvider);
            final hasCompletedPreferences =
                userProfileState.user?.initialPreferencesCompleted ?? false;

            if (hasCompletedPreferences) {
              // User has already completed preferences, go to home
              context.go('/home');
            } else {
              // First time user or user hasn't completed preferences, go to onboarding
              context.go(AllergySelectorScreen.routePath);
            }
          }
        },
        loading: () {
          // Clear message when loading
          if (_sessionExpiredMessage != null) {
            setState(() {
              _sessionExpiredMessage = null;
            });
          }
        },
        error: (error, _) {
          // Show session expired message if it's that type of error
          if (error is SessionExpiredException) {
            setState(() {
              _sessionExpiredMessage = error.message;
            });
          }
        },
      );
    });

    return AuthErrorHandler(
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  const Center(child: AnimatedLogo(size: 120)),
                  const SizedBox(height: 40),

                  // Welcome text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenido de Nuevo',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark
                                    ? AppColors.darkMainText
                                    : AppColors.lightMainText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Inicie sesión para seguir reduciendo el desperdicio de alimentos',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            color:
                                isDark
                                    ? AppColors.darkSecondaryText
                                    : AppColors.lightSecondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Session expired message
                  if (_sessionExpiredMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _sessionExpiredMessage!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 20),

                  // Login form
                  LoginForm(
                    onForgotPassword: () {
                      context.go('/forgot-password');
                    },
                    onRegister: () {
                      context.go('/register');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
