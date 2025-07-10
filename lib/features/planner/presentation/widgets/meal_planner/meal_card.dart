import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan_model.dart';
import 'package:zer0_waste_ai/features/planner/application/services/meal_preparation_service.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';

class MealCard extends ConsumerWidget {
  final MealPlan meal;
  final PlannedMeal plannedMeal;
  final String mealKey;
  final VoidCallback? onTap;

  const MealCard({
    super.key, 
    required this.meal, 
    required this.plannedMeal,
    required this.mealKey,
    this.onTap
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getStatusColor(plannedMeal.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(plannedMeal.status),
                      color: _getStatusColor(plannedMeal.status),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comida ${_getStatusText(plannedMeal.status)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${plannedMeal.servings} porciones - ${plannedMeal.type.name}',
                          style: TextStyle(
                            color: AppColors.lightPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (plannedMeal.status == MealStatus.planned)
                    _buildPrepareButton(context, ref),
                ],
              ),
              const SizedBox(height: 8),
              _buildStatusChip(plannedMeal.status),
              if (plannedMeal.status == MealStatus.prepared && plannedMeal.impactData != null)
                _buildImpactSummary(plannedMeal.impactData!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrepareButton(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () => _markAsPrepared(context, ref),
      icon: const Icon(Icons.restaurant_menu, size: 16),
      label: const Text('Preparar'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildStatusChip(MealStatus status) {
    return Chip(
      label: Text(
        _getStatusText(status),
        style: TextStyle(
          fontSize: 12,
          color: _getStatusColor(status),
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: _getStatusColor(status).withValues(alpha: 0.1),
      side: BorderSide(
        color: _getStatusColor(status).withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildImpactSummary(Map<String, dynamic> impactData) {
    final co2 = impactData['co2Emissions'] as double? ?? 0.0;
    final water = impactData['waterUsage'] as double? ?? 0.0;
    final sustainability = impactData['sustainabilityScore'] as double? ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildImpactItem('CO₂', '${co2.toStringAsFixed(1)}kg', Icons.cloud_off),
          _buildImpactItem('Agua', '${water.toStringAsFixed(0)}L', Icons.water_drop),
          _buildImpactItem('Score', '${sustainability.toStringAsFixed(0)}/100', Icons.eco),
        ],
      ),
    );
  }

  Widget _buildImpactItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.green),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.green),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _markAsPrepared(BuildContext context, WidgetRef ref) async {
    try {
      final service = ref.read(mealPreparationServiceProvider);
      
      // Crear una receta mock basada en el plannedMeal
      final mockRecipe = Recipe(
        id: plannedMeal.recipeId,
        name: 'Receta de ${plannedMeal.type.name}',
        description: 'Receta planificada',
        ingredients: ['Ingrediente 1', 'Ingrediente 2'], // Mock ingredients
        servings: plannedMeal.servings,
      );

      await service.markMealAsPrepared(
        mealPlanId: meal.id,
        mealKey: mealKey,
        meal: plannedMeal,
        recipe: mockRecipe,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Comida marcada como preparada!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al marcar como preparada: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(MealStatus status) {
    switch (status) {
      case MealStatus.planned:
        return AppColors.lightPrimary;
      case MealStatus.prepared:
        return Colors.orange;
      case MealStatus.completed:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(MealStatus status) {
    switch (status) {
      case MealStatus.planned:
        return Icons.schedule;
      case MealStatus.prepared:
        return Icons.restaurant_menu;
      case MealStatus.completed:
        return Icons.check_circle;
    }
  }

  String _getStatusText(MealStatus status) {
    switch (status) {
      case MealStatus.planned:
        return 'Planificada';
      case MealStatus.prepared:
        return 'Preparada';
      case MealStatus.completed:
        return 'Completada';
    }
  }
}
