import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/animated_logo.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/login_form.dart';
import 'package:zer0_waste_ai/features/profile/presentation/screens/allergy_selector_screen.dart';
import 'package:zer0_waste_ai/features/auth/presentation/screens/auth_transition_screen.dart';

/// Login screen
class LoginScreen extends ConsumerStatefulWidget {
  /// Constructor
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isResendingEmail = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if coming from verification screen
    final uri = GoRouterState.of(context).uri;
    final fromVerification = uri.queryParameters['from'] == 'verification';

    if (fromVerification) {
      // Show success message if coming from verification
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '¡Email verificado con éxito! Ahora puedes iniciar sesión.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      });
    }
  }

  // Show a non-dismissible dialog for unverified email
  Future<void> _showVerificationDialog(String email) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authController = ref.read(authControllerProvider.notifier);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
              title: Text(
                'Verificación de email necesaria',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      isDark ? AppColors.darkMainText : AppColors.lightMainText,
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
                      'Tu cuenta no ha sido verificada',
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
                      'Antes de iniciar sesión, debes verificar tu correo electrónico haciendo clic en el enlace que te enviamos a $email.',
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
                      'Si no encuentras el correo, revisa tu carpeta de spam o solicita un nuevo correo de verificación.',
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
                    foregroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () async {
                    // Sign out and close dialog
                    await authController.signOut();
                    if (context.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('Cancelar'),
                ),
                _isResendingEmail
                    ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                    : TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () async {
                        // Set loading state
                        setState(() {
                          _isResendingEmail = true;
                        });

                        try {
                          // Resend verification email
                          await authController.sendVerificationEmail();

                          // Show success message
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Correo de verificación reenviado. ¡Revisa tu bandeja de entrada!',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          // Show error message
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error al reenviar el correo: $e',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          // Reset loading state and sign out
                          setState(() {
                            _isResendingEmail = false;
                          });
                          await authController.signOut();
                          if (context.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        }
                      },
                      child: const Text('Reenviar correo'),
                    ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Handle auth state changes
    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      state.whenData((user) async {
        if (user != null) {
          // Check if email is verified (only for email-based accounts)
          final authController = ref.read(authControllerProvider.notifier);

          // Get user authentication method
          final authMethod = user.providerId;
          // Check if this is an email-based account
          final isEmailAccount = authMethod == 'email';

          if (isEmailAccount) {
            // Reload user to get the most recent verification status
            await authController.reloadUser();
            final isVerified = await authController.isEmailVerified();

            if (!isVerified) {
              // If email isn't verified, show non-dismissible dialog
              if (mounted) {
                await _showVerificationDialog(user.email);
                return;
              }
            }
          }

          // If verification passed or using another login method, continue with normal flow
          final isFirstTime = await authController.isFirstTimeUser();

          if (mounted) {
            if (isFirstTime) {
              // If first time, take them to select allergies
              // This is the first screen in the user preferences flow
              context.go(AllergySelectorScreen.routePath);
            } else {
              // Si no es primera vez, ir a pantalla de transición en lugar de directamente al home
              context.go(AuthTransitionScreen.routePath);
            }
          }
        }
      });

      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al iniciar sesión: ${state.error}',
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
    );
  }
}
