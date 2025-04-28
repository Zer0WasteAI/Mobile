import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/selectable_item_chip.dart';
import 'package:zer0_waste_ai/features/profile/application/providers/food_types_provider.dart';
import 'package:zer0_waste_ai/features/profile/application/providers/selected_food_types_provider.dart';
import 'package:zer0_waste_ai/features/profile/domain/models/food_type.dart';
import 'package:zer0_waste_ai/features/profile/presentation/screens/special_diet_selector_screen.dart';

// --- Screen Widget ---

class PreferredFoodTypeScreen extends ConsumerWidget {
  const PreferredFoodTypeScreen({super.key});

  static const String routeName = 'preferred_food_type';
  static const String routePath = '/preferred-food-type';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTypes = ref.watch(selectedFoodTypesProviderWithPersistence);
    final notifier = ref.read(
      selectedFoodTypesProviderWithPersistence.notifier,
    );
    final allFoodTypesAsyncValue = ref.watch(foodTypesProvider);

    // Use Theme colors
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color primaryColor = colorScheme.primary;
    final Color backgroundColor = colorScheme.surface;
    final Color defaultChipTextColor = colorScheme.onSurfaceVariant;
    final Color defaultChipBorderColor = colorScheme.outline.withOpacity(0.5);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
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
                                onTap: () => notifier.toggleFoodType(foodType),
                                selectedColor: primaryColor,
                                defaultBackgroundColor: backgroundColor,
                                defaultTextColor: defaultChipTextColor,
                                defaultBorderColor: defaultChipBorderColor,
                              );
                            }).toList(),
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
                          'Error al cargar: $error',
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
                      allFoodTypesAsyncValue.hasValue
                          ? () {
                            print('Selected Food Types: $selectedTypes');
                            context.go(SpecialDietSelectorScreen.routePath);
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        allFoodTypesAsyncValue.hasValue
                            ? primaryColor
                            : Colors.grey,
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
