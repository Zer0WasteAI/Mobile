import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/loading_snackbar.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/selectable_item_chip.dart';
import 'package:zer0_waste_ai/features/profile/application/providers/special_diets_provider.dart';
import 'package:zer0_waste_ai/features/profile/domain/models/special_diet.dart';

// Enum para los tipos de dieta especial
enum SpecialDietType {
  vegetarian,
  vegan,
  pescatarian,
  paleo,
  keto,
  lowCarb,
  glutenFree,
  dairyFree,
  lowFat,
  mediterranean,
}

// Extensión para obtener información legible
extension SpecialDietTypeExtension on SpecialDietType {
  String get displayName {
    switch (this) {
      case SpecialDietType.vegetarian:
        return 'Vegetariana';
      case SpecialDietType.vegan:
        return 'Vegana';
      case SpecialDietType.pescatarian:
        return 'Pescetariana';
      case SpecialDietType.paleo:
        return 'Paleo';
      case SpecialDietType.keto:
        return 'Keto';
      case SpecialDietType.lowCarb:
        return 'Baja en carbohidratos';
      case SpecialDietType.glutenFree:
        return 'Sin gluten';
      case SpecialDietType.dairyFree:
        return 'Sin lácteos';
      case SpecialDietType.lowFat:
        return 'Baja en grasas';
      case SpecialDietType.mediterranean:
        return 'Mediterránea';
    }
  }

  String get description {
    switch (this) {
      case SpecialDietType.vegetarian:
        return 'No carne, pero sí huevos y lácteos';
      case SpecialDietType.vegan:
        return 'Sin productos de origen animal';
      case SpecialDietType.pescatarian:
        return 'Vegetariana + pescado y mariscos';
      case SpecialDietType.paleo:
        return 'Basada en alimentos ancestrales';
      case SpecialDietType.keto:
        return 'Alta en grasas, baja en carbohidratos';
      case SpecialDietType.lowCarb:
        return 'Reducción de carbohidratos';
      case SpecialDietType.glutenFree:
        return 'Sin trigo, cebada ni centeno';
      case SpecialDietType.dairyFree:
        return 'Sin leche ni derivados';
      case SpecialDietType.lowFat:
        return 'Reducción de grasas';
      case SpecialDietType.mediterranean:
        return 'Rica en grasas saludables y vegetales';
    }
  }

  IconData get icon {
    switch (this) {
      case SpecialDietType.vegetarian:
        return Icons.eco;
      case SpecialDietType.vegan:
        return Icons.spa;
      case SpecialDietType.pescatarian:
        return Icons.set_meal;
      case SpecialDietType.paleo:
        return Icons.lunch_dining;
      case SpecialDietType.keto:
        return Icons.egg_alt;
      case SpecialDietType.lowCarb:
        return Icons.grain_outlined;
      case SpecialDietType.glutenFree:
        return Icons.block;
      case SpecialDietType.dairyFree:
        return Icons.no_drinks;
      case SpecialDietType.lowFat:
        return Icons.opacity;
      case SpecialDietType.mediterranean:
        return Icons.local_bar;
    }
  }
}

// DEPRECATED: Legacy provider for special diets (replaced by specialDietsProviderWithPersistence)
// ADVICE: Use specialDietsProviderWithPersistence from special_diets_provider.dart
final selectedDietProvider = StateNotifierProvider<
  SelectedDietNotifier,
  SpecialDietType?
>((ref) {
  // INFO: This provider is deprecated - use specialDietsProviderWithPersistence instead
  return SelectedDietNotifier(null);
});

class SelectedDietNotifier extends StateNotifier<SpecialDietType?> {
  SelectedDietNotifier(super.state);

  void selectDiet(SpecialDietType? type) {
    state = type;
    // INFO: This is a legacy method - use specialDietsProviderWithPersistence for persistence
  }
}

class ProfileSpecialDietSelectorScreen extends ConsumerStatefulWidget {
  const ProfileSpecialDietSelectorScreen({super.key});

  static const String routeName = 'profile_special_diet_selector';
  static const String routePath = '/profile/special-diet-selector';

  @override
  ConsumerState<ProfileSpecialDietSelectorScreen> createState() =>
      _ProfileSpecialDietSelectorScreenState();
}

