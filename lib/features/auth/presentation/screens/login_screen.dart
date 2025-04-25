import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/login_provider.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/animated_logo.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/login_form.dart';

/// Login screen
class LoginScreen extends ConsumerWidget {
  /// Constructor
  const LoginScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch login state
    final loginAsync = ref.watch(loginNotifierProvider);
    
    // Get theme data
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Handle login success
    ref.listen<AsyncValue>(loginNotifierProvider, (_, state) {
      state.whenData((user) {
        if (user != null) {
          // Navigate to home screen
          context.go('/home');
        }
      });
      
      // Handle error
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login failed: ${state.error}',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: isDark ? AppColors.darkError : AppColors.lightError,
          ),
        );
      }
    });
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                const Center(
                  child: AnimatedLogo(size: 120),
                ),
                const SizedBox(height: 40),
                
                // Welcome text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back',
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue reducing food waste',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
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
    );
  }
}