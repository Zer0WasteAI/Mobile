import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/profile/presentation/screens/preferred_food_type_screen.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/loading_snackbar.dart';

// --- Enum & State Management ---

enum CookingLevel { beginner, intermediate, advanced }

// Extension to convert enum to string for storage
extension CookingLevelExtension on CookingLevel {
  String toStorageString() {
    switch (this) {
      case CookingLevel.beginner:
        return 'beginner';
      case CookingLevel.intermediate:
        return 'intermediate';
      case CookingLevel.advanced:
        return 'advanced';
    }
  }

  static CookingLevel fromStorageString(String? value) {
    switch (value) {
      case 'beginner':
        return CookingLevel.beginner;
      case 'intermediate':
        return CookingLevel.intermediate;
      case 'advanced':
        return CookingLevel.advanced;
      default:
        return CookingLevel.beginner; // Default value
    }
  }
}

final selectedCookingLevelProvider = StateNotifierProvider.autoDispose<
  SelectedCookingLevelNotifier,
  CookingLevel?
>((ref) {
  // Using autoDispose to ensure state is reset when leaving the screen
  return SelectedCookingLevelNotifier(null); // Start with nothing selected
});

class SelectedCookingLevelNotifier extends StateNotifier<CookingLevel?> {
  SelectedCookingLevelNotifier(super.initialState);

  void selectLevel(CookingLevel level) {
    state = level;
  }

  void reset() {
    state = null;
    print("Resetting cooking level selection");
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
    final authController = ref.read(authControllerProvider.notifier);

    // Use Theme colors for consistent styling
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    const cardRadius = Radius.circular(16.0);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Cuál es tu nivel de cocina?',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona tu nivel para recibir recetas adecuadas a tu experiencia.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Cooking level cards
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
                  onPressed: () async {
                    try {
                      // Mostrar indicador de carga
                      if (context.mounted) {
                        showLoadingSnackBar(
                          context,
                          message: 'Guardando nivel de cocina...',
                        );
                      }

                      // Save cooking level to Firestore - use a default if none selected
                      final cookingLevelString =
                          selectedLevel != null
                              ? selectedLevel.toStorageString()
                              : CookingLevel.beginner
                                  .toStorageString(); // Default to beginner if none selected

                      print("Guardando nivel de cocina: $cookingLevelString");

                      final authRepository = ref.read(authRepositoryProvider);
                      final authController = ref.read(
                        authControllerProvider.notifier,
                      );

                      await authRepository.saveUserCookingLevel(
                        cookingLevelString,
                      );

                      // Marcar explícitamente como completado en Firestore
                      await authRepository.markInitialPreferencesCompleted();

                      // Refrescar datos de usuario
                      await authController.refreshUserFromFirestore();

                      // Reset state to avoid keeping selections
                      notifier.reset();

                      // Navigate to the cooking level selector screen
                      if (context.mounted) {
                        // Usar go en lugar de replace para transiciones más fluidas
                        context.go(PreferredFoodTypeScreen.routePath);
                      }
                    } catch (e) {
                      print("Error guardando nivel de cocina: $e");
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).hideCurrentSnackBar(); // Eliminar SnackBars previos
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error: No se pudo guardar el nivel de cocina: $e',
                            ),
                            backgroundColor: Colors.red,
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
                  ),
                  child: Text(
                    'Continuar',
                    style: GoogleFonts.inter(
                      fontSize: 16,
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

// Widget for displaying cooking level cards with animation
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
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? selectedColor : textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: secondaryTextColor,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: selectedColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: selectedColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Seleccionado',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: selectedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Opacity(
                  opacity: 0.9,
                  child: Image.asset(
                    imagePath,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      );
                    },
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
