import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/core/services/api_service.dart';
import 'package:zer0_waste_ai/features/impact/data/repositories/impact_repository_impl.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/environmental_impact.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/environmental_summary.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/impact_metrics.dart';
import 'package:zer0_waste_ai/features/impact/domain/repositories/impact_repository.dart';

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

/// Proveedor para el índice de la pestaña activa en el panel de impacto
final impactTabIndexProvider = StateProvider<int>((ref) => 0);

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
