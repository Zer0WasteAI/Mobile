import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final TextEditingController controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final String? newItemName = await showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: backgroundColor,
        titlePadding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
        title: Center(
          child: Text(
            title,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 12.0,
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Container(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              constraints: const BoxConstraints(minHeight: 180),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    iconData,
                    size: 36,
                    color: primaryColor.withValues(alpha: 0.8),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fieldLabel,
                    style: GoogleFonts.inter(
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
                      hintText: hintText,
                      hintStyle: GoogleFonts.inter(
                        color: secondaryTextColor.withValues(alpha: 0.7),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: secondaryTextColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: secondaryTextColor.withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: primaryColor, width: 1.5),
                      ),
                    ),
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
                            existing.trim().toLowerCase() ==
                            enteredName.toLowerCase(),
                      )) {
                        return 'Este elemento ya existe';
                      }
                      return null;
                    },
                    style: GoogleFonts.inter(),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 16.0),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: <Widget>[
          TextButton(
            onPressed:
                () => Navigator.of(dialogContext).pop(), // Pop without value
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
            ),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                color: secondaryTextColor,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(
                  dialogContext,
                ).pop(controller.text.trim()); // Pop with value
              }
            },
            child: Text(
              'Agregar',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
    },
  );

  // If dialog was dismissed with a valid name, call the onAdd callback
  if (newItemName != null && newItemName.isNotEmpty) {
    onAdd(newItemName);
  }
}
