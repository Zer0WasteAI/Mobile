import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/recipe_history_provider.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';
import 'package:zer0_waste_ai/features/recipes/presentation/widgets/favorite_button.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/meal_planning_providers.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan_models.dart';
import 'package:zer0_waste_ai/features/recipes/presentation/widgets/recipe_cooking_mode.dart';
import 'package:zer0_waste_ai/features/recipes/presentation/widgets/recipe_rating_dialog.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  /// Convert Recipe to format expected by RecipeCookingMode
  Map<String, dynamic> _convertRecipeToStepsFormat(Recipe recipe) {
    // Generate cooking steps based on ingredients and recipe type
    List<String> steps = _generateCookingSteps(recipe);

    return {
      'title': recipe.name,
      'description': recipe.description,
      'emoji': recipe.emoji,
      'cookingTime': recipe.cookingTime,
      'difficulty': recipe.difficulty,
      'ingredients': recipe.ingredients,
      'steps': steps,
    };
  }

  /// Generate cooking steps from recipe data (fallback when instructions not available)
  List<String> _generateCookingSteps(Recipe recipe) {
    // If recipe has real instructions, use those instead
    if (recipe.instructions.isNotEmpty) {
      return recipe.instructions;
    }

    // Fallback: Generate generic steps
    List<String> steps = [];

    // Step 1: Preparation
    steps.add(
      'Preparar todos los ingredientes: ${recipe.ingredients.take(3).join(', ')}${recipe.ingredients.length > 3 ? ' y más.' : '.'}',
    );

    // Step 2: Initial cooking based on recipe type
    if (recipe.ingredients.any((ing) => ing.toLowerCase().contains('pasta'))) {
      steps.add('Hervir agua con sal en una olla grande.');
      steps.add(
        'Agregar la pasta al agua hirviendo y cocinar según las instrucciones del paquete.',
      );
    } else if (recipe.ingredients.any(
      (ing) => ing.toLowerCase().contains('arroz'),
    )) {
      steps.add('Enjuagar el arroz hasta que el agua salga clara.');
      steps.add(
        'Cocinar el arroz con agua en proporción 2:1 durante 18-20 minutos.',
      );
    } else if (recipe.ingredients.any(
      (ing) => ing.toLowerCase().contains('huevo'),
    )) {
      steps.add('Batir los huevos en un bowl con sal y pimienta.');
      steps.add('Calentar la sartén a fuego medio con un poco de aceite.');
    } else {
      steps.add('Calentar una sartén o olla a fuego medio.');
      steps.add('Agregar aceite y calentar por 1-2 minutos.');
    }

    // Step 3: Main cooking process
    if (recipe.ingredients.any(
      (ing) =>
          ['cebolla', 'ajo'].any((base) => ing.toLowerCase().contains(base)),
    )) {
      steps.add(
        'Sofreír cebolla y ajo hasta que estén dorados y fragantes (3-4 minutos).',
      );
    }

    // Step 4: Add main ingredients
    steps.add(
      'Agregar los ingredientes principales y cocinar según la receta.',
    );

    // Step 5: Seasoning and final cooking
    steps.add('Sazonar con sal, pimienta y especias al gusto.');

    // Step 6: Final cooking time based on difficulty
    if (recipe.difficulty.toLowerCase() == 'fácil') {
      steps.add(
        'Cocinar por ${(recipe.cookingTime * 0.7).round()} minutos más, revolviendo ocasionalmente.',
      );
    } else if (recipe.difficulty.toLowerCase() == 'medio') {
      steps.add(
        'Cocinar a fuego medio por ${(recipe.cookingTime * 0.8).round()} minutos, ajustando la temperatura según sea necesario.',
      );
    } else {
      steps.add(
        'Cocinar con cuidado por ${recipe.cookingTime} minutos, siguiendo técnicas específicas.',
      );
    }

    // Step 7: Final touches
    steps.add('Verificar la cocción y ajustar sazón si es necesario.');
    steps.add('Servir caliente y disfrutar tu deliciosa ${recipe.name}.');

    return steps;
  }

  Map<String, bool> _ingredientAvailability = {};

  @override
  void initState() {
    super.initState();
    // Track recipe view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recipeHistoryProvider.notifier).trackRecipeView(widget.recipe);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkIngredientAvailability();
  }

  // Verifica qué ingredientes están disponibles en el inventario
  void _checkIngredientAvailability() {
    final inventoryState = ref.read(inventoryRealProvider);
    final List<String> recipeIngredients = widget.recipe.ingredients;

    final availableIngredients = <String>{};

    for (var ingredient in recipeIngredients) {
      final ingredientInfo = _parseIngredientSimple(ingredient);
      String ingredientName = (ingredientInfo['name'] ?? '').toLowerCase();
      // Verificar si algún item del inventario contiene este ingrediente
      bool isAvailable = inventoryState.items.any(
        (item) =>
            item.name.toLowerCase().contains(ingredientName) ||
            ingredientName.contains(item.name.toLowerCase()),
      );
      if (isAvailable) {
        availableIngredients.add(ingredientInfo['name'] ?? '');
      }
    }

    setState(() {
      _ingredientAvailability = {
        for (var ingredient in availableIngredients) ingredient: true,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme colors
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    // Recipe history state
    final recipeHistory = ref
        .read(recipeHistoryProvider.notifier)
        .getRecipeHistory(widget.recipe);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          widget.recipe.name,
          style: GoogleFonts.inter(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [FavoriteButton(recipe: widget.recipe)],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe header
            Container(
              padding: const EdgeInsets.all(16),
              color: cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emoji and basic info
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            widget.recipe.emoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.recipe.name,
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildInfoChip(
                                  Icons.timer,
                                  '${widget.recipe.cookingTime} min',
                                  primaryColor,
                                  isDark,
                                ),
                                const SizedBox(width: 8),
                                _buildInfoChip(
                                  Icons.restaurant,
                                  widget.recipe.difficulty,
                                  primaryColor,
                                  isDark,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    widget.recipe.description,
                    style: GoogleFonts.inter(fontSize: 16, color: textColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Recipe history stats
            if (recipeHistory != null && recipeHistory.timesCooked > 0)
              Container(
                padding: const EdgeInsets.all(16),
                color: cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Historial',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatChip(
                          Icons.restaurant,
                          'Cocinada ${recipeHistory.timesCooked} veces',
                          primaryColor,
                          isDark,
                        ),
                        if (recipeHistory.averageRating != null) ...[
                          const SizedBox(width: 8),
                          _buildStatChip(
                            Icons.star,
                            '${recipeHistory.averageRating!.toStringAsFixed(1)} ★',
                            primaryColor,
                            isDark,
                          ),
                        ],
                      ],
                    ),
                    if (recipeHistory.lastCooked != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Última vez: ${_formatDate(recipeHistory.lastCooked!)}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Ingredients
            Container(
              padding: const EdgeInsets.all(16),
              color: cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingredientes',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.recipe.ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = widget.recipe.ingredients[index];
                      final isAvailable =
                          _ingredientAvailability[ingredient] ?? false;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              isAvailable
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              size: 20,
                              color: isAvailable ? primaryColor : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ingredient,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Instructions (only show if available)
            if (widget.recipe.instructions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                color: cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instrucciones',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.recipe.instructions.length,
                      itemBuilder: (context, index) {
                        final instruction = widget.recipe.instructions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  instruction,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: textColor,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Add to plan button
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    return ElevatedButton(
                      onPressed: () async {
                        // Get the date and meal type from route parameters
                        final params =
                            GoRouter.of(context)
                                .routeInformationProvider
                                .value
                                .uri
                                .queryParameters;
                        final dateStr = params['date'];
                        final mealType = params['mealType'];

                        if (dateStr != null && mealType != null) {
                          // Direct add when parameters are available
                          await _addRecipeToMealPlan(dateStr, mealType);
                        } else {
                          // Show date/meal type picker when parameters are missing
                          await _showMealPlanDialog();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: const Text('Agregar al Plan'),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Start cooking button
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    // Record recipe as started cooking in history
                    await ref
                        .read(recipeHistoryProvider.notifier)
                        .startCooking(widget.recipe);

                    // Navigate to cooking mode with converted recipe
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => RecipeCookingMode(
                              recipe: _convertRecipeToStepsFormat(
                                widget.recipe,
                              ),
                              onExit: () {
                                Navigator.pop(context);
                              },
                              onComplete: () {
                                // Record recipe as completed in history
                                ref
                                    .read(recipeHistoryProvider.notifier)
                                    .completeCooking(widget.recipe);

                                // Show completion message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '¡Felicidades! Has completado la receta: ${widget.recipe.name}',
                                    ),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 3),
                                    action: SnackBarAction(
                                      label: 'Calificar',
                                      onPressed: () {
                                        // Show rating dialog
                                        showDialog(
                                          context: context,
                                          builder:
                                              (context) => RecipeRatingDialog(
                                                recipeName: widget.recipe.name,
                                                onSubmit: (rating, comment) {
                                                  // Save rating and comment to recipe history
                                                  ref
                                                      .read(
                                                        recipeHistoryProvider
                                                            .notifier,
                                                      )
                                                      .completeCooking(
                                                        widget.recipe,
                                                        rating:
                                                            rating.toDouble(),
                                                        notes:
                                                            comment.isNotEmpty
                                                                ? comment
                                                                : null,
                                                      );
                                                },
                                              ),
                                        );
                                      },
                                    ),
                                  ),
                                );

                                // Return to recipe detail
                                Navigator.pop(context);
                              },
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                  child: const Text('Empezar a Cocinar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    Color primaryColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primaryColor.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    IconData icon,
    String label,
    Color primaryColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Función simple para parsear ingredientes
  Map<String, String> _parseIngredientSimple(dynamic ingredient) {
    if (ingredient is String) {
      // Si es un string que parece JSON, extraer el nombre
      if (ingredient.contains('name:')) {
        final nameMatch = RegExp(r'name:\s*([^,}]+)').firstMatch(ingredient);
        final quantityMatch = RegExp(
          r'quantity:\s*([^,}]+)',
        ).firstMatch(ingredient);
        final unitMatch = RegExp(r'unit:\s*([^,}]+)').firstMatch(ingredient);

        String name = nameMatch?.group(1)?.trim() ?? ingredient;
        String quantity = quantityMatch?.group(1)?.trim() ?? '';
        String unit = unitMatch?.group(1)?.trim() ?? '';

        // Limpiar comillas y espacios
        name = name.replaceAll(RegExp(r'["\s]+'), ' ').trim();
        quantity = quantity.replaceAll(RegExp(r'["\s]+'), ' ').trim();
        unit = unit.replaceAll(RegExp(r'["\s]+'), ' ').trim();

        return {'name': name, 'quantity': quantity, 'unit': unit};
      } else {
        return {'name': ingredient, 'quantity': '', 'unit': ''};
      }
    } else if (ingredient is Map) {
      return {
        'name': ingredient['name']?.toString() ?? 'Ingrediente',
        'quantity': ingredient['quantity']?.toString() ?? '',
        'unit': ingredient['unit']?.toString() ?? '',
      };
    } else {
      return {'name': ingredient.toString(), 'quantity': '', 'unit': ''};
    }
  }

  /// Show dialog to select date and meal type for adding recipe to meal plan
  Future<void> _showMealPlanDialog() async {
    DateTime selectedDate = DateTime.now();
    String selectedMealType = 'lunch';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Agregar al Plan de Comidas',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecciona la fecha y tipo de comida:',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Date picker
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: GoogleFonts.inter(),
                    ),
                    subtitle: const Text('Fecha'),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 8),

                  // Meal type selector
                  Text(
                    'Tipo de comida:',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Desayuno'),
                        selected: selectedMealType == 'breakfast',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedMealType = 'breakfast';
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Almuerzo'),
                        selected: selectedMealType == 'lunch',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedMealType = 'lunch';
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Cena'),
                        selected: selectedMealType == 'dinner',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedMealType = 'dinner';
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed:
                      () => Navigator.of(dialogContext).pop({
                        'date': selectedDate,
                        'mealType': selectedMealType,
                      }),
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      final date = result['date'] as DateTime;
      final mealType = result['mealType'] as String;
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      await _addRecipeToMealPlan(dateStr, mealType);
    }
  }

  /// Add recipe to meal plan with specified date and meal type
  Future<void> _addRecipeToMealPlan(String dateStr, String mealType) async {
    try {
      // Convert recipe ingredients to MealIngredient format
      final mealIngredients =
          widget.recipe.ingredients
              .map(
                (ingredient) => MealIngredient(
                  name: ingredient,
                  quantity:
                      1, // Default quantity, should be adjusted based on servings
                  unit:
                      'unidad', // Default unit, should be adjusted based on recipe
                ),
              )
              .toList();

      final meal = Meal(
        recipeTitle: widget.recipe.name,
        ingredientsNeeded: mealIngredients,
        prepTime: widget.recipe.cookingTime,
        calories: 0, // This should come from the recipe model
      );

      final dailyMeals = DailyMeals(
        breakfast: mealType == 'breakfast' ? meal : null,
        lunch: mealType == 'lunch' ? meal : null,
        dinner: mealType == 'dinner' ? meal : null,
      );

      final notifier = ref.read(mealPlanningProvider.notifier);
      final existingPlan = await ref.read(
        mealPlanByDateProvider(dateStr).future,
      );

      if (existingPlan != null) {
        // Update existing plan - merge with existing meals
        final updatedMeals = DailyMeals(
          breakfast:
              mealType == 'breakfast' ? meal : existingPlan.meals.breakfast,
          lunch: mealType == 'lunch' ? meal : existingPlan.meals.lunch,
          dinner: mealType == 'dinner' ? meal : existingPlan.meals.dinner,
        );
        await notifier.updateMealPlan(dateStr, updatedMeals);
      } else {
        // Create new plan
        await notifier.saveMealPlan(dateStr, dailyMeals);
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ ${widget.recipe.name} agregada al plan de ${_getMealTypeLabel(mealType)} del ${_formatDateString(dateStr)}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Ver Plan',
              textColor: Colors.white,
              onPressed: () {
                context.push('/unified-planning?date=$dateStr');
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al agregar al plan: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Get meal type label in Spanish
  String _getMealTypeLabel(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return 'desayuno';
      case 'lunch':
        return 'almuerzo';
      case 'dinner':
        return 'cena';
      default:
        return mealType;
    }
  }

  /// Format date string for display
  String _formatDateString(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
