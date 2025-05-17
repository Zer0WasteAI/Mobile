import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/impact_metrics.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/impact_goal.dart';
import 'package:zer0_waste_ai/features/home/application/providers/home_providers.dart';

/// Proveedor para el estado de las métricas de impacto
final impactMetricsProvider =
    StateNotifierProvider<ImpactMetricsNotifier, ImpactMetrics>((ref) {
      return ImpactMetricsNotifier(ref);
    });

/// Notificador para las métricas de impacto con integración de EcoCoins
class ImpactMetricsNotifier extends StateNotifier<ImpactMetrics> {
  final Ref _ref;

  ImpactMetricsNotifier(this._ref)
    : super(
        // Datos de prueba - Reemplazar con datos reales de la base de datos
        ImpactMetrics(
          foodSavedKg: 12.5,
          co2AvoidedKg: 20.3,
          waterSavedLiters: 1250.0,
          level: 2,
          levelProgress: 0.65,
          lastUpdated: DateTime.now(),
          badges: [
            UserBadge(
              id: '1',
              title: 'Primer Paso',
              description: 'Salvaste tu primer kilogramo de alimentos',
              iconPath: 'assets/icons/impact/badge_first_step.png',
              obtainedAt: DateTime.now().subtract(const Duration(days: 30)),
            ),
            UserBadge(
              id: '2',
              title: 'Eco Guerrero',
              description: 'Evitaste 10kg de emisiones de CO2',
              iconPath: 'assets/icons/impact/badge_eco_warrior.png',
              obtainedAt: DateTime.now().subtract(const Duration(days: 15)),
            ),
            UserBadge(
              id: '3',
              title: 'Defensor del Agua',
              description: 'Ahorraste 1000 litros de agua',
              iconPath: 'assets/icons/impact/badge_water_saver.png',
              obtainedAt: DateTime.now().subtract(const Duration(days: 5)),
            ),
          ],
          achievements: [
            UserAchievement(
              id: '1',
              title: 'Primera Semana',
              description: 'Completaste tu primera semana usando la app',
              value: 7,
              achievedAt: DateTime.now().subtract(const Duration(days: 23)),
            ),
            UserAchievement(
              id: '2',
              title: 'Experto en Inventario',
              description: 'Agregaste 20 ingredientes a tu inventario',
              value: 20,
              achievedAt: DateTime.now().subtract(const Duration(days: 10)),
            ),
          ],
        ),
      );

  /// Actualiza las métricas basadas en el sistema de EcoCoins
  void syncWithEcoCoins() {
    final ecoCoinsNotifier = _ref.read(ecoCoinsProvider.notifier);

    // Obtener nivel y progreso basados en EcoCoins
    final newLevel = ecoCoinsNotifier.calculateLevel();
    final newProgress = ecoCoinsNotifier.calculateLevelProgress();

    // Si el nivel cambió, actualizar y añadir un logro
    if (newLevel > state.level) {
      // Crear un nuevo logro por subir de nivel
      final levelUpAchievement = UserAchievement(
        id: const Uuid().v4(),
        title: 'Nivel $newLevel Alcanzado',
        description: '¡Subiste al nivel $newLevel! Sigue así.',
        value: newLevel.toDouble(),
        achievedAt: DateTime.now(),
      );

      // Actualizar el estado con el nuevo nivel y logro
      state = state.copyWith(
        level: newLevel,
        levelProgress: newProgress,
        achievements: [...state.achievements, levelUpAchievement],
        lastUpdated: DateTime.now(),
      );
    } else {
      // Solo actualizar el progreso
      state = state.copyWith(
        level: newLevel,
        levelProgress: newProgress,
        lastUpdated: DateTime.now(),
      );
    }
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

    // Otorgar EcoCoins por la acción
    _ref
        .read(ecoCoinsProvider.notifier)
        .addCoins((kg * EcoCoinRewards.foodSaved).toInt());

    // Actualizar el estado
    state = state.copyWith(
      foodSavedKg: newFoodSaved,
      co2AvoidedKg: newCO2,
      waterSavedLiters: newWater,
      lastUpdated: DateTime.now(),
    );

    // Comprobar si se ha alcanzado algún hito para insignias
    _checkForNewBadges();

    // Sincronizar con EcoCoins para actualizar nivel si es necesario
    syncWithEcoCoins();
  }

