import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/impact/application/providers/impact_providers.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider_config.dart';
import 'dart:developer';

import 'package:zer0_waste_ai/features/favorites/presentation/providers/favorite_recipe_providers.dart';

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
  final int cookedRecipes;
  final int totalRecipes;

  ImpactSummary({required this.cookedRecipes, required this.totalRecipes});
}

// --- Providers ---

/// Proveedor para la cantidad de ingredientes guardados
final savedIngredientsProvider = Provider<int>((ref) {
  final inventoryState = ref.watch(inventoryStateProvider);
  return inventoryState.items.length;
});

/// Proveedor para el resumen del inventario
final inventorySummaryProvider = Provider<InventorySummary>((ref) {
  final inventoryState = ref.watch(inventoryStateProvider);
  final items = inventoryState.items;

  final activeItems = items.length;
  final expiringSoonItems =
      items.where((item) {
        if (item.expirationDate == null) return false;
        final daysUntilExpiration =
            item.expirationDate!.difference(DateTime.now()).inDays;
        return daysUntilExpiration <= 3 && daysUntilExpiration >= 0;
      }).length;

  return InventorySummary(
    activeItems: activeItems,
    expiringSoonItems: expiringSoonItems,
  );
});

final recipeSuggestionsProvider = FutureProvider<List<Recipe>>((ref) async {
  // Watch favorites from Firestore (these are recipes saved as favorites)
  final favoritesAsyncValue = ref.watch(userFavoritesProvider);

  return favoritesAsyncValue.when(
    data: (favoriteRecipes) {
      if (favoriteRecipes.isEmpty) {
        return []; // Return empty list if no favorites
      }
      
      // Convert FavoriteRecipe objects to Recipe objects for home display
      return favoriteRecipes.map((favoriteRecipe) {
        return Recipe(
          id: favoriteRecipe.id,
          title: favoriteRecipe.title,
          imageUrl: favoriteRecipe.imagePath ?? 
              'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=880&q=80',
          difficulty: favoriteRecipe.difficulty,
        );
      }).toList();
    },
    loading: () => [], // Return empty list while loading
    error: (error, stackTrace) {
      // Log the error and return an empty list on failure
      log('Error fetching favorite recipes: $error');
      return [];
    },
  );
});

final impactSummaryProvider = Provider<ImpactSummary>((ref) {
  final calculationsAsync = ref.watch(allImpactCalculationsProvider);

  return calculationsAsync.when(
    data: (calculations) {
      final cookedRecipes =
          calculations.calculations.where((c) => c.isCooked).length;
      return ImpactSummary(
        cookedRecipes: cookedRecipes,
        totalRecipes: calculations.count,
      );
    },
    loading: () => ImpactSummary(cookedRecipes: 0, totalRecipes: 0),
    error: (_, _) => ImpactSummary(cookedRecipes: 0, totalRecipes: 0),
  );
});
