import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';

/// Mostrar diálogo para verificación de correo
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        title: Text(
          'Verificación necesaria',
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
                'Debes verificar tu correo electrónico antes de iniciar sesión.',
                style: GoogleFonts.inter(
                  color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Por favor, revisa tu bandeja de entrada y haz clic en el enlace de verificación.',
                style: GoogleFonts.inter(
                  color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
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
            child: const Text('Entendido'),
          ),
        ],
      );
    },
  );
}