  /// Añade una nueva insignia al usuario y otorga EcoCoins
  void addBadge(UserBadge badge) {
    // Comprobar si ya existe esta insignia
    if (state.badges.any((b) => b.id == badge.id)) return;

    // Añadir la insignia
    state = state.copyWith(
      badges: [...state.badges, badge],
      lastUpdated: DateTime.now(),
    );

    // Otorgar EcoCoins por la insignia
    _ref.read(ecoCoinsProvider.notifier).addCoins(EcoCoinRewards.badgeEarned);
  }

  /// Comprueba si el usuario ha alcanzado nuevas insignias
  void _checkForNewBadges() {
    // Comprobar hitos para alimentos salvados
    if (state.foodSavedKg >= 20 &&
        !state.badges.any((b) => b.id == 'food_20kg')) {
      addBadge(
        UserBadge(
          id: 'food_20kg',
          title: 'Guardián de Alimentos',
          description: 'Has salvado 20kg de alimentos del desperdicio',
          iconPath: 'assets/icons/impact/badge_food_guardian.png',
          obtainedAt: DateTime.now(),
        ),
      );
    }

    // Comprobar hitos para CO2 evitado
    if (state.co2AvoidedKg >= 50 &&
        !state.badges.any((b) => b.id == 'co2_50kg')) {
      addBadge(
        UserBadge(
          id: 'co2_50kg',
          title: 'Defensor del Clima',
          description: 'Has evitado 50kg de emisiones de CO2',
          iconPath: 'assets/icons/impact/badge_climate_defender.png',
          obtainedAt: DateTime.now(),
        ),
      );
    }

    // Comprobar hitos para agua ahorrada
    if (state.waterSavedLiters >= 5000 &&
        !state.badges.any((b) => b.id == 'water_5000L')) {
      addBadge(
        UserBadge(
          id: 'water_5000L',
          title: 'Protector del Agua',
          description: 'Has ahorrado 5000 litros de agua',
          iconPath: 'assets/icons/impact/badge_water_protector.png',
          obtainedAt: DateTime.now(),
        ),
      );
    }
  }
}

/// Proveedor para la lista de objetivos del usuario
final impactGoalsProvider =
    StateNotifierProvider<ImpactGoalsNotifier, List<ImpactGoal>>((ref) {
      return ImpactGoalsNotifier(ref);
    });

/// Notificador para los objetivos de impacto
class ImpactGoalsNotifier extends StateNotifier<List<ImpactGoal>> {
  final Ref _ref;

  ImpactGoalsNotifier(this._ref)
    : super([
        // Datos de prueba - Reemplazar con datos reales
        ImpactGoal(
          id: '1',
          title: 'Salvar 5kg de alimentos',
          description: 'Mi objetivo es salvar 5kg de alimentos este mes',
          metricType: GoalMetricType.foodSaved,
          targetValue: 5.0,
          currentValue: 3.2,
          startDate: DateTime.now().subtract(const Duration(days: 15)),
          endDate: DateTime.now().add(const Duration(days: 15)),
          isActive: true,
          ecoCoinsReward: 15,
          xpReward: 75,
        ),
        ImpactGoal(
          id: '2',
          title: 'Reducir mi huella de CO2',
          description: 'Evitar 25kg de emisiones de CO2',
          metricType: GoalMetricType.co2Avoided,
          targetValue: 25.0,
          currentValue: 20.3,
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now().add(const Duration(days: 30)),
          isActive: true,
          ecoCoinsReward: 30,
          xpReward: 120,
        ),
        ImpactGoal(
          id: '3',
          title: 'Cocinar con lo que tengo',
          description: 'Usar 10 ingredientes a punto de vencer',
          metricType: GoalMetricType.cookingWithExpiring,
          targetValue: 10.0,
          currentValue: 4.0,
          startDate: DateTime.now().subtract(const Duration(days: 10)),
          isActive: true,
          ecoCoinsReward: 20,
          xpReward: 90,
        ),
      ]);

  /// Añade un nuevo objetivo
  void addGoal(ImpactGoal goal) {
    state = [...state, goal];
  }

