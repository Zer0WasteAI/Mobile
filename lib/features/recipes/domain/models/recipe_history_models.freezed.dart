// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe_history_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecipeHistoryEntry {

 String get id; String get recipeId; String get recipeName; RecipeInteractionType get interactionType; DateTime get timestamp; double? get rating; String? get notes; Map<String, dynamic>? get metadata;
/// Create a copy of RecipeHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeHistoryEntryCopyWith<RecipeHistoryEntry> get copyWith => _$RecipeHistoryEntryCopyWithImpl<RecipeHistoryEntry>(this as RecipeHistoryEntry, _$identity);

  /// Serializes this RecipeHistoryEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipeHistoryEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.recipeName, recipeName) || other.recipeName == recipeName)&&(identical(other.interactionType, interactionType) || other.interactionType == interactionType)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recipeId,recipeName,interactionType,timestamp,rating,notes,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'RecipeHistoryEntry(id: $id, recipeId: $recipeId, recipeName: $recipeName, interactionType: $interactionType, timestamp: $timestamp, rating: $rating, notes: $notes, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $RecipeHistoryEntryCopyWith<$Res>  {
  factory $RecipeHistoryEntryCopyWith(RecipeHistoryEntry value, $Res Function(RecipeHistoryEntry) _then) = _$RecipeHistoryEntryCopyWithImpl;
