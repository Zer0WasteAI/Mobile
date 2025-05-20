import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/register_provider.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/animated_logo.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/register_form.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/features/auth/presentation/screens/email_verification_screen.dart';

/// Register screen
class RegisterScreen extends ConsumerWidget {
  /// Constructor
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch register state
    final registerAsync = ref.watch(registerNotifierProvider);

    // Get theme data
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Handle register success
    ref.listen<AsyncValue>(registerNotifierProvider, (_, state) {
      state.whenData((user) async {
        if (user != null) {
          // Cuando un usuario se registra, cerrar sesión y dirigirlo a la pantalla de verificación de correo
          final authController = ref.read(authControllerProvider.notifier);
          await authController.signOut();
          context.go(EmailVerificationScreen.routePath);
        }
      });

      // Handle error
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error en el registro: ${state.error}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor:
                isDark ? AppColors.darkError : AppColors.lightError,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                const Center(child: AnimatedLogo(size: 100)),
                const SizedBox(height: 30),

                // Title text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crear Cuenta',
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
                        'Únete a nosotros y empieza a ahorrar comida',
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
                const SizedBox(height: 30),

                // Register form
                RegisterForm(
                  onLogin: () {
                    context.go('/login');
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
