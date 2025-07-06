import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/loading_snackbar.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/selectable_item_chip.dart';
import 'package:zer0_waste_ai/features/profile/application/providers/allergies_provider.dart';
import 'package:zer0_waste_ai/features/profile/domain/models/allergy.dart';

// Enum para los tipos de alergia
enum AllergyType { gluten, lactose, nuts, seafood, eggs, soy, wheat, peanuts }

// Extensión para obtener información legible
extension AllergyTypeExtension on AllergyType {
  String get displayName {
    switch (this) {
      case AllergyType.gluten:
        return 'Gluten';
      case AllergyType.lactose:
        return 'Lactosa';
      case AllergyType.nuts:
        return 'Frutos secos';
      case AllergyType.seafood:
        return 'Mariscos';
      case AllergyType.eggs:
        return 'Huevos';
      case AllergyType.soy:
        return 'Soja';
      case AllergyType.wheat:
        return 'Trigo';
      case AllergyType.peanuts:
        return 'Cacahuetes';
    }
  }

  String toStorageString() {
    return displayName.toLowerCase();
  }

  static AllergyType? fromStorageString(String name) {
    final lowerName = name.toLowerCase();
    return AllergyType.values.firstWhere(
      (type) => type.toStorageString() == lowerName,
      orElse: () => throw Exception('Unknown allergy type: $name'),
    );
  }

  IconData get icon {
    switch (this) {
      case AllergyType.gluten:
        return Icons.bakery_dining;
      case AllergyType.lactose:
        return Icons.emoji_food_beverage;
      case AllergyType.nuts:
        return Icons.grain;
      case AllergyType.seafood:
        return Icons.set_meal;
      case AllergyType.eggs:
        return Icons.egg;
      case AllergyType.soy:
        return Icons.rice_bowl;
      case AllergyType.wheat:
        return Icons.grass;
      case AllergyType.peanuts:
        return Icons.bolt;
    }
  }
}

// Provider for selected allergies with persistence to Firestore
final selectedAllergiesProviderWithPersistence = StateNotifierProvider<
  SelectedAllergiesNotifier,
  List<Allergy>
>((ref) {
  // Load allergies from auth state (will be empty initially)
  final _ = ref.read(authStateProvider).value;
  final List<Allergy> initialAllergies = [];

  // We'll initialize with an empty list and update after loading allergies from provider
  return SelectedAllergiesNotifier(initialAllergies);
});

class SelectedAllergiesNotifier extends StateNotifier<List<Allergy>> {
  SelectedAllergiesNotifier(super.state);

  void toggleAllergy(Allergy allergy) {
    if (state.contains(allergy)) {
      state = [...state.where((a) => a.name != allergy.name)];
    } else {
      state = [...state, allergy];
    }
  }

  // Add a custom allergy
  void addCustomAllergy(String name, String emoji) {
    // Check if allergy with same name already exists
    if (!state.any(
      (allergy) => allergy.name.toLowerCase() == name.toLowerCase(),
    )) {
      final newAllergy = Allergy(name: name, emoji: emoji);
      state = [...state, newAllergy];
    }
  }

  // Initialize allergies from user profile and available allergies list
  void initializeFromUserProfile(
    List<String> userAllergies,
    List<Allergy> availableAllergies,
  ) {
    if (userAllergies.isEmpty) {
      state = [];
      return;
    }

    final List<Allergy> selectedAllergies = [];

    // Add predefined allergies
    for (final allergyName in userAllergies) {
      // First try to find a match in available allergies
      final predefinedMatch =
          availableAllergies
              .where((a) => a.name.toLowerCase() == allergyName.toLowerCase())
              .toList();

      if (predefinedMatch.isNotEmpty) {
        selectedAllergies.add(predefinedMatch.first);
      } else {
        // If not found, add as custom allergy with default emoji
        selectedAllergies.add(Allergy(name: allergyName, emoji: '⚠️'));
      }
    }

    state = selectedAllergies;
  }
}

class ProfileAllergySelectorScreen extends ConsumerStatefulWidget {
  const ProfileAllergySelectorScreen({super.key});

  static const String routeName = 'profile_allergy_selector';
  static const String routePath = '/profile/allergy-selector';

  @override
  ConsumerState<ProfileAllergySelectorScreen> createState() =>
      _ProfileAllergySelectorScreenState();
}

