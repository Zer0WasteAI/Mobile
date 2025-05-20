import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/animated_logo.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/login_form.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/email_verification_dialog.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/user_info_dialog.dart';
import 'package:zer0_waste_ai/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:zer0_waste_ai/features/profile/presentation/screens/allergy_selector_screen.dart';
import 'package:zer0_waste_ai/features/auth/presentation/screens/auth_transition_screen.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/loading_snackbar.dart';

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

    // Handle auth state changes
    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      state.whenData((user) async {
        if (user != null) {
          final authController = ref.read(authControllerProvider.notifier);

          // Verificar si se necesita información adicional (específico para Apple Sign In)
          if (user.needsAdditionalInfo == true) {
            if (mounted) {
              // Mostrar diálogo para recopilar información adicional
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (context) => UserInfoDialog(
                      onSubmit: (displayName, email) async {
                        // Actualizar la información del usuario
                        await authController.updateUserAfterAppleSignIn(
                          displayName,
                          email,
                        );
                        // Cerrar el diálogo
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
              );

              // Después del diálogo, el usuario ya debería estar actualizado
              // No es necesario hacer más verificaciones aquí
              return;
            }
          }

          // Verificar si el correo está verificado (solo si el proveedor es password)
          final authMethod = user.providerId;
          final isEmailPassword =
              authMethod == 'password' || authMethod == null;

          if (isEmailPassword) {
            // Recargar usuario para obtener el estado de verificación más reciente
            await authController.reloadUser();
            final isVerified = await authController.isEmailVerified();

            if (!isVerified) {
              // Si el correo no está verificado, mostrar diálogo
              if (mounted) {
                await showEmailVerificationDialog(
                  context: context,
                  onConfirm: () async {
                    // Cerrar sesión y redirigir a la pantalla de verificación
                    await authController.signOut();
                    if (mounted) {
                      context.go(EmailVerificationScreen.routePath);
                    }
                  },
                );
                return;
              }
            }
          }

          // Si pasó la verificación o usa otro método de login, continuar con flujo normal
          // En lugar de verificar las preferencias aquí, usar la pantalla de transición
          if (mounted) {
            // Mostrar indicador de carga antes de navegar para una transición más suave
            showLoadingSnackBar(
              context,
              message: 'Iniciando sesión...',
              duration: const Duration(milliseconds: 1000),
            );

            // Usar un pequeño delay para permitir que el SnackBar se muestre
            // antes de navegar a la pantalla de transición
            Future.delayed(const Duration(milliseconds: 600), () {
              // Verificar que el contexto todavía está montado
              if (mounted) {
                // Mostrar pantalla de transición que manejará las verificaciones
                context.go(AuthTransitionScreen.routePath);
              }
            });
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
