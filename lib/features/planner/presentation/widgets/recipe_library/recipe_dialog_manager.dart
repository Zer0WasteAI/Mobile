import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_providers.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_screen_providers.dart';

/// Manager for handling all recipe-related dialogs
class RecipeDialogManager {
  /// Show dialog to add recipe to meal plan
  static void showAddToPlanDialog(
    BuildContext context,
    MealPlan recipe,
    WidgetRef ref,
  ) {
    // Obtener la fecha actual por defecto
    final today = DateTime.now();
    DateTime selectedDate = today;

    // Formatear la fecha actual como clave
    String dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Añadir al plan',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información sobre la receta
                  _buildRecipeInfo(recipe),
                  
                  const SizedBox(height: 20),

                  // Selección de fecha
                  _buildDateSelection(selectedDate, setState),
                  
                  const SizedBox(height: 16),

                  // Selección de tipo de comida
                  _buildMealTypeSelection(recipe, setState),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.inter(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _addMealToPlan(selectedDate, recipe, ref);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                ),
                child: Text(
                  'Añadir',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Show detailed recipe information dialog
  static void showRecipeDetails(
    BuildContext context,
    MealPlan recipe,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              // Header with recipe image and basic info
              _buildRecipeHeader(recipe, context, ref),
              
              // Content with tabs for ingredients, instructions, etc.
              Expanded(
                child: _buildRecipeContent(recipe, context),
              ),
              
              // Actions
              _buildRecipeActions(recipe, context, ref),
            ],
          ),
        ),
      ),
    );
  }

  /// Show AI suggestion dialog for generating recipes
  static void showAiSuggestionDialog(BuildContext context, WidgetRef ref) {
    final ingredients = TextEditingController();
    final selectedDietary = <String>[];
    MealType selectedType = MealType.lunch;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
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
                  // Header
                  _buildAiSuggestionHeader(),
                  
                  const SizedBox(height: 20),

                  // Meal type selection
                  _buildMealTypeSelectionForAi(selectedType, setState),
                  
                  const SizedBox(height: 16),

                  // Ingredients input
                  _buildIngredientsInput(ingredients),
                  
                  const SizedBox(height: 16),

                  // Dietary preferences
                  _buildDietaryPreferences(selectedDietary, setState),
                  
                  const SizedBox(height: 24),

                  // Generate button
                  _buildGenerateButton(
                    context, 
                    ref, 
                    selectedType, 
                    ingredients, 
                    selectedDietary,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Private helper methods for building UI components

  static Widget _buildRecipeInfo(MealPlan recipe) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: recipe.type.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            recipe.type.icon,
            color: recipe.type.color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.name,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: recipe.type.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  recipe.type.name,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: recipe.type.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildDateSelection(DateTime selectedDate, StateSetter setState) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona el día:',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        
        // Quick date options
        Row(
          children: [
            _buildDateOption('Hoy', today, selectedDate, setState),
            const SizedBox(width: 8),
            _buildDateOption('Mañana', tomorrow, selectedDate, setState),
            const SizedBox(width: 8),
            _buildDateOption('Otro día', null, selectedDate, setState, isCustom: true),
          ],
        ),
        
        if (selectedDate != today && selectedDate != tomorrow) ...[
          const SizedBox(height: 8),
          Text(
            'Fecha seleccionada: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }

  static Widget _buildDateOption(
    String label, 
    DateTime? date, 
    DateTime selectedDate, 
    StateSetter setState,
    {bool isCustom = false}
  ) {
    final isSelected = !isCustom && date != null && 
      DateFormat('yyyy-MM-dd').format(selectedDate) == DateFormat('yyyy-MM-dd').format(date);

    return Expanded(
      child: InkWell(
        onTap: () async {
          if (isCustom) {
            final picked = await showDatePicker(
              context: null as BuildContext, // This needs to be passed properly
              initialDate: selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              setState(() {
                // selectedDate = picked; // This needs proper state management
              });
            }
          } else if (date != null) {
            setState(() {
              // selectedDate = date; // This needs proper state management
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00BFA5) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isSelected ? Colors.white : Colors.grey.shade800,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildMealTypeSelection(MealPlan recipe, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de comida:',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: MealType.values.map((type) {
            final isSelected = recipe.type == type;
            return ChoiceChip(
              label: Text(type.name),
              selected: isSelected,
              onSelected: (selected) {
                // Handle selection
              },
              backgroundColor: Colors.grey.shade100,
              selectedColor: type.color.withValues(alpha: 0.2),
            );
          }).toList(),
        ),
      ],
    );
  }

  static Widget _buildRecipeHeader(MealPlan recipe, BuildContext context, WidgetRef ref) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: recipe.type.color.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Stack(
        children: [
          // Recipe image placeholder
          Center(
            child: Icon(
              recipe.type.icon,
              size: 80,
              color: recipe.type.color,
            ),
          ),
          
          // Close button
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ),
          
          // Recipe title
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Text(
              recipe.name,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildRecipeContent(MealPlan recipe, BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Ingredientes'),
              Tab(text: 'Instrucciones'),
              Tab(text: 'Información'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildIngredientsTab(recipe),
                _buildInstructionsTab(recipe),
                _buildInfoTab(recipe),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildRecipeActions(MealPlan recipe, BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // Add to favorites
              },
              child: const Text('Favorito'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                showAddToPlanDialog(context, recipe, ref);
              },
              child: const Text('Añadir al Plan'),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildAiSuggestionHeader() {
    return Column(
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
      ],
    );
  }

  static Widget _buildMealTypeSelectionForAi(MealType selectedType, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de comida',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: MealType.values.length,
            itemBuilder: (context, index) {
              final type = MealType.values[index];
              final isSelected = selectedType == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(type.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        // selectedType = type; // This needs proper state management
                      });
                    }
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: type.color.withValues(alpha: 0.2),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static Widget _buildIngredientsInput(TextEditingController ingredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredientes disponibles',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ingredients,
          decoration: const InputDecoration(
            hintText: 'Ej: pollo, arroz, verduras...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  static Widget _buildDietaryPreferences(List<String> selectedDietary, StateSetter setState) {
    final dietaryTags = [
      'Vegetariano',
      'Vegano',
      'Sin gluten',
      'Sin lácteos',
      'Sin azúcar',
      'Alto en proteínas',
      'Bajo en calorías',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferencias dietéticas',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: dietaryTags.map((tag) {
            final isSelected = selectedDietary.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedDietary.add(tag);
                  } else {
                    selectedDietary.remove(tag);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  static Widget _buildGenerateButton(
    BuildContext context,
    WidgetRef ref,
    MealType selectedType,
    TextEditingController ingredients,
    List<String> selectedDietary,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Generate AI suggestions
          Navigator.pop(context);
          _generateAiSuggestions(ref, selectedType, ingredients.text, selectedDietary);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00BFA5),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Generar Sugerencias',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Helper methods for recipe content tabs
  static Widget _buildIngredientsTab(MealPlan recipe) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text('Ingredientes de la receta...'),
    );
  }

  static Widget _buildInstructionsTab(MealPlan recipe) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text('Instrucciones de la receta...'),
    );
  }

  static Widget _buildInfoTab(MealPlan recipe) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text('Información nutricional...'),
    );
  }

  // Helper methods for actions
  static void _addMealToPlan(DateTime date, MealPlan recipe, WidgetRef ref) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    // Add to meal plan logic
  }

  static void _generateAiSuggestions(
    WidgetRef ref,
    MealType type,
    String ingredients,
    List<String> dietary,
  ) {
    // Generate AI suggestions logic
  }
}