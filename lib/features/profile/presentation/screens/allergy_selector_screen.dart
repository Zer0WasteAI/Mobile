import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/add_item_dialog.dart'; // Import the shared dialog
import 'package:zer0_waste_ai/core/presentation/widgets/selectable_item_chip.dart'; // Import the shared chip
import 'package:zer0_waste_ai/core/presentation/widgets/loading_snackbar.dart';
import 'package:zer0_waste_ai/features/profile/application/providers/allergies_provider.dart';
import 'package:zer0_waste_ai/features/profile/presentation/screens/cooking_level_selector_screen.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/features/profile/application/providers/user_profile_provider.dart';

// --- Riverpod State Management (Selected Allergy Names) ---
final selectedAllergiesProvider =
    StateNotifierProvider<SelectedAllergiesNotifier, Set<String>>((ref) {
      return SelectedAllergiesNotifier();
    });

class SelectedAllergiesNotifier extends StateNotifier<Set<String>> {
  SelectedAllergiesNotifier() : super({});
  bool _isInitializing = false;

  void toggleAllergy(String allergyName) {
    if (_isInitializing) return;

    final newState = Set<String>.from(state);
    if (newState.contains(allergyName)) {
      newState.remove(allergyName);
    } else {
      newState.add(allergyName);
    }
    state = newState;
    log("Toggled allergy: $allergyName - Current state: $state");
  }

  void addCustomAllergy(String allergyName) {
    if (_isInitializing) return;

    if (allergyName.isNotEmpty && !state.contains(allergyName)) {
      state = {...state, allergyName};
      log("Added custom allergy: $allergyName - Current state: $state");
    }
  }

  void removeCustomAllergy(String allergyName) {
    if (_isInitializing) return;

    state = {...state}..remove(allergyName);
    log("Removed custom allergy: $allergyName - Current state: $state");
  }

  void initializeFromProfile(List<String> allergies) {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      // Crear un nuevo Set con las alergias
      final newState = Set<String>.from(allergies);

      // Solo actualizar si hay cambios
      if (newState != state) {
        state = newState;
        log("Initialized allergies from profile: $state");
      } else {
        log("No changes needed during initialization");
      }
    } catch (e) {
      log("Error initializing allergies: $e");
    } finally {
      _isInitializing = false;
    }
  }

  void reset() {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      state = {};
      log("Reset allergies state");
    } finally {
      _isInitializing = false;
    }
  }
}

// --- Screen Widget ---

/// INFO: Allergy selector for onboarding/first-time setup
/// USAGE: Used during user registration and initial preferences setup
/// NOTE: For profile editing with persistence, use ProfileAllergySelectorScreen
class AllergySelectorScreen extends ConsumerStatefulWidget {
  const AllergySelectorScreen({super.key, this.fromProfile = false});

  static const String routeName = 'allergy_selector';
  static const String routePath = '/allergy-selector';

  /// Whether this screen was navigated from profile (for back navigation)
  final bool fromProfile;

  @override
  ConsumerState<AllergySelectorScreen> createState() =>
      _AllergySelectorScreenState();
}

