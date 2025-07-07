import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/recipe_generation_providers.dart';
import '../../../favorites/presentation/providers/favorite_recipe_providers.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final GeneratedRecipe recipe;
  final VoidCallback? onAddToPlan;
  final String? mealType;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    this.onAddToPlan,
    this.mealType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final recipeId =
        '${recipe.title}_${recipe.generatedAt.millisecondsSinceEpoch}';
    final isFavoriteAsync = ref.watch(isFavoriteProvider(recipeId));
    final favoriteAction = ref.watch(favoriteActionProvider.notifier);

    // Debug: Print any errors
    isFavoriteAsync.whenOrNull(
      error: (error, stackTrace) {
        print('Favorites error for $recipeId: $error');
        print('Stack trace: $stackTrace');
      },
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primaryContainer,
                          colorScheme.primaryContainer.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child:
                        recipe.imagePath != null &&
                                recipe.imageStatus == 'ready'
                            ? Image.network(
                              recipe.imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderImage(colorScheme);
                              },
                            )
                            : _buildPlaceholderImage(colorScheme),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              isFavoriteAsync.when(
                data:
                    (isFavorite) => IconButton(
                      onPressed: () async {
                        try {
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
                            mealType: mealType ?? _detectMealType(recipe.title),
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error al actualizar favoritos: $e',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : colorScheme.onPrimary,
                        size: 28,
                      ),
                    ),
                loading:
                    () => const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                error:
                    (error, stackTrace) => IconButton(
                      onPressed: () async {
                        // Try to refresh the provider and attempt toggle again
                        ref.invalidate(isFavoriteProvider(recipeId));
                        await Future.delayed(const Duration(milliseconds: 500));
                        try {
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
                            mealType: mealType ?? _detectMealType(recipe.title),
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error al agregar/quitar de favoritos: $e',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: Icon(
                        Icons.favorite_border,
                        color: colorScheme.onPrimary,
                        size: 28,
                      ),
                    ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(textTheme, colorScheme),
                  const SizedBox(height: 16),
                  _buildMetrics(textTheme, colorScheme),
                  const SizedBox(height: 24),
                  _buildDescription(textTheme, colorScheme),
                  const SizedBox(height: 24),
                  _buildIngredients(textTheme, colorScheme),
                  const SizedBox(height: 24),
                  _buildInstructions(textTheme, colorScheme),
                  const SizedBox(height: 32),
                  if (onAddToPlan != null)
                    _buildActionButton(context, colorScheme),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 80,
          color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mealType != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              mealType!,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ),
        if (mealType != null) const SizedBox(height: 12),
        Text(
          _cleanRecipeTitle(recipe.title),
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
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
        const SizedBox(width: 24),
        _buildMetric(
          Icons.people,
          '${recipe.servings} ${recipe.servings == 1 ? 'porción' : 'porciones'}',
          textTheme,
          colorScheme,
        ),
        const SizedBox(width: 24),
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
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          recipe.description,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.5,
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
          'Ingredientes',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...recipe.ingredients.asMap().entries.map((entry) {
          final ingredient = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${ingredient.quantity} ${ingredient.unit} ${ingredient.name}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }


  Widget _buildInstructions(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preparación',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...recipe.instructions.asMap().entries.map((entry) {
          final index = entry.key;
          final instruction = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    instruction,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          onAddToPlan?.call();
          Navigator.pop(context);
        },
        icon: const Icon(Icons.add_circle),
        label: Text(
          'Agregar al Plan',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

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
}
