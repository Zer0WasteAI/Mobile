import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/app_dialog.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/dialog_helper.dart';

/// Shows a reusable dialog for adding a custom text item (like allergy or diet).
Future<void> showAddItemDialog({
  required BuildContext context,
  required String title,
  required String fieldLabel,
  required String hintText,
  required IconData iconData,
  required Set<String> existingItemNames, // Used for validation
  required ValueChanged<String> onAdd,
  // Styling parameters (pass from theme usually)
  required Color primaryColor,
  required Color backgroundColor,
  required Color secondaryTextColor,
}) async {
  final result = await DialogHelper.showInputDialog(
    context: context,
    title: title,
    label: fieldLabel,
    hint: hintText,
    icon: iconData,
    existingValues: existingItemNames,
    validator: (value) {
      final enteredName = value?.trim() ?? '';
      if (enteredName.isEmpty) {
        return 'Por favor ingresa un nombre';
      }
      if (enteredName.length > 50) {
        return 'El nombre es muy largo (máx 50)';
      }
      // Check for duplicates (case-insensitive)
      if (existingItemNames.any(
        (existing) =>
            existing.trim().toLowerCase() == enteredName.toLowerCase(),
      )) {
        return 'Este elemento ya existe';
      }
      return null;
    },
  );

  // If dialog was dismissed with a valid name, call the onAdd callback
  if (result != null && result.isNotEmpty) {
    onAdd(result);
  }
}