@useResult
$Res call({
 String id, String recipeId, String recipeName, RecipeInteractionType interactionType, DateTime timestamp, double? rating, String? notes, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$RecipeHistoryEntryCopyWithImpl<$Res>
    implements $RecipeHistoryEntryCopyWith<$Res> {
  _$RecipeHistoryEntryCopyWithImpl(this._self, this._then);

  final RecipeHistoryEntry _self;
  final $Res Function(RecipeHistoryEntry) _then;

/// Create a copy of RecipeHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? recipeId = null,Object? recipeName = null,Object? interactionType = null,Object? timestamp = null,Object? rating = freezed,Object? notes = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,recipeName: null == recipeName ? _self.recipeName : recipeName // ignore: cast_nullable_to_non_nullable
as String,interactionType: null == interactionType ? _self.interactionType : interactionType // ignore: cast_nullable_to_non_nullable
as RecipeInteractionType,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _RecipeHistoryEntry implements RecipeHistoryEntry {
  const _RecipeHistoryEntry({required this.id, required this.recipeId, required this.recipeName, required this.interactionType, required this.timestamp, this.rating, this.notes, final  Map<String, dynamic>? metadata}): _metadata = metadata;
  factory _RecipeHistoryEntry.fromJson(Map<String, dynamic> json) => _$RecipeHistoryEntryFromJson(json);

@override final  String id;
@override final  String recipeId;
@override final  String recipeName;
@override final  RecipeInteractionType interactionType;
@override final  DateTime timestamp;
@override final  double? rating;
@override final  String? notes;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of RecipeHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeHistoryEntryCopyWith<_RecipeHistoryEntry> get copyWith => __$RecipeHistoryEntryCopyWithImpl<_RecipeHistoryEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeHistoryEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipeHistoryEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.recipeName, recipeName) || other.recipeName == recipeName)&&(identical(other.interactionType, interactionType) || other.interactionType == interactionType)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recipeId,recipeName,interactionType,timestamp,rating,notes,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'RecipeHistoryEntry(id: $id, recipeId: $recipeId, recipeName: $recipeName, interactionType: $interactionType, timestamp: $timestamp, rating: $rating, notes: $notes, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$RecipeHistoryEntryCopyWith<$Res> implements $RecipeHistoryEntryCopyWith<$Res> {
  factory _$RecipeHistoryEntryCopyWith(_RecipeHistoryEntry value, $Res Function(_RecipeHistoryEntry) _then) = __$RecipeHistoryEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String recipeId, String recipeName, RecipeInteractionType interactionType, DateTime timestamp, double? rating, String? notes, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$RecipeHistoryEntryCopyWithImpl<$Res>
    implements _$RecipeHistoryEntryCopyWith<$Res> {
  __$RecipeHistoryEntryCopyWithImpl(this._self, this._then);

  final _RecipeHistoryEntry _self;
  final $Res Function(_RecipeHistoryEntry) _then;

/// Create a copy of RecipeHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? recipeId = null,Object? recipeName = null,Object? interactionType = null,Object? timestamp = null,Object? rating = freezed,Object? notes = freezed,Object? metadata = freezed,}) {
  return _then(_RecipeHistoryEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,recipeName: null == recipeName ? _self.recipeName : recipeName // ignore: cast_nullable_to_non_nullable
as String,interactionType: null == interactionType ? _self.interactionType : interactionType // ignore: cast_nullable_to_non_nullable
as RecipeInteractionType,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$RecipeCollection {

 String get id; String get name; String get description; String get iconName; List<String> get recipeIds; DateTime get createdAt; DateTime get updatedAt; bool get isSystem; bool get isPublic; bool get isEditable;
/// Create a copy of RecipeCollection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeCollectionCopyWith<RecipeCollection> get copyWith => _$RecipeCollectionCopyWithImpl<RecipeCollection>(this as RecipeCollection, _$identity);

  /// Serializes this RecipeCollection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipeCollection&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&const DeepCollectionEquality().equals(other.recipeIds, recipeIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isSystem, isSystem) || other.isSystem == isSystem)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.isEditable, isEditable) || other.isEditable == isEditable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,iconName,const DeepCollectionEquality().hash(recipeIds),createdAt,updatedAt,isSystem,isPublic,isEditable);

@override
String toString() {
  return 'RecipeCollection(id: $id, name: $name, description: $description, iconName: $iconName, recipeIds: $recipeIds, createdAt: $createdAt, updatedAt: $updatedAt, isSystem: $isSystem, isPublic: $isPublic, isEditable: $isEditable)';
}


}

/// @nodoc
abstract mixin class $RecipeCollectionCopyWith<$Res>  {
  factory $RecipeCollectionCopyWith(RecipeCollection value, $Res Function(RecipeCollection) _then) = _$RecipeCollectionCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String iconName, List<String> recipeIds, DateTime createdAt, DateTime updatedAt, bool isSystem, bool isPublic, bool isEditable
});




}
/// @nodoc
class _$RecipeCollectionCopyWithImpl<$Res>
    implements $RecipeCollectionCopyWith<$Res> {
  _$RecipeCollectionCopyWithImpl(this._self, this._then);

  final RecipeCollection _self;
  final $Res Function(RecipeCollection) _then;

/// Create a copy of RecipeCollection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? iconName = null,Object? recipeIds = null,Object? createdAt = null,Object? updatedAt = null,Object? isSystem = null,Object? isPublic = null,Object? isEditable = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,recipeIds: null == recipeIds ? _self.recipeIds : recipeIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isSystem: null == isSystem ? _self.isSystem : isSystem // ignore: cast_nullable_to_non_nullable
as bool,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,isEditable: null == isEditable ? _self.isEditable : isEditable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _RecipeCollection implements RecipeCollection {
  const _RecipeCollection({required this.id, required this.name, required this.description, required this.iconName, required final  List<String> recipeIds, required this.createdAt, required this.updatedAt, required this.isSystem, required this.isPublic, required this.isEditable}): _recipeIds = recipeIds;
  factory _RecipeCollection.fromJson(Map<String, dynamic> json) => _$RecipeCollectionFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
@override final  String iconName;
 final  List<String> _recipeIds;
@override List<String> get recipeIds {
  if (_recipeIds is EqualUnmodifiableListView) return _recipeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recipeIds);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  bool isSystem;
@override final  bool isPublic;
@override final  bool isEditable;

/// Create a copy of RecipeCollection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeCollectionCopyWith<_RecipeCollection> get copyWith => __$RecipeCollectionCopyWithImpl<_RecipeCollection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeCollectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipeCollection&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&const DeepCollectionEquality().equals(other._recipeIds, _recipeIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isSystem, isSystem) || other.isSystem == isSystem)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.isEditable, isEditable) || other.isEditable == isEditable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,iconName,const DeepCollectionEquality().hash(_recipeIds),createdAt,updatedAt,isSystem,isPublic,isEditable);

@override
String toString() {
  return 'RecipeCollection(id: $id, name: $name, description: $description, iconName: $iconName, recipeIds: $recipeIds, createdAt: $createdAt, updatedAt: $updatedAt, isSystem: $isSystem, isPublic: $isPublic, isEditable: $isEditable)';
}


}

/// @nodoc
abstract mixin class _$RecipeCollectionCopyWith<$Res> implements $RecipeCollectionCopyWith<$Res> {
  factory _$RecipeCollectionCopyWith(_RecipeCollection value, $Res Function(_RecipeCollection) _then) = __$RecipeCollectionCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String iconName, List<String> recipeIds, DateTime createdAt, DateTime updatedAt, bool isSystem, bool isPublic, bool isEditable
});




}
/// @nodoc
class __$RecipeCollectionCopyWithImpl<$Res>
    implements _$RecipeCollectionCopyWith<$Res> {
  __$RecipeCollectionCopyWithImpl(this._self, this._then);

  final _RecipeCollection _self;
  final $Res Function(_RecipeCollection) _then;

/// Create a copy of RecipeCollection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? iconName = null,Object? recipeIds = null,Object? createdAt = null,Object? updatedAt = null,Object? isSystem = null,Object? isPublic = null,Object? isEditable = null,}) {
  return _then(_RecipeCollection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,recipeIds: null == recipeIds ? _self._recipeIds : recipeIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isSystem: null == isSystem ? _self.isSystem : isSystem // ignore: cast_nullable_to_non_nullable
as bool,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,isEditable: null == isEditable ? _self.isEditable : isEditable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$RecipeWithHistory {

 Recipe get recipe; List<RecipeHistoryEntry> get historyEntries; bool get isFavorite; int get timesCooked; int get timesViewed; double? get averageRating; DateTime? get lastCooked; DateTime? get lastViewed; DateTime? get lastUpdated;
/// Create a copy of RecipeWithHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeWithHistoryCopyWith<RecipeWithHistory> get copyWith => _$RecipeWithHistoryCopyWithImpl<RecipeWithHistory>(this as RecipeWithHistory, _$identity);

  /// Serializes this RecipeWithHistory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipeWithHistory&&(identical(other.recipe, recipe) || other.recipe == recipe)&&const DeepCollectionEquality().equals(other.historyEntries, historyEntries)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.timesCooked, timesCooked) || other.timesCooked == timesCooked)&&(identical(other.timesViewed, timesViewed) || other.timesViewed == timesViewed)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.lastCooked, lastCooked) || other.lastCooked == lastCooked)&&(identical(other.lastViewed, lastViewed) || other.lastViewed == lastViewed)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recipe,const DeepCollectionEquality().hash(historyEntries),isFavorite,timesCooked,timesViewed,averageRating,lastCooked,lastViewed,lastUpdated);

@override
String toString() {
  return 'RecipeWithHistory(recipe: $recipe, historyEntries: $historyEntries, isFavorite: $isFavorite, timesCooked: $timesCooked, timesViewed: $timesViewed, averageRating: $averageRating, lastCooked: $lastCooked, lastViewed: $lastViewed, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class $RecipeWithHistoryCopyWith<$Res>  {
  factory $RecipeWithHistoryCopyWith(RecipeWithHistory value, $Res Function(RecipeWithHistory) _then) = _$RecipeWithHistoryCopyWithImpl;
@useResult
$Res call({
 Recipe recipe, List<RecipeHistoryEntry> historyEntries, bool isFavorite, int timesCooked, int timesViewed, double? averageRating, DateTime? lastCooked, DateTime? lastViewed, DateTime? lastUpdated
});


$RecipeCopyWith<$Res> get recipe;

}
/// @nodoc
class _$RecipeWithHistoryCopyWithImpl<$Res>
    implements $RecipeWithHistoryCopyWith<$Res> {
  _$RecipeWithHistoryCopyWithImpl(this._self, this._then);

  final RecipeWithHistory _self;
  final $Res Function(RecipeWithHistory) _then;

/// Create a copy of RecipeWithHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recipe = null,Object? historyEntries = null,Object? isFavorite = null,Object? timesCooked = null,Object? timesViewed = null,Object? averageRating = freezed,Object? lastCooked = freezed,Object? lastViewed = freezed,Object? lastUpdated = freezed,}) {
  return _then(_self.copyWith(
recipe: null == recipe ? _self.recipe : recipe // ignore: cast_nullable_to_non_nullable
as Recipe,historyEntries: null == historyEntries ? _self.historyEntries : historyEntries // ignore: cast_nullable_to_non_nullable
as List<RecipeHistoryEntry>,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,timesCooked: null == timesCooked ? _self.timesCooked : timesCooked // ignore: cast_nullable_to_non_nullable
as int,timesViewed: null == timesViewed ? _self.timesViewed : timesViewed // ignore: cast_nullable_to_non_nullable
as int,averageRating: freezed == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double?,lastCooked: freezed == lastCooked ? _self.lastCooked : lastCooked // ignore: cast_nullable_to_non_nullable
as DateTime?,lastViewed: freezed == lastViewed ? _self.lastViewed : lastViewed // ignore: cast_nullable_to_non_nullable
as DateTime?,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of RecipeWithHistory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecipeCopyWith<$Res> get recipe {
  
  return $RecipeCopyWith<$Res>(_self.recipe, (value) {
    return _then(_self.copyWith(recipe: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _RecipeWithHistory implements RecipeWithHistory {
  const _RecipeWithHistory({required this.recipe, required final  List<RecipeHistoryEntry> historyEntries, required this.isFavorite, required this.timesCooked, required this.timesViewed, required this.averageRating, required this.lastCooked, required this.lastViewed, required this.lastUpdated}): _historyEntries = historyEntries;
  factory _RecipeWithHistory.fromJson(Map<String, dynamic> json) => _$RecipeWithHistoryFromJson(json);

@override final  Recipe recipe;
 final  List<RecipeHistoryEntry> _historyEntries;
@override List<RecipeHistoryEntry> get historyEntries {
  if (_historyEntries is EqualUnmodifiableListView) return _historyEntries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_historyEntries);
}

@override final  bool isFavorite;
@override final  int timesCooked;
@override final  int timesViewed;
@override final  double? averageRating;
@override final  DateTime? lastCooked;
@override final  DateTime? lastViewed;
@override final  DateTime? lastUpdated;

/// Create a copy of RecipeWithHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeWithHistoryCopyWith<_RecipeWithHistory> get copyWith => __$RecipeWithHistoryCopyWithImpl<_RecipeWithHistory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeWithHistoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipeWithHistory&&(identical(other.recipe, recipe) || other.recipe == recipe)&&const DeepCollectionEquality().equals(other._historyEntries, _historyEntries)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.timesCooked, timesCooked) || other.timesCooked == timesCooked)&&(identical(other.timesViewed, timesViewed) || other.timesViewed == timesViewed)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.lastCooked, lastCooked) || other.lastCooked == lastCooked)&&(identical(other.lastViewed, lastViewed) || other.lastViewed == lastViewed)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recipe,const DeepCollectionEquality().hash(_historyEntries),isFavorite,timesCooked,timesViewed,averageRating,lastCooked,lastViewed,lastUpdated);

@override
String toString() {
  return 'RecipeWithHistory(recipe: $recipe, historyEntries: $historyEntries, isFavorite: $isFavorite, timesCooked: $timesCooked, timesViewed: $timesViewed, averageRating: $averageRating, lastCooked: $lastCooked, lastViewed: $lastViewed, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class _$RecipeWithHistoryCopyWith<$Res> implements $RecipeWithHistoryCopyWith<$Res> {
  factory _$RecipeWithHistoryCopyWith(_RecipeWithHistory value, $Res Function(_RecipeWithHistory) _then) = __$RecipeWithHistoryCopyWithImpl;
@override @useResult
$Res call({
 Recipe recipe, List<RecipeHistoryEntry> historyEntries, bool isFavorite, int timesCooked, int timesViewed, double? averageRating, DateTime? lastCooked, DateTime? lastViewed, DateTime? lastUpdated
});


@override $RecipeCopyWith<$Res> get recipe;

}
/// @nodoc
class __$RecipeWithHistoryCopyWithImpl<$Res>
    implements _$RecipeWithHistoryCopyWith<$Res> {
  __$RecipeWithHistoryCopyWithImpl(this._self, this._then);

  final _RecipeWithHistory _self;
  final $Res Function(_RecipeWithHistory) _then;

/// Create a copy of RecipeWithHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recipe = null,Object? historyEntries = null,Object? isFavorite = null,Object? timesCooked = null,Object? timesViewed = null,Object? averageRating = freezed,Object? lastCooked = freezed,Object? lastViewed = freezed,Object? lastUpdated = freezed,}) {
  return _then(_RecipeWithHistory(
recipe: null == recipe ? _self.recipe : recipe // ignore: cast_nullable_to_non_nullable
as Recipe,historyEntries: null == historyEntries ? _self._historyEntries : historyEntries // ignore: cast_nullable_to_non_nullable
as List<RecipeHistoryEntry>,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,timesCooked: null == timesCooked ? _self.timesCooked : timesCooked // ignore: cast_nullable_to_non_nullable
as int,timesViewed: null == timesViewed ? _self.timesViewed : timesViewed // ignore: cast_nullable_to_non_nullable
as int,averageRating: freezed == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double?,lastCooked: freezed == lastCooked ? _self.lastCooked : lastCooked // ignore: cast_nullable_to_non_nullable
as DateTime?,lastViewed: freezed == lastViewed ? _self.lastViewed : lastViewed // ignore: cast_nullable_to_non_nullable
as DateTime?,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of RecipeWithHistory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecipeCopyWith<$Res> get recipe {
  
  return $RecipeCopyWith<$Res>(_self.recipe, (value) {
    return _then(_self.copyWith(recipe: value));
  });
}
}


/// @nodoc
mixin _$RecipeStatistics {

 int get totalRecipes; int get cookedRecipes; int get favoriteRecipes; int get totalCookingTime; double get averageCookingTime; double get averageRating; Map<String, int> get categoryStats; Map<String, int> get difficultyStats; Map<String, int> get dietTypeStats; Map<String, int> get ingredientStats; Map<String, int> get timeOfDayStats; Map<String, int> get weekdayStats;
/// Create a copy of RecipeStatistics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeStatisticsCopyWith<RecipeStatistics> get copyWith => _$RecipeStatisticsCopyWithImpl<RecipeStatistics>(this as RecipeStatistics, _$identity);

  /// Serializes this RecipeStatistics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipeStatistics&&(identical(other.totalRecipes, totalRecipes) || other.totalRecipes == totalRecipes)&&(identical(other.cookedRecipes, cookedRecipes) || other.cookedRecipes == cookedRecipes)&&(identical(other.favoriteRecipes, favoriteRecipes) || other.favoriteRecipes == favoriteRecipes)&&(identical(other.totalCookingTime, totalCookingTime) || other.totalCookingTime == totalCookingTime)&&(identical(other.averageCookingTime, averageCookingTime) || other.averageCookingTime == averageCookingTime)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&const DeepCollectionEquality().equals(other.categoryStats, categoryStats)&&const DeepCollectionEquality().equals(other.difficultyStats, difficultyStats)&&const DeepCollectionEquality().equals(other.dietTypeStats, dietTypeStats)&&const DeepCollectionEquality().equals(other.ingredientStats, ingredientStats)&&const DeepCollectionEquality().equals(other.timeOfDayStats, timeOfDayStats)&&const DeepCollectionEquality().equals(other.weekdayStats, weekdayStats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalRecipes,cookedRecipes,favoriteRecipes,totalCookingTime,averageCookingTime,averageRating,const DeepCollectionEquality().hash(categoryStats),const DeepCollectionEquality().hash(difficultyStats),const DeepCollectionEquality().hash(dietTypeStats),const DeepCollectionEquality().hash(ingredientStats),const DeepCollectionEquality().hash(timeOfDayStats),const DeepCollectionEquality().hash(weekdayStats));

@override
String toString() {
  return 'RecipeStatistics(totalRecipes: $totalRecipes, cookedRecipes: $cookedRecipes, favoriteRecipes: $favoriteRecipes, totalCookingTime: $totalCookingTime, averageCookingTime: $averageCookingTime, averageRating: $averageRating, categoryStats: $categoryStats, difficultyStats: $difficultyStats, dietTypeStats: $dietTypeStats, ingredientStats: $ingredientStats, timeOfDayStats: $timeOfDayStats, weekdayStats: $weekdayStats)';
}


}

/// @nodoc
abstract mixin class $RecipeStatisticsCopyWith<$Res>  {
  factory $RecipeStatisticsCopyWith(RecipeStatistics value, $Res Function(RecipeStatistics) _then) = _$RecipeStatisticsCopyWithImpl;
@useResult
$Res call({
 int totalRecipes, int cookedRecipes, int favoriteRecipes, int totalCookingTime, double averageCookingTime, double averageRating, Map<String, int> categoryStats, Map<String, int> difficultyStats, Map<String, int> dietTypeStats, Map<String, int> ingredientStats, Map<String, int> timeOfDayStats, Map<String, int> weekdayStats
});




}
/// @nodoc
class _$RecipeStatisticsCopyWithImpl<$Res>
    implements $RecipeStatisticsCopyWith<$Res> {
  _$RecipeStatisticsCopyWithImpl(this._self, this._then);

  final RecipeStatistics _self;
  final $Res Function(RecipeStatistics) _then;

/// Create a copy of RecipeStatistics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalRecipes = null,Object? cookedRecipes = null,Object? favoriteRecipes = null,Object? totalCookingTime = null,Object? averageCookingTime = null,Object? averageRating = null,Object? categoryStats = null,Object? difficultyStats = null,Object? dietTypeStats = null,Object? ingredientStats = null,Object? timeOfDayStats = null,Object? weekdayStats = null,}) {
  return _then(_self.copyWith(
totalRecipes: null == totalRecipes ? _self.totalRecipes : totalRecipes // ignore: cast_nullable_to_non_nullable
as int,cookedRecipes: null == cookedRecipes ? _self.cookedRecipes : cookedRecipes // ignore: cast_nullable_to_non_nullable
as int,favoriteRecipes: null == favoriteRecipes ? _self.favoriteRecipes : favoriteRecipes // ignore: cast_nullable_to_non_nullable
as int,totalCookingTime: null == totalCookingTime ? _self.totalCookingTime : totalCookingTime // ignore: cast_nullable_to_non_nullable
as int,averageCookingTime: null == averageCookingTime ? _self.averageCookingTime : averageCookingTime // ignore: cast_nullable_to_non_nullable
as double,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,categoryStats: null == categoryStats ? _self.categoryStats : categoryStats // ignore: cast_nullable_to_non_nullable
as Map<String, int>,difficultyStats: null == difficultyStats ? _self.difficultyStats : difficultyStats // ignore: cast_nullable_to_non_nullable
as Map<String, int>,dietTypeStats: null == dietTypeStats ? _self.dietTypeStats : dietTypeStats // ignore: cast_nullable_to_non_nullable
as Map<String, int>,ingredientStats: null == ingredientStats ? _self.ingredientStats : ingredientStats // ignore: cast_nullable_to_non_nullable
as Map<String, int>,timeOfDayStats: null == timeOfDayStats ? _self.timeOfDayStats : timeOfDayStats // ignore: cast_nullable_to_non_nullable
as Map<String, int>,weekdayStats: null == weekdayStats ? _self.weekdayStats : weekdayStats // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _RecipeStatistics implements RecipeStatistics {
  const _RecipeStatistics({required this.totalRecipes, required this.cookedRecipes, required this.favoriteRecipes, required this.totalCookingTime, required this.averageCookingTime, required this.averageRating, required final  Map<String, int> categoryStats, required final  Map<String, int> difficultyStats, required final  Map<String, int> dietTypeStats, required final  Map<String, int> ingredientStats, required final  Map<String, int> timeOfDayStats, required final  Map<String, int> weekdayStats}): _categoryStats = categoryStats,_difficultyStats = difficultyStats,_dietTypeStats = dietTypeStats,_ingredientStats = ingredientStats,_timeOfDayStats = timeOfDayStats,_weekdayStats = weekdayStats;
  factory _RecipeStatistics.fromJson(Map<String, dynamic> json) => _$RecipeStatisticsFromJson(json);

@override final  int totalRecipes;
@override final  int cookedRecipes;
@override final  int favoriteRecipes;
@override final  int totalCookingTime;
@override final  double averageCookingTime;
@override final  double averageRating;
 final  Map<String, int> _categoryStats;
@override Map<String, int> get categoryStats {
  if (_categoryStats is EqualUnmodifiableMapView) return _categoryStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_categoryStats);
}

 final  Map<String, int> _difficultyStats;
@override Map<String, int> get difficultyStats {
  if (_difficultyStats is EqualUnmodifiableMapView) return _difficultyStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_difficultyStats);
}

 final  Map<String, int> _dietTypeStats;
@override Map<String, int> get dietTypeStats {
  if (_dietTypeStats is EqualUnmodifiableMapView) return _dietTypeStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_dietTypeStats);
}

 final  Map<String, int> _ingredientStats;
@override Map<String, int> get ingredientStats {
  if (_ingredientStats is EqualUnmodifiableMapView) return _ingredientStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_ingredientStats);
}

 final  Map<String, int> _timeOfDayStats;
@override Map<String, int> get timeOfDayStats {
  if (_timeOfDayStats is EqualUnmodifiableMapView) return _timeOfDayStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_timeOfDayStats);
}

 final  Map<String, int> _weekdayStats;
@override Map<String, int> get weekdayStats {
  if (_weekdayStats is EqualUnmodifiableMapView) return _weekdayStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_weekdayStats);
}


/// Create a copy of RecipeStatistics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeStatisticsCopyWith<_RecipeStatistics> get copyWith => __$RecipeStatisticsCopyWithImpl<_RecipeStatistics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeStatisticsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipeStatistics&&(identical(other.totalRecipes, totalRecipes) || other.totalRecipes == totalRecipes)&&(identical(other.cookedRecipes, cookedRecipes) || other.cookedRecipes == cookedRecipes)&&(identical(other.favoriteRecipes, favoriteRecipes) || other.favoriteRecipes == favoriteRecipes)&&(identical(other.totalCookingTime, totalCookingTime) || other.totalCookingTime == totalCookingTime)&&(identical(other.averageCookingTime, averageCookingTime) || other.averageCookingTime == averageCookingTime)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&const DeepCollectionEquality().equals(other._categoryStats, _categoryStats)&&const DeepCollectionEquality().equals(other._difficultyStats, _difficultyStats)&&const DeepCollectionEquality().equals(other._dietTypeStats, _dietTypeStats)&&const DeepCollectionEquality().equals(other._ingredientStats, _ingredientStats)&&const DeepCollectionEquality().equals(other._timeOfDayStats, _timeOfDayStats)&&const DeepCollectionEquality().equals(other._weekdayStats, _weekdayStats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalRecipes,cookedRecipes,favoriteRecipes,totalCookingTime,averageCookingTime,averageRating,const DeepCollectionEquality().hash(_categoryStats),const DeepCollectionEquality().hash(_difficultyStats),const DeepCollectionEquality().hash(_dietTypeStats),const DeepCollectionEquality().hash(_ingredientStats),const DeepCollectionEquality().hash(_timeOfDayStats),const DeepCollectionEquality().hash(_weekdayStats));

@override
String toString() {
  return 'RecipeStatistics(totalRecipes: $totalRecipes, cookedRecipes: $cookedRecipes, favoriteRecipes: $favoriteRecipes, totalCookingTime: $totalCookingTime, averageCookingTime: $averageCookingTime, averageRating: $averageRating, categoryStats: $categoryStats, difficultyStats: $difficultyStats, dietTypeStats: $dietTypeStats, ingredientStats: $ingredientStats, timeOfDayStats: $timeOfDayStats, weekdayStats: $weekdayStats)';
}


}

/// @nodoc
abstract mixin class _$RecipeStatisticsCopyWith<$Res> implements $RecipeStatisticsCopyWith<$Res> {
  factory _$RecipeStatisticsCopyWith(_RecipeStatistics value, $Res Function(_RecipeStatistics) _then) = __$RecipeStatisticsCopyWithImpl;
@override @useResult
$Res call({
 int totalRecipes, int cookedRecipes, int favoriteRecipes, int totalCookingTime, double averageCookingTime, double averageRating, Map<String, int> categoryStats, Map<String, int> difficultyStats, Map<String, int> dietTypeStats, Map<String, int> ingredientStats, Map<String, int> timeOfDayStats, Map<String, int> weekdayStats
});




}
/// @nodoc
class __$RecipeStatisticsCopyWithImpl<$Res>
    implements _$RecipeStatisticsCopyWith<$Res> {
  __$RecipeStatisticsCopyWithImpl(this._self, this._then);

  final _RecipeStatistics _self;
  final $Res Function(_RecipeStatistics) _then;

/// Create a copy of RecipeStatistics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalRecipes = null,Object? cookedRecipes = null,Object? favoriteRecipes = null,Object? totalCookingTime = null,Object? averageCookingTime = null,Object? averageRating = null,Object? categoryStats = null,Object? difficultyStats = null,Object? dietTypeStats = null,Object? ingredientStats = null,Object? timeOfDayStats = null,Object? weekdayStats = null,}) {
  return _then(_RecipeStatistics(
totalRecipes: null == totalRecipes ? _self.totalRecipes : totalRecipes // ignore: cast_nullable_to_non_nullable
as int,cookedRecipes: null == cookedRecipes ? _self.cookedRecipes : cookedRecipes // ignore: cast_nullable_to_non_nullable
as int,favoriteRecipes: null == favoriteRecipes ? _self.favoriteRecipes : favoriteRecipes // ignore: cast_nullable_to_non_nullable
as int,totalCookingTime: null == totalCookingTime ? _self.totalCookingTime : totalCookingTime // ignore: cast_nullable_to_non_nullable
as int,averageCookingTime: null == averageCookingTime ? _self.averageCookingTime : averageCookingTime // ignore: cast_nullable_to_non_nullable
as double,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,categoryStats: null == categoryStats ? _self._categoryStats : categoryStats // ignore: cast_nullable_to_non_nullable
as Map<String, int>,difficultyStats: null == difficultyStats ? _self._difficultyStats : difficultyStats // ignore: cast_nullable_to_non_nullable
as Map<String, int>,dietTypeStats: null == dietTypeStats ? _self._dietTypeStats : dietTypeStats // ignore: cast_nullable_to_non_nullable
as Map<String, int>,ingredientStats: null == ingredientStats ? _self._ingredientStats : ingredientStats // ignore: cast_nullable_to_non_nullable
as Map<String, int>,timeOfDayStats: null == timeOfDayStats ? _self._timeOfDayStats : timeOfDayStats // ignore: cast_nullable_to_non_nullable
as Map<String, int>,weekdayStats: null == weekdayStats ? _self._weekdayStats : weekdayStats // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}

// dart format on
