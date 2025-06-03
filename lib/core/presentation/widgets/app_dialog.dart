import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Un widget de diálogo estandarizado para mantener la consistencia en toda la aplicación.
///
/// Proporciona una apariencia coherente para todos los diálogos,
/// con opciones para personalizar contenido, íconos y acciones.
class AppDialog extends StatelessWidget {
  /// Título del diálogo
  final String title;

  /// Contenido principal del diálogo
  final Widget content;

  /// Icono opcional para mostrar en la parte superior
  final IconData? icon;

  /// Color del icono
  final Color? iconColor;

  /// Acción primaria (botón principal)
  final Widget primaryAction;

  /// Acción secundaria opcional (generalmente un botón de cancelar)
  final Widget? secondaryAction;

  /// Emoji o imagen opcional para mostrar encima del título
  final String? emoji;

  /// Título secundario o subtítulo opcional
  final String? subtitle;

  /// Si es true, el diálogo tendrá un ancho máximo para dispositivos grandes
  final bool constrainWidth;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    required this.primaryAction,
    this.secondaryAction,
    this.icon,
    this.iconColor,
    this.emoji,
    this.subtitle,
    this.constrainWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Colores configurados según el tema
    final backgroundColor =
        isDark
            ? colorScheme.surfaceContainerHigh
            : Colors.white;
    final textColor = colorScheme.onSurface;
    final secondaryTextColor = colorScheme.onSurfaceVariant;

    Widget dialogContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Emoji o ícono en la parte superior
        if (emoji != null) ...[
          Text(emoji!, style: const TextStyle(fontSize: 42)),
          const SizedBox(height: 12.0),
        ] else if (icon != null) ...[
          Icon(icon!, size: 42, color: iconColor ?? colorScheme.primary),
          const SizedBox(height: 12.0),
        ],

        // Título
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),

        // Subtítulo (si existe)
        if (subtitle != null) ...[
          const SizedBox(height: 4.0),
          Text(
            subtitle!,
            style: GoogleFonts.inter(fontSize: 16, color: secondaryTextColor),
            textAlign: TextAlign.center,
          ),
        ],

        // Separador
        const SizedBox(height: 8.0),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 20.0),

        // Contenido principal
        content,

        const SizedBox(height: 24.0),

        // Botones de acción
        Row(
          mainAxisAlignment:
              secondaryAction != null
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.end,
          children: [
            if (secondaryAction != null) secondaryAction!,
            primaryAction,
          ],
        ),
      ],
    );

    // Aplicar restricción de ancho para tablets/desktop
    if (constrainWidth) {
      final screenWidth = MediaQuery.of(context).size.width;
      final maxDialogWidth = screenWidth > 600 ? 400.0 : screenWidth * 0.85;

      dialogContent = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxDialogWidth),
        child: dialogContent,
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      elevation: 8,
      backgroundColor: backgroundColor,
      child: Padding(padding: const EdgeInsets.all(24.0), child: dialogContent),
    );
  }

  /// Factory para crear un botón primario estándar para usar en diálogos
  static Widget createPrimaryButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    bool isEnabled = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  /// Factory para crear un botón secundario estándar para usar en diálogos
  static Widget createSecondaryButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    );
  }
}
