import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/core/services/api_service.dart';
import 'package:zer0_waste_ai/features/impact/data/repositories/impact_repository_impl.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/environmental_impact.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/environmental_summary.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/impact_metrics.dart';
import 'package:zer0_waste_ai/features/impact/domain/repositories/impact_repository.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/consumption_tracking.dart';

enum ImpactHistoryFilter { all, cooked, notCooked }

final impactHistoryFilterProvider = StateProvider<ImpactHistoryFilter>(
  (ref) => ImpactHistoryFilter.all,
);

/// Notificador para las métricas de impacto ambiental
class ImpactMetricsNotifier extends StateNotifier<ImpactMetrics> {
  ImpactMetricsNotifier() : super(_getInitialMetrics());

  static ImpactMetrics _getInitialMetrics() {
    return ImpactMetrics(
      foodSavedKg: 0.0, // Empezar con 0 para que sea más real
      co2AvoidedKg: 0.0,
      waterSavedLiters: 0.0,
      lastUpdated: DateTime.now(),
    );
  }

  /// Actualiza las métricas basado en el consumo de ingredientes
  void updateFromConsumption(ConsumptionTracking tracking) {
    if (tracking.environmentalImpact == null) {
      // Si no hay impacto calculado, usar valores por defecto basados en la cantidad
      final consumedKg = tracking.consumedPortions ?? 0.0;
      state = state.copyWith(
        foodSavedKg: state.foodSavedKg + consumedKg,
        co2AvoidedKg: state.co2AvoidedKg + (consumedKg * 4.2), // 1kg alimento = 4.2kg CO2 aprox
        waterSavedLiters: state.waterSavedLiters + (consumedKg * 1000), // 1kg alimento = 1000L agua aprox
        lastUpdated: DateTime.now(),
      );
      return;
    }

    final co2Saved =
        tracking.environmentalImpact!['co2_saved']?.toDouble() ?? 0.0;
    final waterSaved =
        tracking.environmentalImpact!['water_saved']?.toDouble() ?? 0.0;
    final foodSaved = tracking.consumedPortions ?? 0.0;

    state = state.copyWith(
      foodSavedKg: state.foodSavedKg + foodSaved,
      co2AvoidedKg: state.co2AvoidedKg + co2Saved,
      waterSavedLiters: state.waterSavedLiters + waterSaved,
      lastUpdated: DateTime.now(),
    );
  }

  /// Añade una cantidad de alimentos salvados y actualiza métricas relacionadas
  void addFoodSaved(double kg) {
    // Actualizar métricas de impacto
    final newFoodSaved = state.foodSavedKg + kg;
    final newCO2 =
        state.co2AvoidedKg +
        (kg * 4.2); // Aproximación: 1kg alimento = 4.2kg CO2
    final newWater =
        state.waterSavedLiters +
        (kg * 1000); // Aproximación: 1kg alimento = 1000L agua

    // Actualizar el estado
    state = state.copyWith(
      foodSavedKg: newFoodSaved,
      co2AvoidedKg: newCO2,
      waterSavedLiters: newWater,
      lastUpdated: DateTime.now(),
    );
  }

  /// Añade CO2 evitado directamente
  void addCO2Avoided(double kg) {
    state = state.copyWith(
      co2AvoidedKg: state.co2AvoidedKg + kg,
      lastUpdated: DateTime.now(),
    );
  }

  /// Añade agua ahorrada directamente
  void addWaterSaved(double liters) {
    state = state.copyWith(
      waterSavedLiters: state.waterSavedLiters + liters,
      lastUpdated: DateTime.now(),
    );
  }

  /// Resetea todas las métricas
  void resetMetrics() {
    state = ImpactMetrics.empty();
  }
}

/// Proveedor para las métricas de impacto
final impactMetricsProvider =
    StateNotifierProvider<ImpactMetricsNotifier, ImpactMetrics>((ref) {
      return ImpactMetricsNotifier();
    });