  /// Actualiza el progreso de un objetivo y verifica si se ha completado
  void updateGoalProgress(String goalId, double newValue) {
    state =
        state.map((goal) {
          if (goal.id != goalId) return goal;

          // Actualizar el valor actual
          final updatedGoal = goal.copyWith(currentValue: newValue);

          // Comprobar si el objetivo se ha completado
          if (!goal.isCompleted && updatedGoal.progress >= 1.0) {
            // Objetivo completado, otorgar recompensa
            _rewardCompletedGoal(updatedGoal);
            return updatedGoal.copyWith(isCompleted: true);
          }

          return updatedGoal;
        }).toList();
  }

  /// Otorga recompensas por completar un objetivo
  void _rewardCompletedGoal(ImpactGoal goal) {
    // Usar la recompensa definida en el objetivo
    int ecoCoinsReward = goal.ecoCoinsReward;

    // Asegurarnos de que hay un mínimo de recompensa
    if (ecoCoinsReward <= 0) {
      // Determinar la cantidad de EcoCoins a otorgar si no está definida
      ecoCoinsReward = EcoCoinRewards.goalCompleted;

      // Ajustar recompensa según la duración del objetivo
      if (goal.endDate != null) {
        final duration = goal.endDate!.difference(goal.startDate).inDays;
        if (duration <= 1) {
          ecoCoinsReward = EcoCoinRewards.dailyGoalCompleted;
        } else if (duration <= 7) {
          ecoCoinsReward = EcoCoinRewards.weeklyGoalCompleted;
        } else if (duration <= 31) {
          ecoCoinsReward = EcoCoinRewards.monthlyGoalCompleted;
        }
      }
    }

    // Otorgar EcoCoins
    _ref.read(ecoCoinsProvider.notifier).addCoins(ecoCoinsReward);

    // Otorgar XP si está definida
    if (goal.xpReward > 0) {
      // TODO: Implementar sistema de XP
      // Para una versión futura, actualmente solo se muestra al usuario
    }

    // Añadir logro
    final achievement = UserAchievement(
      id: const Uuid().v4(),
      title: 'Objetivo Completado',
      description: goal.title,
      value: goal.targetValue,
      achievedAt: DateTime.now(),
    );

    // Actualizar métricas según el tipo de objetivo
    final metricsNotifier = _ref.read(impactMetricsProvider.notifier);
    final metrics = _ref.read(impactMetricsProvider);

    // Actualizar métricas específicas si es necesario
    if (goal.metricType == GoalMetricType.foodSaved) {
      // Si ya está contabilizado en las métricas, no sumamos de nuevo
    }

    // Añadir el logro a las métricas
    final newAchievements = [...metrics.achievements, achievement];
    _ref.read(impactMetricsProvider.notifier).syncWithEcoCoins();
  }
}

/// Proveedor para el objetivo activo seleccionado
final activeGoalProvider = StateProvider<String?>((ref) => '1');

/// Proveedor para el índice de pestaña seleccionado en la pantalla de impacto
final impactTabIndexProvider = StateProvider<int>((ref) => 0);

/// Proveedor para identificar un objetivo recién creado (para destacarlo visualmente)
final newGoalIdProvider = StateProvider<String?>((ref) => null);

/// Proveedor para los datos curiosos sobre el impacto ambiental
final impactFactProvider = Provider<String>((ref) {
  final facts = [
    "Cada kilogramo de alimentos que evitas desperdiciar ahorra 4.2 kg de emisiones de CO2.",
    "La producción de 1 kg de carne de res requiere 15,000 litros de agua.",
    "El 30% de los alimentos producidos a nivel mundial se desperdician.",
    "El desperdicio de alimentos es responsable del 8% de las emisiones globales de gases de efecto invernadero.",
    "Salvar 1 kg de pan equivale a ahorrar 1,600 litros de agua.",
    "Si el desperdicio de alimentos fuera un país, sería el tercer mayor emisor de gases de efecto invernadero.",
    "Los hogares son responsables del 53% del desperdicio de alimentos en países desarrollados.",
    "Cada vez que salvas un alimento, ahorras la energía que se usó para producirlo, transportarlo y refrigerarlo.",
  ];

  // Selecciona un dato aleatorio
  final index = DateTime.now().day % facts.length;
  return facts[index];
});

