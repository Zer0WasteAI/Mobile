import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/core/widgets/error_handler.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/animated_logo.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/login_form.dart';
import 'package:zer0_waste_ai/features/profile/presentation/screens/allergy_selector_screen.dart';

/// Login screen
class LoginScreen extends ConsumerStatefulWidget {
  /// Constructor
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Handle auth state changes - only handle successful login
    // Errors are handled globally by AuthErrorHandler
    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      state.whenData((user) {
        if (user != null) {
          context.go(AllergySelectorScreen.routePath);
        }
      });
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
                const SizedBox(height: 40),

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
