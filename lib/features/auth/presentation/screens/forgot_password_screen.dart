import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/forgot_password_provider.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/animated_logo.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/otp_input.dart';

/// Forgot password screen
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  /// Constructor
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  Timer? _resendTimer;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  late TextEditingController _emailController;
  late TextEditingController _codeController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _startResendTimerIfNeeded();

    // We'll start the timer in the build method when the state changes
    _emailController = TextEditingController();
    _codeController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    ref.listenManual(forgotPasswordProvider, (previous, next) {
      // Sincroniza los controladores con el estado del provider
      // Solo actualiza si el texto es diferente para evitar bucles/saltos de cursor
      _updateControllerTextIfNeeded(_emailController, next.email);
      _updateControllerTextIfNeeded(_codeController, next.code);
      _updateControllerTextIfNeeded(_newPasswordController, next.newPassword);
      _updateControllerTextIfNeeded(
        _confirmPasswordController,
        next.confirmPassword,
      );
    }, fireImmediately: true);
  }

  void _updateControllerTextIfNeeded(
    TextEditingController controller,
    String newStateText,
  ) {
    if (controller.text != newStateText) {
      // Usar addPostFrameCallback puede ayudar a evitar errores si esto ocurre durante un build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Siempre verifica si el widget está montado
          controller.text = newStateText;
          // Mueve el cursor al final del texto
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();

    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  void _startResendTimerIfNeeded() {
    final state = ref.read(forgotPasswordProvider);

    // If we're in the code verification step and the timer is active
    if (state.step == ForgotPasswordStep.codeVerification &&
        state.resendTimer > 0) {
      _resendTimer?.cancel();
      _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        ref.read(forgotPasswordProvider.notifier).decrementResendTimer();

        // Stop the timer when it reaches 0
        if (ref.read(forgotPasswordProvider).resendTimer <= 0) {
          _resendTimer?.cancel();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant ForgotPasswordScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _startResendTimerIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    // Get theme data
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get forgot password state
    final forgotPasswordState = ref.watch(forgotPasswordProvider);

    // Start the timer if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startResendTimerIfNeeded();
    });

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
          ),
          onPressed: () {
            // If we're in the email input step, go back to login
            // Otherwise, go back to the previous step
            if (forgotPasswordState.step == ForgotPasswordStep.emailInput) {
              context.go('/login');
            } else {
              ref.read(forgotPasswordProvider.notifier).resetToEmailInput();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                const Center(child: AnimatedLogo(size: 100)),
                const SizedBox(height: 30),

                // Title and content based on current step
                _buildStepContent(context, forgotPasswordState, isDark, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build content based on current step
  Widget _buildStepContent(
    BuildContext context,
    ForgotPasswordState state,
    bool isDark,
    ThemeData theme,
  ) {
    switch (state.step) {
      case ForgotPasswordStep.emailInput:
        return _buildEmailInputStep(context, state, isDark, theme);
      case ForgotPasswordStep.codeVerification:
        return _buildCodeVerificationStep(context, state, isDark, theme);
      case ForgotPasswordStep.passwordReset:
        return _buildPasswordResetStep(context, state, isDark, theme);
      case ForgotPasswordStep.success:
        return _buildSuccessStep(context, state, isDark, theme);
    }
  }

  /// Build email input step
  Widget _buildEmailInputStep(
    BuildContext context,
    ForgotPasswordState state,
    bool isDark,
    ThemeData theme,
  ) {
    final notifier = ref.read(forgotPasswordProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'Contraseña Olvidada',
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ingresa tu correo para recibir un código de restablecimiento',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            color:
                isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText,
          ),
        ),
        const SizedBox(height: 30),

        // Email field
        CustomTextField(
          controller: _emailController,
          label: 'Correo Electrónico',
          hint: 'Ingresa tu correo electrónico',
          icon: FontAwesomeIcons.solidEnvelope,
          errorText: state.emailError,
          isValid: state.isEmailFormValid,
          onChanged: (value) => notifier.updateEmail(value),
        ),
        const SizedBox(height: 30),

        // Send reset code button
        Center(
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  state.isEmailFormValid
                      ? () async {
                        final success = await notifier.sendResetCode();
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Hemos enviado un código de restablecimiento a tu correo',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor:
                                  isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.lightPrimary,
                            ),
                          );
                        }
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: (isDark
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary)
                    .withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Enviar Código',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Back to login
        Center(
          child: TextButton(
            onPressed: () {
              context.go('/login');
            },
            child: Text(
              'Volver a Iniciar Sesión',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build code verification step
  Widget _buildCodeVerificationStep(
    BuildContext context,
    ForgotPasswordState state,
    bool isDark,
    ThemeData theme,
  ) {
    final notifier = ref.read(forgotPasswordProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'Verificar Código',
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ingresa el código de 6 dígitos que enviamos a ${state.email}',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            color:
                isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText,
          ),
        ),
        const SizedBox(height: 30),

        // Code field
        Text(
          'Código',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color:
                isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText,
          ),
        ),
        const SizedBox(height: 8),
        OtpInput(
          controller: _codeController,
          onChanged: (value) => notifier.updateCode(value),
          onCompleted: (value) async {
            // Optionally trigger verification automatically on completion
            if (state.isCodeFormValid) {
              await notifier.verifyCode();
            }
          },
          errorText: state.codeError,
          length: 6,
        ),
        const SizedBox(height: 12),

        // Resend timer
        if (state.resendTimer > 0)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Reenviar en ${state.resendTimer}s',
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText,
              ),
            ),
          )
        else
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                final success = await notifier.sendResetCode();
                if (success && context.mounted) {
                  // Start the timer
                  _startResendTimerIfNeeded();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Hemos enviado un nuevo código de restablecimiento a tu correo',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor:
                          isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
                    ),
                  );
                }
              },
              child: Text(
                'Reenviar Código',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color:
                      isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
              ),
            ),
          ),
        const SizedBox(height: 30),

        // Verify code button
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed:
                state.isCodeFormValid
                    ? () async {
                      final success = await notifier.verifyCode();
                      if (!success && context.mounted) {
                        // Show error if verification failed
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              state.codeError ??
                                  'Código inválido. Por favor, inténtalo de nuevo.',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor:
                                isDark
                                    ? AppColors.darkError
                                    : AppColors.lightError,
                          ),
                        );
                      }
                    }
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: (isDark
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary)
                  .withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Verificar Código',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Attempts counter
        if (state.verificationAttempts > 0)
          Center(
            child: Text(
              'Intentos: ${state.verificationAttempts}/3',
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    state.verificationAttempts >= 2
                        ? (isDark ? AppColors.darkError : AppColors.lightError)
                        : (isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText),
              ),
            ),
          ),
      ],
    );
  }

  /// Build password reset step
  Widget _buildPasswordResetStep(
    BuildContext context,
    ForgotPasswordState state,
    bool isDark,
    ThemeData theme,
  ) {
    final notifier = ref.read(forgotPasswordProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'Restablecer Contraseña',
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Crea una nueva contraseña para tu cuenta',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            color:
                isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText,
          ),
        ),
        const SizedBox(height: 30),

        // New password field
        CustomTextField(
          controller: _newPasswordController,
          label: 'Nueva Contraseña',
          hint: 'Ingresa la nueva contraseña',
          icon: FontAwesomeIcons.lock,
          isPassword: true,
          isPasswordVisible: _isPasswordVisible,
          errorText: state.newPasswordError,
          onChanged: (value) => notifier.updateNewPassword(value),
          onToggleVisibility: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        const SizedBox(height: 20),

        // Confirm password field
        CustomTextField(
          controller: _confirmPasswordController,
          label: 'Confirmar Contraseña',
          hint: 'Confirma la nueva contraseña',
          icon: FontAwesomeIcons.lock,
          isPassword: true,
          isPasswordVisible: _isConfirmPasswordVisible,
          errorText: state.confirmPasswordError,
          onChanged: (value) => notifier.updateConfirmPassword(value),
          onToggleVisibility: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
        const SizedBox(height: 30),

        // Reset password button
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed:
                state.isPasswordFormValid
                    ? () async {
                      final success = await notifier.resetPassword();
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Contraseña actualizada con éxito',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor:
                                isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.lightPrimary,
                          ),
                        );

                        // Navigate to login
                        context.go('/login');
                      }
                    }
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: (isDark
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary)
                  .withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Actualizar Contraseña',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build success step
  Widget _buildSuccessStep(
    BuildContext context,
    ForgotPasswordState state,
    bool isDark,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Success icon
        Icon(
          Icons.check_circle_outline,
          size: 80,
          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
        ),
        const SizedBox(height: 20),

        // Title
        Text(
          'Restablecimiento de Contraseña Exitoso',
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Tu contraseña ha sido actualizada con éxito. Ahora puedes iniciar sesión con tu nueva contraseña.',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            color:
                isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        // Back to login button
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Volver a Iniciar Sesión',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
