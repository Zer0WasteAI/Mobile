import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/core/services/api_service.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_history_models.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';

/// Provider for tracking recipe cooking progress
final isRecipeInProgressProvider = StateProvider.family<bool, String>(
  (ref, recipeId) => false,
);

/// Provider for recipe history state
final recipeHistoryProvider =
    StateNotifierProvider<RecipeHistoryNotifier, List<RecipeHistoryEntry>>(
      (ref) => RecipeHistoryNotifier(ref),
    );

/// Notifier for managing recipe history
class RecipeHistoryNotifier extends StateNotifier<List<RecipeHistoryEntry>> {
  final Ref _ref;
  final ApiService _apiService = ApiService.instance;

  RecipeHistoryNotifier(this._ref) : super([]) {
    _loadHistory();
  }

  /// Load recipe history from backend
  Future<void> _loadHistory() async {
    try {
      final response = await _apiService.getRecipeHistory();
      final List<dynamic> historyData = response['history'] ?? [];
      state =
          historyData
              .map((entry) => RecipeHistoryEntry.fromJson(entry))
              .toList();
    } catch (e) {
      // Handle error
    }
  }

  /// Track recipe view
  Future<void> trackRecipeView(Recipe recipe) async {
    final entry = RecipeHistoryEntry(
      id: DateTime.now().toIso8601String(),
      recipeId: recipe.id,
      recipeName: recipe.name,
      interactionType: RecipeInteractionType.viewed,
      timestamp: DateTime.now(),
    );

    state = [...state, entry];
    await _saveHistoryEntry(entry);
  }

  /// Start cooking a recipe
  Future<void> startCooking(Recipe recipe) async {
    final entry = RecipeHistoryEntry(
      id: DateTime.now().toIso8601String(),
      recipeId: recipe.id,
      recipeName: recipe.name,
      interactionType: RecipeInteractionType.startedCooking,
      timestamp: DateTime.now(),
    );

    state = [...state, entry];
    _ref.read(isRecipeInProgressProvider(recipe.id).notifier).state = true;
    await _saveHistoryEntry(entry);
  }

  /// Complete cooking a recipe
  Future<void> completeCooking(
    Recipe recipe, {
    double? rating,
    String? notes,
  }) async {
    final entry = RecipeHistoryEntry(
      id: DateTime.now().toIso8601String(),
      recipeId: recipe.id,
      recipeName: recipe.name,
      interactionType: RecipeInteractionType.completed,
      timestamp: DateTime.now(),
      rating: rating,
      notes: notes,
    );

    state = [...state, entry];
    _ref.read(isRecipeInProgressProvider(recipe.id).notifier).state = false;
    await _saveHistoryEntry(entry);
  }

  /// Save history entry to backend
  Future<void> _saveHistoryEntry(RecipeHistoryEntry entry) async {
    try {
      await _apiService.saveRecipeHistory(entry.toJson());
    } catch (e) {
      // Handle error
    }
  }

  /// Get recipe history for a specific recipe
  RecipeWithHistory? getRecipeHistory(Recipe recipe) {
    final historyEntries =
        state.where((entry) => entry.recipeId == recipe.id).toList();

    if (historyEntries.isEmpty) {
      return null;
    }

    final timesCooked =
        historyEntries
            .where(
              (entry) =>
                  entry.interactionType == RecipeInteractionType.completed,
            )
            .length;

    final timesViewed =
        historyEntries
            .where(
              (entry) => entry.interactionType == RecipeInteractionType.viewed,
            )
            .length;

    final ratings =
        historyEntries
            .where((entry) => entry.rating != null)
            .map((entry) => entry.rating!)
            .toList();

    final averageRating =
        ratings.isNotEmpty
            ? ratings.reduce((a, b) => a + b) / ratings.length
            : null;

    final lastCooked = historyEntries
        .where(
          (entry) => entry.interactionType == RecipeInteractionType.completed,
        )
        .map((entry) => entry.timestamp)
        .fold<DateTime?>(
          null,
          (prev, curr) => prev == null || curr.isAfter(prev) ? curr : prev,
        );

    final lastViewed = historyEntries
        .where((entry) => entry.interactionType == RecipeInteractionType.viewed)
        .map((entry) => entry.timestamp)
        .fold<DateTime?>(
          null,
          (prev, curr) => prev == null || curr.isAfter(prev) ? curr : prev,
        );

    final lastUpdated = historyEntries
        .map((entry) => entry.timestamp)
        .fold<DateTime?>(
          null,
          (prev, curr) => prev == null || curr.isAfter(prev) ? curr : prev,
        );

    final isFavorite = historyEntries.any(
      (entry) => entry.interactionType == RecipeInteractionType.favorited,
    );

    return RecipeWithHistory(
      recipe: recipe,
      historyEntries: historyEntries,
      isFavorite: isFavorite,
      timesCooked: timesCooked,
      timesViewed: timesViewed,
      averageRating: averageRating,
      lastCooked: lastCooked,
      lastViewed: lastViewed,
      lastUpdated: lastUpdated,
    );
  }
}

/// Convenience providers
final recipeHistoryEntriesProvider = Provider<List<RecipeHistoryEntry>>((ref) {
  return ref.watch(recipeHistoryProvider);
});

final recipeHistoryLoadingProvider = Provider<bool>((ref) {
  return ref.watch(recipeHistoryProvider).isNotEmpty;
});

final recipeHistoryErrorProvider = Provider<String?>((ref) {
  return ref.watch(recipeHistoryProvider).isNotEmpty
      ? null
      : 'No history found';
});
