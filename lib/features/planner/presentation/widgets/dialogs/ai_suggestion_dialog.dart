import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_providers.dart';

class AiSuggestionDialog extends ConsumerStatefulWidget {
  final MealType? initialType;
  final Function(MealPlan) onSelect;

  const AiSuggestionDialog({
    super.key,
    this.initialType,
    required this.onSelect,
  });

  @override
  ConsumerState<AiSuggestionDialog> createState() => _AiSuggestionDialogState();
}

class _AiSuggestionDialogState extends ConsumerState<AiSuggestionDialog> {
  late final TextEditingController _ingredientsController;
  final List<String> _dietaryTags = [];
  late MealType _mealType;

  // Todas las etiquetas dietéticas disponibles
  final List<String> _allDietaryTags = [
    'Vegetariano',
    'Vegano',
    'Sin gluten',
    'Sin lácteos',
    'Alto en proteínas',
  ];

  @override
  void initState() {
    super.initState();
    _ingredientsController = TextEditingController();
    _mealType = widget.initialType ?? MealType.lunch;
  }

  @override
  void dispose() {
    _ingredientsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '✨ Sugerencia Inteligente',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nuestra IA te recomendará recetas basadas en tus preferencias y los ingredientes que ya tienes',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            _buildIngredientsSection(),
            const SizedBox(height: 16),
            _buildDietaryPreferencesSection(),
            const SizedBox(height: 24),
            _buildSuggestionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Ingredientes disponibles',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(Opcional)',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Si no ingresas ingredientes, te recomendaremos recetas populares',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _ingredientsController,
          decoration: InputDecoration(
            hintText: 'Escribe ingredientes separados por comas',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildDietaryPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Preferencias dietéticas',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(Opcional)',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Selecciona si tienes alguna preferencia dietética específica',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _allDietaryTags.map((tag) {
                final isSelected = _dietaryTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: const Color(0xFF00BFA5).withValues(alpha: 0.2),
                  checkmarkColor: const Color(0xFF00BFA5),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _dietaryTags.add(tag);
                      } else {
                        _dietaryTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestionSection() {
    final params = <String, dynamic>{
      'mealType': _mealType,
      'dietaryTags': _dietaryTags,
      'availableIngredients':
          _ingredientsController.text.isEmpty
              ? null
              : _ingredientsController.text
                  .split(',')
                  .map((e) => e.trim())
                  .toList(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botón para generar
        ElevatedButton.icon(
          onPressed: () {
            // Invalidar el provider para generar nuevas sugerencias
            ref.invalidate(aiSuggestionsProvider(params));
          },
          icon: const Icon(Icons.autorenew),
          label: const Text('Generar sugerencia'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BFA5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Resultado de la sugerencia
        ref
            .watch(aiSuggestionsProvider(params))
            .when(
              data: (suggestions) => _buildSuggestionResult(suggestions),
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(),
            ),
      ],
    );
  }

  Widget _buildSuggestionResult(List<MealPlan> suggestions) {
    if (suggestions.isEmpty) {
      return Text(
        'No se encontraron sugerencias con esos criterios',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
      );
    }

    // Mostrar la primera sugerencia
    final suggestion = suggestions.first;

    return Column(
      children: [
        // Título de sugerencia
        Text(
          'Te recomendamos:',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        // Receta sugerida
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              // Imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  suggestion.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: suggestion.type.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        suggestion.type.name,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: suggestion.type.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      suggestion.name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      suggestion.ingredients.take(3).join(', ') +
                          (suggestion.ingredients.length > 3 ? '...' : ''),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Botón para seleccionar
        OutlinedButton(
          onPressed: () {
            // Seleccionar esta receta
            widget.onSelect(suggestion);
            Navigator.pop(context);
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF00BFA5),
            side: const BorderSide(color: Color(0xFF00BFA5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(double.infinity, 44),
          ),
          child: const Text('Usar esta receta'),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BFA5)),
          ),
          const SizedBox(height: 16),
          Text(
            'Buscando la mejor receta para ti...',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Text(
      'Error al generar sugerencias. Inténtalo de nuevo.',
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(fontSize: 14, color: Colors.red),
    );
  }

  // ignore: unused_element
  static void show(
    BuildContext context, {
    MealType? initialType,
    required Function(MealPlan) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) =>
              AiSuggestionDialog(initialType: initialType, onSelect: onSelect),
    );
  }
}
