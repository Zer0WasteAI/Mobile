import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan_model.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan_models.dart' as models;
import 'package:zer0_waste_ai/features/planner/presentation/providers/meal_planning_providers.dart';
import 'package:zer0_waste_ai/features/planner/application/services/meal_notification_service.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';
import 'package:zer0_waste_ai/features/impact/application/providers/impact_providers.dart';

/// Servicio para manejar la preparación de comidas planificadas
class MealPreparationService {
  final Ref _ref;
  
  MealPreparationService(this._ref);
  
  /// Marca una comida como preparada y activa el tracking de impacto
  Future<void> markMealAsPrepared({
    required String mealPlanId,
    required String mealKey,
    required PlannedMeal meal,
    required Recipe recipe,
  }) async {
    try {
      // 1. Calcular impacto ambiental de la comida
      final impactData = await _calculateMealImpact(recipe, meal.servings);
      
      // 2. Actualizar estado de la comida a preparada
      final updatedMeal = meal.copyWith(
        status: MealStatus.prepared,
        preparedAt: DateTime.now(),
        impactData: impactData,
      );
      
      // 3. Actualizar el plan de comidas
      await _updateMealPlan(mealPlanId, mealKey, updatedMeal);
      
      // 4. Registrar el impacto en el sistema de tracking
      await _registerImpactTracking(recipe.name, impactData);
      
      // 5. Enviar notificación de comida preparada
      await _notifyMealPrepared(recipe.name, impactData);
      
      print('✅ Comida marcada como preparada: ${recipe.name}');
      
    } catch (e) {
      print('❌ Error al marcar comida como preparada: $e');
      rethrow;
    }
  }
  
  /// Calcula el impacto ambiental de una comida basado en la receta y porciones
  Future<Map<String, dynamic>> _calculateMealImpact(Recipe recipe, int servings) async {
    // Usar la misma lógica que se usa en recipe_detail_screen.dart
    final baseImpact = _calculateEnvironmentalImpact(recipe);
    
    // Escalar el impacto según el número de porciones
    final scaleFactor = servings / recipe.servings;
    
    return {
      'co2Emissions': baseImpact['co2Emissions'] * scaleFactor,
      'waterUsage': baseImpact['waterUsage'] * scaleFactor,
      'sustainabilityScore': baseImpact['sustainabilityScore'], // No escalar el score
      'wastePreventionScore': baseImpact['wastePreventionScore'] * scaleFactor,
      'transportationImpact': baseImpact['transportationImpact'] * scaleFactor,
      'localIngredients': baseImpact['localIngredients'],
      'needToBuy': baseImpact['needToBuy'],
    };
  }
  
  /// Calcula el impacto ambiental base de una receta
  Map<String, dynamic> _calculateEnvironmentalImpact(Recipe recipe) {
    double co2Emissions = 0.0;
    double waterUsage = 0.0;
    double sustainabilityScore = 85.0; // Score base
    double wastePreventionScore = 0.0;
    double transportationImpact = 0.0;
    int localIngredients = 0;
    int needToBuy = 0;
    
    for (final ingredient in recipe.ingredients) {
      // Los ingredientes son strings, simular categorías basado en el nombre
      final ingredientName = ingredient.toLowerCase();
      final quantity = 0.25; // Cantidad estimada por ingrediente
      
      // Detectar categoría basado en el nombre del ingrediente
      String category = '';
      if (ingredientName.contains('carne') || ingredientName.contains('beef') || ingredientName.contains('res')) {
        category = 'carne';
      } else if (ingredientName.contains('pollo') || ingredientName.contains('chicken')) {
        category = 'pollo';
      } else if (ingredientName.contains('pescado') || ingredientName.contains('fish') || ingredientName.contains('salmón')) {
        category = 'pescado';
      } else if (ingredientName.contains('leche') || ingredientName.contains('queso') || ingredientName.contains('yogur')) {
        category = 'lácteos';
      } else if (ingredientName.contains('cebolla') || ingredientName.contains('tomate') || ingredientName.contains('verdura')) {
        category = 'verduras';
      } else if (ingredientName.contains('manzana') || ingredientName.contains('fruta') || ingredientName.contains('limón')) {
        category = 'frutas';
      } else if (ingredientName.contains('arroz') || ingredientName.contains('trigo') || ingredientName.contains('avena')) {
        category = 'granos';
      }
      
      // Factores de impacto por categoría de ingrediente
      switch (category) {
        case 'carne':
        case 'meat':
          co2Emissions += quantity * 27.0; // kg CO2 per kg
          waterUsage += quantity * 15400; // litros per kg
          sustainabilityScore -= 10;
          break;
        case 'pollo':
        case 'chicken':
        case 'poultry':
          co2Emissions += quantity * 6.9;
          waterUsage += quantity * 4325;
          sustainabilityScore -= 5;
          break;
        case 'pescado':
        case 'fish':
          co2Emissions += quantity * 5.4;
          waterUsage += quantity * 3500;
          sustainabilityScore -= 3;
          break;
        case 'lácteos':
        case 'dairy':
          co2Emissions += quantity * 3.2;
          waterUsage += quantity * 1000;
          sustainabilityScore -= 2;
          break;
        case 'verduras':
        case 'vegetables':
          co2Emissions += quantity * 2.0;
          waterUsage += quantity * 322;
          sustainabilityScore += 5;
          wastePreventionScore += 2;
          break;
        case 'frutas':
        case 'fruits':
          co2Emissions += quantity * 1.1;
          waterUsage += quantity * 962;
          sustainabilityScore += 3;
          wastePreventionScore += 1;
          break;
        case 'granos':
        case 'grains':
          co2Emissions += quantity * 2.5;
          waterUsage += quantity * 1644;
          sustainabilityScore += 2;
          wastePreventionScore += 1;
          break;
        default:
          co2Emissions += quantity * 2.0;
          waterUsage += quantity * 500;
          break;
      }
      
      // Simular ingredientes locales vs necesarios comprar
      if (ingredientName.contains('local')) {
        localIngredients++;
        transportationImpact += 0.1;
      } else {
        needToBuy++;
        transportationImpact += 0.5;
      }
    }
    
    // Ajustar sustainability score
    sustainabilityScore = sustainabilityScore.clamp(0, 100);
    
    return {
      'co2Emissions': co2Emissions,
      'waterUsage': waterUsage,
      'sustainabilityScore': sustainabilityScore,
      'wastePreventionScore': wastePreventionScore,
      'transportationImpact': transportationImpact,
      'localIngredients': localIngredients,
      'needToBuy': needToBuy,
    };
  }
  
