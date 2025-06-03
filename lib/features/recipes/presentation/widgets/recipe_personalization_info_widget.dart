import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/ai_recipes_provider.dart';

/// Widget que muestra la información de personalización aplicada en la generación de recetas
/// según CAMBIOS_ENDPOINTS.md
class RecipePersonalizationInfoWidget extends ConsumerWidget {
  const RecipePersonalizationInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personalizationInfo = ref.watch(personalizationInfoProvider);
    final totalRecipes = ref.watch(totalRecipesGeneratedProvider);
    final inventoryUsage = ref.watch(inventoryUsageProvider);
    final appliedPreferences = ref.watch(appliedPreferencesProvider);
    final filteredAllergies = ref.watch(filteredAllergiesProvider);
    final language = ref.watch(recipeLanguageProvider);
    final measurementSystem = ref.watch(measurementSystemProvider);
    final cookingLevel = ref.watch(cookingLevelProvider);

    // Si no hay información de personalización, no mostrar nada
    if (personalizationInfo == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Personalización Aplicada',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Información básica
            if (totalRecipes != null) ...[
              _buildInfoRow(
                icon: Icons.restaurant,
                label: 'Total de recetas',
                value: totalRecipes,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 8),
            ],

            if (inventoryUsage != null) ...[
              _buildInfoRow(
                icon: Icons.inventory,
                label: 'Uso del inventario',
                value: inventoryUsage,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 8),
            ],

            // Configuración aplicada
            if (language != null) ...[
              _buildInfoRow(
                icon: Icons.language,
                label: 'Idioma',
                value: language == 'es' ? 'Español' : language,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 8),
            ],

            if (measurementSystem != null) ...[
              _buildInfoRow(
                icon: Icons.straighten,
                label: 'Sistema de medidas',
                value: measurementSystem == 'metric' ? 'Métrico' : 'Imperial',
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 8),
            ],

            if (cookingLevel != null) ...[
              _buildInfoRow(
                icon: Icons.star,
                label: 'Nivel de cocina',
                value: _getCookingLevelDisplayName(cookingLevel),
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 8),
            ],

            // Preferencias aplicadas
            if (appliedPreferences.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Preferencias aplicadas:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children:
                    appliedPreferences.map((preference) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          preference,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],

            // Alergias filtradas
            if (filteredAllergies.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.shield, color: colorScheme.error, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Alergias filtradas:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children:
                    filteredAllergies.map((allergy) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          allergy,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: colorScheme.onErrorContainer,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _getCookingLevelDisplayName(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return 'Principiante';
      case 'intermediate':
        return 'Intermedio';
      case 'advanced':
        return 'Avanzado';
      default:
        return level;
    }
  }
}
