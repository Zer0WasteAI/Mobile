import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Hooks para crear un FocusNode que puede ser controlado desde fuera
FocusNode useUnfocusableFocusNode() {
  final focusNode = useFocusNode();
  return focusNode;
}

/// Widget que envuelve el contenido de la pantalla y gestiona el foco
class UnfocusOnTap extends StatelessWidget {
  final FocusNode focusNode;
  final Widget child;

  const UnfocusOnTap({super.key, required this.focusNode, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Quitar el foco cuando se hace clic fuera del campo de búsqueda
        focusNode.unfocus();
      },
      child: child,
    );
  }
}

/// Extension para los TextFields para agregar la funcionalidad de unfocus
extension UnfocusableTextField on TextField {
  /// Crea un TextField con un FocusNode que permitirá quitarle el foco al hacer clic fuera
  static TextField withUnfocusableFocusNode({
    required FocusNode focusNode,
    required ValueChanged<String>? onChanged,
    required InputDecoration decoration,
    TextStyle? style,
  }) {
    return TextField(
      onChanged: onChanged,
      focusNode: focusNode,
      decoration: decoration,
      style: style,
    );
  }
}
