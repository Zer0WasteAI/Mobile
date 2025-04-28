import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Dummy Data Models (Replace with actual models) ---
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

// --- Dummy Providers (Replace with actual StateNotifiers/FutureProviders) ---

final ecoCoinsProvider = Provider<int>((ref) {
  // Replace with actual data fetching
  return 120;
});

final inventorySummaryProvider = Provider<InventorySummary>((ref) {
  // Replace with actual data fetching
  return InventorySummary(activeItems: 18, expiringSoonItems: 3);
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
