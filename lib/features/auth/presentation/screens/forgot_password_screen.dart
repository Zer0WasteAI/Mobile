import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
// import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart'; // No longer directly using authControllerProvider
import 'package:zer0_waste_ai/features/auth/presentation/providers/forgot_password_provider.dart';

/// Forgot password screen
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  /// Constructor
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Reset state when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(forgotPasswordProvider.notifier).resetToEmailInput();
      // Initialize text controller if there's an email in the state
      // (e.g., if user navigates back and email was preserved)
      final initialEmail = ref.read(forgotPasswordProvider).email;
      if (initialEmail.isNotEmpty && _emailController.text != initialEmail) {
        _emailController.text = initialEmail;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
    // Validate form
    if (!(_formKey.currentState?.validate() ?? false)) {
      // If form is not valid, updateEmail will have set the error in the state.
      // We can also explicitly update here if needed, but validator should handle it.
      ref
          .read(forgotPasswordProvider.notifier)
          .updateEmail(_emailController.text.trim());
      return;
    }
    // Call the notifier method
    await ref.read(forgotPasswordProvider.notifier).sendResetCode();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Watch the state from the provider
    final forgotPasswordState = ref.watch(forgotPasswordProvider);
    final notifier = ref.read(forgotPasswordProvider.notifier);

    // Update text controller if email in state changes and controller is out of sync
    // This might happen if state is updated by other means or on rebuilds.
    // Only update if it's different to avoid cursor jumping or infinite loops.
    if (_emailController.text != forgotPasswordState.email &&
        forgotPasswordState.step == ForgotPasswordStep.emailInput) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _emailController.text = forgotPasswordState.email;
        _emailController.selection = TextSelection.fromPosition(
          TextPosition(offset: _emailController.text.length),
        );
      });
    }

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
            // Before popping, ensure the state is reset for next time
            notifier.resetToEmailInput();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  'Recuperar Contraseña',
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
                  forgotPasswordState.step == ForgotPasswordStep.success
                      ? 'Revisa tu correo electrónico.' // Updated subtitle for success
                      : 'Te enviaremos un correo electrónico para restablecer tu contraseña.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    color:
                        isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText,
                  ),
                ),
                const SizedBox(height: 40),

                if (forgotPasswordState.step == ForgotPasswordStep.success)
                  Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 72,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '¡Correo enviado!',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color:
                              isDark
                                  ? AppColors.darkMainText
                                  : AppColors.lightMainText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hemos enviado un enlace para restablecer tu contraseña a ${forgotPasswordState.email}. Por favor, revisa tu bandeja de entrada y la carpeta de spam.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color:
                              isDark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.lightSecondaryText,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          notifier
                              .resetToEmailInput(); // Reset state before navigating
                          context.go('/login');
                        },
                        child: const Text('Volver al Inicio de Sesión'),
                      ),
                    ],
                  )
                else // Corresponds to ForgotPasswordStep.emailInput
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: const OutlineInputBorder(),
                            errorText:
                                forgotPasswordState
                                    .emailError, // Display error from state
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            // Update email in state as user types for live validation (optional)
                            // notifier.updateEmail(value);
                            // For now, let's validate on submit or when focusing out.
                          },
                          validator: (value) {
                            // Basic validation, can be enhanced or rely on notifier's validation logic
                            // The notifier's updateEmail method already sets emailError.
                            // This validator is mostly for the form's own validation trigger.
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu email';
                            }
                            if (!value.contains('@')) {
                              // Simple check
                              return 'Por favor ingresa un email válido';
                            }
                            // If notifier has an error for the current email, show it.
                            // This might be redundant if errorText is already bound to forgotPasswordState.emailError
                            if (forgotPasswordState.emailError != null &&
                                value == forgotPasswordState.email) {
                              return forgotPasswordState.emailError;
                            }
                            return null;
                          },
                          onEditingComplete: () {
                            notifier.updateEmail(_emailController.text.trim());
                            FocusScope.of(
                              context,
                            ).unfocus(); // Dismiss keyboard
                          },
                          onTapOutside: (_) {
                            notifier.updateEmail(_emailController.text.trim());
                            // FocusScope.of(context).unfocus(); // Might be too aggressive
                          },
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                forgotPasswordState.isLoading
                                    ? null
                                    : _sendPasswordResetEmail,
                            child:
                                forgotPasswordState.isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text('Enviar Enlace'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            notifier.resetToEmailInput(); // Reset state
                            context.go('/login');
                          },
                          child: const Text('Volver al Inicio de Sesión'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
