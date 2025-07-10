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
import 'package:zer0_waste_ai/features/recipes/application/providers/firestore_recipes_provider.dart';

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

  /// Generate cooking steps from recipe data (fallback if instructions not available)
  List<String> _generateCookingSteps(Recipe recipe) {
    // Use instructions if available
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
  Map<String, dynamic> _environmentalImpact = {};
  List<String> _missingIngredients = [];
  List<String> _availableIngredients = [];

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

  // Verifica qué ingredientes están disponibles en el inventario y calcula impacto ambiental
  void _checkIngredientAvailability() {
    final inventoryState = ref.read(inventoryRealProvider);
    final List<String> recipeIngredients = widget.recipe.ingredients;

    final availableIngredients = <String>[];
    final missingIngredients = <String>[];
    final availabilityMap = <String, bool>{};

    for (var ingredient in recipeIngredients) {
      final ingredientInfo = _parseIngredientSimple(ingredient);
      String ingredientName = (ingredientInfo['name'] ?? '').toLowerCase();

      // Verificar si algún item del inventario contiene este ingrediente (y no está expirado)
      bool isAvailable = inventoryState.items.any((item) {
        bool nameMatches =
            item.name.toLowerCase().contains(ingredientName) ||
            ingredientName.contains(item.name.toLowerCase());
        bool notExpired =
            item.expirationDate == null ||
            item.expirationDate!.isAfter(DateTime.now());
        return nameMatches && notExpired;
      });

      final cleanIngredientName = ingredientInfo['name'] ?? ingredient;
      availabilityMap[cleanIngredientName] = isAvailable;

      if (isAvailable) {
        availableIngredients.add(cleanIngredientName);
      } else {
        missingIngredients.add(cleanIngredientName);
      }
    }

    // Calculate environmental impact
    final impact = _calculateEnvironmentalImpact(
      recipeIngredients,
      availableIngredients.length,
      missingIngredients.length,
    );

    setState(() {
      _ingredientAvailability = availabilityMap;
      _missingIngredients = missingIngredients;
      _availableIngredients = availableIngredients;
      _environmentalImpact = impact;
    });
  }

  // Calculate environmental impact based on recipe and ingredient availability
  Map<String, dynamic> _calculateEnvironmentalImpact(
    List<String> ingredients,
    int availableCount,
    int missingCount,
  ) {
    double baseCO2 = 0.0;
    double baseWaterUsage = 0.0;
    double sustainabilityScore = 85.0; // Base score

    // Calculate base environmental cost per ingredient
    for (String ingredient in ingredients) {
      final ingredientLower = ingredient.toLowerCase();

      // CO2 emissions (kg CO2 per serving)
      if (ingredientLower.contains('carne') ||
          ingredientLower.contains('beef') ||
          ingredientLower.contains('res')) {
        baseCO2 += 3.2;
        sustainabilityScore -= 8;
      } else if (ingredientLower.contains('pollo') ||
          ingredientLower.contains('chicken')) {
        baseCO2 += 1.8;
        sustainabilityScore -= 4;
      } else if (ingredientLower.contains('pescado') ||
          ingredientLower.contains('fish') ||
          ingredientLower.contains('salmón')) {
        baseCO2 += 2.1;
        sustainabilityScore -= 3;
      } else if (ingredientLower.contains('cerdo') ||
          ingredientLower.contains('pork')) {
        baseCO2 += 2.9;
        sustainabilityScore -= 6;
      } else if (ingredientLower.contains('queso') ||
          ingredientLower.contains('cheese')) {
        baseCO2 += 1.4;
        sustainabilityScore -= 2;
      } else if (ingredientLower.contains('leche') ||
          ingredientLower.contains('milk')) {
        baseCO2 += 0.9;
        sustainabilityScore -= 1;
      } else if (ingredientLower.contains('arroz') ||
          ingredientLower.contains('rice')) {
        baseCO2 += 0.8;
      } else if (ingredientLower.contains('papa') ||
          ingredientLower.contains('potato')) {
        baseCO2 += 0.2;
        sustainabilityScore += 2;
      } else if (ingredientLower.contains('tomate') ||
          ingredientLower.contains('tomato')) {
        baseCO2 += 0.4;
        sustainabilityScore += 1;
      } else if (ingredientLower.contains('cebolla') ||
          ingredientLower.contains('onion')) {
        baseCO2 += 0.2;
        sustainabilityScore += 1;
      } else {
        // Default for vegetables and other ingredients
        baseCO2 += 0.3;
        sustainabilityScore += 0.5;
      }

      // Water usage (liters per serving)
      if (ingredientLower.contains('carne') ||
          ingredientLower.contains('beef')) {
        baseWaterUsage += 185;
      } else if (ingredientLower.contains('pollo') ||
          ingredientLower.contains('chicken')) {
        baseWaterUsage += 85;
      } else if (ingredientLower.contains('arroz') ||
          ingredientLower.contains('rice')) {
        baseWaterUsage += 45;
      } else if (ingredientLower.contains('queso') ||
          ingredientLower.contains('cheese')) {
        baseWaterUsage += 65;
      } else {
        baseWaterUsage += 15; // Default for vegetables
      }
    }

    // Bonus for using inventory ingredients (reduces transportation and waste)
    double inventoryBonus = (availableCount / ingredients.length) * 100;
    sustainabilityScore +=
        inventoryBonus * 0.15; // 15% bonus for each available ingredient

    // Penalty for missing ingredients (need to buy, transportation, packaging)
    double transportationCO2 =
        missingCount * 0.5; // Additional CO2 for shopping trips
    baseCO2 += transportationCO2;

    // Food waste prevention bonus
    double wastePreventionScore =
        availableCount * 5.0; // Points for using inventory items

    // Clamp sustainability score
    sustainabilityScore = sustainabilityScore.clamp(0.0, 100.0);

    return {
      'co2Emissions': baseCO2,
      'waterUsage': baseWaterUsage,
      'sustainabilityScore': sustainabilityScore,
      'inventoryUsage': inventoryBonus,
      'wastePreventionScore': wastePreventionScore,
      'transportationImpact': transportationCO2,
      'localIngredients': availableCount,
      'needToBuy': missingCount,
    };
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDeleteRecipe(context),
            tooltip: 'Eliminar receta',
          ),
          FavoriteButton(recipe: widget.recipe),
        ],
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

            // Environmental Impact Section - CORE OF THE APP!
            _buildEnvironmentalImpactSection(
              primaryColor,
              cardColor,
              textColor,
              secondaryTextColor,
              isDark,
            ),
            const SizedBox(height: 16),

            // Ingredient Availability Section
            _buildIngredientAvailabilitySection(
              primaryColor,
              cardColor,
              textColor,
              secondaryTextColor,
              isDark,
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

            // Recipe steps (previously called instructions)
            if (widget.recipe.instructions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                color: cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pasos',
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

  /// Environmental Impact Section - CORE OF THE APP!
  Widget _buildEnvironmentalImpactSection(
    Color primaryColor,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    if (_environmentalImpact.isEmpty) {
      return const SizedBox.shrink();
    }

    final co2 = _environmentalImpact['co2Emissions']?.toDouble() ?? 0.0;
    final water = _environmentalImpact['waterUsage']?.toDouble() ?? 0.0;
    final sustainability =
        _environmentalImpact['sustainabilityScore']?.toDouble() ?? 0.0;
    final wastePreventionScore =
        _environmentalImpact['wastePreventionScore']?.toDouble() ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2E7D32).withValues(alpha: 0.1),
            const Color(0xFF4CAF50).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.eco,
                  color: Color(0xFF2E7D32),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🌍 Impacto Ambiental',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    Text(
                      'Análisis del impacto de esta receta',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              _buildSustainabilityBadge(sustainability),
            ],
          ),
          const SizedBox(height: 16),

          // Environmental metrics grid
          Row(
            children: [
              Expanded(
                child: _buildEnvironmentalMetric(
                  icon: Icons.cloud,
                  label: 'CO₂',
                  value: '${co2.toStringAsFixed(1)} kg',
                  color: _getCO2Color(co2),
                  subtitle: 'Emisiones',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEnvironmentalMetric(
                  icon: Icons.water_drop,
                  label: 'Agua',
                  value: '${water.toStringAsFixed(0)} L',
                  color: const Color(0xFF2196F3),
                  subtitle: 'Uso de agua',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildEnvironmentalMetric(
                  icon: Icons.recycling,
                  label: 'Desperdicio',
                  value: '${wastePreventionScore.toStringAsFixed(0)} pts',
                  color: const Color(0xFF4CAF50),
                  subtitle: 'Prevención',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEnvironmentalMetric(
                  icon: Icons.inventory_2,
                  label: 'Inventario',
                  value:
                      '${_availableIngredients.length}/${widget.recipe.ingredients.length}',
                  color: primaryColor,
                  subtitle: 'Disponible',
                ),
              ),
            ],
          ),

          if (_missingIngredients.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildEnvironmentalTip(),
          ],
        ],
      ),
    );
  }

  Widget _buildSustainabilityBadge(double score) {
    Color badgeColor;
    String label;
    IconData icon;

    if (score >= 80) {
      badgeColor = const Color(0xFF4CAF50);
      label = 'Excelente';
      icon = Icons.star;
    } else if (score >= 60) {
      badgeColor = const Color(0xFF8BC34A);
      label = 'Bueno';
      icon = Icons.thumb_up;
    } else if (score >= 40) {
      badgeColor = const Color(0xFFFF9800);
      label = 'Regular';
      icon = Icons.warning;
    } else {
      badgeColor = const Color(0xFFE53935);
      label = 'Mejorable';
      icon = Icons.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalTip() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF2196F3).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Color(0xFF2196F3), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Comprando ${_missingIngredients.length} ingredientes aumentas +${(_missingIngredients.length * 0.5).toStringAsFixed(1)} kg CO₂',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF2196F3),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCO2Color(double co2) {
    if (co2 <= 1.0) return const Color(0xFF4CAF50); // Green - low impact
    if (co2 <= 3.0) return const Color(0xFF8BC34A); // Light green
    if (co2 <= 6.0) return const Color(0xFFFF9800); // Orange - medium impact
    return const Color(0xFFE53935); // Red - high impact
  }

  /// Ingredient Availability Section
  Widget _buildIngredientAvailabilitySection(
    Color primaryColor,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    final totalIngredients = widget.recipe.ingredients.length;
    final availableCount = _availableIngredients.length;
    // final missingCount = _missingIngredients.length; // Unused for now
    final availabilityPercentage =
        (availableCount / totalIngredients * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      color: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2, color: primaryColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disponibilidad de Ingredientes',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Comparando con tu inventario actual',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$availabilityPercentage% disponible',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progreso de ingredientes:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  Text(
                    '$availableCount de $totalIngredients',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: availableCount / totalIngredients,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                minHeight: 8,
              ),
            ],
          ),

          if (_availableIngredients.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildIngredientsList(
              title: '✅ Tienes en inventario (${_availableIngredients.length})',
              ingredients: _availableIngredients,
              color: const Color(0xFF4CAF50),
              textColor: textColor,
              available: true,
            ),
          ],

          if (_missingIngredients.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildIngredientsList(
              title: '🛒 Necesitas comprar (${_missingIngredients.length})',
              ingredients: _missingIngredients,
              color: const Color(0xFFFF9800),
              textColor: textColor,
              available: false,
            ),
            const SizedBox(height: 12),
            _buildShoppingListButton(primaryColor),
          ],
        ],
      ),
    );
  }

  Widget _buildIngredientsList({
    required String title,
    required List<String> ingredients,
    required Color color,
    required Color textColor,
    required bool available,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              ingredients.map((ingredient) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        available ? Icons.check_circle : Icons.shopping_cart,
                        size: 14,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ingredient,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildShoppingListButton(Color primaryColor) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          _showShoppingListDialog();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFF9800),
          side: const BorderSide(color: Color(0xFFFF9800)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.shopping_cart, size: 18),
        label: Text(
          'Generar Lista de Compras',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showShoppingListDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.shopping_cart, color: Color(0xFFFF9800)),
                const SizedBox(width: 8),
                const Text('Lista de Compras'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingredientes necesarios para: ${widget.recipe.name}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                ...(_missingIngredients.map(
                  (ingredient) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shopping_cart,
                          size: 16,
                          color: Color(0xFFFF9800),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(ingredient)),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🌱 Consejo Ecológico:',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Compra productos locales y de temporada para reducir tu huella de carbono.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Here you could integrate with a shopping app or save to notes
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lista de compras guardada en Notas'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                ),
                icon: const Icon(Icons.save, size: 16),
                label: const Text('Guardar Lista'),
              ),
            ],
          ),
    );
  }

  // Add the confirmDeleteRecipe method
  void _confirmDeleteRecipe(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Eliminar Receta',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            content: Text(
              '¿Estás seguro que deseas eliminar esta receta? Esta acción no se puede deshacer.',
              style: GoogleFonts.inter(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar', style: GoogleFonts.inter()),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // Close dialog

                  try {
                    // Delete recipe from Firestore
                    await ref
                        .read(firestoreRecipesProvider.notifier)
                        .deleteRecipe(widget.recipe.id);

                    // Show confirmation
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Receta eliminada correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Navigate back to recipe list
                      context.pop();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al eliminar la receta: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  'Eliminar',
                  style: GoogleFonts.inter(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