class _ProfileAllergySelectorScreenState
    extends ConsumerState<ProfileAllergySelectorScreen> {
  bool _isLoading = true;
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

  @override
  void initState() {
    super.initState();
    // Initialize allergies after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAllergies();
    });
  }

  @override
  void dispose() {
    _allergyController.dispose();
    super.dispose();
  }

  Future<void> _initializeAllergies() async {
    final allergiesAsyncValue = ref.read(allergiesProvider);
    final user = ref.read(authStateProvider).value;

    // Wait for allergies to load if they haven't yet
    if (allergiesAsyncValue is AsyncLoading) {
      // ✅ UPDATED: Removed artificial delay
    }

    // Get the list of all available allergies
    final availableAllergies = ref.read(allergiesProvider).value ?? [];

    // Get user's selected allergies from profile
    final userAllergies = user?.prefs.allergies ?? [];

    // Initialize the selected allergies
    ref
        .read(selectedAllergiesProviderWithPersistence.notifier)
        .initializeFromUserProfile(userAllergies, availableAllergies);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show dialog to add custom allergy
  void _showAddAllergyDialog() {
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
                    if (_allergyController.text.trim().isNotEmpty) {
                      // Add custom allergy
                      ref
                          .read(
                            selectedAllergiesProviderWithPersistence.notifier,
                          )
                          .addCustomAllergy(
                            _allergyController.text.trim(),
                            _selectedEmoji,
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

  @override
  Widget build(BuildContext context) {
    final selectedAllergies = ref.watch(
      selectedAllergiesProviderWithPersistence,
    );
    final notifier = ref.read(
      selectedAllergiesProviderWithPersistence.notifier,
    );
    final allergiesAsyncValue = ref.watch(allergiesProvider);
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
          'Alergias alimentarias',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Tienes alguna alergia?',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona los alimentos a los que eres alérgico para evitarlos en tus recetas.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Lista de alergias disponibles
              Expanded(
                child: allergiesAsyncValue.when(
                  data: (allergies) {
                    if (_isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (allergies.isEmpty) {
                      return Center(
                        child: Text(
                          'No se pudieron cargar las alergias.',
                          style: GoogleFonts.inter(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    // Create a list with predefined allergies first, then add custom allergies,
                    // and finally add the "Add" button
                    final List<Widget> allergyChips = [];

                    // Add predefined allergies
                    for (final allergy in allergies) {
                      final isSelected = selectedAllergies.any(
                        (a) => a.name == allergy.name,
                      );
                      allergyChips.add(
                        SelectableItemChip(
                          label: allergy.name,
                          emoji: allergy.emoji,
                          isSelected: isSelected,
                          onTap: () => notifier.toggleAllergy(allergy),
                          selectedColor: primaryColor,
                          defaultBackgroundColor: backgroundColor,
                          defaultTextColor: defaultChipTextColor,
                          defaultBorderColor: defaultChipBorderColor,
                        ),
                      );
                    }

                    // Add custom allergies that aren't in the predefined list
                    for (final customAllergy in selectedAllergies) {
                      // Skip if it's a predefined allergy
                      if (allergies.any((a) => a.name == customAllergy.name)) {
                        continue;
                      }

                      allergyChips.add(
                        SelectableItemChip(
                          label: customAllergy.name,
                          emoji: customAllergy.emoji,
                          isSelected: true,
                          isCustom: true,
                          onTap: () => notifier.toggleAllergy(customAllergy),
                          onDelete: () => notifier.toggleAllergy(customAllergy),
                          selectedColor: primaryColor,
                          defaultBackgroundColor: backgroundColor,
                          defaultTextColor: defaultChipTextColor,
                          defaultBorderColor: defaultChipBorderColor,
                        ),
                      );
                    }

                    // Add "Añadir" chip
                    allergyChips.add(
                      InkWell(
                        onTap: _showAddAllergyDialog,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.4),
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

                    return SingleChildScrollView(
                      child: Wrap(
                        spacing: 12.0,
                        runSpacing: 12.0,
                        children: allergyChips,
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

              // Botón de guardar
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        allergiesAsyncValue.hasValue && !_isLoading
                            ? () async {
                              // Mostrar indicador de carga
                              if (context.mounted) {
                                showLoadingSnackBar(
                                  context,
                                  message: 'Guardando alergias...',
                                );
                              }

                              try {
                                // Save allergies to Firestore
                                final allergyNames =
                                    selectedAllergies
                                        .map((allergy) => allergy.name)
                                        .toList();

                                // Create allergyItems with custom flag
                                final allergyItems =
                                    selectedAllergies
                                        .map(
                                          (allergy) => {
                                            'name': allergy.name,
                                            'emoji': allergy.emoji,
                                            'isCustom':
                                                allergy.isCustom ||
                                                !ref
                                                    .read(allergiesProvider)
                                                    .value!
                                                    .any(
                                                      (a) =>
                                                          a.name ==
                                                          allergy.name,
                                                    ),
                                          },
                                        )
                                        .toList();

                                log('Guardando alergias: $allergyNames');
                                log('Guardando allergyItems: $allergyItems');

                                // Save to Firestore using new method
                                await authRepository.saveUserAllergyItems(
                                  allergyNames,
                                );

                                // Refresh user data
                                await authController.refreshUserFromFirestore();

                                if (context.mounted) {
                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Alergias actualizadas'),
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
