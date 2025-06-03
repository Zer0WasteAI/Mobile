import 'package:flutter/material.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/app_dialog.dart';

/// Helper para mostrar diálogos consistentes en la aplicación
class DialogHelper {
  /// Muestra un diálogo de alerta simple con un botón de aceptar
  static Future<void> showAlert({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'Aceptar',
    IconData? icon,
    Color? iconColor,
    String? emoji,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AppDialog(
          title: title,
          icon: icon,
          iconColor: iconColor,
          emoji: emoji,
          content: Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          primaryAction: AppDialog.createPrimaryButton(
            context: context,
            text: buttonText,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        );
      },
    );
  }

  /// Muestra un diálogo de confirmación con botones de aceptar y cancelar
  static Future<bool> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Aceptar',
    String cancelText = 'Cancelar',
    IconData? icon,
    Color? iconColor,
    String? emoji,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AppDialog(
          title: title,
          icon: icon,
          iconColor: iconColor,
          emoji: emoji,
          content: Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          primaryAction: AppDialog.createPrimaryButton(
            context: context,
            text: confirmText,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
          secondaryAction: AppDialog.createSecondaryButton(
            context: context,
            text: cancelText,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
        );
      },
    );

    return result ?? false;
  }

  /// Muestra un diálogo para añadir un elemento de texto
  static Future<String?> showInputDialog({
    required BuildContext context,
    required String title,
    required String label,
    required String hint,
    required IconData icon,
    String confirmText = 'Agregar',
    String cancelText = 'Cancelar',
    Set<String>? existingValues,
    String? emoji,
    String? subtitle,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) async {
    final TextEditingController controller = TextEditingController();
    final formKey = GlobalKey<FormState>(
      debugLabel: 'inputDialog_${DateTime.now().millisecondsSinceEpoch}',
    );

    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        final colorScheme = Theme.of(context).colorScheme;
        final primaryColor = colorScheme.primary;
        final secondaryTextColor = colorScheme.onSurfaceVariant;

        return AppDialog(
          title: title,
          subtitle: subtitle,
          emoji: emoji,
          icon: icon,
          iconColor: primaryColor,
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: secondaryTextColor.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hint,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  validator:
                      validator ??
                      (value) {
                        final enteredValue = value?.trim() ?? '';
                        if (enteredValue.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        if (existingValues != null &&
                            existingValues.contains(enteredValue)) {
                          return 'Este elemento ya existe';
                        }
                        return null;
                      },
                  keyboardType: keyboardType,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
          primaryAction: AppDialog.createPrimaryButton(
            context: context,
            text: confirmText,
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(controller.text.trim());
              }
            },
          ),
          secondaryAction: AppDialog.createSecondaryButton(
            context: context,
            text: cancelText,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        );
      },
    );
  }
}
