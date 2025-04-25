import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/login_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    // Get login state
    final loginNotifier = ref.watch(loginNotifierProvider.notifier);
    final loginState = loginNotifier.loginState;
    final loginAsync = ref.watch(loginNotifierProvider);

    // Get theme data
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Check if loading
    final isLoading = loginAsync.isLoading;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          CustomTextField(
            label: 'Email',
            hint: 'Enter your email',
            icon: FontAwesomeIcons.solidEnvelope,
            errorText: loginState.emailError,
            isValid:
                loginState.email.isNotEmpty && loginState.emailError == null,
            onChanged: (value) => loginNotifier.updateEmail(value),
          ),
          const SizedBox(height: 20),

          // Password field
          CustomTextField(
            label: 'Password',
            hint: 'Enter your password',
            icon: FontAwesomeIcons.lock,
            isPassword: true,
            isPasswordVisible: _isPasswordVisible,
            errorText: loginState.passwordError,
            isValid:
                loginState.password.isNotEmpty &&
                loginState.passwordError == null,
            onChanged: (value) => loginNotifier.updatePassword(value),
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
                'Forgot your password?',
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
              onPressed:
                  loginState.isValid && !isLoading
                      ? () => loginNotifier.login()
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
                        'Login',
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
                  'or continue with',
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
            onGoogleTap: () => loginNotifier.loginWithGoogle(),
            onFacebookTap: () => loginNotifier.loginWithFacebook(),
            onAppleTap: () => loginNotifier.loginWithApple(),
          ),
          const SizedBox(height: 30),

          // Register link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
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
                  'Register',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
