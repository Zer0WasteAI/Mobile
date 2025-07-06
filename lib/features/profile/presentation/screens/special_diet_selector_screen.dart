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
import 'package:zer0_waste_ai/features/profile/application/providers/user_profile_provider.dart';

// ✅ RESOLVED: Route name already defined below as routeName and routePath constants

class SpecialDietSelectorScreen extends ConsumerStatefulWidget {
  const SpecialDietSelectorScreen({super.key, this.fromProfile = false});

  static const String routeName = 'special_diet_selector';
  static const String routePath = '/special-diet-selector';

  /// Whether this screen was navigated from profile (for back navigation)
  final bool fromProfile;

  @override
  ConsumerState<SpecialDietSelectorScreen> createState() =>
      _SpecialDietSelectorScreenState();
}

class _SpecialDietSelectorScreenState
    extends ConsumerState<SpecialDietSelectorScreen> {
  bool _isInitialized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize special diets after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSpecialDiets();
    });
  }

  Future<void> _initializeSpecialDiets() async {
    // When coming from profile, always reinitialize to load current values
    if (_isInitialized && !widget.fromProfile) return;

    final predefinedDietsAsyncValue = ref.read(predefinedDietsProvider);
    final user = ref.read(authStateProvider).value;

    log(
      '🔧 _initializeSpecialDiets - widget.fromProfile: ${widget.fromProfile}',
    );

    // Reset state BEFORE loading data when coming from profile
    if (widget.fromProfile) {
      final notifier = ref.read(specialDietsProviderWithPersistence.notifier);
      notifier.reset();
      log('🔄 Reset special diets state for profile editing');
    }

    // Wait for diets to load if they haven't yet
    if (predefinedDietsAsyncValue is AsyncLoading) {
      log('⏳ Special diets still loading, waiting...');
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Get the list of all available diets
    final availableDiets = ref.read(predefinedDietsProvider).value ?? [];
    log('📋 Available diets: ${availableDiets.map((d) => d.name).toList()}');

    // Get user's selected diets from profile
    final userDiets =
        user?.prefs.specialDietItems.isNotEmpty == true
            ? user!.prefs.specialDietItems
                .map((item) => item['name'] as String)
                .toList()
            : user?.prefs.specialDiets ?? [];

    log('🔧 Initializing special diets selector with: $userDiets');

    // Initialize with user's saved preferences
    if (userDiets.isNotEmpty && availableDiets.isNotEmpty) {
      final notifier = ref.read(specialDietsProviderWithPersistence.notifier);

      for (final dietName in userDiets) {
        log('🔍 Looking for diet: "$dietName"');
        bool found = false;

        // Find matching predefined diet
        final predefinedDiet =
            availableDiets.where((d) => d.name == dietName).firstOrNull;
        if (predefinedDiet != null) {
          notifier.toggleDiet(predefinedDiet, availableDiets);
          log('✅ Added predefined diet to selection: ${predefinedDiet.name}');
          found = true;
        } else {
          // Create custom diet
          final customDiet = SpecialDiet(
            name: dietName,
            emoji: '🍴',
            isCustom: true,
          );
          notifier.addCustomDiet(customDiet);
          log('✅ Added custom diet to selection: $dietName');
          found = true;
        }

        if (!found) {
          log('❌ Diet not processed: "$dietName"');
        }
      }
    } else {
      log('⚠️ No diets to initialize or available diets list is empty');
      log('   - userDiets: $userDiets');
      log('   - availableDiets count: ${availableDiets.length}');
    }

    setState(() {
      _isInitialized = true;
      _isLoading = false;
    });

    log('✅ Special diets initialization completed');
  }

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

    // Show loading if still initializing
    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

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
                          onPressed: () async {
                            // Mostrar indicador de carga
                            if (context.mounted) {
                              showLoadingSnackBar(
                                context,
                                message: 'Guardando dietas especiales...',
                              );
                            }

                            // Save special diets to Firestore
                            try {
                              final authRepository = ref.read(
                                authRepositoryProvider,
                              );

                              // Create special diet items with metadata (emoji, isCustom)
                              final List<Map<String, dynamic>>
                              specialDietItems =
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

                              // Refrescar datos de usuario y estado de autenticación
                              await ref
                                  .read(authControllerProvider.notifier)
                                  .refreshUserFromFirestore();

                              // Force refresh del perfil para asegurar actualización
                              await ref
                                  .read(userProfileProvider.notifier)
                                  .refresh();

                              log(
                                '✅ Special diets saved to Firestore successfully',
                              );
                              log("Selected Diets on Save: $selectedDiets");

                              // Show success message
                              if (context.mounted) {
                                ScaffoldMessenger.of(
                                  context,
                                ).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Dietas especiales actualizadas',
                                    ),
                                    backgroundColor: colorScheme.primary,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                // Go back to profile
                                context.go('/profile');
                              }
                            } catch (e) {
                              log('❌ Error saving special diets: $e');
                              if (context.mounted) {
                                ScaffoldMessenger.of(
                                  context,
                                ).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Error: No se pudieron guardar las dietas',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
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
                      onPressed: () async {
                        // Mostrar indicador de carga
                        if (context.mounted) {
                          showLoadingSnackBar(
                            context,
                            message: 'Guardando dietas especiales...',
                          );
                        }

                        // Save special diets to Firestore before navigating
                        try {
                          final authRepository = ref.read(
                            authRepositoryProvider,
                          );

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
                          await authRepository
                              .markInitialPreferencesCompleted();

                          // Refrescar datos de usuario y estado de autenticación
                          await ref
                              .read(authControllerProvider.notifier)
                              .refreshUserFromFirestore();

                          // Force refresh del perfil para asegurar actualización
                          await ref
                              .read(userProfileProvider.notifier)
                              .refresh();

                          log(
                            '✅ Special diets saved to Firestore successfully',
                          );
                          log('✅ Initial preferences marked as completed');
                          log("Selected Diets on Continue: $selectedDiets");

                          // Continue to home after onboarding
                          if (context.mounted) {
                            context.go('/home');
                          }
                        } catch (e) {
                          log('❌ Error saving special diets: $e');
                          // Still navigate even if save fails
                          if (context.mounted) {
                            context.go('/home');
                          }
                        }
                      },
                      child: Text(
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
