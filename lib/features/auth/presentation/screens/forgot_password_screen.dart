import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';

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
  bool _isSubmitting = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        await ref
            .read(authControllerProvider.notifier)
            .sendPasswordResetEmail(_emailController.text.trim());
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _emailSent = true;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error al enviar el correo: ${e.toString()}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.lightError,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get theme data
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          onPressed: () => context.pop(),
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
                  'Te enviaremos un correo electrónico para restablecer tu contraseña',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    color:
                        isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText,
                  ),
                ),
                const SizedBox(height: 40),

                if (_emailSent)
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
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hemos enviado un enlace para restablecer tu contraseña a ${_emailController.text}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Volver al Inicio de Sesión'),
                      ),
                    ],
                  )
                else
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu email';
                            }
                            if (!value.contains('@')) {
                              return 'Por favor ingresa un email válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _isSubmitting ? null : _sendPasswordResetEmail,
                            child:
                                _isSubmitting
                                    ? const CircularProgressIndicator()
                                    : const Text('Enviar Enlace'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.go('/login'),
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
