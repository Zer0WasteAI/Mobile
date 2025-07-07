import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/meal_plan_models.dart';

class MealDetailScreen extends StatelessWidget {
  static const String routePath = '/planner/meal-detail';
  static const String routeName = 'mealDetail';

  final Meal meal;
  final MealType mealType;

  const MealDetailScreen({
    super.key,
    required this.meal,
    required this.mealType,
  });

  @override
  Widget build(BuildContext context) {
    // Debug: Print meal data to see backend response
    print('=== MEAL DETAIL SCREEN DEBUG ===');
    print('Recipe Title: ${meal.recipeTitle}');
    print('Prep Time: ${meal.prepTime}');
    print('Calories: ${meal.calories}');
    print('Instructions count: ${meal.instructions.length}');
    print('Instructions: ${meal.instructions}');
    print('Ingredients count: ${meal.ingredientsNeeded.length}');
    final validIngredients =
        meal.ingredientsNeeded
            .where((ingredient) => ingredient.quantity > 0)
            .toList();
    print('Valid ingredients count (quantity > 0): ${validIngredients.length}');

    for (int i = 0; i < meal.ingredientsNeeded.length; i++) {
      final ingredient = meal.ingredientsNeeded[i];
      print(
        'Ingredient $i: quantity=${ingredient.quantity}, unit="${ingredient.unit}", name="${ingredient.name}"',
      );
    }
    print('=== END MEAL DEBUG ===');

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(colorScheme),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(textTheme, colorScheme),
                  const SizedBox(height: 24),
                  _buildMetrics(textTheme, colorScheme),
                  const SizedBox(height: 32),
                  _buildIngredientsList(textTheme, colorScheme),
                  //if (meal.instructions.isNotEmpty) ...[
                  //  const SizedBox(height: 32),
                  //  _buildPreparationSteps(textTheme, colorScheme),
                  //],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: mealType.color,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [mealType.color, mealType.color.withValues(alpha: 0.8)],
            ),
          ),
          child: Stack(
            children: [
              // Pattern overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
              ),
              // Meal type icon
              Positioned(
                top: 100,
                right: 30,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(mealType.icon, size: 40, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: mealType.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            mealType.name,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: mealType.color,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _cleanRecipeTitle(meal.recipeTitle),
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildMetrics(TextTheme textTheme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetric(
            Icons.schedule,
            '${meal.prepTime} min',
            'Tiempo',
            textTheme,
            colorScheme,
          ),
          _buildDivider(colorScheme),
          _buildMetric(
            Icons.restaurant,
            '${meal.ingredientsNeeded.where((i) => i.quantity > 0).length}',
            'Ingredientes',
            textTheme,
            colorScheme,
          ),
          _buildDivider(colorScheme),
          _buildMetric(
            mealType.icon,
            mealType.name,
            'Tipo',
            textTheme,
            colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(
    IconData icon,
    String value,
    String label,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: mealType.color),
        const SizedBox(height: 8),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(ColorScheme colorScheme) {
    return Container(
      height: 40,
      width: 1,
      color: colorScheme.outline.withValues(alpha: 0.3),
    );
  }

  Widget _buildIngredientsList(TextTheme textTheme, ColorScheme colorScheme) {
    final validIngredients =
        meal.ingredientsNeeded
            .where((ingredient) => ingredient.quantity > 0)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: mealType.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.shopping_cart, size: 20, color: mealType.color),
            ),
            const SizedBox(width: 12),
            Text(
              'Ingredientes',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: mealType.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${validIngredients.length} items',
                style: textTheme.bodySmall?.copyWith(
                  color: mealType.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children:
                validIngredients.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ingredient = entry.value;
                  final isLast = index == validIngredients.length - 1;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border:
                          isLast
                              ? null
                              : Border(
                                bottom: BorderSide(
                                  color: colorScheme.outline.withValues(
                                    alpha: 0.1,
                                  ),
                                  width: 1,
                                ),
                              ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: mealType.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${ingredient.quantity}',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: mealType.color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ingredient.name,
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              if (ingredient.unit.isNotEmpty)
                                Text(
                                  ingredient.unit,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.check_circle_outline,
                          size: 20,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildPreparationSteps(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: mealType.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.menu_book, size: 20, color: mealType.color),
            ),
            const SizedBox(width: 12),
            Text(
              'Preparación',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children:
                meal.instructions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final instruction = entry.value;
                  final isLast = index == meal.instructions.length - 1;

                  return _buildStep(
                    index + 1,
                    instruction,
                    isLast,
                    textTheme,
                    colorScheme,
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStep(
    int number,
    String description,
    bool isLast,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border:
            isLast
                ? null
                : Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: mealType.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: mealType.color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _cleanRecipeTitle(String title) {
    return title.replaceAll(RegExp(r'\s*\(\d+\)(\s*\(\d+\))*\s*$'), '');
  }
}
