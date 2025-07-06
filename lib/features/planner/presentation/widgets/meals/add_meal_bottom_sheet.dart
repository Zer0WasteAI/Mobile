import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/meal_plan_models.dart';

/// Este widget ahora solo redirige a RecipeGenerationScreen
/// Se mantiene para compatibilidad con código existente
class AddMealBottomSheet extends ConsumerStatefulWidget {
  final MealType mealType;
  final DateTime selectedDate;
  final Meal? existingMeal;

  const AddMealBottomSheet({
    super.key,
    required this.mealType,
    required this.selectedDate,
    this.existingMeal,
  });

  @override
  ConsumerState<AddMealBottomSheet> createState() => _AddMealBottomSheetState();
}

class _AddMealBottomSheetState extends ConsumerState<AddMealBottomSheet> {
  @override
  void initState() {
    super.initState();
    // Redirigir a RecipeGenerationScreen después de que se construya el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirectToRecipeGeneration();
    });
  }

  void _redirectToRecipeGeneration() {
    // Cerrar el bottom sheet
    Navigator.of(context).pop();
    
    // Navegar a RecipeGenerationScreen
    context.pushNamed(
      'recipeGeneration',
      queryParameters: {
        'date': widget.selectedDate.toIso8601String(),
        'mealType': widget.mealType.toString().split('.').last,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar un indicador de carga brevemente antes de la redirección
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
