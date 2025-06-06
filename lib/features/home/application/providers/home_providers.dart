import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider_config.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/expiration_status.dart';

// --- Data Models ---
class Recipe {
  final String id;
  final String title;
  final String imageUrl;
  final String difficulty;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.difficulty,
  });
}

class InventorySummary {
  final int activeItems;
  final int expiringSoonItems;

  InventorySummary({
    required this.activeItems,
    required this.expiringSoonItems,
  });
}

class ImpactSummary {
  final double foodSavedKg;
  final double co2ReducedG;

  ImpactSummary({required this.foodSavedKg, required this.co2ReducedG});
}

// --- Providers ---

/// Proveedor para la cantidad de EcoCoins del usuario
final ecoCoinsProvider = StateNotifierProvider<EcoCoinsNotifier, int>((ref) {
  return EcoCoinsNotifier();
});

/// Notificador para gestionar los EcoCoins del usuario
class EcoCoinsNotifier extends StateNotifier<int> {
  EcoCoinsNotifier() : super(125); // Valor inicial de ejemplo

  void addCoins(int amount) {
    state = state + amount;
  }

  void spendCoins(int amount) {
    if (state >= amount) {
      state = state - amount;
    }
  }

  void resetCoins() {
    state = 0;
  }

  /// Calcula el nivel del usuario basado en EcoCoins acumulados
  int calculateLevel() {
    return ((state / 100) + 1).clamp(1, 10).toInt();
  }

  /// Calcula el progreso hacia el siguiente nivel (0.0 - 1.0)
  double calculateLevelProgress() {
    final currentLevel = calculateLevel();
    if (currentLevel >= 10) return 1.0;
    final coinsForCurrentLevel = (currentLevel - 1) * 100;
    final coinsInCurrentLevel = state - coinsForCurrentLevel;
    return coinsInCurrentLevel / 100;
  }
}

/// Proveedor para la cantidad de ingredientes guardados
final savedIngredientsProvider = StateProvider<int>((ref) {
  // Implementar lógica real de base de datos
  return 12;
});

/// Proveedor para mensajes motivacionales
final motivationalMessageProvider = Provider<String>((ref) {
  final messages = [
    '¡Acabas de salvar 2 kg de alimentos esta semana!',
    'Has evitado la emisión de 3.5 kg de CO₂ este mes',
    'Estás en el top 10% de usuarios reduciendo desperdicio',
    'Tu receta de ayer ahorró 5 ingredientes',
    'Lleva tu impacto al siguiente nivel completando un objetivo',
  ];
  // Seleccionar uno aleatorio
  final index = DateTime.now().day % messages.length;
  return messages[index];
});

/// Proveedor real del resumen de inventario usando datos del backend
final inventorySummaryProvider = Provider<InventorySummary>((ref) {
  final inventoryState = ref.watch(inventoryStateProvider);
  final items = inventoryState.items;

  // Calcular elementos activos (todos los elementos del inventario)
  final activeItems = items.length;

  // Calcular elementos próximos a vencer
  final expiringSoonItems =
      items.where((item) {
        final status = ExpirationStatusExtension.fromDate(item.expirationDate);
        return status == ExpirationStatus.expiringSoon;
      }).length;

  return InventorySummary(
    activeItems: activeItems,
    expiringSoonItems: expiringSoonItems,
  );
});

final recipeSuggestionsProvider = Provider<List<Recipe>>((ref) {
  // Replace with actual data fetching
  return [
    Recipe(
      id: '1',
      title: 'Pasta Primavera Fácil',
      imageUrl:
          'https://images.services.kitchenstories.io/w7kIw5bZaJP6rgq3Zj_HOouUq_U=/3840x0/filters:quality(85)/images.kitchenstories.io/wagtailOriginalImages/R2572-picnic-final-photo-4x3.jpg',
      difficulty: 'Fácil',
    ),
    Recipe(
      id: '2',
      title: 'Ensalada César Rápida',
      imageUrl:
          'https://www.recetassinlactosa.com/wp-content/uploads/2022/02/Ensalada-Cesar.jpg',
      difficulty: 'Fácil',
    ),
    Recipe(
      id: '3',
      title: 'Salteado Vegano',
      imageUrl:
          'https://img-global.cpcdn.com/recipes/a2633772f3972747/680x482cq70/salteado-de-verduras-en-30-minutos-vegano-foto-principal.jpg',
      difficulty: 'Medio',
    ),
  ];
});

final impactSummaryProvider = Provider<ImpactSummary>((ref) {
  // Replace with actual data fetching
  return ImpactSummary(foodSavedKg: 5.0, co2ReducedG: 400.0);
});

/// Valor de recompensa en EcoCoins para diferentes acciones
class EcoCoinRewards {
  // Recompensas por nivel de impacto
  static const int levelUp = 50;

  // Recompensas por objetivos
  static const int goalCompleted = 30;
  static const int dailyGoalCompleted = 15;
  static const int weeklyGoalCompleted = 25;
  static const int monthlyGoalCompleted = 40;

  // Recompensas por insignias
  static const int badgeEarned = 20;

  // Recompensas por acciones diarias
  static const int ingredientSaved = 5;
  static const int foodSaved = 10;
  static const int recipeWithExpiring = 15;
}

/// Costos de funcionalidades premium en EcoCoins
class EcoCoinCosts {
  // Funcionalidades de IA
  static const int generateAIRecipe = 25;
  static const int aiMealPlan = 50;
  static const int aiShoppingList = 20;
  static const int aiIngredientSubstitution = 15;
}
