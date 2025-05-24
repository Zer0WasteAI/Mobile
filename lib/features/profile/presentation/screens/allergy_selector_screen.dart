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
import 'package:zer0_waste_ai/core/presentation/widgets/loading_snackbar.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/app_dialog.dart';
import 'package:zer0_waste_ai/features/profile/presentation/screens/profile_allergy_selector_screen.dart';

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

    final TextEditingController _allergyController = TextEditingController();
    final List<String> _commonEmojis = [
      '🍞',
      '🥚',
      '🥜',
      '🥛',
      '🦐',
      '🌾',
      '🌿',
      '🫘',
      '⚠️',
    ];

    String _selectedEmoji = '⚠️';

    void _showAddAllergyDialog(SelectedAllergiesNotifier allergyNotifier) {
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(
                  'Añadir alergia personalizada',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _allergyController,
                        decoration: InputDecoration(
                          labelText: 'Nombre de la alergia',
                          hintText: 'Ej: Mostaza, Apio, etc.',
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
                      if (_allergyController.text.trim().isNotEmpty) {
                        // Add custom allergy using the passed notifier
                        allergyNotifier.addCustomAllergy(
                          _allergyController.text.trim(),
                        );

                        // Reset controller and close dialog
                        _allergyController.clear();
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

    return Scaffold(
      backgroundColor: backgroundColor, // Use theme-based background
      appBar: AppBar(
        title: Text(
          'Alergias alimentarias',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Tienes alguna alergia?',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface, // Use theme text color
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona los alimentos a los que eres alérgico para evitarlos en tus recetas.',
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
                        label: 'Añadir',
                        isSelected: false,
                        isAddButton: true,
                        onTap: () {
                          _showAddAllergyDialog(notifier);
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
                          ? () async {
                            print(
                              'Selected allergy names: $selectedAllergyNames',
                            );

                            // Mostrar indicador de carga
                            if (context.mounted) {
                              showLoadingSnackBar(
                                context,
                                message: 'Guardando alergias...',
                              );
                            }

                            // Obtener referencia al repositorio de auth y controller
                            final authRepository = ref.read(
                              authRepositoryProvider,
                            );
                            final authController = ref.read(
                              authControllerProvider.notifier,
                            );

                            try {
                              // Convertir nombres de alergias a items de alergias
                              final allergyItems =
                                  selectedAllergyNames.map((name) {
                                    // Buscar la alergia en la lista de alergias predefinidas
                                    final predefinedAllergies =
                                        ref.read(allergiesProvider).value ?? [];
                                    final predefinedAllergy =
                                        predefinedAllergies.firstWhere(
                                          (a) => a.name == name,
                                          orElse:
                                              () => Allergy(
                                                name: name,
                                                emoji: '⚠️',
                                              ), // Default emoji para custom
                                        );

                                    // Determinar si es una alergia personalizada
                                    final isCustom =
                                        !predefinedAllergies.any(
                                          (a) => a.name == name,
                                        );

                                    return {
                                      'name': name,
                                      'emoji': predefinedAllergy.emoji,
                                      'isCustom': isCustom,
                                    };
                                  }).toList();

                              print('Guardando allergyItems: $allergyItems');

                              // 1. Guardar alergias en Firestore
                              await authRepository.saveUserAllergyItems(
                                allergyItems,
                              );
                              print('✅ Alergias guardadas en Firestore');

                              // 2. Esperar un momento para asegurar que la escritura se complete
                              await Future.delayed(
                                const Duration(milliseconds: 500),
                              );

                              // 3. Refrescar datos de usuario ANTES de marcar como completado
                              await authController.refreshUserFromFirestore();
                              print(
                                '✅ Datos de usuario refrescados desde Firestore',
                              );

                              // 4. Verificar que las alergias se guardaron correctamente
                              final refreshedUser =
                                  ref.read(authControllerProvider).value;
                              if (refreshedUser?.allergies.isEmpty ?? true) {
                                print(
                                  '⚠️ Las alergias no se reflejaron en el usuario refrescado',
                                );
                              }

                              // 5. Navegación (NO marcar como completado aquí, se hace en el siguiente screen)
                              if (context.mounted) {
                                context.go(
                                  CookingLevelSelectorScreen.routePath,
                                );
                              }
                            } catch (e) {
                              // Mostrar error si falla el guardado
                              print('❌ Error al guardar alergias: $e');

                              if (context.mounted) {
                                ScaffoldMessenger.of(
                                  context,
                                ).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error al guardar alergias: $e',
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
