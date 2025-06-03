import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget que proporciona un campo de búsqueda con la funcionalidad de perder el foco al tocar fuera
class UnfocusableSearchField extends HookConsumerWidget {
  final ValueChanged<String> onChanged;
  final String hintText;
  final Color iconColor;
  final Color backgroundColor;
  final Color textColor;
  final Color hintTextColor;

  const UnfocusableSearchField({
    super.key,
    required this.onChanged,
    required this.hintText,
    required this.iconColor,
    required this.backgroundColor,
    required this.textColor,
    required this.hintTextColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usar hooks para crear un FocusNode
    final focusNode = useFocusNode();

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withValues(alpha: 0.25)
                    : Colors.grey.withValues(alpha: 0.15),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        focusNode: focusNode,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(Icons.search, color: iconColor),
          filled: true,
          fillColor: backgroundColor,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14.0,
            horizontal: 16.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide.none,
          ),
          hintStyle: GoogleFonts.inter(color: hintTextColor),
        ),
        style: GoogleFonts.inter(color: textColor),
      ),
    );
  }
}