/// Proveedor para el texto de equivalencia basado en las métricas
final impactEquivalenceProvider = Provider<Map<String, String>>((ref) {
  final metrics = ref.watch(impactMetricsProvider);

  return {
    'food':
        '${metrics.foodSavedKg.toStringAsFixed(1)} kg de alimentos salvados',
    'co2': '${metrics.co2AvoidedKg.toStringAsFixed(1)} kg de CO₂ evitados',
    'water':
        '${metrics.waterSavedLiters.toStringAsFixed(0)} L de agua ahorrados',
    'trees':
        '${(metrics.co2AvoidedKg / 22).toStringAsFixed(1)} árboles equivalentes',
    'cars':
        '${(metrics.co2AvoidedKg / 4.6).toStringAsFixed(1)} km en auto evitados',
  };
});

// Proveedor para controlar el índice de la pestaña activa en la pantalla de impacto
final impactTabIndexProvider = StateProvider<int>((ref) => 0);

// Proveedor para almacenar datos de impacto ambiental de la última receta cocinada
final lastRecipeImpactProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {
    'co2Emissions': 0.0,
    'waterUsage': 0.0,
    'sustainabilityScore': 0.0,
    'inventoryUsage': 0.0,
    'wastePreventionScore': 0.0,
    'transportationImpact': 0.0,
    'localIngredients': 0,
    'needToBuy': 0,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  };
});

// Proveedor para actualizar los datos de impacto desde la pantalla de recetas
class ImpactNotifier extends StateNotifier<Map<String, dynamic>> {
  ImpactNotifier(this._ref)
    : super({
        'co2Emissions': 0.0,
        'waterUsage': 0.0,
        'sustainabilityScore': 0.0,
        'inventoryUsage': 0.0,
        'wastePreventionScore': 0.0,
        'transportationImpact': 0.0,
        'localIngredients': 0,
        'needToBuy': 0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'recipesCooked': 0,
        'totalScore': 0.0,
        'completedRecipes': <Map<String, dynamic>>[], // Lista de recetas completadas
      });

  final Ref _ref;

  void updateImpactData(Map<String, dynamic> recipeImpact, {String? recipeTitle}) {
    // Crear registro de receta completada
    final completedRecipe = {
      'title': recipeTitle ?? 'Receta',
      'date': DateTime.now().toIso8601String(),
      'sustainabilityScore': recipeImpact['sustainabilityScore'] as double? ?? 0.0,
      'co2Emissions': recipeImpact['co2Emissions'] as double? ?? 0.0,
      'waterUsage': recipeImpact['waterUsage'] as double? ?? 0.0,
      'wastePreventionScore': recipeImpact['wastePreventionScore'] as double? ?? 0.0,
      'isCooked': true,
    };

    // Obtener lista actual de recetas completadas
    final currentCompletedRecipes = List<Map<String, dynamic>>.from(
      state['completedRecipes'] as List<Map<String, dynamic>>? ?? []
    );
    
    // Añadir nueva receta
    currentCompletedRecipes.add(completedRecipe);

    // Actualizar los datos de impacto acumulados
    state = {
      ...state,
      'co2Emissions':
          (state['co2Emissions'] as double) +
          (recipeImpact['co2Emissions'] as double? ?? 0.0),
      'waterUsage':
          (state['waterUsage'] as double) +
          (recipeImpact['waterUsage'] as double? ?? 0.0),
      'wastePreventionScore':
          (state['wastePreventionScore'] as double) +
          (recipeImpact['wastePreventionScore'] as double? ?? 0.0),
      'transportationImpact':
          (state['transportationImpact'] as double) +
          (recipeImpact['transportationImpact'] as double? ?? 0.0),
      'localIngredients':
          (state['localIngredients'] as int) +
          (recipeImpact['localIngredients'] as int? ?? 0),
      'needToBuy':
          (state['needToBuy'] as int) +
          (recipeImpact['needToBuy'] as int? ?? 0),
      'recipesCooked': (state['recipesCooked'] as int) + 1,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'lastRecipeScore': recipeImpact['sustainabilityScore'] as double? ?? 0.0,
      'totalScore':
          (state['totalScore'] as double) +
          (recipeImpact['sustainabilityScore'] as double? ?? 0.0),
      'completedRecipes': currentCompletedRecipes,
    };

    // Imprimir los datos para debugging
    print('Datos de impacto actualizados: $state');
    print('Receta completada agregada: $completedRecipe');

    // También intentar registrar en el sistema API si es posible
    _tryRegisterApiImpact(recipeTitle ?? 'Receta', completedRecipe);
  }

