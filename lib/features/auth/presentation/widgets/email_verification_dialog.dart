import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';

/// Show dialog for email verification
Future<void> showEmailVerificationDialog({
  required BuildContext context,
  required VoidCallback onConfirm,
}) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        title: Text(
          'Verificación de email necesaria',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
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
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color:
                      isDark ? AppColors.darkMainText : AppColors.lightMainText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Antes de iniciar sesión, debes verificar tu correo electrónico haciendo clic en el enlace que te enviamos.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color:
                      isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.lightSecondaryText,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Si no encuentras el correo, revisa tu carpeta de spam o solicita uno nuevo desde la pantalla de verificación.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onConfirm();
            },
            child: const Text('Ir a verificar'),
          ),
        ],
      );
    },
  );
}
