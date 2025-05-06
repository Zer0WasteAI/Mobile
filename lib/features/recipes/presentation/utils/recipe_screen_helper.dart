import 'package:flutter/material.dart';
import 'package:zer0_waste_ai/core/presentation/utils/focus_utils.dart';

/// Clase que proporciona métodos para ayudar con la implementación de la pantalla de recetas
class RecipeScreenHelper {
  /// Crea un TextField de búsqueda con la capacidad de quitar el foco al hacer clic fuera
  static Widget createSearchTextField({
    required FocusNode focusNode,
    required ValueChanged<String> onChanged,
    required InputDecoration decoration,
    required TextStyle style,
  }) {
    return TextField(
      onChanged: onChanged,
      focusNode: focusNode,
      decoration: decoration,
      style: style,
    );
  }

  /// Envuelve el contenido de la pantalla para gestionar el foco en el campo de búsqueda
  static Widget wrapScreenContent({
    required FocusNode searchFocusNode,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: () {
        // Quitar el foco cuando se hace clic fuera del campo de búsqueda
        searchFocusNode.unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
