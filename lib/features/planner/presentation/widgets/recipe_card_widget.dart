import 'package:flutter/material.dart';
import '../providers/recipe_generation_providers.dart';

class RecipeCardWidget extends StatelessWidget {
  final GeneratedRecipe recipe;
  final VoidCallback onAddToPlan;

  const RecipeCardWidget({
    super.key,
    required this.recipe,
    required this.onAddToPlan,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(colorScheme),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(textTheme, colorScheme),
                const SizedBox(height: 8),
                _buildDescription(textTheme, colorScheme),
                const SizedBox(height: 12),
                _buildMetrics(textTheme, colorScheme),
                const SizedBox(height: 12),
                _buildIngredients(textTheme, colorScheme),
                const SizedBox(height: 16),
                _buildActionButton(colorScheme),
              ],
            ),
          ),
        ],
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
      child: recipe.imagePath != null && recipe.imageStatus == 'ready'
          ? ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
          if (recipe.imageStatus == 'generating')
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
        ],
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            recipe.title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (recipe.calories != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${recipe.calories} kcal',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.secondary,
                fontWeight: FontWeight.w600,
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
        _buildMetric(
          Icons.star,
          recipe.difficulty,
          textTheme,
          colorScheme,
        ),
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
        Icon(
          icon,
          size: 16,
          color: colorScheme.primary,
        ),
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
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: recipe.ingredients.take(4).map((ingredient) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  Widget _buildActionButton(ColorScheme colorScheme) {
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