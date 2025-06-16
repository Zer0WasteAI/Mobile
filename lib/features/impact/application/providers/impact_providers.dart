import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/impact_metrics.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/impact_goal.dart';

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

/// Notificador para los objetivos de impacto
class ImpactGoalsNotifier extends StateNotifier<List<ImpactGoal>> {
  ImpactGoalsNotifier() : super(_getInitialGoals());

  static List<ImpactGoal> _getInitialGoals() {
    return [
        ImpactGoal(
        id: const Uuid().v4(),
          title: 'Salvar 5kg de alimentos',
        description:
            'Evita el desperdicio de 5 kilogramos de alimentos esta semana',
          metricType: GoalMetricType.foodSaved,
          targetValue: 5.0,
        currentValue: 2.3,
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        ),
        ImpactGoal(
        id: const Uuid().v4(),
        title: 'Reducir 20kg de CO2',
        description: 'Evita la emisión de 20kg de CO2 este mes',
          metricType: GoalMetricType.co2Avoided,
        targetValue: 20.0,
        currentValue: 8.7,
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 20)),
        ),
        ImpactGoal(
        id: const Uuid().v4(),
        title: 'Ahorrar 1000L de agua',
        description:
            'Ahorra 1000 litros de agua mediante el aprovechamiento de alimentos',
        metricType: GoalMetricType.waterSaved,
        targetValue: 1000.0,
        currentValue: 450.0,
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 25)),
        ),
    ];
  }

  /// Añade un nuevo objetivo
  void addGoal(ImpactGoal goal) {
    state = [...state, goal];
  }

  /// Elimina un objetivo
  void removeGoal(String goalId) {
    state = state.where((goal) => goal.id != goalId).toList();
  }

  /// Actualiza el progreso de un objetivo
  void updateGoalProgress(String goalId, double newValue) {
    state =
        state.map((goal) {
          if (goal.id != goalId) return goal;

          // Actualizar el valor actual
          final updatedGoal = goal.copyWith(currentValue: newValue);

          // Comprobar si el objetivo se ha completado
          if (!goal.isCompleted && updatedGoal.progress >= 1.0) {
            return updatedGoal.copyWith(isCompleted: true);
          }

          return updatedGoal;
        }).toList();
  }

  /// Marca un objetivo como completado
  void completeGoal(String goalId) {
    state =
        state.map((goal) {
          if (goal.id == goalId) {
            return goal.copyWith(isCompleted: true);
          }
          return goal;
        }).toList();
  }
}

/// Proveedor para los objetivos de impacto
final impactGoalsProvider =
    StateNotifierProvider<ImpactGoalsNotifier, List<ImpactGoal>>((ref) {
      return ImpactGoalsNotifier();
});

/// Función para crear un nuevo objetivo
ImpactGoal createNewGoal({
  required String title,
  required String description,
  required GoalMetricType metricType,
  required double targetValue,
  DateTime? endDate,
}) {
  return ImpactGoal(
    id: const Uuid().v4(),
    title: title,
    description: description,
    metricType: metricType,
    targetValue: targetValue,
    currentValue: 0,
    startDate: DateTime.now(),
    endDate: endDate,
    isActive: true,
  );
}

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
