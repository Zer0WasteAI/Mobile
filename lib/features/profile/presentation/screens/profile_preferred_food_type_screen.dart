import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/loading_snackbar.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/selectable_item_chip.dart';
import 'package:zer0_waste_ai/features/profile/application/providers/food_types_provider.dart';
import 'package:zer0_waste_ai/features/profile/application/providers/selected_food_types_provider.dart';

// Definir los tipos de comida disponibles
enum FoodType {
  italian,
  mexican,
  chinese,
  japanese,
  indian,
  mediterranean,
  american,
  thai,
  french,
  spanish,
  // ignore: constant_identifier_names
  middle_eastern,
  greek,
}

// Extensión para obtener información legible de la enumeración
extension FoodTypeExtension on FoodType {
  String get displayName {
    switch (this) {
      case FoodType.italian:
        return 'Italiana';
      case FoodType.mexican:
        return 'Mexicana';
      case FoodType.chinese:
        return 'China';
      case FoodType.japanese:
        return 'Japonesa';
      case FoodType.indian:
        return 'India';
      case FoodType.mediterranean:
        return 'Mediterránea';
      case FoodType.american:
        return 'Americana';
      case FoodType.thai:
        return 'Tailandesa';
      case FoodType.french:
        return 'Francesa';
      case FoodType.spanish:
        return 'Española';
      case FoodType.middle_eastern:
        return 'Medio Oriente';
      case FoodType.greek:
        return 'Griega';
    }
  }

  IconData get icon {
    switch (this) {
      case FoodType.italian:
        return Icons.local_pizza;
      case FoodType.mexican:
        return Icons.local_dining;
      case FoodType.chinese:
        return Icons.rice_bowl;
      case FoodType.japanese:
        return Icons.set_meal;
      case FoodType.indian:
        return Icons.restaurant;
      case FoodType.mediterranean:
        return Icons.local_bar;
      case FoodType.american:
        return Icons.fastfood;
      case FoodType.thai:
        return Icons.soup_kitchen;
      case FoodType.french:
        return Icons.cake;
      case FoodType.spanish:
        return Icons.tapas;
      case FoodType.middle_eastern:
        return Icons.kebab_dining;
      case FoodType.greek:
        return Icons.lunch_dining;
    }
  }
}

// Provider para los tipos de comida seleccionados
final selectedFoodTypesProvider =
    StateNotifierProvider<SelectedFoodTypesNotifier, List<FoodType>>((ref) {
      // TODO: Load saved preferences
      return SelectedFoodTypesNotifier([]);
    });

class SelectedFoodTypesNotifier extends StateNotifier<List<FoodType>> {
  SelectedFoodTypesNotifier(super.state);

  void toggle(FoodType type) {
    if (state.contains(type)) {
      state = [...state.where((t) => t != type)];
    } else {
      state = [...state, type];
    }
    // TODO: Save preferences
  }
}

class ProfilePreferredFoodTypeScreen extends ConsumerStatefulWidget {
  const ProfilePreferredFoodTypeScreen({super.key});

  static const String routeName = 'profile_preferred_food_type';
  static const String routePath = '/profile/preferred-food-type';

  @override
  ConsumerState<ProfilePreferredFoodTypeScreen> createState() =>
      _ProfilePreferredFoodTypeScreenState();
}

class _ProfilePreferredFoodTypeScreenState
    extends ConsumerState<ProfilePreferredFoodTypeScreen> {
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
    if (_isInitialized) return;

    final foodTypesAsyncValue = ref.read(foodTypesProvider);
    final user = ref.read(authControllerProvider).value;

    // Wait for food types to load if they haven't yet
    if (foodTypesAsyncValue is AsyncLoading) {
      await Future.delayed(const Duration(milliseconds: 500));
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
    final authController = ref.read(authControllerProvider.notifier);

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
      appBar: AppBar(
        title: Text(
          'Comidas preferidas',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Qué tipos de comida prefieres?',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Selecciona tus cocinas favoritas para recibir mejores recomendaciones.',
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

                      // Botón de guardar
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                allFoodTypesAsyncValue.hasValue
                                    ? () async {
                                      // Mostrar indicador de carga
                                      if (context.mounted) {
                                        showLoadingSnackBar(
                                          context,
                                          message:
                                              'Guardando preferencias de comida...',
                                        );
                                      }

                                      try {
                                        // Save selected food types to Firestore - even if empty list
                                        final foodTypeNames =
                                            selectedTypes
                                                .map(
                                                  (foodType) => foodType.name,
                                                )
                                                .toList();

                                        log(
                                          "Guardando tipos de comida en Firestore: $foodTypeNames",
                                        );

                                        await authRepository
                                            .saveUserPreferredFoodTypes(
                                              foodTypeNames, // Could be empty list
                                            );

                                        // Actualizar datos del usuario en memoria
                                        await authController
                                            .refreshUserFromFirestore();

                                        if (context.mounted) {
                                          // Mostrar mensaje de éxito
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Preferencias actualizadas',
                                              ),
                                              backgroundColor:
                                                  colorScheme.primary,
                                            ),
                                          );
                                          // Volver al perfil
                                          context.pop();
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error al guardar: $e',
                                              ),
                                              backgroundColor:
                                                  colorScheme.error,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              textStyle: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('Guardar'),
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

// ignore: unused_element
class _FoodTypeCard extends StatelessWidget {
  final FoodType foodType;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;
  final Color surfaceColor;

  const _FoodTypeCard({
    required this.foodType,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected ? primaryColor.withValues(alpha: 0.15) : surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? primaryColor.withValues(alpha: 0.2)
                        : colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                foodType.icon,
                color: isSelected ? primaryColor : colorScheme.onSurfaceVariant,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              foodType.displayName,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? primaryColor : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
