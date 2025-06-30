import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/selectable_item_chip.dart';
import 'package:zer0_waste_ai/features/profile/application/providers/food_types_provider.dart';
import 'package:zer0_waste_ai/features/profile/application/providers/selected_food_types_provider.dart';
import 'package:zer0_waste_ai/features/profile/presentation/screens/special_diet_selector_screen.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/loading_snackbar.dart';

// --- Screen Widget ---

class PreferredFoodTypeScreen extends ConsumerStatefulWidget {
  const PreferredFoodTypeScreen({super.key, this.fromProfile = false});

  static const String routeName = 'preferred_food_type';
  static const String routePath = '/preferred-food-type';

  /// Whether this screen was navigated from profile (for back navigation)
  final bool fromProfile;

  @override
  ConsumerState<PreferredFoodTypeScreen> createState() =>
      _PreferredFoodTypeScreenState();
}

class _PreferredFoodTypeScreenState
    extends ConsumerState<PreferredFoodTypeScreen> {
  bool _isInitialized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize food types after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFoodTypes();
    });
  }

  Future<void> _initializeFoodTypes() async {
    // When coming from profile, always reinitialize to load current values
    if (_isInitialized && !widget.fromProfile) return;
    
    // Reset state if coming from profile
    if (widget.fromProfile) {
      final notifier = ref.read(
        selectedFoodTypesProviderWithPersistence.notifier,
      );
      notifier.reset();
    }

    final foodTypesAsyncValue = ref.read(foodTypesProvider);
    final user = ref.read(authControllerProvider).value;

    // Wait for food types to load if they haven't yet
    if (foodTypesAsyncValue is AsyncLoading) {
      // ✅ UPDATED: Removed artificial delay
    }

    // Get the list of all available food types
    final availableFoodTypes = ref.read(foodTypesProvider).value ?? [];

    // Get user's selected food types from profile
    final userFoodTypes = user?.prefs.preferredFoodTypes ?? [];
    final userFoodTypeItems = user?.prefs.preferredFoodTypeItems;

    log('Initializing food types selector with:');
    log('- Legacy food type names: $userFoodTypes');
    log('- Food type items: $userFoodTypeItems');

    List<String> foodTypeNamesToInitialize = userFoodTypes;

    // If we have preferredFoodTypeItems, use those instead of legacy preferredFoodTypes
    if (userFoodTypeItems != null && userFoodTypeItems.isNotEmpty) {
      foodTypeNamesToInitialize =
          userFoodTypeItems.map((item) => item['name'] as String).toList();
    }

    // Initialize the selectedFoodTypesProviderWithPersistence with user's saved preferences
    if (foodTypeNamesToInitialize.isNotEmpty && availableFoodTypes.isNotEmpty) {
      final notifier = ref.read(
        selectedFoodTypesProviderWithPersistence.notifier,
      );

      for (final foodTypeName in foodTypeNamesToInitialize) {
        for (final availableFoodType in availableFoodTypes) {
          if (availableFoodType.name.toLowerCase() ==
              foodTypeName.toLowerCase()) {
            notifier.toggleFoodType(availableFoodType);
            log('Added food type to selection: ${availableFoodType.name}');
            break;
          }
        }
      }
    }

    setState(() {
      _isInitialized = true;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedTypes = ref.watch(selectedFoodTypesProviderWithPersistence);
    final notifier = ref.read(
      selectedFoodTypesProviderWithPersistence.notifier,
    );
    final allFoodTypesAsyncValue = ref.watch(foodTypesProvider);
    final authRepository = ref.read(authRepositoryProvider);

    // Use Theme colors
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color primaryColor = colorScheme.primary;
    final Color backgroundColor = colorScheme.surface;
    final Color defaultChipTextColor = colorScheme.onSurfaceVariant;
    final Color defaultChipBorderColor = colorScheme.outline.withValues(
      alpha: 0.5,
    );

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
      body: SafeArea(
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Qué tipos de comida prefieres?',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Selecciona todos tus estilos favoritos.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: allFoodTypesAsyncValue.when(
                          data: (allFoodTypes) {
                            if (allFoodTypes.isEmpty) {
                              return Center(
                                child: Text(
                                  'No se pudieron cargar los tipos de comida.',
                                  style: GoogleFonts.inter(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              );
                            }
                            return SingleChildScrollView(
                              child: Wrap(
                                spacing: 12.0,
                                runSpacing: 12.0,
                                children:
                                    allFoodTypes.map((foodType) {
                                      final isSelected = selectedTypes.contains(
                                        foodType,
                                      );
                                      return SelectableItemChip(
                                        label: foodType.name,
                                        emoji: foodType.emoji,
                                        isSelected: isSelected,
                                        onTap:
                                            () => notifier.toggleFoodType(
                                              foodType,
                                            ),
                                        selectedColor: primaryColor,
                                        defaultBackgroundColor: backgroundColor,
                                        defaultTextColor: defaultChipTextColor,
                                        defaultBorderColor:
                                            defaultChipBorderColor,
                                      );
                                    }).toList(),
                              ),
                            );
                          },
                          loading:
                              () => Center(
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                ),
                              ),
                          error:
                              (error, stack) => Center(
                                child: Text(
                                  'Error al cargar tipos de comida: $error',
                                  style: GoogleFonts.inter(
                                    color: colorScheme.error,
                                  ),
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
                                  // Cancel - reset state and go back
                                  notifier.reset();
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
                                    allFoodTypesAsyncValue.hasValue
                                        ? () async {
                                          try {
                                            // Mostrar indicador de carga
                                            if (context.mounted) {
                                              showLoadingSnackBar(
                                                context,
                                                message:
                                                    'Guardando tipos de comida...',
                                              );
                                            }

                                            // Save selected food types to Firestore
                                            final foodTypeNames =
                                                selectedTypes
                                                    .map((foodType) => foodType.name)
                                                    .toList();

                                            log(
                                              "Guardando tipos de comida en Firestore: $foodTypeNames",
                                            );

                                            await authRepository
                                                .saveUserPreferredFoodTypes(
                                                  foodTypeNames,
                                                );

                                            // Refrescar datos de usuario
                                            await ref
                                                .read(authControllerProvider.notifier)
                                                .refreshUserFromFirestore();

                                            // Reset state to avoid keeping selections
                                            notifier.reset();

                                            // Show success message
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: const Text('Tipos de comida actualizados'),
                                                  backgroundColor: colorScheme.primary,
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                              // Go back to profile
                                              context.go('/profile');
                                            }
                                          } catch (e) {
                                            log(
                                              "Error guardando tipos de comida: $e",
                                            );
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).hideCurrentSnackBar();
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: const Text(
                                                    'Error: No se pudieron guardar los tipos de comida',
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
                                      allFoodTypesAsyncValue.hasValue
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
                                allFoodTypesAsyncValue.hasValue
                                    ? () async {
                                      try {
                                        // Mostrar indicador de carga
                                        if (context.mounted) {
                                          showLoadingSnackBar(
                                            context,
                                            message:
                                                'Guardando tipos de comida...',
                                          );
                                        }

                                        // Save selected food types to Firestore - even if empty list
                                        final foodTypeNames =
                                            selectedTypes
                                                .map((foodType) => foodType.name)
                                                .toList();

                                        log(
                                          "Guardando tipos de comida en Firestore: $foodTypeNames",
                                        );

                                        await authRepository
                                            .saveUserPreferredFoodTypes(
                                              foodTypeNames, // Could be empty list
                                            );

                                        // Refrescar datos de usuario
                                        await ref
                                            .read(authControllerProvider.notifier)
                                            .refreshUserFromFirestore();

                                        // Reset state to avoid keeping selections
                                        notifier.reset();

                                        // Continue to next step in onboarding
                                        if (context.mounted) {
                                          context.go(
                                            SpecialDietSelectorScreen.routePath,
                                          );
                                        }
                                      } catch (e) {
                                        log(
                                          "Error guardando tipos de comida: $e",
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error: No se pudieron guardar los tipos de comida: $e',
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
                                  allFoodTypesAsyncValue.hasValue
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
