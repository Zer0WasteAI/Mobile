import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/selectable_item_chip.dart';
import 'package:zer0_waste_ai/features/profile/application/providers/special_diets_provider.dart';
import 'package:zer0_waste_ai/features/profile/domain/models/special_diet.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/features/auth/application/services/user_preferences_service.dart';
import 'package:zer0_waste_ai/features/auth/data/models/user_model.dart';

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
    final defaultChipBorderColor = colorScheme.outline.withValues(alpha: 0.5);

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
                                                .withOpacity(0.1)
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
                                                  .withOpacity(0.5),
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
                        //TODO: Add the "Add" button chip - Updated onTap
                        SelectableItemChip(
                          label: SpecialDietsNotifier.addDietName.replaceFirst(
                            'Agregar ',
                            '',
                          ),
                          isSelected: false,
                          isAddButton: true,
                          onTap: () {
                            // Mostrar diálogo consistente con el que se muestra en la imagen
                            _showAddDietDialog();
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
                      try {
                        // 1. INMEDIATAMENTE marcar preferencias completadas en memoria
                        // Esto permite que el router vea el estado correcto al instante
                        print(
                          '⚡ Marcando preferencias completadas en memoria INMEDIATAMENTE',
                        );

                        // Actualizar userPreferencesProvider
                        ref
                            .read(userPreferencesProvider.notifier)
                            .markPreferencesAsCompleted();

                        // Actualizar authControllerProvider - marcar preferencias en el usuario actual
                        final currentUser =
                            ref.read(authControllerProvider).value;
                        if (currentUser != null) {
                          final updatedUser = currentUser.copyWith(
                            initialPreferencesCompleted: true,
                          );
                          ref
                              .read(authControllerProvider.notifier)
                              .state = AsyncValue.data(updatedUser);
                          print(
                            '✅ AuthController actualizado con preferencias completadas',
                          );
                        }

                        print(
                          '✅ Estado en memoria actualizado - router puede navegar',
                        );

                        // 2. Forzar navegación inmediata (el router a veces no detecta el cambio inmediato)
                        if (context.mounted) {
                          print('🚀 Forzando navegación inmediata a home');
                          context.go('/home');
                        }

                        // 3. Mostrar mensaje de éxito inmediato
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '¡Configuración completada! Bienvenido a Zero Waste AI.',
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }

                        // 4. En background: Guardar en Firestore (sin esperar)
                        print('🔄 Guardando en Firestore en background...');

                        // Guardar dietas especiales
                        final dietNames =
                            selectedDiets.map((diet) => diet.name).toList();
                        final dietItems =
                            selectedDiets.map((diet) => diet.toJson()).toList();

                        authRepository
                            .saveUserSpecialDietItems(dietItems)
                            .then((_) {
                              print(
                                '✅ Dietas especiales guardadas en Firestore',
                              );
                            })
                            .catchError((e) {
                              print('❌ Error guardando dietas: $e');
                            });

                        // Marcar preferencias completadas en Firestore
                        authRepository
                            .markInitialPreferencesCompleted()
                            .then((_) {
                              print('✅ Preferencias marcadas en Firestore');
                              // NO invalidar providers aquí - el widget ya está dispuesto
                              // Los providers se actualizarán automáticamente cuando se lean de nuevo
                            })
                            .catchError((e) {
                              print('❌ Error marcando preferencias: $e');
                            });

                        // 5. Reset local state
                        notifier.reset();

                        print(
                          '🚀 Configuración completada - navegación inmediata disponible',
                        );
                      } catch (e) {
                        print('❌ Error al finalizar configuración: $e');

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 5),
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
