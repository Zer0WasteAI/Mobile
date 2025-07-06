import 'package:flutter/material.dart';
import '../../domain/models/meal_plan_models.dart';

class MealCreationCard extends StatelessWidget {
  final Meal? meal;
  final MealType mealType;
  final VoidCallback onAddMeal;
  final Function(Meal?) onMealChanged;

  const MealCreationCard({
    super.key,
    this.meal,
    required this.mealType,
    required this.onAddMeal,
    required this.onMealChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (meal == null) {
      return _buildEmptyCard(context);
    }

    return _buildMealCard(context, textTheme);
  }

  // Método para limpiar el título de la receta
  String _cleanRecipeTitle(String title) {
    // Eliminar patrones como "(1)" o "(2)" al final del título
    return title.replaceAll(RegExp(r'\s*\(\d+\)(\s*\(\d+\))*\s*$'), '');
  }

  Widget _buildMealCard(BuildContext context, TextTheme textTheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
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
                child: Icon(
                  mealType.icon,
                  color: mealType.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cleanRecipeTitle(meal!.recipeTitle),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${meal!.prepTime} min',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue[400]),
                onPressed: onAddMeal,
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red[400]),
                onPressed: () => onMealChanged(null),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingredientes:',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                ...meal!.ingredientsNeeded.take(3).map(
                  (ingredient) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: textTheme.bodySmall),
                        Expanded(
                          child: Text(
                            ingredient.toString(),
                            style: textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (meal!.ingredientsNeeded.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${meal!.ingredientsNeeded.length - 3} más...',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onAddMeal,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: mealType.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: mealType.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Agregar ${mealType.name}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: mealType.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Toca para seleccionar una receta',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}