class _AllergySelectorScreenState extends ConsumerState<AllergySelectorScreen> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Mover la inicialización a después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAllergies();
    });
  }

  Future<void> _initializeAllergies() async {
    if (_hasInitialized) return;

    final authState = ref.read(authStateProvider);
    if (!authState.hasValue || !widget.fromProfile) {
      _hasInitialized = true;
      return;
    }

    final user = authState.value;
    if (user == null) {
      _hasInitialized = true;
      return;
    }

    final userAllergies =
        user.prefs.allergyItems.isNotEmpty
            ? user.prefs.allergyItems
                .map((item) => item['name'] as String)
                .toList()
            : user.prefs.allergies;

    // Usar Future.microtask para asegurar que la actualización ocurra después del build
    await Future.microtask(() {
      if (!mounted) return;
      final notifier = ref.read(selectedAllergiesProvider.notifier);
      notifier.initializeFromProfile(userAllergies);
    });

    _hasInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final selectedAllergyNames = ref.watch(selectedAllergiesProvider);
    final notifier = ref.read(selectedAllergiesProvider.notifier);
    final allergiesAsyncValue = ref.watch(allergiesProvider);
    // ignore: unused_local_variable
    final authState = ref.watch(authStateProvider);

    // Use Theme colors for consistency
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // ignore: unused_local_variable
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // Define colors based on theme (adjust as needed)
    final Color primaryColor = colorScheme.primary; // Use primary from theme
    final Color backgroundColor = colorScheme.surface; // Use surface from theme
    final Color defaultChipTextColor =
        colorScheme.onSurfaceVariant; // Muted text
    final Color defaultChipBorderColor = colorScheme.outline.withValues(
      alpha: 0.5,
    );
    final Color secondaryTextColorForDialog =
        colorScheme.onSurfaceVariant; // For dialog text

    return Scaffold(
      backgroundColor: backgroundColor, // Use theme-based background
      appBar:
          widget.fromProfile
              ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurface),
                  onPressed: () => context.go('/profile'),
                ),
              )
              : null,
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
              // Bottom Buttons
              if (widget.fromProfile) ...[
                // Show Save and Cancel buttons when editing from profile
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Cancel - go back without saving
                          context.go('/profile');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.onSurface,
                          side: BorderSide(color: colorScheme.outline),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed:
                            allergiesAsyncValue.hasValue
                                ? () async {
                                  // Mostrar indicador de carga
                                  if (context.mounted) {
                                    showLoadingSnackBar(
                                      context,
                                      message: 'Guardando alergias...',
                                    );
                                  }

                                  log(
                                    'Selected allergy names: $selectedAllergyNames',
                                  );

                                  // Save allergies to Firestore
                                  try {
                                    final authRepository = ref.read(
                                      authRepositoryProvider,
                                    );
                                    final allergies =
                                        ref.read(allergiesProvider).value ?? [];

                                    // Create allergy items with metadata (emoji, isCustom)
                                    final List<Map<String, dynamic>>
                                    allergyItems = [];

                                    for (final allergyName
                                        in selectedAllergyNames) {
                                      // Find if it's a predefined allergy
                                      final predefinedAllergy =
                                          allergies
                                              .where(
                                                (a) => a.name == allergyName,
                                              )
                                              .firstOrNull;

                                      if (predefinedAllergy != null) {
                                        // Predefined allergy
                                        allergyItems.add({
                                          'name': predefinedAllergy.name,
                                          'emoji': predefinedAllergy.emoji,
                                          'isCustom': false,
                                        });
                                      } else {
                                        // Custom allergy
                                        allergyItems.add({
                                          'name': allergyName,
                                          'emoji': '🚫',
                                          'isCustom': true,
                                        });
                                      }
                                    }

                                    // Save both simple list and complex structure
                                    await authRepository
                                        .saveUserAllergyItemsWithMetadata(
                                          allergyItems,
                                        );

                                    // Refrescar datos de usuario y estado de autenticación
                                    await ref
                                        .read(authControllerProvider.notifier)
                                        .refreshUserFromFirestore();

                                    // Force refresh del perfil para asegurar actualización
                                    await ref
                                        .read(userProfileProvider.notifier)
                                        .refresh();

                                    log(
                                      '✅ Allergies saved to Firestore successfully',
                                    );

                                    // Show success message
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).hideCurrentSnackBar();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Alergias actualizadas',
                                          ),
                                          backgroundColor: colorScheme.primary,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                      // Go back to profile
                                      context.go('/profile');
                                    }
                                  } catch (e) {
                                    log('❌ Error saving allergies: $e');
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).hideCurrentSnackBar();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Error: No se pudieron guardar las alergias',
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
                        ),
                        child: Text(
                          'Guardar',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else
                // Show single Continue button for onboarding
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        allergiesAsyncValue.hasValue
                            ? () async {
                              // Mostrar indicador de carga
                              if (context.mounted) {
                                showLoadingSnackBar(
                                  context,
                                  message: 'Guardando alergias...',
                                );
                              }

                              log(
                                'Selected allergy names: $selectedAllergyNames',
                              );

                              // Save allergies to Firestore before navigating
                              try {
                                final authRepository = ref.read(
                                  authRepositoryProvider,
                                );
                                final allergies =
                                    ref.read(allergiesProvider).value ?? [];

                                // Create allergy items with metadata (emoji, isCustom)
                                final List<Map<String, dynamic>> allergyItems =
                                    [];

                                for (final allergyName
                                    in selectedAllergyNames) {
                                  // Find if it's a predefined allergy
                                  final predefinedAllergy =
                                      allergies
                                          .where((a) => a.name == allergyName)
                                          .firstOrNull;

                                  if (predefinedAllergy != null) {
                                    // Predefined allergy
                                    allergyItems.add({
                                      'name': predefinedAllergy.name,
                                      'emoji': predefinedAllergy.emoji,
                                      'isCustom': false,
                                    });
                                  } else {
                                    // Custom allergy
                                    allergyItems.add({
                                      'name': allergyName,
                                      'emoji':
                                          '🚫', // Default emoji for custom allergies
                                      'isCustom': true,
                                    });
                                  }
                                }

                                // Save both simple list and complex structure
                                await authRepository
                                    .saveUserAllergyItemsWithMetadata(
                                      allergyItems,
                                    );

                                // Refrescar datos de usuario y estado de autenticación
                                await ref
                                    .read(authControllerProvider.notifier)
                                    .refreshUserFromFirestore();

                                // Force refresh del perfil para asegurar actualización
                                await ref
                                    .read(userProfileProvider.notifier)
                                    .refresh();

                                log(
                                  '✅ Allergies saved to Firestore successfully',
                                );

                                // Continue to next step in onboarding
                                if (context.mounted) {
                                  context.go(
                                    CookingLevelSelectorScreen.routePath,
                                  );
                                }
                              } catch (e) {
                                log('❌ Error saving allergies: $e');
                                // Still navigate even if save fails
                                if (context.mounted) {
                                  context.go(
                                    CookingLevelSelectorScreen.routePath,
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
