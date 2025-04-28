import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/profile/presentation/screens/preferred_food_type_screen.dart';

// --- Enum & State Management ---

enum CookingLevel { beginner, intermediate, advanced }

final selectedCookingLevelProvider =
    StateNotifierProvider<SelectedCookingLevelNotifier, CookingLevel?>((ref) {
      // TODO: Load saved preference if available (e.g., from SharedPreferences)
      return SelectedCookingLevelNotifier(null); // Start with nothing selected
    });

class SelectedCookingLevelNotifier extends StateNotifier<CookingLevel?> {
  SelectedCookingLevelNotifier(super.initialState);

  void selectLevel(CookingLevel level) {
    state = level;
    // TODO: Save selected preference (e.g., to SharedPreferences)
  }
}

// --- Screen Widget ---

class CookingLevelSelectorScreen extends ConsumerWidget {
  const CookingLevelSelectorScreen({super.key});

  static const String routeName = 'cooking_level_selector';
  static const String routePath = '/cooking-level-selector';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLevel = ref.watch(selectedCookingLevelProvider);
    final notifier = ref.read(selectedCookingLevelProvider.notifier);

    // --- Theme Colors Integration ---
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // --- End Theme Colors Integration ---

    // Remove hardcoded const colors if they are now derived from theme
    // const primaryColor = Color(0xFF00B894);
    // const secondaryColor = Color(0xFF70605A);
    // const backgroundColor = Color(0xFFFAF9F6);
    const cardRadius = Radius.circular(16.0);

    return Scaffold(
      backgroundColor: colorScheme.surface, // Use theme background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titles
              Text(
                '¿Cuál es tu nivel de cocina?',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface, // Use theme text color
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Queremos sugerirte recetas adecuadas para ti.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color:
                      colorScheme
                          .onSurfaceVariant, // Use theme secondary text color
                ),
              ),
              const SizedBox(height: 32),

              // Selection Cards
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _CookingLevelCard(
                      level: CookingLevel.beginner,
                      title: 'Principiante',
                      description: 'Recetas simples, pocos pasos.',
                      imagePath:
                          'assets/images/user_preferences/cooking_levels/beginner.png',
                      isSelected: selectedLevel == CookingLevel.beginner,
                      onTap: () => notifier.selectLevel(CookingLevel.beginner),
                      selectedColor: colorScheme.primary,
                      unselectedBorderColor: colorScheme.outlineVariant,
                      selectedBackgroundColor: colorScheme.primaryContainer
                          .withValues(alpha: 0.3),
                      unselectedBackgroundColor: colorScheme.surface,
                      textColor: colorScheme.onSurface,
                      secondaryTextColor: colorScheme.onSurfaceVariant,
                      shadowColor: colorScheme.shadow,
                      radius: cardRadius,
                    ),
                    const SizedBox(height: 16),
                    _CookingLevelCard(
                      level: CookingLevel.intermediate,
                      title: 'Intermedio',
                      description: 'Recetas de dificultad moderada.',
                      imagePath:
                          'assets/images/user_preferences/cooking_levels/intermediate.png',
                      isSelected: selectedLevel == CookingLevel.intermediate,
                      onTap:
                          () => notifier.selectLevel(CookingLevel.intermediate),
                      selectedColor: colorScheme.primary,
                      unselectedBorderColor: colorScheme.outlineVariant,
                      selectedBackgroundColor: colorScheme.primaryContainer
                          .withValues(alpha: 0.3),
                      unselectedBackgroundColor: colorScheme.surface,
                      textColor: colorScheme.onSurface,
                      secondaryTextColor: colorScheme.onSurfaceVariant,
                      shadowColor: colorScheme.shadow,
                      radius: cardRadius,
                    ),
                    const SizedBox(height: 16),
                    _CookingLevelCard(
                      level: CookingLevel.advanced,
                      title: 'Avanzado',
                      description: 'Platos complejos, técnicas avanzadas.',
                      imagePath:
                          'assets/images/user_preferences/cooking_levels/advanced.png',
                      isSelected: selectedLevel == CookingLevel.advanced,
                      onTap: () => notifier.selectLevel(CookingLevel.advanced),
                      selectedColor: colorScheme.primary,
                      unselectedBorderColor: colorScheme.outlineVariant,
                      selectedBackgroundColor: colorScheme.primaryContainer
                          .withValues(alpha: 0.3),
                      unselectedBackgroundColor: colorScheme.surface,
                      textColor: colorScheme.onSurface,
                      secondaryTextColor: colorScheme.onSurfaceVariant,
                      shadowColor: colorScheme.shadow,
                      radius: cardRadius,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bottom Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      selectedLevel == null
                          ? null
                          : () {
                            print('Selected Level: $selectedLevel');
                            // Navigate to the Food Preferences screen
                            context.go(PreferredFoodTypeScreen.routePath);
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary, // Theme primary
                    foregroundColor:
                        colorScheme.onPrimary, // Theme text on primary
                    disabledBackgroundColor: colorScheme.primary.withValues(
                      alpha: 0.5,
                    ),
                    disabledForegroundColor: colorScheme.onPrimary.withValues(
                      alpha: 0.7,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ), // Apply text style here
                  ),
                  child: const Text('Continuar'), // Text widget is simpler now
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Reusable Card Widget ---

class _CookingLevelCard extends StatelessWidget {
  final CookingLevel level;
  final String title;
  final String description;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedBorderColor;
  final Color selectedBackgroundColor;
  final Color unselectedBackgroundColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color shadowColor;
  final Radius radius;

  const _CookingLevelCard({
    required this.level,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedBorderColor,
    required this.selectedBackgroundColor,
    required this.unselectedBackgroundColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.shadowColor,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final cardBackgroundColor =
        isSelected ? selectedBackgroundColor : unselectedBackgroundColor;
    final borderColor = isSelected ? selectedColor : unselectedBorderColor;

    return AnimatedScale(
      scale: isSelected ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: cardBackgroundColor,
            borderRadius: BorderRadius.all(radius),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withValues(alpha: isSelected ? 0.15 : 0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Image.asset(
                imagePath,
                width: 50,
                height: 50,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.error, size: 50),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
