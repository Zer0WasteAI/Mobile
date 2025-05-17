import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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

class ProfilePreferredFoodTypeScreen extends ConsumerWidget {
  const ProfilePreferredFoodTypeScreen({super.key});

  static const String routeName = 'profile_preferred_food_type';
  static const String routePath = '/profile/preferred-food-type';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTypes = ref.watch(selectedFoodTypesProvider);
    final notifier = ref.read(selectedFoodTypesProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
        child: Padding(
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
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: FoodType.values.length,
                  itemBuilder: (context, index) {
                    final foodType = FoodType.values[index];
                    final isSelected = selectedTypes.contains(foodType);

                    return _FoodTypeCard(
                      foodType: foodType,
                      isSelected: isSelected,
                      onTap: () => notifier.toggle(foodType),
                      primaryColor: colorScheme.primary,
                      surfaceColor: colorScheme.surface,
                    );
                  },
                ),
              ),

              // Botón de guardar
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        selectedTypes.isNotEmpty
                            ? () {
                              // Guardar selecciones y volver al perfil
                              print(
                                'Tipos de comida seleccionados: $selectedTypes',
                              );
                              context.pop();
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      disabledBackgroundColor: colorScheme.primary.withOpacity(
                        0.5,
                      ),
                      disabledForegroundColor: colorScheme.onPrimary
                          .withOpacity(0.7),
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
          color: isSelected ? primaryColor.withOpacity(0.15) : surfaceColor,
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
                        ? primaryColor.withOpacity(0.2)
                        : colorScheme.surfaceVariant.withOpacity(0.3),
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
