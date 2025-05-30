import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/add_item_dialog.dart'; // Import the shared dialog
import 'package:zer0_waste_ai/core/presentation/widgets/selectable_item_chip.dart'; // Import the shared chip
import 'package:zer0_waste_ai/features/profile/application/providers/allergies_provider.dart';
import 'package:zer0_waste_ai/features/profile/domain/models/allergy.dart';
import 'package:zer0_waste_ai/features/profile/presentation/screens/cooking_level_selector_screen.dart';

// --- Riverpod State Management (Selected Allergy Names) ---
final selectedAllergiesProvider =
    StateNotifierProvider<SelectedAllergiesNotifier, Set<String>>((ref) {
      // TODO: Implement loading from persistence if needed
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
      backgroundColor: backgroundColor, // Use theme-based background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Tienes alergias?',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface, // Use theme text color
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona cualquier alergia alimentaria que tengas. Puedes añadir otras si no están en la lista.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color:
                      colorScheme
                          .onSurfaceVariant, // Use theme secondary text color
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
                        label: 'Otra alergia',
                        isSelected: false,
                        isAddButton: true,
                        onTap: () {
                          // Call the reusable dialog function
                          showAddItemDialog(
                            context: context,
                            title: 'Agregar Alergia',
                            fieldLabel: 'Nombre de la alergia:',
                            hintText: 'Ej: Fresas, Mostaza...',
                            iconData: FontAwesomeIcons.triangleExclamation,
                            existingItemNames: selectedAllergyNames,
                            onAdd: (newItemName) {
                              notifier.addCustomAllergy(newItemName);
                            },
                            primaryColor: primaryColor,
                            backgroundColor: backgroundColor,
                            secondaryTextColor: secondaryTextColorForDialog,
                          );
                        },
                        selectedColor: primaryColor,
                        defaultBackgroundColor: backgroundColor,
                        defaultTextColor:
                            defaultChipTextColor, // Add button text color managed internally
                        defaultBorderColor: defaultChipBorderColor,
                      ),
                    );

                    return SingleChildScrollView(
                      child: Wrap(
                        spacing: 10.0,
                        runSpacing: 10.0,
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
                          ? () {
                            print(
                              'Selected allergy names: $selectedAllergyNames',
                            );
                            context.go(CookingLevelSelectorScreen.routePath);
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
                  child: Text(
                    'Continuar',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
