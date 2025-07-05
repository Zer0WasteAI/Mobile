import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/meal_plan_models.dart';
import '../providers/recipe_generation_providers.dart';
import '../providers/meal_planning_providers.dart';
import '../widgets/recipe_card_widget.dart';

class RecipeGenerationScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final MealType mealType;
  final bool isManualPlan;

  const RecipeGenerationScreen({
    super.key,
    required this.selectedDate,
    required this.mealType,
    this.isManualPlan = false,
  });

  @override
  ConsumerState<RecipeGenerationScreen> createState() => _RecipeGenerationScreenState();
}

class _RecipeGenerationScreenState extends ConsumerState<RecipeGenerationScreen> {
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Generate recipes after first build
    Future(() => _generateRecipes());
  }

  Future<void> _generateRecipes({bool forceRegenerate = false}) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      await ref.read(recipeGenerationProvider.notifier).generateCustomRecipes(
        mealType: widget.mealType,
        numRecipes: 5,
        forceRegenerate: forceRegenerate,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar recetas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final recipeState = ref.watch(recipeGenerationProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Recetas para ${widget.mealType.name}'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _generateRecipes,
            icon: const Icon(Icons.refresh),
            tooltip: 'Generar nuevas recetas',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(colorScheme, textTheme, recipeState),
          Expanded(
            child: _buildContent(colorScheme, textTheme, recipeState),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme, RecipeGenerationState recipeState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.mealType.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.mealType.icon,
                  color: colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mealType.name,
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, d MMMM', 'es_ES').format(widget.selectedDate),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  recipeState.areRecipesFresh ? Icons.storage : Icons.auto_awesome,
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recipeState.areRecipesFresh 
                      ? 'Recetas guardadas para tu ${widget.mealType.name.toLowerCase()}'
                      : 'Recetas generadas especialmente para tu ${widget.mealType.name.toLowerCase()}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                if (recipeState.areRecipesFresh)
                  GestureDetector(
                    onTap: () => _generateRecipes(forceRegenerate: true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Regenerar',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ColorScheme colorScheme, TextTheme textTheme, RecipeGenerationState state) {
    if (_isGenerating || state.isLoading) {
      return _buildLoadingState();
    }

    if (state.error != null) {
      return _buildErrorState(state.error!, colorScheme, textTheme);
    }

    if (state.recipes.isEmpty) {
      return _buildEmptyState(colorScheme, textTheme);
    }

    return _buildRecipesList(state.recipes, colorScheme);
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Generando recetas deliciosas...'),
          SizedBox(height: 8),
          Text(
            'Esto puede tardar unos segundos',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al generar recetas',
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _generateRecipes,
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar de nuevo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron recetas',
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta generar nuevas recetas o verifica tu conexión',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _generateRecipes,
              icon: const Icon(Icons.refresh),
              label: const Text('Generar recetas'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipesList(List<GeneratedRecipe> recipes, ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: RecipeCardWidget(
            recipe: recipe,
            onAddToPlan: () => _addRecipeToPlan(recipe),
            onStartCooking: () => _onCookingComplete(recipe),
            onSaveRecipe: () => _saveRecipe(recipe),
          ),
        );
      },
    );
  }

  Future<void> _addRecipeToPlan(GeneratedRecipe recipe) async {
    try {
      // Convert GeneratedRecipe to Meal
      final meal = Meal(
        recipeTitle: recipe.title,
        ingredientsNeeded: recipe.ingredients.map((ingredient) => 
          MealIngredient(
            name: ingredient.name,
            quantity: ingredient.quantity.toInt(),
            unit: ingredient.unit,
          )
        ).toList(),
        prepTime: recipe.prepTime + recipe.cookTime,
        calories: recipe.calories ?? 250,
      );
      
      // If this is from manual plan creation, just return the meal
      if (widget.isManualPlan) {
        if (mounted) {
          // Return the meal to the manual plan creation screen
          context.pop(meal);
        }
        return;
      }
      
      // Otherwise, proceed with normal plan saving
      final dateString = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
      
      // Get current meal plan for the date
      final existingPlan = await ref.read(mealPlanByDateProvider(dateString).future);
      
      // Create updated daily meals
      DailyMeals updatedMeals;
      if (existingPlan != null) {
        // Update existing plan
        updatedMeals = DailyMeals(
          breakfast: widget.mealType == MealType.breakfast ? meal : existingPlan.meals.breakfast,
          lunch: widget.mealType == MealType.lunch ? meal : existingPlan.meals.lunch,
          dinner: widget.mealType == MealType.dinner ? meal : existingPlan.meals.dinner,
        );
        
        // Update the existing plan
        await ref.read(mealPlanningProvider.notifier).updateMealPlan(
          dateString,
          updatedMeals,
        );
        
        // Invalidate the meal plan by date provider to refresh UI
        ref.invalidate(mealPlanByDateProvider(dateString));
      } else {
        // Create new plan
        updatedMeals = DailyMeals(
          breakfast: widget.mealType == MealType.breakfast ? meal : null,
          lunch: widget.mealType == MealType.lunch ? meal : null,
          dinner: widget.mealType == MealType.dinner ? meal : null,
        );
        
        // Save new plan
        await ref.read(mealPlanningProvider.notifier).saveMealPlan(
          dateString,
          updatedMeals,
        );
        
        // Invalidate the meal plan by date provider to refresh UI
        ref.invalidate(mealPlanByDateProvider(dateString));
      }
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${recipe.title} agregado al plan del ${widget.mealType.name.toLowerCase()}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Ver Plan',
              onPressed: () {
                context.pop(); // Return to planning screen
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
            content: Text('Error al agregar receta al plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _onCookingComplete(GeneratedRecipe recipe) {
    // Show additional success message for completed cooking
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Excelente! Has cocinado ${recipe.title} con éxito'),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Agregar al Plan',
          textColor: Colors.white,
          onPressed: () => _addRecipeToPlan(recipe),
        ),
      ),
    );
  }
  
  Future<void> _saveRecipe(GeneratedRecipe recipe) async {
    try {
      final success = await ref.read(recipeGenerationProvider.notifier).saveGeneratedRecipe(recipe);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                ? '¡${recipe.title} guardada en tus favoritos!'
                : 'Error al guardar la receta'
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}