  /// Actualiza el plan de comidas con la comida preparada
  Future<void> _updateMealPlan(String mealPlanId, String mealKey, PlannedMeal updatedMeal) async {
    try {
      print('📝 Actualizando plan de comidas: $mealPlanId - $mealKey');
      
      // Obtener la fecha del mealPlanId (asumiendo formato YYYY-MM-DD)
      final date = mealPlanId;
      
      // Obtener el plan de comidas actual
      final currentMealPlanAsync = await _ref.read(mealPlanByDateProvider(date).future);
      
      if (currentMealPlanAsync == null) {
        print('⚠️ No se encontró plan de comidas para la fecha: $date');
        return;
      }
      
      // Convertir el plan actual a DailyMeals para poder modificarlo
      final currentMeals = currentMealPlanAsync.meals;
      
      // Crear una nueva comida con los datos actualizados usando el modelo correcto
      final updatedMealData = models.Meal(
        recipeTitle: 'Receta de ${updatedMeal.type.name}',
        ingredientsNeeded: [], // Lista vacía por defecto
        prepTime: 30, // Valor por defecto
        calories: 400, // Valor por defecto
        instructions: [],
      );
      
      // Actualizar la comida específica según el tipo
      models.DailyMeals updatedDailyMeals;
      switch (updatedMeal.type) {
        case MealType.breakfast:
          updatedDailyMeals = models.DailyMeals(
            breakfast: updatedMealData,
            lunch: currentMeals.lunch,
            dinner: currentMeals.dinner,
          );
          break;
        case MealType.lunch:
          updatedDailyMeals = models.DailyMeals(
            breakfast: currentMeals.breakfast,
            lunch: updatedMealData,
            dinner: currentMeals.dinner,
          );
          break;
        case MealType.dinner:
          updatedDailyMeals = models.DailyMeals(
            breakfast: currentMeals.breakfast,
            lunch: currentMeals.lunch,
            dinner: updatedMealData,
          );
          break;
        case MealType.snack:
          // Los snacks no están soportados en el modelo actual DailyMeals
          print('⚠️ Snacks no están soportados en el modelo actual');
          return;
      }
      
      // Actualizar el plan de comidas usando el provider
      final mealPlanningNotifier = _ref.read(mealPlanningProvider.notifier);
      await mealPlanningNotifier.updateMealPlan(date, updatedDailyMeals);
      
      print('✅ Plan de comidas actualizado exitosamente');
      
    } catch (e) {
      print('❌ Error actualizando plan de comidas: $e');
      rethrow;
    }
  }
  
  /// Registra el impacto en el sistema de tracking
  Future<void> _registerImpactTracking(String recipeTitle, Map<String, dynamic> impactData) async {
    final impactNotifier = _ref.read(impactDataProvider.notifier);
    impactNotifier.updateImpactData(impactData, recipeTitle: recipeTitle);
  }
  
  /// Envía notificación de comida preparada
  Future<void> _notifyMealPrepared(String mealName, Map<String, dynamic> impactData) async {
    try {
      final mealNotificationService = _ref.read(mealNotificationServiceProvider);
      await mealNotificationService.notifyMealPrepared(
        mealName: mealName,
        impactData: impactData,
      );
    } catch (e) {
      print('⚠️ Error enviando notificación de comida preparada: $e');
      // No fallar la operación principal por un error de notificación
    }
  }
}

/// Provider para el servicio de preparación de comidas
final mealPreparationServiceProvider = Provider<MealPreparationService>((ref) {
  return MealPreparationService(ref);
});