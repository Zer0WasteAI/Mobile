import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/social_buttons_row.dart';

/// Login form widget
class LoginForm extends ConsumerStatefulWidget {
  /// On forgot password callback
  final VoidCallback onForgotPassword;

  /// On register callback
  final VoidCallback onRegister;

  /// Constructor
  const LoginForm({
    super.key,
    required this.onForgotPassword,
    required this.onRegister,
  });

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  bool _isPasswordVisible = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _emailController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _emailError == null &&
      _passwordError == null;

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = 'Por favor ingresa tu correo electrónico';
      } else if (!value.contains('@')) {
        _emailError = 'Por favor ingresa un correo válido';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Por favor ingresa tu contraseña';
      } else if (value.length < 6) {
        _passwordError = 'La contraseña debe tener al menos 6 caracteres';
      } else {
        _passwordError = null;
      }
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref
          .read(authControllerProvider.notifier)
          .signInWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get auth state
    final authState = ref.watch(authControllerProvider);

    // Get theme data
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Check if loading
    final isLoading = authState.isLoading;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email field
            CustomTextField(
              label: 'Correo Electrónico',
              hint: 'Ingresa tu correo electrónico',
              icon: FontAwesomeIcons.solidEnvelope,
              controller: _emailController,
              errorText: _emailError,
              isValid: _emailController.text.isNotEmpty && _emailError == null,
              onChanged: (value) {
                _validateEmail(value);
              },
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Password field
            CustomTextField(
              label: 'Contraseña',
              hint: 'Ingresa tu contraseña',
              icon: FontAwesomeIcons.lock,
              controller: _passwordController,
              isPassword: true,
              isPasswordVisible: _isPasswordVisible,
              errorText: _passwordError,
              isValid:
                  _passwordController.text.isNotEmpty && _passwordError == null,
              onChanged: (value) {
                _validatePassword(value);
              },
              onToggleVisibility: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            const SizedBox(height: 12),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: widget.onForgotPassword,
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color:
                        isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Login button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isFormValid && !isLoading ? _login : null,
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
                child:
                    isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          'Iniciar Sesión',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 30),

            // Divider
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: isDark ? Colors.white30 : Colors.black26,
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'o continuar con',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          isDark
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: isDark ? Colors.white30 : Colors.black26,
                    thickness: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Social buttons
            SocialButtonsRow(
              onGoogleTap:
                  () =>
                      ref
                          .read(authControllerProvider.notifier)
                          .signInWithGoogle(),
              onFacebookTap:
                  () =>
                      ref
                          .read(authControllerProvider.notifier)
                          .signInWithFacebook(),
              onAppleTap:
                  () =>
                      ref
                          .read(authControllerProvider.notifier)
                          .signInWithApple(),
            ),
            const SizedBox(height: 30),

            // Register link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¿No tienes una cuenta? ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText,
                  ),
                ),
                GestureDetector(
                  onTap: widget.onRegister,
                  child: Text(
                    'Regístrate',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
