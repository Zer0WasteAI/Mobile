import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/meal_plan_models.dart';
import '../providers/recipe_generation_providers.dart';
import '../providers/meal_planning_providers.dart';
import '../widgets/recipe_card_widget.dart';
import '../../../favorites/presentation/providers/favorite_recipe_providers.dart';
import '../../../favorites/domain/models/favorite_recipe_model.dart';

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
  ConsumerState<RecipeGenerationScreen> createState() =>
      _RecipeGenerationScreenState();
}

class _RecipeGenerationScreenState
    extends ConsumerState<RecipeGenerationScreen> {
  bool _isGenerating = false;
  bool _showFavorites = false; // Toggle between generated recipes and favorites

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
      await ref
          .read(recipeGenerationProvider.notifier)
          .generateCustomRecipes(
            mealType: widget.mealType,
            numRecipes: 5,
            forceRegenerate: forceRegenerate,
          );

      // Show success message only when force regenerating
      if (mounted && forceRegenerate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Nuevas recetas generadas para ${widget.mealType.name.toLowerCase()}!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Ver',
              textColor: Colors.white,
              onPressed: () {
                // Scroll to top to see new recipes
                if (mounted) {
                  Scrollable.ensureVisible(
                    context,
                    duration: const Duration(milliseconds: 500),
                  );
                }
              },
            ),
          ),
        );
      }
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
          // Toggle between favorites and generated recipes
          /*
          IconButton(
            onPressed: () {
              setState(() {
                _showFavorites = !_showFavorites;
              });
            },
            icon: Icon(_showFavorites ? Icons.auto_awesome : Icons.favorite),
            tooltip:
                _showFavorites ? 'Ver recetas generadas' : 'Ver mis favoritos',
          ),
          */
          if (!_showFavorites)
            IconButton(
              onPressed:
                  _isGenerating
                      ? null
                      : () => _generateRecipes(forceRegenerate: true),
              icon:
                  _isGenerating
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.refresh),
              tooltip: 'Generar nuevas recetas',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(colorScheme, textTheme, recipeState),
          Expanded(child: _buildContent(colorScheme, textTheme, recipeState)),
        ],
      ),
    );
  }

  Widget _buildHeader(
    ColorScheme colorScheme,
    TextTheme textTheme,
    RecipeGenerationState recipeState,
  ) {
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
                      DateFormat(
                        'EEEE, d MMMM',
                        'es_ES',
                      ).format(widget.selectedDate),
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
                  _showFavorites
                      ? Icons.favorite
                      : (recipeState.areRecipesFresh
                          ? Icons.storage
                          : Icons.auto_awesome),
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _showFavorites
                        ? 'Tus recetas favoritas de ${widget.mealType.name.toLowerCase()}'
                        : (recipeState.areRecipesFresh
                            ? 'Recetas guardadas para tu ${widget.mealType.name.toLowerCase()}'
                            : 'Recetas generadas especialmente para tu ${widget.mealType.name.toLowerCase()}'),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                if (recipeState.areRecipesFresh && !_showFavorites)
                  GestureDetector(
                    onTap:
                        _isGenerating
                            ? null
                            : () => _generateRecipes(forceRegenerate: true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _isGenerating
                                ? colorScheme.onPrimary.withValues(alpha: 0.1)
                                : colorScheme.onPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.onPrimary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isGenerating)
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.onPrimary,
                                ),
                              ),
                            )
                          else
                            Icon(
                              Icons.auto_awesome,
                              color: colorScheme.onPrimary,
                              size: 16,
                            ),
                          const SizedBox(width: 4),
                          Text(
                            _isGenerating ? 'Generando...' : 'Regenerar',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

  Widget _buildContent(
    ColorScheme colorScheme,
    TextTheme textTheme,
    RecipeGenerationState state,
  ) {
    if (_showFavorites) {
      return _buildFavoritesContent(colorScheme, textTheme);
    }

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

  Widget _buildErrorState(
    String error,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
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
            Icon(Icons.restaurant_menu, size: 64, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text('No se encontraron recetas', style: textTheme.headlineSmall),
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

  Widget _buildRecipesList(
    List<GeneratedRecipe> recipes,
    ColorScheme colorScheme,
  ) {
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
          ),
        );
      },
    );
  }

  Widget _buildFavoritesContent(ColorScheme colorScheme, TextTheme textTheme) {
    final favoritesAsync = ref.watch(userFavoritesProvider);

    return favoritesAsync.when(
      data: (favorites) {
        // Filter favorites by current meal type
        final filteredFavorites = _filterFavoritesByMealType(favorites);

        if (filteredFavorites.isEmpty) {
          return _buildEmptyFavoritesState(colorScheme, textTheme);
        }

        return _buildFavoritesList(filteredFavorites, colorScheme, textTheme);
      },
      loading: () => _buildLoadingState(),
      error:
          (error, _) =>
              _buildErrorState(error.toString(), colorScheme, textTheme),
    );
  }

  List<FavoriteRecipe> _filterFavoritesByMealType(
    List<FavoriteRecipe> favorites,
  ) {
    final mealTypeString = _getMealTypeString(widget.mealType);
    return favorites
        .where(
          (favorite) =>
              favorite.mealType?.toLowerCase() == mealTypeString.toLowerCase(),
        )
        .toList();
  }

  String _getMealTypeString(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return 'Desayuno';
      case MealType.lunch:
        return 'Almuerzo';
      case MealType.dinner:
        return 'Cena';
      case MealType.snack:
        return 'Snack';
    }
  }

  Widget _buildEmptyFavoritesState(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 50,
                color: colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin favoritos de ${widget.mealType.name.toLowerCase()}',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Agrega recetas de ${widget.mealType.name.toLowerCase()} a tus favoritos para verlas aquí',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showFavorites = false;
                });
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Ver recetas generadas'),
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

  Widget _buildFavoritesList(
    List<FavoriteRecipe> favorites,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with count
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Icon(Icons.favorite, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${favorites.length} ${favorites.length == 1 ? 'favorito' : 'favoritos'} de ${widget.mealType.name.toLowerCase()}',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Favorites horizontal scroll (like home screen)
        Expanded(
          child:
              favorites.length <= 2
                  // If 2 or fewer favorites, show them in a row
                  ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children:
                          favorites.asMap().entries.map((entry) {
                            final index = entry.key;
                            final favorite = entry.value;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: index == favorites.length - 1 ? 0 : 12,
                                ),
                                child: _buildFavoriteCard(
                                  favorite,
                                  colorScheme,
                                  textTheme,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  )
                  // If more than 2 favorites, show horizontal scroll
                  : SizedBox(
                    height: 220, // Fixed height like home screen
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final favorite = favorites[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index == favorites.length - 1 ? 0 : 12.0,
                          ),
                          child: _buildFavoriteCard(
                            favorite,
                            colorScheme,
                            textTheme,
                          ),
                        );
                      },
                    ),
                  ),
        ),
        // Add some bottom padding
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFavoriteCard(
    FavoriteRecipe favorite,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    // Get colors and styling similar to home screen cards
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBackgroundColor =
        isDark ? colorScheme.surface : Colors.white;
    final Color primaryColor = colorScheme.primary;
    final Color mainTextColor = colorScheme.onSurface;
    final Color placeholderColor = Colors.grey.shade200;
    final Color placeholderIconColor = Colors.grey.shade400;

    // Determine badge color based on difficulty
    final Color badgeColor =
        favorite.difficulty == 'Fácil'
            ? primaryColor.withValues(alpha: 0.2)
            : Colors.orange.withValues(alpha: 0.2);
    final Color badgeTextColor =
        favorite.difficulty == 'Fácil' ? primaryColor : Colors.orange;

    return SizedBox(
      width: 160, // Fixed width for consistency with home screen
      child: Card(
        elevation: isDark ? 1 : 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: cardBackgroundColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () => _addFavoriteRecipeToPlan(favorite),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              AspectRatio(
                aspectRatio: 16 / 10,
                child:
                    favorite.imagePath != null
                        ? Image.network(
                          favorite.imagePath!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            return progress == null
                                ? child
                                : Container(
                                  color: placeholderColor,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                          },
                          errorBuilder: (context, error, stack) {
                            return Container(
                              color: placeholderColor,
                              child: Icon(
                                Icons.restaurant_menu,
                                color: placeholderIconColor,
                                size: 40,
                              ),
                            );
                          },
                        )
                        : Container(
                          color: placeholderColor,
                          child: Icon(
                            Icons.restaurant_menu,
                            color: placeholderIconColor,
                            size: 40,
                          ),
                        ),
              ),
              // Content section
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with favorite icon
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            favorite.title,
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: mainTextColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.favorite, color: Colors.red, size: 16),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Difficulty badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        favorite.difficulty,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Time and servings info
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 12, color: primaryColor),
                        const SizedBox(width: 2),
                        Text(
                          '${favorite.prepTime + favorite.cookTime} min',
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: mainTextColor.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.people, size: 12, color: primaryColor),
                        const SizedBox(width: 2),
                        Text(
                          '${favorite.servings}',
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: mainTextColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addRecipeToPlan(GeneratedRecipe recipe) async {
    try {
      // Convert GeneratedRecipe to Meal
      final meal = Meal(
        recipeTitle: _cleanRecipeTitle(recipe.title),
        ingredientsNeeded:
            recipe.ingredients
                .map(
                  (ingredient) => MealIngredient(
                    name: ingredient.name,
                    quantity: ingredient.quantity.toInt(),
                    unit: ingredient.unit,
                  ),
                )
                .toList(),
        prepTime: recipe.prepTime + recipe.cookTime,
        calories: 0, // Sin calorías
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
      final existingPlan = await ref.read(
        mealPlanByDateProvider(dateString).future,
      );

      // Create updated daily meals
      DailyMeals updatedMeals;
      if (existingPlan != null) {
        // Update existing plan
        updatedMeals = DailyMeals(
          breakfast:
              widget.mealType == MealType.breakfast
                  ? meal
                  : existingPlan.meals.breakfast,
          lunch:
              widget.mealType == MealType.lunch
                  ? meal
                  : existingPlan.meals.lunch,
          dinner:
              widget.mealType == MealType.dinner
                  ? meal
                  : existingPlan.meals.dinner,
        );

        // Update the existing plan
        await ref
            .read(mealPlanningProvider.notifier)
            .updateMealPlan(dateString, updatedMeals);

        // Invalidate the meal plan by date provider to refresh UI
        ref.invalidate(mealPlanByDateProvider(dateString));
      } else {
        // Create new plan
        updatedMeals = DailyMeals(
          breakfast: widget.mealType == MealType.breakfast ? meal : null,
          lunch: widget.mealType == MealType.lunch ? meal : null,
          dinner: widget.mealType == MealType.dinner ? meal : null,
        );

        // Save new plan with fallback to update if already exists
        try {
          await ref
              .read(mealPlanningProvider.notifier)
              .saveMealPlan(dateString, updatedMeals);
        } catch (saveError) {
          // Check if the error is about existing plan
          final errorMessage = saveError.toString().toLowerCase();
          if (errorMessage.contains('ya existe') ||
              errorMessage.contains('already exists')) {
            // Plan already exists, try to update instead
            await ref
                .read(mealPlanningProvider.notifier)
                .updateMealPlan(dateString, updatedMeals);
          } else {
            // If it's not about existing plan, rethrow the error
            rethrow;
          }
        }

        // Invalidate the meal plan by date provider to refresh UI
        ref.invalidate(mealPlanByDateProvider(dateString));
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${recipe.title} agregado al plan del ${widget.mealType.name.toLowerCase()}',
            ),
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
        content: Text(
          '¡Excelente! Has cocinado ${_cleanRecipeTitle(recipe.title)} con éxito',
        ),
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

  Future<void> _addFavoriteRecipeToPlan(FavoriteRecipe favorite) async {
    try {
      // Convert FavoriteRecipe to Meal
      final meal = Meal(
        recipeTitle: _cleanRecipeTitle(favorite.title),
        ingredientsNeeded:
            favorite.ingredients
                .map(
                  (ingredient) => MealIngredient(
                    name: ingredient.name,
                    quantity: ingredient.quantity.toInt(),
                    unit: ingredient.unit,
                  ),
                )
                .toList(),
        prepTime: favorite.prepTime + favorite.cookTime,
        calories: 0, // Sin calorías
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
      final existingPlan = await ref.read(
        mealPlanByDateProvider(dateString).future,
      );

      // Create updated daily meals
      DailyMeals updatedMeals;
      if (existingPlan != null) {
        // Update existing plan
        updatedMeals = DailyMeals(
          breakfast:
              widget.mealType == MealType.breakfast
                  ? meal
                  : existingPlan.meals.breakfast,
          lunch:
              widget.mealType == MealType.lunch
                  ? meal
                  : existingPlan.meals.lunch,
          dinner:
              widget.mealType == MealType.dinner
                  ? meal
                  : existingPlan.meals.dinner,
        );

        // Update the existing plan
        await ref
            .read(mealPlanningProvider.notifier)
            .updateMealPlan(dateString, updatedMeals);

        // Invalidate the meal plan by date provider to refresh UI
        ref.invalidate(mealPlanByDateProvider(dateString));
      } else {
        // Create new plan
        updatedMeals = DailyMeals(
          breakfast: widget.mealType == MealType.breakfast ? meal : null,
          lunch: widget.mealType == MealType.lunch ? meal : null,
          dinner: widget.mealType == MealType.dinner ? meal : null,
        );

        // Save new plan with fallback to update if already exists
        try {
          await ref
              .read(mealPlanningProvider.notifier)
              .saveMealPlan(dateString, updatedMeals);
        } catch (saveError) {
          // Check if the error is about existing plan
          final errorMessage = saveError.toString().toLowerCase();
          if (errorMessage.contains('ya existe') ||
              errorMessage.contains('already exists')) {
            // Plan already exists, try to update instead
            await ref
                .read(mealPlanningProvider.notifier)
                .updateMealPlan(dateString, updatedMeals);
          } else {
            // If it's not about existing plan, rethrow the error
            rethrow;
          }
        }

        // Invalidate the meal plan by date provider to refresh UI
        ref.invalidate(mealPlanByDateProvider(dateString));
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${favorite.title} agregado al plan del ${widget.mealType.name.toLowerCase()}',
            ),
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

  // Función para limpiar nombres de recetas removiendo sufijos como (1), (2), etc.
  String _cleanRecipeTitle(String title) {
    return title.replaceAll(RegExp(r'\s*\(\d+\)$'), '').trim();
  }
}
