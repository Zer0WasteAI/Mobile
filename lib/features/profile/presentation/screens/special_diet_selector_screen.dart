import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/add_item_dialog.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/selectable_item_chip.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/loading_snackbar.dart';
import 'package:zer0_waste_ai/features/profile/application/providers/special_diets_provider.dart';
import 'package:zer0_waste_ai/features/profile/domain/models/special_diet.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/features/auth/application/services/user_preferences_service.dart';

// ✅ RESOLVED: Route name already defined below as routeName and routePath constants

class SpecialDietSelectorScreen extends ConsumerStatefulWidget {
  const SpecialDietSelectorScreen({super.key, this.fromProfile = false});

  static const String routeName = 'special_diet_selector';
  static const String routePath = '/special-diet-selector';

  /// Whether this screen was navigated from profile (for back navigation)
  final bool fromProfile;

  @override
  ConsumerState<SpecialDietSelectorScreen> createState() => _SpecialDietSelectorScreenState();
}

class _SpecialDietSelectorScreenState extends ConsumerState<SpecialDietSelectorScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final selectedDiets = ref.watch(specialDietsProviderWithPersistence);
    final notifier = ref.read(specialDietsProviderWithPersistence.notifier);
    final predefinedDietsAsyncValue = ref.watch(predefinedDietsProvider);

    // Use Theme colors
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color primaryColor = colorScheme.primary;
    final Color backgroundColor = colorScheme.surface;
    final Color mainTextColor = colorScheme.onSurface;
    final Color secondaryTextColor = colorScheme.onSurfaceVariant;
    final Color defaultChipTextColor = colorScheme.onSurfaceVariant;
    final Color defaultChipBorderColor = colorScheme.outline.withValues(
      alpha: 0.5,
    );
    final Color secondaryTextColorForDialog = colorScheme.onSurfaceVariant;

    return predefinedDietsAsyncValue.when(
      data: (predefinedDiets) {
        final predefinedNames = predefinedDiets.map((d) => d.name).toSet();

        // Extract custom diets currently in state
        final List<SpecialDiet> customDietsInState =
            selectedDiets
                .where((d) => d.isCustom && !predefinedNames.contains(d.name))
                .toList();

        // Prepare set of existing names for dialog validation
        final Set<String> existingDietNames =
            selectedDiets.map((d) => d.name).toSet();

        // --- Build the main Scaffold --- START
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "¿Sigues alguna dieta especial?",
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: mainTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Esto nos ayudará a sugerirte recetas adecuadas.",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 32),
                // Diet list/grid implementation
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      children: [
                        // Add predefined diets
                        ...predefinedDiets
                            .where(
                              (diet) =>
                                  diet.name != SpecialDietsNotifier.addDietName,
                            ) // Exclude the placeholder
                            .map(
                              (diet) => SelectableItemChip(
                                label: diet.name,
                                emoji: diet.emoji,
                                isSelected: selectedDiets.contains(diet),
                                onTap:
                                    () => notifier.toggleDiet(
                                      diet,
                                      predefinedDiets,
                                    ),
                                selectedColor: primaryColor,
                                defaultBackgroundColor: backgroundColor,
                                defaultTextColor: defaultChipTextColor,
                                defaultBorderColor: defaultChipBorderColor,
                              ),
                            ),
                        // Add custom diets that are in the state
                        ...customDietsInState.map(
                          (diet) => SelectableItemChip(
                            label: diet.name,
                            emoji: diet.emoji,
                            isSelected: true,
                            isCustom: true,
                            onTap:
                                () =>
                                    notifier.toggleDiet(diet, predefinedDiets),
                            onDelete:
                                () => notifier.toggleDiet(
                                  diet,
                                  predefinedDiets,
                                ), // Removing is same as toggling off
                            selectedColor: primaryColor,
                            defaultBackgroundColor: backgroundColor,
                            defaultTextColor: defaultChipTextColor,
                            defaultBorderColor: defaultChipBorderColor,
                          ),
                        ),
                        // Add the "Add" button chip - Updated onTap
                        SelectableItemChip(
                          label: SpecialDietsNotifier.addDietName.replaceFirst(
                            'Agregar ',
                            '',
                          ),
                          isSelected: false,
                          isAddButton: true,
                          onTap: () {
                            // Call the reusable dialog function
                            showAddItemDialog(
                              context: context,
                              title: 'Agregar Dieta Personalizada',
                              fieldLabel: 'Nombre de la dieta:',
                              hintText: 'Ej: Mediterránea, Vegana...',
                              iconData: FontAwesomeIcons.solidPenToSquare,
                              existingItemNames: existingDietNames,
                              onAdd: (newItemName) {
                                notifier.addCustomDiet(
                                  SpecialDiet(
                                    emoji: '🍴',
                                    name: newItemName,
                                    isCustom: true,
                                  ),
                                );
                              },
                              primaryColor: primaryColor,
                              backgroundColor: backgroundColor,
                              secondaryTextColor: secondaryTextColorForDialog,
                            );
                          },
                          selectedColor: primaryColor,
                          defaultBackgroundColor: backgroundColor,
                          defaultTextColor: defaultChipTextColor,
                          defaultBorderColor: defaultChipBorderColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2, // Subtle shadow
                      shadowColor: primaryColor.withValues(alpha: 0.3),
                      foregroundColor:
                          colorScheme.onPrimary, // Use theme color for text
                    ),
                    onPressed: _isSaving ? null : () async {
                      if (_isSaving) return;
                      
                      setState(() {
                        _isSaving = true;
                      });

                      // Mostrar indicador de carga
                      if (context.mounted) {
                        showLoadingSnackBar(
                          context,
                          message: 'Guardando dietas especiales...',
                        );
                      }

                      // Save special diets to Firestore before navigating
                      try {
                        final authRepository = ref.read(authRepositoryProvider);

                        // Create special diet items with metadata (emoji, isCustom)
                        final List<Map<String, dynamic>> specialDietItems =
                            selectedDiets
                                .map(
                                  (diet) => {
                                    'name': diet.name,
                                    'emoji': diet.emoji,
                                    'isCustom': diet.isCustom,
                                  },
                                )
                                .toList();

                        // Save both simple list and complex structure
                        await authRepository
                            .saveUserSpecialDietItemsWithMetadata(
                              specialDietItems,
                            );

                        // IMPORTANT: Mark initial preferences as completed since this is the last onboarding screen
                        await authRepository.markInitialPreferencesCompleted();

                        // Update UserPreferencesService to reflect completion
                        await ref.read(userPreferencesProvider.notifier).markPreferencesAsCompleted();

                        log('✅ Special diets saved to Firestore successfully');
                        log('✅ Initial preferences marked as completed');
                        log("Selected Diets on Continue: $selectedDiets");

                        // Reset saving state
                        setState(() {
                          _isSaving = false;
                        });

                        // Navigate based on context
                        if (context.mounted) {
                          if (widget.fromProfile) {
                            // From profile - go back to profile
                            context.pop();
                          } else {
                            // From onboarding - go to home (mark preferences completed)
                            context.go('/home');
                          }
                        }
                      } catch (e) {
                        log('❌ Error saving special diets: $e');
                        
                        // Reset saving state
                        setState(() {
                          _isSaving = false;
                        });
                        
                        // Show error to user and don't navigate
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error al guardar las preferencias. Por favor, intenta de nuevo.',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 4),
                              action: SnackBarAction(
                                label: 'Reintentar',
                                textColor: Colors.white,
                                onPressed: () {
                                  // User can press the continue button again
                                },
                              ),
                            ),
                          );
                        }
                        
                        // Don't navigate if save fails to prevent inconsistent state
                        return;
                      }
                    },
                    child: _isSaving 
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Guardando...',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Continuar',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 16), // Add some padding at the bottom
              ],
            ),
          ),
        );
        // --- Build the main Scaffold --- END
      },
      loading:
          () => Scaffold(
            backgroundColor: backgroundColor,
            body: Center(child: CircularProgressIndicator(color: primaryColor)),
          ),
      error:
          (error, stackTrace) => Scaffold(
            backgroundColor: backgroundColor,
            body: Center(
              child: Text(
                'Error al cargar las dietas: $error',
                style: GoogleFonts.inter(color: colorScheme.error),
              ),
            ),
          ),
    );
  }
}
