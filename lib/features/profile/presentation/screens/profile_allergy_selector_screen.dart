import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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

// Provider para las alergias seleccionadas
final selectedAllergiesProvider =
    StateNotifierProvider<SelectedAllergiesNotifier, List<AllergyType>>((ref) {
      // TODO: Load saved preferences
      return SelectedAllergiesNotifier([]);
    });

class SelectedAllergiesNotifier extends StateNotifier<List<AllergyType>> {
  SelectedAllergiesNotifier(super.state);

  void toggle(AllergyType type) {
    if (state.contains(type)) {
      state = [...state.where((t) => t != type)];
    } else {
      state = [...state, type];
    }
    // TODO: Save preferences
  }
}

class ProfileAllergySelectorScreen extends ConsumerWidget {
  const ProfileAllergySelectorScreen({super.key});

  static const String routeName = 'profile_allergy_selector';
  static const String routePath = '/profile/allergy-selector';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAllergies = ref.watch(selectedAllergiesProvider);
    final notifier = ref.read(selectedAllergiesProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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

              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: AllergyType.values.length,
                  itemBuilder: (context, index) {
                    final allergyType = AllergyType.values[index];
                    final isSelected = selectedAllergies.contains(allergyType);

                    return _AllergyCard(
                      allergyType: allergyType,
                      isSelected: isSelected,
                      onTap: () => notifier.toggle(allergyType),
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
                    onPressed: () {
                      // Guardar selecciones y volver al perfil
                      print('Alergias seleccionadas: $selectedAllergies');
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

class _AllergyCard extends StatelessWidget {
  final AllergyType allergyType;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;
  final Color surfaceColor;

  const _AllergyCard({
    required this.allergyType,
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
      margin: EdgeInsets.zero,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? primaryColor.withOpacity(0.2)
                          : colorScheme.surfaceVariant.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  allergyType.icon,
                  color:
                      isSelected ? primaryColor : colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  allergyType.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? primaryColor : colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: primaryColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
