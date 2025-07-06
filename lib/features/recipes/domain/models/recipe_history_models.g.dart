// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_history_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecipeHistoryEntry _$RecipeHistoryEntryFromJson(Map<String, dynamic> json) =>
    _RecipeHistoryEntry(
      id: json['id'] as String,
      recipeId: json['recipeId'] as String,
      recipeName: json['recipeName'] as String,
      interactionType: $enumDecode(
        _$RecipeInteractionTypeEnumMap,
        json['interactionType'],
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      rating: (json['rating'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$RecipeHistoryEntryToJson(
  _RecipeHistoryEntry instance,
) => <String, dynamic>{
  'id': instance.id,
  'recipeId': instance.recipeId,
  'recipeName': instance.recipeName,
  'interactionType': _$RecipeInteractionTypeEnumMap[instance.interactionType]!,
  'timestamp': instance.timestamp.toIso8601String(),
  'rating': instance.rating,
  'notes': instance.notes,
  'metadata': instance.metadata,
};

const _$RecipeInteractionTypeEnumMap = {
  RecipeInteractionType.generated: 'generated',
  RecipeInteractionType.viewed: 'viewed',
  RecipeInteractionType.startedCooking: 'startedCooking',
  RecipeInteractionType.completed: 'completed',
  RecipeInteractionType.favorited: 'favorited',
  RecipeInteractionType.shared: 'shared',
};

_RecipeCollection _$RecipeCollectionFromJson(Map<String, dynamic> json) =>
    _RecipeCollection(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String,
      recipeIds:
          (json['recipeIds'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSystem: json['isSystem'] as bool,
      isPublic: json['isPublic'] as bool,
      isEditable: json['isEditable'] as bool,
    );

Map<String, dynamic> _$RecipeCollectionToJson(_RecipeCollection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'iconName': instance.iconName,
      'recipeIds': instance.recipeIds,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isSystem': instance.isSystem,
      'isPublic': instance.isPublic,
      'isEditable': instance.isEditable,
    };

_RecipeWithHistory _$RecipeWithHistoryFromJson(Map<String, dynamic> json) =>
    _RecipeWithHistory(
      recipe: Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
      historyEntries:
          (json['historyEntries'] as List<dynamic>)
              .map(
                (e) => RecipeHistoryEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      isFavorite: json['isFavorite'] as bool,
      timesCooked: (json['timesCooked'] as num).toInt(),
      timesViewed: (json['timesViewed'] as num).toInt(),
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      lastCooked:
          json['lastCooked'] == null
              ? null
              : DateTime.parse(json['lastCooked'] as String),
      lastViewed:
          json['lastViewed'] == null
              ? null
              : DateTime.parse(json['lastViewed'] as String),
      lastUpdated:
          json['lastUpdated'] == null
              ? null
              : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$RecipeWithHistoryToJson(_RecipeWithHistory instance) =>
    <String, dynamic>{
      'recipe': instance.recipe,
      'historyEntries': instance.historyEntries,
      'isFavorite': instance.isFavorite,
      'timesCooked': instance.timesCooked,
      'timesViewed': instance.timesViewed,
      'averageRating': instance.averageRating,
      'lastCooked': instance.lastCooked?.toIso8601String(),
      'lastViewed': instance.lastViewed?.toIso8601String(),
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };

_RecipeStatistics _$RecipeStatisticsFromJson(Map<String, dynamic> json) =>
    _RecipeStatistics(
      totalRecipes: (json['totalRecipes'] as num).toInt(),
      cookedRecipes: (json['cookedRecipes'] as num).toInt(),
      favoriteRecipes: (json['favoriteRecipes'] as num).toInt(),
      totalCookingTime: (json['totalCookingTime'] as num).toInt(),
      averageCookingTime: (json['averageCookingTime'] as num).toDouble(),
      averageRating: (json['averageRating'] as num).toDouble(),
      categoryStats: Map<String, int>.from(json['categoryStats'] as Map),
      difficultyStats: Map<String, int>.from(json['difficultyStats'] as Map),
      dietTypeStats: Map<String, int>.from(json['dietTypeStats'] as Map),
      ingredientStats: Map<String, int>.from(json['ingredientStats'] as Map),
      timeOfDayStats: Map<String, int>.from(json['timeOfDayStats'] as Map),
      weekdayStats: Map<String, int>.from(json['weekdayStats'] as Map),
    );

Map<String, dynamic> _$RecipeStatisticsToJson(_RecipeStatistics instance) =>
    <String, dynamic>{
      'totalRecipes': instance.totalRecipes,
      'cookedRecipes': instance.cookedRecipes,
      'favoriteRecipes': instance.favoriteRecipes,
      'totalCookingTime': instance.totalCookingTime,
      'averageCookingTime': instance.averageCookingTime,
      'averageRating': instance.averageRating,
      'categoryStats': instance.categoryStats,
      'difficultyStats': instance.difficultyStats,
      'dietTypeStats': instance.dietTypeStats,
      'ingredientStats': instance.ingredientStats,
      'timeOfDayStats': instance.timeOfDayStats,
      'weekdayStats': instance.weekdayStats,
    };
