import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/add_item_dialog.dart'; // Import the shared dialog
import 'package:zer0_waste_ai/core/presentation/widgets/selectable_item_chip.dart'; // Import the shared chip
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart'; // Import auth provider
import 'package:zer0_waste_ai/features/profile/application/providers/allergies_provider.dart';
import 'package:zer0_waste_ai/features/profile/domain/models/allergy.dart';
import 'package:zer0_waste_ai/features/profile/presentation/screens/cooking_level_selector_screen.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/loading_snackbar.dart'; // Importar widget de carga

// --- Riverpod State Management (Selected Allergy Names) ---
final selectedAllergiesProvider =
    StateNotifierProvider.autoDispose<SelectedAllergiesNotifier, Set<String>>((
      ref,
    ) {
      // Using autoDispose to ensure state is reset when leaving the screen
      return SelectedAllergiesNotifier();
    });

class SelectedAllergiesNotifier extends StateNotifier<Set<String>> {
  SelectedAllergiesNotifier() : super({});

  void toggleAllergy(String allergyName) {
    final newState = Set<String>.from(state);
    if (newState.contains(allergyName)) {
      newState.remove(allergyName);
    } else {
      newState.add(allergyName);
    }
    state = newState;
    print("Selected allergy names: $state");
  }

  void addCustomAllergy(String allergyName) {
    if (allergyName.isNotEmpty && !state.contains(allergyName)) {
      state = {...state, allergyName};
      print("Selected allergy names: $state");
    }
  }

  void removeCustomAllergy(String allergyName) {
    state = {...state}..remove(allergyName);
    print("Selected allergy names: $state");
  }

  // Reset state
  void reset() {
    state = {};
  }
}

// --- Screen Widget ---

class AllergySelectorScreen extends ConsumerWidget {
  const AllergySelectorScreen({super.key});

  static const String routeName = 'allergy_selector';
  static const String routePath = '/allergy-selector';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAllergyNames = ref.watch(selectedAllergiesProvider);
    final notifier = ref.read(selectedAllergiesProvider.notifier);
    final allergiesAsyncValue = ref.watch(allergiesProvider);
    final authRepository = ref.read(authRepositoryProvider);

    // Use Theme colors for consistency
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // Define colors based on theme (adjust as needed)
    final Color primaryColor = colorScheme.primary; // Use primary from theme
    final Color backgroundColor = colorScheme.surface; // Use surface from theme
    final Color defaultChipTextColor =
        colorScheme.onSurfaceVariant; // Muted text
    final Color defaultChipBorderColor = colorScheme.outline.withOpacity(0.5);
    final Color secondaryTextColorForDialog =
        colorScheme.onSurfaceVariant; // For dialog text

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Tienes alguna alergia alimentaria?',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona tus alergias para evitar recetas inadecuadas para ti.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: allergiesAsyncValue.when(
                  data: (predefinedAllergies) {
                    final predefinedNames =
                        predefinedAllergies.map((a) => a.name).toSet();
                    final customAllergyNames =
                        selectedAllergyNames
                            .where((name) => !predefinedNames.contains(name))
                            .toList();

                    // Combine all items for the Wrap widget
                    List<Widget> chipWidgets = [];

                    // Add predefined allergies
                    chipWidgets.addAll(
                      predefinedAllergies.map(
                        (allergy) => SelectableItemChip(
                          label: allergy.name,
                          emoji: allergy.emoji,
                          isSelected: selectedAllergyNames.contains(
                            allergy.name,
                          ),
                          onTap: () => notifier.toggleAllergy(allergy.name),
                          selectedColor: primaryColor,
                          defaultBackgroundColor: backgroundColor,
                          defaultTextColor: defaultChipTextColor,
                          defaultBorderColor: defaultChipBorderColor,
                        ),
                      ),
                    );

                    // Add custom allergies
                    chipWidgets.addAll(
                      customAllergyNames.map(
                        (name) => SelectableItemChip(
                          label: name,
                          isSelected: true, // Custom are always selected
                          isCustom: true,
                          onTap: () => notifier.toggleAllergy(name),
                          onDelete: () => notifier.removeCustomAllergy(name),
                          selectedColor: primaryColor,
                          defaultBackgroundColor: backgroundColor,
                          defaultTextColor: defaultChipTextColor,
                          defaultBorderColor: defaultChipBorderColor,
                        ),
                      ),
                    );

                    // Add the "Add" button chip
                    chipWidgets.add(
                      SelectableItemChip(
                        label: 'Agregar otra',
                        isSelected: false,
                        isAddButton: true,
                        onTap: () {
                          // Show a dialog for adding a custom allergy
                          showAddItemDialog(
                            context: context,
                            title: 'Agregar Alergia Personalizada',
                            fieldLabel: 'Nombre de la alergia:',
                            hintText: 'Ej: Fresas, pescado, etc.',
                            iconData: FontAwesomeIcons.allergies,
                            existingItemNames: selectedAllergyNames,
                            onAdd: (newAllergyName) {
                              notifier.addCustomAllergy(newAllergyName);
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
                    );

                    // Return the wrap with all chips
                    return SingleChildScrollView(
                      child: Wrap(
                        spacing: 12.0,
                        runSpacing: 12.0,
                        children: chipWidgets,
                      ),
                    );
                  },
                  loading:
                      () => Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                  error:
                      (error, stack) => Center(
                        child: Text(
                          'Error al cargar alergias: $error',
                          style: GoogleFonts.inter(color: colorScheme.error),
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      allergiesAsyncValue.hasValue
                          ? () async {
                            try {
                              // Mostrar indicador de carga
                              if (context.mounted) {
                                showLoadingSnackBar(
                                  context,
                                  message: 'Guardando alergias...',
                                );
                              }

                              // Siempre guardar la lista de alergias (incluso si está vacía)
                              // Esto garantiza que se guarde un array vacío si no se selecciona ninguna
                              final allergyList = selectedAllergyNames.toList();
                              print(
                                "Guardando alergias en Firestore: $allergyList",
                              );

                              await authRepository.saveUserAllergies(
                                allergyList, // Podría ser una lista vacía
                              );

                              // Reset state to avoid keeping selections
                              notifier.reset();

                              // Continue to the cooking level selector screen
                              if (context.mounted) {
                                // Usar go en lugar de replace para transiciones más fluidas
                                context.go(
                                  CookingLevelSelectorScreen.routePath,
                                );
                              }
                            } catch (e) {
                              print("Error guardando alergias: $e");
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error: No se pudieron guardar las alergias: $e',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        allergiesAsyncValue.hasValue
                            ? primaryColor
                            : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    foregroundColor: colorScheme.onPrimary,
                    textStyle: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Continuar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
