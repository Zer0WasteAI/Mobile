import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan_model.dart';
import 'package:zer0_waste_ai/features/impact/application/providers/impact_providers.dart';

class MealCard extends ConsumerWidget {
  final MealPlan meal;
  final VoidCallback? onTap;

  const MealCard({super.key, required this.meal, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstMeal = meal.meals.values.firstOrNull;
    if (firstMeal == null) return const SizedBox.shrink();

    final estimatedImpactAsync = ref.watch(
      mealImpactProvider(firstMeal.recipeId),
    );

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                firstMeal.recipeId,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                firstMeal.type.name,
                style: TextStyle(
                  color: AppColors.lightPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              estimatedImpactAsync.when(
                data:
                    (impact) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CO₂: ${impact.formattedCarbonFootprint}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          'Ahorro: ${impact.formattedCost}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                loading: () => const CircularProgressIndicator(),
                error: (_, _) => const Text('Failed to load impact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
