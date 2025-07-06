import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recipe_generation_providers.dart';
import '../../../favorites/presentation/providers/favorite_recipe_providers.dart';
import '../screens/recipe_detail_screen.dart';

class RecipeCardWidget extends ConsumerWidget {
  final GeneratedRecipe recipe;
  final VoidCallback onAddToPlan;
  final VoidCallback? onStartCooking;
  final VoidCallback? onSaveRecipe;

  const RecipeCardWidget({
    super.key,
    required this.recipe,
    required this.onAddToPlan,
    this.onStartCooking,
    this.onSaveRecipe,
  });

  /// Convert GeneratedRecipe to format expected by RecipeCookingMode
  // ignore: unused_element
  Map<String, dynamic> _convertGeneratedRecipeToStepsFormat(
    GeneratedRecipe recipe,
  ) {
    return {
      'title': _cleanRecipeTitle(recipe.title),
      'description': recipe.description,
      'cookingTime': recipe.prepTime + recipe.cookTime,
      'difficulty': recipe.difficulty,
      'ingredients': recipe.ingredients.map((ing) => ing.name).toList(),
      'steps':
          recipe
              .instructions, // GeneratedRecipe already has instructions as List<String>
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showRecipeDetail(context, ref),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(colorScheme),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(textTheme, colorScheme, ref),
                  const SizedBox(height: 8),
                  _buildDescription(textTheme, colorScheme),
                  const SizedBox(height: 12),
                  _buildMetrics(textTheme, colorScheme),
                  const SizedBox(height: 12),
                  _buildIngredients(textTheme, colorScheme),
                  const SizedBox(height: 16),
                  _buildActionButton(context, colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(ColorScheme colorScheme) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      ),
      child:
          recipe.imagePath != null && recipe.imageStatus == 'ready'
              ? ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  recipe.imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderImage(colorScheme);
                  },
                ),
              )
              : _buildPlaceholderImage(colorScheme),
    );
  }

  Widget _buildPlaceholderImage(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.restaurant_menu,
              size: 48,
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
            ),
          ),
          /*if (recipe.imageStatus == 'generating')
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Generando...',
                      style: TextStyle(
                        color: colorScheme.onSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        */
        ],
      ),
    );
  }

  Widget _buildHeader(
    TextTheme textTheme,
    ColorScheme colorScheme,
    WidgetRef ref,
  ) {
    final recipeId =
        '${recipe.title}_${recipe.generatedAt.millisecondsSinceEpoch}';
    final isFavoriteAsync = ref.watch(isFavoriteProvider(recipeId));
    final favoriteAction = ref.watch(favoriteActionProvider.notifier);
    return Row(
      children: [
        Expanded(
          child: Text(
            _cleanRecipeTitle(recipe.title),
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        isFavoriteAsync.when(
          data:
              (isFavorite) => InkWell(
                onTap: () async {
                  await favoriteAction.toggleFavorite(
                    recipeId,
                    recipe.title,
                    recipe.description,
                    recipe.ingredients.map((ing) => ing.name).toList(),
                    recipe.instructions,
                    recipe.prepTime,
                    recipe.cookTime,
                    recipe.servings,
                    recipe.difficulty,
                    imagePath: recipe.imagePath,
                    mealType: _detectMealType(recipe.title),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color:
                        isFavorite
                            ? colorScheme.primary.withValues(alpha: 0.2)
                            : colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
          loading:
              () => Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
              ),
          error:
              (_, _) => Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.favorite_border,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildDescription(TextTheme textTheme, ColorScheme colorScheme) {
    return Text(
      recipe.description,
      style: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetrics(TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      children: [
        _buildMetric(
          Icons.schedule,
          '${recipe.prepTime + recipe.cookTime} min',
          textTheme,
          colorScheme,
        ),
        const SizedBox(width: 16),
        _buildMetric(
          Icons.people,
          '${recipe.servings} ${recipe.servings == 1 ? 'porción' : 'porciones'}',
          textTheme,
          colorScheme,
        ),
        const SizedBox(width: 16),
        _buildMetric(Icons.star, recipe.difficulty, textTheme, colorScheme),
      ],
    );
  }

  Widget _buildMetric(
    IconData icon,
    String text,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          text,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredients(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredientes principales:',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children:
              recipe.ingredients.take(4).map((ingredient) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ingredient.name,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                );
              }).toList(),
        ),
        if (recipe.ingredients.length > 4)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+ ${recipe.ingredients.length - 4} más',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, ColorScheme colorScheme) {
    if (onStartCooking != null) {
      // Show both buttons when cooking functionality is available
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onAddToPlan,
              icon: const Icon(Icons.add_circle),
              label: const Text('Agregar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      );
    } else {
      // Show only add to plan button when cooking is not available
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onAddToPlan,
          icon: const Icon(Icons.add_circle),
          label: const Text('Agregar al Plan'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    }
  }

  // Función para limpiar nombres de recetas removiendo sufijos como (1), (2), etc.
  String _cleanRecipeTitle(String title) {
    return title.replaceAll(RegExp(r'\s*\(\d+\)$'), '').trim();
  }

  String _detectMealType(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('desayuno') ||
        lowerTitle.contains('breakfast') ||
        lowerTitle.contains('avena') ||
        lowerTitle.contains('tostada') ||
        lowerTitle.contains('cereal') ||
        lowerTitle.contains('huevo') ||
        lowerTitle.contains('pancake')) {
      return 'Desayuno';
    } else if (lowerTitle.contains('almuerzo') ||
        lowerTitle.contains('lunch') ||
        lowerTitle.contains('sopa') ||
        lowerTitle.contains('ensalada')) {
      return 'Almuerzo';
    } else if (lowerTitle.contains('cena') ||
        lowerTitle.contains('dinner') ||
        lowerTitle.contains('pasta') ||
        lowerTitle.contains('pollo') ||
        lowerTitle.contains('pescado') ||
        lowerTitle.contains('carne')) {
      return 'Cena';
    } else {
      return 'Comida'; // Tipo genérico
    }
  }

  void _showRecipeDetail(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => RecipeDetailScreen(
              recipe: recipe,
              onAddToPlan: onAddToPlan,
              mealType: _detectMealType(recipe.title),
            ),
      ),
    );
  }
}