  /// Intenta registrar el impacto en el sistema API (opcional)
  Future<void> _tryRegisterApiImpact(String recipeTitle, Map<String, dynamic> recipeData) async {
    try {
      final impactService = _ref.read(impactCalculationServiceProvider);
      // Intentar calcular y registrar el impacto usando el título de la receta
      await impactService.calculateFromTitle(recipeTitle);
      print('Impacto registrado en API para: $recipeTitle');
    } catch (e) {
      print('No se pudo registrar en API (normal si no hay conexión): $e');
      // No hacer nada, el sistema local funciona independientemente
    }
  }

  /// Obtiene las recetas completadas para mostrar en el progreso
  List<Map<String, dynamic>> getCompletedRecipes() {
    return List<Map<String, dynamic>>.from(
      state['completedRecipes'] as List<Map<String, dynamic>>? ?? []
    );
  }
}

final impactDataProvider =
    StateNotifierProvider<ImpactNotifier, Map<String, dynamic>>((ref) {
      return ImpactNotifier(ref);
    });

/// Provider for calculating meal impact
final mealImpactProvider = FutureProvider.family<EnvironmentalImpact, String>((
  ref,
  recipeId,
) {
  final repository = ref.watch(impactRepositoryProvider);
  return repository.calculateImpactFromUid(recipeId);
});

// --- API Based Providers ---

final impactRepositoryProvider = Provider<ImpactRepository>((ref) {
  return ImpactRepositoryImpl(ApiService.instance);
});

final impactSummaryProvider = FutureProvider<EnvironmentalSummary>((ref) {
  final repository = ref.watch(impactRepositoryProvider);
  return repository.getImpactSummary();
});

final allImpactCalculationsProvider = FutureProvider<EnvironmentalCalculations>(
  (ref) {
    final repository = ref.watch(impactRepositoryProvider);
    return repository.getAllCalculations();
  },
);

final impactCalculationsByStatusProvider =
    FutureProvider.family<EnvironmentalCalculations, bool>((ref, isCooked) {
      final repository = ref.watch(impactRepositoryProvider);
      return repository.getCalculationsByStatus(isCooked);
    });

final impactCalculationServiceProvider = Provider((ref) {
  final repository = ref.watch(impactRepositoryProvider);
  return ImpactCalculationService(repository);
});

class ImpactCalculationService {
  final ImpactRepository _repository;

  ImpactCalculationService(this._repository);

  Future<EnvironmentalImpact> calculateFromTitle(String title) {
    return _repository.calculateImpactFromTitle(title);
  }

  Future<EnvironmentalImpact> calculateFromUid(String recipeUid) {
    return _repository.calculateImpactFromUid(recipeUid);
  }

  Future<void> updateStatus(String recipeUid, bool isCooked) {
    return _repository.updateCalculationStatus(recipeUid, isCooked);
  }
}

/// Provider unificado que combina recetas del sistema local y API
final unifiedCompletedRecipesProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final localImpactData = ref.watch(impactDataProvider);
  final apiCalculationsAsync = ref.watch(allImpactCalculationsProvider);
  
  // Obtener recetas locales
  final localRecipes = List<Map<String, dynamic>>.from(
    localImpactData['completedRecipes'] as List<Map<String, dynamic>>? ?? []
  );
  
  // Convertir recetas API al formato local si están disponibles
  final apiRecipes = apiCalculationsAsync.when(
    data: (calculations) => calculations.calculations.map((calc) => {
      'title': calc.recipeTitle,
      'date': calc.savedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'sustainabilityScore': 85.0, // Score por defecto ya que API no lo proporciona
      'co2Emissions': calc.carbonFootprint,
      'waterUsage': calc.waterFootprint,
      'wastePreventionScore': 0.0,
      'isCooked': calc.isCooked,
      'isFromAPI': true,
    }).toList(),
    loading: () => <Map<String, dynamic>>[],
    error: (_, _) => <Map<String, dynamic>>[],
  );
  
  // Combinar ambas listas y ordenar por fecha (más recientes primero)
  final allRecipes = [...localRecipes, ...apiRecipes];
  allRecipes.sort((a, b) {
    final dateA = DateTime.parse(a['date'] as String);
    final dateB = DateTime.parse(b['date'] as String);
    return dateB.compareTo(dateA); // Más recientes primero
  });
  
  return allRecipes;
});
