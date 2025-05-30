import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/loading_snackbar.dart';

// Reutilizamos el mismo enum y provider del selector original
enum CookingLevel { beginner, intermediate, advanced }

// Extension para convertir enum a string para almacenamiento
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

final selectedCookingLevelProvider =
    StateNotifierProvider<SelectedCookingLevelNotifier, CookingLevel?>((ref) {
      // Inicializar con el nivel del usuario, si está disponible
      final user = ref.read(authStateProvider).value;
      final String? storedLevel = user?.prefs.cookingLevel;
      if (storedLevel != null) {
        return SelectedCookingLevelNotifier(
          CookingLevelExtension.fromStorageString(storedLevel),
        );
      }
      return SelectedCookingLevelNotifier(null);
    });

class SelectedCookingLevelNotifier extends StateNotifier<CookingLevel?> {
  SelectedCookingLevelNotifier(super.initialState);

  void selectLevel(CookingLevel level) {
    state = level;
  }
}

class ProfileCookingLevelSelectorScreen extends ConsumerWidget {
  const ProfileCookingLevelSelectorScreen({super.key});

  static const String routeName = 'profile_cooking_level_selector';
  static const String routePath = '/profile/cooking-level-selector';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLevel = ref.watch(selectedCookingLevelProvider);
    final notifier = ref.read(selectedCookingLevelProvider.notifier);
    final authRepository = ref.read(authRepositoryProvider);
    final authController = ref.read(authControllerProvider.notifier);

    final colorScheme = Theme.of(context).colorScheme;
    const cardRadius = Radius.circular(16.0);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Nivel de cocina',
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Títulos
              Text(
                '¿Cuál es tu nivel de cocina?',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Queremos sugerirte recetas adecuadas para ti.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Tarjetas de selección
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
                          .withOpacity(0.3),
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
                          .withOpacity(0.3),
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
                          .withOpacity(0.3),
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

              // Botón guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      selectedLevel == null
                          ? null
                          : () async {
                            // Mostrar indicador de carga
                            if (context.mounted) {
                              showLoadingSnackBar(
                                context,
                                message: 'Guardando nivel de cocina...',
                              );
                            }

                            try {
                              // Guardar en Firestore
                              final levelString =
                                  selectedLevel.toStorageString();
                              print('Guardando nivel de cocina: $levelString');

                              await authRepository.saveUserCookingLevel(
                                levelString,
                              );

                              // Marcar explícitamente como completado en Firestore
                              await authRepository
                                  .markInitialPreferencesCompleted();

                              // Actualizar datos del usuario en memoria
                              await authController.refreshUserFromFirestore();

                              if (context.mounted) {
                                // Mostrar mensaje de éxito
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Nivel de cocina actualizado',
                                    ),
                                    backgroundColor: colorScheme.primary,
                                  ),
                                );
                                // Volver al perfil
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
                    disabledBackgroundColor: colorScheme.primary.withOpacity(
                      0.5,
                    ),
                    disabledForegroundColor: colorScheme.onPrimary.withOpacity(
                      0.7,
                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}

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
    return Card(
      margin: EdgeInsets.zero,
      elevation: isSelected ? 2 : 0,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(radius),
        side: BorderSide(
          width: 2,
          color: isSelected ? selectedColor : unselectedBorderColor,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      color: isSelected ? selectedBackgroundColor : unselectedBackgroundColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Imagen o ícono representativo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: selectedColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    // Usar un placeholder o icono si la imagen no carga
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.restaurant,
                        color: selectedColor,
                        size: 32,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Texto descriptivo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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

              // Indicador de selección
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedColor,
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
