import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/register_provider.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/animated_logo.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/register_form.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';

/// Register screen
class RegisterScreen extends ConsumerWidget {
  /// Constructor
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get theme data
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Handle register success using the new auth provider
    ref.listen<AsyncValue>(registerAuthProvider, (_, state) {
      state.whenData((user) async {
        if (user != null) {
          final email = user.email;

          // When a user registers, send verification email and sign out
          final authController = ref.read(authControllerProvider.notifier);

          // Ensure email is sent
          await authController.sendVerificationEmail();

          // Sign out completely to prevent redirection to preferences
          await authController.signOut();

          // Add a small delay to ensure sign out is complete
          await Future.delayed(const Duration(milliseconds: 300));

          // Verify we're fully signed out before showing dialog
          final currentUser =
              await ref
                  .read(authRepositoryProvider)
                  .getCurrentUserWithFirestore();
          if (currentUser != null) {
            // If somehow still logged in, try signing out again
            await authController.signOut();
            await Future.delayed(const Duration(milliseconds: 300));
          }

          // Show non-dismissible dialog with WillPopScope to prevent back button
          if (context.mounted) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext dialogContext) {
                return WillPopScope(
                  onWillPop: () async => false, // Prevent back button
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor:
                        isDark ? AppColors.darkBackground : Colors.white,
                    title: Text(
                      'Verificación de email necesaria',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            isDark
                                ? AppColors.darkMainText
                                : AppColors.lightMainText,
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mark_email_unread_rounded,
                            size: 80,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Se ha enviado un enlace de verificación',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color:
                                  isDark
                                      ? AppColors.darkMainText
                                      : AppColors.lightMainText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hemos enviado un enlace de verificación a $email. Por favor, revisa tu correo y haz clic en el enlace para activar tu cuenta.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  isDark
                                      ? AppColors.darkSecondaryText
                                      : AppColors.lightSecondaryText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Si no encuentras el correo, revisa tu carpeta de spam.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  isDark
                                      ? AppColors.darkSecondaryText
                                      : AppColors.lightSecondaryText,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          // Ensure we go to login and not get redirected elsewhere
                          WidgetsBinding.instance.addPostFrameCallback((
                            _,
                          ) async {
                            // Double-check there's no user still in memory
                            final authController = ref.read(
                              authControllerProvider.notifier,
                            );
                            await authController.signOut();

                            // Ensure the navigation stack is cleared
                            if (context.mounted) {
                              context.replace('/login');
                            }
                          });
                        },
                        child: const Text('Ir a iniciar sesión'),
                      ),
                    ],
                  ),
                );
              },
            );
          }
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
