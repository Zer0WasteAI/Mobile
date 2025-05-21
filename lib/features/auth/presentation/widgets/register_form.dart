import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/register_provider.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:zer0_waste_ai/features/auth/presentation/widgets/social_buttons_row.dart';

/// Register form widget
class RegisterForm extends ConsumerStatefulWidget {
  /// On login callback
  final VoidCallback onLogin;

  /// Constructor
  const RegisterForm({super.key, required this.onLogin});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    ref.listenManual(registerNotifierProvider, (previous, next) {
      // Accede al estado síncrono a través del notifier
      final currentState =
          ref.read(registerNotifierProvider.notifier).registerState;
      _updateControllerTextIfNeeded(_nameController, currentState.name);
      _updateControllerTextIfNeeded(_emailController, currentState.email);
      _updateControllerTextIfNeeded(_passwordController, currentState.password);
      _updateControllerTextIfNeeded(
        _confirmPasswordController,
        currentState.confirmPassword,
      );
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    // Disponer controladores
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateControllerTextIfNeeded(
    TextEditingController controller,
    String newStateText,
  ) {
    if (controller.text != newStateText) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          controller.text = newStateText;
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get register state
    final registerNotifier = ref.watch(registerNotifierProvider.notifier);
    final registerState = registerNotifier.registerState;
    final registerAsync = ref.watch(registerNotifierProvider);

    // Get theme data
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Check if loading
    final isLoading = registerAsync.isLoading;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full Name field
          CustomTextField(
            controller: _nameController,
            label: 'Nombre Completo',
            hint: 'Ingresa tu nombre completo',
            icon: FontAwesomeIcons.solidUser,
            errorText: registerState.nameError,
            onChanged: (value) => registerNotifier.updateName(value),
          ),
          const SizedBox(height: 20),

          // Email field
          CustomTextField(
            controller: _emailController,
            label: 'Correo Electrónico',
            hint: 'Ingresa tu correo electrónico',
            icon: FontAwesomeIcons.solidEnvelope,
            errorText: registerState.emailError,
            onChanged: (value) => registerNotifier.updateEmail(value),
          ),
          const SizedBox(height: 20),

          // Password field
          CustomTextField(
            controller: _passwordController,
            label: 'Contraseña',
            hint: 'Ingresa tu contraseña',
            isPassword: true,
            isPasswordVisible: _isPasswordVisible,
            icon: FontAwesomeIcons.lock,
            errorText: registerState.passwordError,
            onChanged: (value) => registerNotifier.updatePassword(value),
            onToggleVisibility: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          const SizedBox(height: 20),

          // Confirm Password field
          CustomTextField(
            controller: _confirmPasswordController,
            label: 'Confirmar Contraseña',
            hint: 'Confirma tu contraseña',
            isPassword: true,
            isPasswordVisible: _isConfirmPasswordVisible,
            icon: FontAwesomeIcons.lock,
            errorText: registerState.confirmPasswordError,
            onChanged: (value) => registerNotifier.updateConfirmPassword(value),
            onToggleVisibility: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),
          const SizedBox(height: 30),

          // Register button
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed:
                  isLoading || !registerState.isValid
                      ? null
                      : () => registerNotifier.register(),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child:
                  isLoading
                      ? const CircularProgressIndicator.adaptive()
                      : const Text(
                        'Crear Cuenta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 20),

          // Social login buttons
          SocialButtonsRow(
            onGoogleTap: () => registerNotifier.loginWithGoogle(),
            onFacebookTap: () => registerNotifier.loginWithFacebook(),
            onAppleTap: () => registerNotifier.loginWithApple(),
          ),
          const SizedBox(height: 20),

          // Login link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿Ya tienes una cuenta?',
                style: TextStyle(
                  color:
                      isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.lightSecondaryText,
                ),
              ),
              TextButton(
                onPressed: widget.onLogin,
                child: Text(
                  'Inicia Sesión',
                  style: TextStyle(
                    color:
                        isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    fontWeight: FontWeight.bold,
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
