import 'package:flutter/material.dart';
import 'package:zer0_waste_ai/core/navigation/navigation_extension.dart';

/// Botón de atrás seguro que verifica si se puede hacer pop antes de intentarlo
class SafeBackButton extends StatelessWidget {
  /// Color del icono
  final Color? iconColor;

  /// Constructor
  const SafeBackButton({Key? key, this.iconColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: iconColor),
      onPressed: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
    );
  }
}

/// Botón de texto seguro que verifica si se puede hacer pop antes de intentarlo
class SafeTextButton extends StatelessWidget {
  /// Texto a mostrar
  final String text;

  /// Estilo del texto
  final TextStyle? style;

  /// Constructor
  const SafeTextButton({Key? key, required this.text, this.style})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Text(text, style: style),
    );
  }
}
