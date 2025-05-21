import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';

/// Email verification screen shown after registration
class EmailVerificationScreen extends ConsumerStatefulWidget {
  /// Constructor
  const EmailVerificationScreen({super.key});

  /// Route name
  static const String routeName = 'email-verification';

  /// Route path
  static const String routePath = '/email-verification';

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _isResendingEmail = false;
  bool _isCheckingVerification = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResendingEmail = true;
    });

    try {
      final authController = ref.read(authControllerProvider.notifier);
      await authController.sendVerificationEmail();

      if (mounted) {
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
      if (mounted) {
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
      if (mounted) {
        setState(() {
          _isResendingEmail = false;
        });
      }
    }
  }

  Future<void> _checkVerification() async {
    setState(() {
      _isCheckingVerification = true;
    });

    try {
      final authController = ref.read(authControllerProvider.notifier);
      await authController.reloadUser();
      final isVerified = await authController.isEmailVerified();

      if (mounted) {
        if (isVerified) {
          // Redirect user to login with verification indicator
          await authController.signOut();
          context.go('/login?from=verification');
        } else {
          // Show message that email is not verified yet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Tu correo electrónico aún no ha sido verificado. Por favor, verifica tu correo e intenta nuevamente.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al verificar el correo: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingVerification = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Email animation
              Lottie.asset(
                'assets/animations/email_verification.json',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Verifica tu correo electrónico',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color:
                      isDark ? AppColors.darkMainText : AppColors.lightMainText,
                ),
              ),
              const SizedBox(height: 16),

              // Message with clearer instructions
              Text(
                'Antes de continuar, debes verificar tu correo electrónico. Hemos enviado un enlace de verificación a tu bandeja de entrada.\n\nHaz clic en el enlace y luego presiona "Ya verifiqué mi correo" para continuar.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color:
                      isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.lightSecondaryText,
                ),
              ),
              const SizedBox(height: 40),

              // Verification button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isCheckingVerification ? null : _checkVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child:
                      _isCheckingVerification
                          ? const CircularProgressIndicator.adaptive()
                          : const Text(
                            'Ya verifiqué mi correo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),

              // Resend email button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed:
                      _isResendingEmail ? null : _resendVerificationEmail,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                  child:
                      _isResendingEmail
                          ? const CircularProgressIndicator.adaptive()
                          : Text(
                            'Reenviar correo de verificación',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
