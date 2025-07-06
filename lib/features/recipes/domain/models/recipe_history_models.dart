/// Recipe history models for tracking cooked and generated recipes
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';

part 'recipe_history_models.freezed.dart';
part 'recipe_history_models.g.dart';

/// Enum for recipe interaction types
enum RecipeInteractionType {
  generated,
  viewed,
  startedCooking,
  completed,
  favorited,
  shared,
}

/// Recipe history entry model
@freezed
abstract class RecipeHistoryEntry with _$RecipeHistoryEntry {
  const factory RecipeHistoryEntry({
    required String id,
    required String recipeId,
    required String recipeName,
    required RecipeInteractionType interactionType,
    required DateTime timestamp,
    double? rating,
    String? notes,
    Map<String, dynamic>? metadata,
  }) = _RecipeHistoryEntry;

  factory RecipeHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$RecipeHistoryEntryFromJson(json);
}

/// Recipe collection model
@freezed
abstract class RecipeCollection with _$RecipeCollection {
  const factory RecipeCollection({
    required String id,
    required String name,
    required String description,
    required String iconName,
    required List<String> recipeIds,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isSystem,
    required bool isPublic,
    required bool isEditable,
  }) = _RecipeCollection;

  factory RecipeCollection.fromJson(Map<String, dynamic> json) =>
      _$RecipeCollectionFromJson(json);
}

/// Recipe with history model
@freezed
abstract class RecipeWithHistory with _$RecipeWithHistory {
  const factory RecipeWithHistory({
    required Recipe recipe,
    required List<RecipeHistoryEntry> historyEntries,
    required bool isFavorite,
    required int timesCooked,
    required int timesViewed,
    required double? averageRating,
    required DateTime? lastCooked,
    required DateTime? lastViewed,
    required DateTime? lastUpdated,
  }) = _RecipeWithHistory;

  factory RecipeWithHistory.fromJson(Map<String, dynamic> json) =>
      _$RecipeWithHistoryFromJson(json);
}

/// Recipe statistics model
@freezed
abstract class RecipeStatistics with _$RecipeStatistics {
  const factory RecipeStatistics({
    required int totalRecipes,
    required int cookedRecipes,
    required int favoriteRecipes,
    required int totalCookingTime,
    required double averageCookingTime,
    required double averageRating,
    required Map<String, int> categoryStats,
    required Map<String, int> difficultyStats,
    required Map<String, int> dietTypeStats,
    required Map<String, int> ingredientStats,
    required Map<String, int> timeOfDayStats,
    required Map<String, int> weekdayStats,
  }) = _RecipeStatistics;

  factory RecipeStatistics.fromJson(Map<String, dynamic> json) =>
      _$RecipeStatisticsFromJson(json);
}

/// Extension methods for recipe history
extension RecipeHistoryEntryExtension on RecipeHistoryEntry {
  /// Get display text for interaction type
  String get displayText {
    switch (interactionType) {
      case RecipeInteractionType.generated:
        return 'Generada';
      case RecipeInteractionType.viewed:
        return 'Vista';
      case RecipeInteractionType.startedCooking:
        return 'Comenzó a cocinar';
      case RecipeInteractionType.completed:
        return 'Completada';
      case RecipeInteractionType.favorited:
        return 'Añadida a favoritos';
      case RecipeInteractionType.shared:
        return 'Compartida';
    }
  }

  /// Get icon for interaction type
  String get iconName {
    switch (interactionType) {
      case RecipeInteractionType.generated:
        return 'auto_awesome';
      case RecipeInteractionType.viewed:
        return 'visibility';
      case RecipeInteractionType.startedCooking:
        return 'restaurant';
      case RecipeInteractionType.completed:
        return 'check_circle';
      case RecipeInteractionType.favorited:
        return 'favorite';
      case RecipeInteractionType.shared:
        return 'share';
    }
  }

  /// Check if this is a cooking interaction
  bool get isCookingInteraction =>
      interactionType == RecipeInteractionType.startedCooking ||
      interactionType == RecipeInteractionType.completed;
}

/// Predefined recipe collections
class SystemRecipeCollections {
  static const String recentlyGeneratedId = 'system_recently_generated';
  static const String recentlyCookedId = 'system_recently_cooked';
  static const String frequentlyCookedId = 'system_frequently_cooked';
  static const String quickRecipesId = 'system_quick_recipes';

  static List<RecipeCollection> get defaultCollections => [
    RecipeCollection(
      id: recentlyGeneratedId,
      name: 'Recetas Recientes',
      description: 'Recetas generadas recientemente',
      recipeIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSystem: true,
      isPublic: true,
      isEditable: false,
      iconName: 'auto_awesome',
    ),
    RecipeCollection(
      id: recentlyCookedId,
      name: 'Cocinadas Recientemente',
      description: 'Recetas que has cocinado recientemente',
      recipeIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSystem: true,
      isPublic: true,
      isEditable: false,
      iconName: 'restaurant',
    ),
    RecipeCollection(
      id: frequentlyCookedId,
      name: 'Más Cocinadas',
      description: 'Tus recetas favoritas para cocinar',
      recipeIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSystem: true,
      isPublic: true,
      isEditable: false,
      iconName: 'trending_up',
    ),
    RecipeCollection(
      id: quickRecipesId,
      name: 'Recetas Rápidas',
      description: 'Recetas que se preparan en menos de 30 minutos',
      recipeIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSystem: true,
      isPublic: true,
      isEditable: false,
      iconName: 'timer',
    ),
  ];
}
