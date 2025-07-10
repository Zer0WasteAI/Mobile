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
      foodSavedKg: 12.5,
      co2AvoidedKg: 20.3,
      waterSavedLiters: 1250.0,
      lastUpdated: DateTime.now(),
    );
  }

  /// Actualiza las métricas basado en el consumo de ingredientes
  void updateFromConsumption(ConsumptionTracking tracking) {
    if (tracking.environmentalImpact == null) return;

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
  ImpactNotifier()
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
      });

  void updateImpactData(Map<String, dynamic> recipeImpact) {
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
    };

    // Imprimir los datos para debugging
    print('Datos de impacto actualizados: $state');
  }
}

final impactDataProvider =
    StateNotifierProvider<ImpactNotifier, Map<String, dynamic>>((ref) {
      return ImpactNotifier();
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