/// Función para crear un nuevo objetivo
ImpactGoal createNewGoal({
  required String title,
  required String description,
  required GoalMetricType metricType,
  required double targetValue,
  DateTime? endDate,
}) {
  // Calcular recompensas basadas en el tipo de métrica y la dificultad (valor objetivo)
  int ecoCoinsReward = 0;
  int xpReward = 0;

  // Base de recompensa según el tipo de métrica
  switch (metricType) {
    case GoalMetricType.foodSaved:
      ecoCoinsReward = 10;
      xpReward = 50;
      break;
    case GoalMetricType.co2Avoided:
      ecoCoinsReward = 15;
      xpReward = 60;
      break;
    case GoalMetricType.waterSaved:
      ecoCoinsReward = 8;
      xpReward = 45;
      break;
    case GoalMetricType.cookingWithExpiring:
      ecoCoinsReward = 12;
      xpReward = 55;
      break;
    case GoalMetricType.ingredientsSaved:
      ecoCoinsReward = 10;
      xpReward = 50;
      break;
  }

  // Ajustar según la dificultad (valor objetivo)
  double difficultyMultiplier = 1.0;

  // Rangos de dificultad según el tipo de métrica
  if (metricType == GoalMetricType.foodSaved) {
    if (targetValue > 20)
      difficultyMultiplier = 3.0;
    else if (targetValue > 10)
      difficultyMultiplier = 2.0;
    else if (targetValue > 5)
      difficultyMultiplier = 1.5;
  } else if (metricType == GoalMetricType.co2Avoided) {
    if (targetValue > 50)
      difficultyMultiplier = 3.0;
    else if (targetValue > 25)
      difficultyMultiplier = 2.0;
    else if (targetValue > 10)
      difficultyMultiplier = 1.5;
  } else if (metricType == GoalMetricType.waterSaved) {
    if (targetValue > 2000)
      difficultyMultiplier = 3.0;
    else if (targetValue > 1000)
      difficultyMultiplier = 2.0;
    else if (targetValue > 500)
      difficultyMultiplier = 1.5;
  } else {
    if (targetValue > 15)
      difficultyMultiplier = 3.0;
    else if (targetValue > 10)
      difficultyMultiplier = 2.0;
    else if (targetValue > 5)
      difficultyMultiplier = 1.5;
  }

  // Aplicar multiplicador
  ecoCoinsReward = (ecoCoinsReward * difficultyMultiplier).round();
  xpReward = (xpReward * difficultyMultiplier).round();

  // También ajustar según duración si hay fecha límite
  if (endDate != null) {
    final durationInDays = endDate.difference(DateTime.now()).inDays;

    // Objetivos más rápidos dan más recompensa
    if (durationInDays <= 1) {
      ecoCoinsReward = (ecoCoinsReward * 1.5).round(); // Diario: +50%
      xpReward = (xpReward * 1.5).round();
    } else if (durationInDays <= 7) {
      ecoCoinsReward = (ecoCoinsReward * 1.2).round(); // Semanal: +20%
      xpReward = (xpReward * 1.2).round();
    }
    // Objetivos mensuales o más largos mantienen la recompensa base
  }

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
    ecoCoinsReward: ecoCoinsReward,
    xpReward: xpReward,
  );
}

/// Función para crear un nuevo objetivo con recompensas personalizadas
ImpactGoal createNewGoalWithCustomRewards({
  required String title,
  required String description,
  required GoalMetricType metricType,
  required double targetValue,
  required int ecoCoinsReward,
  required int xpReward,
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
    ecoCoinsReward: ecoCoinsReward,
    xpReward: xpReward,
  );
}

/// Proveedor para el texto de equivalencia basado en las métricas
final impactEquivalenceProvider = Provider<String>((ref) {
  final metrics = ref.watch(impactMetricsProvider);

  if (metrics.foodSavedKg > 10) {
    return "Has salvado alimentos equivalentes a ${(metrics.foodSavedKg / 2).toStringAsFixed(1)} días de comida para una persona.";
  } else if (metrics.co2AvoidedKg > 15) {
    return "Has evitado emisiones equivalentes a conducir ${(metrics.co2AvoidedKg * 6).toStringAsFixed(0)} km en coche.";
  } else if (metrics.waterSavedLiters > 1000) {
    return "Has ahorrado agua equivalente a ${(metrics.waterSavedLiters / 50).toStringAsFixed(0)} duchas completas.";
  }

  return "Cada pequeña acción cuenta. ¡Sigue adelante!";
});