class _ProfileSpecialDietSelectorScreenState
    extends ConsumerState<ProfileSpecialDietSelectorScreen> {
  bool _isLoading = true;
  final TextEditingController _dietController = TextEditingController();
  final List<String> _commonEmojis = [
    '🥗',
    '🥦',
    '🥑',
    '🍖',
    '🥩',
    '🐟',
    '🥛',
    '🧀',
    '🍽️',
  ];
  String _selectedEmoji = '🍽️';

  @override
  void initState() {
    super.initState();
    // Initialize diets after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDiets();
    });
  }

  @override
  void dispose() {
    _dietController.dispose();
    super.dispose();
  }

  Future<void> _initializeDiets() async {
    // ignore: unused_local_variable
    final dietsAsyncValue = ref.read(predefinedDietsProvider);
    final user = ref.read(authStateProvider).value;

    // Get the list of all available diets
    final availableDiets = ref.read(predefinedDietsProvider).value ?? [];

    // Get user's selected diets from profile
    final userDiets = user?.prefs.specialDiets ?? [];
    final userDietItems = user?.prefs.specialDietItems;

    log('Initializing special diets selector with:');
    log('- Legacy diet names: $userDiets');
    log('- Special diet items: $userDietItems');

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

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show dialog to add custom diet
  void _showAddDietDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Añadir dieta personalizada',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _dietController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de la dieta',
                        hintText: 'Ej: Ayuno intermitente, Kosher, etc.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Elige un emoji:',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          _commonEmojis.map((emoji) {
                            final isSelected = emoji == _selectedEmoji;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedEmoji = emoji;
                                });
                              },
                              borderRadius: BorderRadius.circular(32),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.1)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withValues(alpha: 0.5),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.inter(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_dietController.text.trim().isNotEmpty) {
                      // Add custom diet
                      final customDiet = SpecialDiet(
                        name: _dietController.text.trim(),
                        emoji: _selectedEmoji,
                        isCustom: true,
                      );

                      ref
                          .read(specialDietsProviderWithPersistence.notifier)
                          .addCustomDiet(customDiet);

                      // Reset controller and close dialog
                      _dietController.clear();
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Text(
                    'Añadir',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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

    final backgroundColor = colorScheme.surface;
    final primaryColor = colorScheme.primary;
    final defaultChipTextColor = colorScheme.onSurfaceVariant;
    final defaultChipBorderColor = colorScheme.outline.withValues(alpha: 0.5);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Dieta especial',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: predefinedDietsAsyncValue.when(
        data: (predefinedDiets) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter out the "Add" button from selection
          final dietOptions =
              predefinedDiets
                  .where(
                    (diet) => diet.name != SpecialDietsNotifier.addDietName,
                  )
                  .toList();

          // Create a list of all widget items to display
          final List<Widget> dietChips = [];

          // Add predefined diets
          for (final diet in dietOptions) {
            dietChips.add(
              SelectableItemChip(
                label: diet.name,
                emoji: diet.emoji,
                isSelected: selectedDiets.contains(diet),
                onTap: () => notifier.toggleDiet(diet, predefinedDiets),
                selectedColor: primaryColor,
                defaultBackgroundColor: backgroundColor,
                defaultTextColor: defaultChipTextColor,
                defaultBorderColor: defaultChipBorderColor,
              ),
            );
          }

          // Add custom diets that aren't in predefined diets
          for (final customDiet in selectedDiets) {
            // Skip if it's in the predefined list
            if (dietOptions.any((d) => d.name == customDiet.name)) {
              continue;
            }

            dietChips.add(
              SelectableItemChip(
                label: customDiet.name,
                emoji: customDiet.emoji,
                isSelected: true,
                isCustom: true,
                onTap: () => notifier.toggleDiet(customDiet, predefinedDiets),
                onDelete:
                    () => notifier.toggleDiet(customDiet, predefinedDiets),
                selectedColor: primaryColor,
                defaultBackgroundColor: backgroundColor,
                defaultTextColor: defaultChipTextColor,
                defaultBorderColor: defaultChipBorderColor,
              ),
            );
          }

          // Add "Añadir" chip
          dietChips.add(
            InkWell(
              onTap: _showAddDietDialog,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Añadir',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Sigues alguna dieta especial?',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona tu tipo de dieta para recibir recetas adecuadas.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Lista de dietas disponibles
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 12.0,
                        runSpacing: 12.0,
                        children: dietChips,
                      ),
                    ),
                  ),

                  // Botón de guardar
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Mostrar indicador de carga
                          if (context.mounted) {
                            showLoadingSnackBar(
                              context,
                              message: 'Guardando dieta especial...',
                            );
                          }

                          try {
                            // Save special diets to Firestore
                            final dietNames =
                                selectedDiets.map((diet) => diet.name).toList();

                            // Create dietItems with custom flag
                            final dietItems =
                                selectedDiets
                                    .map((diet) => diet.toJson())
                                    .toList();

                            log("Guardando dietas especiales: $dietNames");
                            log("Guardando diet items: $dietItems");

                            // Save the diets using new method
                            await authRepository.saveUserSpecialDietItems(
                              dietNames,
                            );

                            // Refresh user data
                            await authController.refreshUserFromFirestore();

                            if (context.mounted) {
                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Dieta actualizada'),
                                  backgroundColor: colorScheme.primary,
                                ),
                              );
                              context.pop();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al guardar: $e'),
                                  backgroundColor: colorScheme.error,
                                ),
                              );
                            }
                          }
                        },
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Text(
                'Error al cargar dietas: $error',
                style: TextStyle(color: colorScheme.error),
              ),
            ),
      ),
    );
  }
}

// ignore: unused_element
class _SpecialDietCard extends StatelessWidget {
  final SpecialDietType dietType;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;
  final Color surfaceColor;

  const _SpecialDietCard({
    required this.dietType,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isSelected
                  ? primaryColor
                  : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected ? primaryColor.withValues(alpha: 0.1) : surfaceColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
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
                  dietType.icon,
                  color:
                      isSelected ? primaryColor : colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dietType.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color:
                            isSelected ? primaryColor : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dietType.description,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
