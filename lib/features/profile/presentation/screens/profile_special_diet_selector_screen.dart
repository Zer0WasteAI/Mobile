import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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

// Provider para las dietas seleccionadas
final selectedDietProvider =
    StateNotifierProvider<SelectedDietNotifier, SpecialDietType?>((ref) {
      // TODO: Load saved preferences
      return SelectedDietNotifier(null);
    });

class SelectedDietNotifier extends StateNotifier<SpecialDietType?> {
  SelectedDietNotifier(super.state);

  void selectDiet(SpecialDietType? type) {
    state = type;
    // TODO: Save preference
  }
}

class ProfileSpecialDietSelectorScreen extends ConsumerWidget {
  const ProfileSpecialDietSelectorScreen({super.key});

  static const String routeName = 'profile_special_diet_selector';
  static const String routePath = '/profile/special-diet-selector';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDiet = ref.watch(selectedDietProvider);
    final notifier = ref.read(selectedDietProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
      body: SafeArea(
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

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children:
                      SpecialDietType.values.map((dietType) {
                        final isSelected = selectedDiet == dietType;
                        return _SpecialDietCard(
                          dietType: dietType,
                          isSelected: isSelected,
                          onTap:
                              () => notifier.selectDiet(
                                isSelected ? null : dietType,
                              ),
                          primaryColor: colorScheme.primary,
                          surfaceColor: colorScheme.surface,
                        );
                      }).toList(),
                ),
              ),

              // Botón de guardar
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Guardar selección y volver al perfil
                      print('Dieta seleccionada: $selectedDiet');
                      context.pop();
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
      ),
    );
  }
}

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
                  : colorScheme.outlineVariant.withOpacity(0.5),
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected ? primaryColor.withOpacity(0.1) : surfaceColor,
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
                          ? primaryColor.withOpacity(0.2)
                          : colorScheme.surfaceVariant.withOpacity(0.3),
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
