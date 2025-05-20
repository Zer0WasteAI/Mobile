import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/add_item_dialog.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/selectable_item_chip.dart';
import 'package:zer0_waste_ai/features/profile/application/providers/special_diets_provider.dart';
import 'package:zer0_waste_ai/features/profile/domain/models/special_diet.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/features/auth/application/services/user_preferences_service.dart';

// TODO: Define route name if needed
// No: Defined below

class SpecialDietSelectorScreen extends ConsumerStatefulWidget {
  const SpecialDietSelectorScreen({super.key});

  static const String routeName = 'special_diet_selector';
  static const String routePath = '/special-diet-selector';

  @override
  ConsumerState<SpecialDietSelectorScreen> createState() =>
      _SpecialDietSelectorScreenState();
}

class _SpecialDietSelectorScreenState
    extends ConsumerState<SpecialDietSelectorScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize diets after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDiets();
    });
  }

  Future<void> _initializeDiets() async {
    if (_isInitialized) return;

    final predefinedDietsAsyncValue = ref.read(predefinedDietsProvider);
    final user = ref.read(authControllerProvider).value;

    // Wait for diets to load if they haven't yet
    if (predefinedDietsAsyncValue is AsyncLoading) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Get the list of all available diets
    final availableDiets = ref.read(predefinedDietsProvider).value ?? [];

    // Get user's selected diets from profile
    final userDiets = user?.specialDiets ?? [];
    final userDietItems = user?.specialDietItems;

    print('Initializing special diets selector with:');
    print('- Legacy diet names: $userDiets');
    print('- Special diet items: $userDietItems');

    List<String> dietNamesToInitialize = userDiets;

    // If we have specialDietItems, use those instead of legacy specialDiets
    if (userDietItems != null && userDietItems.isNotEmpty) {
      dietNamesToInitialize =
          userDietItems.map((item) => item['name'] as String).toList();
    }

    // Initialize the selected diets
    if (dietNamesToInitialize.isNotEmpty) {
      ref
          .read(specialDietsProviderWithPersistence.notifier)
          .initializeFromUserProfile(dietNamesToInitialize, availableDiets);
    }

    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final selectedDiets = ref.watch(specialDietsProviderWithPersistence);
    final notifier = ref.read(specialDietsProviderWithPersistence.notifier);
    final predefinedDietsAsyncValue = ref.watch(predefinedDietsProvider);
    final authRepository = ref.read(authRepositoryProvider);
    final authController = ref.read(authControllerProvider.notifier);

    // Theme colors
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    const backgroundColor = Colors.white;
    final primaryColor = colorScheme.primary;
    final defaultChipTextColor = colorScheme.onSurfaceVariant;
    final defaultChipBorderColor = colorScheme.outline.withOpacity(0.5);
    final secondaryTextColorForDialog = colorScheme.onSurfaceVariant;

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
                  '¿Sigues alguna dieta especial?',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selecciona las dietas que sigues para recibir mejores sugerencias.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                // Diet selection area
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
                    onPressed: () async {
                      // Mostrar indicador de carga
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Text('Guardando preferencias...'),
                              ],
                            ),
                            duration: Duration(seconds: 1),
                            backgroundColor: Colors.black54,
                          ),
                        );
                      }

                      try {
                        // 1. Save special diets to Firestore
                        final dietNames =
                            selectedDiets.map((diet) => diet.name).toList();

                        // Create diet items with metadata
                        final dietItems =
                            selectedDiets.map((diet) => diet.toJson()).toList();

                        print(
                          "Guardando dietas especiales en Firestore: $dietNames",
                        );
                        print(
                          "Guardando dietas especiales con metadata: $dietItems",
                        );

                        // Guardar las dietas con metadata
                        await authRepository.saveUserSpecialDietItems(
                          dietItems,
                        );

                        // 2. Mark initial preferences as completed
                        await authRepository.markInitialPreferencesCompleted();

                        // 3. Refresh user data from Firestore
                        await authController.refreshUserFromFirestore();

                        // 4. Mark preferences as completed in memory to avoid redirection loops
                        ref
                            .read(userPreferencesProvider.notifier)
                            .markPreferencesAsCompleted();

                        // Forzar actualización del estado de userPreferences para el router
                        final userPreferencesNotifier = ref.read(
                          userPreferencesProvider.notifier,
                        );
                        await userPreferencesNotifier.loadUserPreferences();

                        // Forzar actualización directa desde el estado del usuario (doble verificación)
                        await userPreferencesNotifier
                            .forceUpdateFromUserState();

                        // Reset state to avoid keeping selections
                        notifier.reset();

                        print("Resetting special diet selections");

                        // Debug logs para diagnóstico
                        print(
                          '====== ESTADO DE PREFERENCIAS ANTES DE NAVEGACIÓN ======',
                        );
                        print(
                          'userPreferencesProvider.hasCompletedPreferences = ${ref.read(userPreferencesProvider).hasCompletedPreferences}',
                        );
                        print(
                          'userPreferencesProvider.isLoading = ${ref.read(userPreferencesProvider).isLoading}',
                        );
                        print(
                          'authState.initialPreferencesCompleted = ${ref.read(authControllerProvider).value?.initialPreferencesCompleted}',
                        );
                        print('====== FIN ESTADO DE PREFERENCIAS ======');

                        // 5. Navigate to home screen or dashboard
                        if (context.mounted) {
                          // Navigate to home page with replaced stack
                          print("Going to /home");
                          context.go(
                            '/home',
                          ); // Using go instead of replace for smoother transition

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '¡Preferencias guardadas! Tus recomendaciones ahora serán personalizadas.',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        print("Error guardando preferencias: $e");
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error: No se pudieron guardar tus preferencias: $e',
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
                      textStyle: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Finalizar configuración'),
                  ),
                ),
              ],
            ),
          ),
        );
        // --- Build the main Scaffold --- END
      },
      loading:
          () => Scaffold(
            backgroundColor: backgroundColor,
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (error, stackTrace) => Scaffold(
            backgroundColor: backgroundColor,
            body: Center(
              child: Text(
                'Error: $error',
                style: GoogleFonts.inter(color: Colors.red),
              ),
            ),
          ),
    );
  }
}
