// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Recipe implements DiagnosticableTreeMixin {

 String get id; String get name; String get description; String? get imageUrl; String get emoji; List<String> get ingredients;// List of ingredient names or IDs
// Smart mode specific fields (might be null in explore mode)
 int? get requiredIngredientsCount; int? get availableIngredientsCount; bool get usesExpiringItems;
/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeCopyWith<Recipe> get copyWith => _$RecipeCopyWithImpl<Recipe>(this as Recipe, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'Recipe'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('description', description))..add(DiagnosticsProperty('imageUrl', imageUrl))..add(DiagnosticsProperty('emoji', emoji))..add(DiagnosticsProperty('ingredients', ingredients))..add(DiagnosticsProperty('requiredIngredientsCount', requiredIngredientsCount))..add(DiagnosticsProperty('availableIngredientsCount', availableIngredientsCount))..add(DiagnosticsProperty('usesExpiringItems', usesExpiringItems));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Recipe&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&const DeepCollectionEquality().equals(other.ingredients, ingredients)&&(identical(other.requiredIngredientsCount, requiredIngredientsCount) || other.requiredIngredientsCount == requiredIngredientsCount)&&(identical(other.availableIngredientsCount, availableIngredientsCount) || other.availableIngredientsCount == availableIngredientsCount)&&(identical(other.usesExpiringItems, usesExpiringItems) || other.usesExpiringItems == usesExpiringItems));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,imageUrl,emoji,const DeepCollectionEquality().hash(ingredients),requiredIngredientsCount,availableIngredientsCount,usesExpiringItems);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'Recipe(id: $id, name: $name, description: $description, imageUrl: $imageUrl, emoji: $emoji, ingredients: $ingredients, requiredIngredientsCount: $requiredIngredientsCount, availableIngredientsCount: $availableIngredientsCount, usesExpiringItems: $usesExpiringItems)';
}


}

/// @nodoc
abstract mixin class $RecipeCopyWith<$Res>  {
  factory $RecipeCopyWith(Recipe value, $Res Function(Recipe) _then) = _$RecipeCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String? imageUrl, String emoji, List<String> ingredients, int? requiredIngredientsCount, int? availableIngredientsCount, bool usesExpiringItems
});




}
/// @nodoc
class _$RecipeCopyWithImpl<$Res>
    implements $RecipeCopyWith<$Res> {
  _$RecipeCopyWithImpl(this._self, this._then);

  final Recipe _self;
  final $Res Function(Recipe) _then;

/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? imageUrl = freezed,Object? emoji = null,Object? ingredients = null,Object? requiredIngredientsCount = freezed,Object? availableIngredientsCount = freezed,Object? usesExpiringItems = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,ingredients: null == ingredients ? _self.ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<String>,requiredIngredientsCount: freezed == requiredIngredientsCount ? _self.requiredIngredientsCount : requiredIngredientsCount // ignore: cast_nullable_to_non_nullable
as int?,availableIngredientsCount: freezed == availableIngredientsCount ? _self.availableIngredientsCount : availableIngredientsCount // ignore: cast_nullable_to_non_nullable
as int?,usesExpiringItems: null == usesExpiringItems ? _self.usesExpiringItems : usesExpiringItems // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc


class _Recipe with DiagnosticableTreeMixin implements Recipe {
  const _Recipe({required this.id, required this.name, required this.description, this.imageUrl, this.emoji = '🍲', required final  List<String> ingredients, this.requiredIngredientsCount, this.availableIngredientsCount, this.usesExpiringItems = false}): _ingredients = ingredients;
  

@override final  String id;
@override final  String name;
@override final  String description;
@override final  String? imageUrl;
@override@JsonKey() final  String emoji;
 final  List<String> _ingredients;
@override List<String> get ingredients {
  if (_ingredients is EqualUnmodifiableListView) return _ingredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ingredients);
}

// List of ingredient names or IDs
// Smart mode specific fields (might be null in explore mode)
@override final  int? requiredIngredientsCount;
@override final  int? availableIngredientsCount;
@override@JsonKey() final  bool usesExpiringItems;

/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeCopyWith<_Recipe> get copyWith => __$RecipeCopyWithImpl<_Recipe>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'Recipe'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('description', description))..add(DiagnosticsProperty('imageUrl', imageUrl))..add(DiagnosticsProperty('emoji', emoji))..add(DiagnosticsProperty('ingredients', ingredients))..add(DiagnosticsProperty('requiredIngredientsCount', requiredIngredientsCount))..add(DiagnosticsProperty('availableIngredientsCount', availableIngredientsCount))..add(DiagnosticsProperty('usesExpiringItems', usesExpiringItems));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Recipe&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&const DeepCollectionEquality().equals(other._ingredients, _ingredients)&&(identical(other.requiredIngredientsCount, requiredIngredientsCount) || other.requiredIngredientsCount == requiredIngredientsCount)&&(identical(other.availableIngredientsCount, availableIngredientsCount) || other.availableIngredientsCount == availableIngredientsCount)&&(identical(other.usesExpiringItems, usesExpiringItems) || other.usesExpiringItems == usesExpiringItems));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,imageUrl,emoji,const DeepCollectionEquality().hash(_ingredients),requiredIngredientsCount,availableIngredientsCount,usesExpiringItems);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'Recipe(id: $id, name: $name, description: $description, imageUrl: $imageUrl, emoji: $emoji, ingredients: $ingredients, requiredIngredientsCount: $requiredIngredientsCount, availableIngredientsCount: $availableIngredientsCount, usesExpiringItems: $usesExpiringItems)';
}


}

/// @nodoc
abstract mixin class _$RecipeCopyWith<$Res> implements $RecipeCopyWith<$Res> {
  factory _$RecipeCopyWith(_Recipe value, $Res Function(_Recipe) _then) = __$RecipeCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String? imageUrl, String emoji, List<String> ingredients, int? requiredIngredientsCount, int? availableIngredientsCount, bool usesExpiringItems
});




}
/// @nodoc
class __$RecipeCopyWithImpl<$Res>
    implements _$RecipeCopyWith<$Res> {
  __$RecipeCopyWithImpl(this._self, this._then);

  final _Recipe _self;
  final $Res Function(_Recipe) _then;

/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? imageUrl = freezed,Object? emoji = null,Object? ingredients = null,Object? requiredIngredientsCount = freezed,Object? availableIngredientsCount = freezed,Object? usesExpiringItems = null,}) {
  return _then(_Recipe(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,ingredients: null == ingredients ? _self._ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<String>,requiredIngredientsCount: freezed == requiredIngredientsCount ? _self.requiredIngredientsCount : requiredIngredientsCount // ignore: cast_nullable_to_non_nullable
as int?,availableIngredientsCount: freezed == availableIngredientsCount ? _self.availableIngredientsCount : availableIngredientsCount // ignore: cast_nullable_to_non_nullable
as int?,usesExpiringItems: null == usesExpiringItems ? _self.usesExpiringItems : usesExpiringItems // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$RecipeState implements DiagnosticableTreeMixin {

 bool get isLoading; List<Recipe> get recipes; List<Recipe> get allRecipes; String? get errorMessage;// Smart mode specific
 int? get expiringIngredientsUsedCount;// Explore mode specific
 String get searchQuery; bool get showOnlyWithMyIngredients;// Map of category value to Set of selected filter values
 Map<String, Set<String>> get selectedFilters;// ✅ RESOLVED: Comprehensive filter criteria already implemented:
// - Recipe type, preparation time, difficulty, diet type, sustainability
// - Sorting by name, cooking time, difficulty (in favorite_recipes_provider.dart)
// - Search functionality, category filtering, ingredient availability toggle
// Cache and source tracking
 bool get hasLoadedCache; Map<String, DateTime> get lastGeneratedAt; Map<String, String> get recipeSource;
/// Create a copy of RecipeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeStateCopyWith<RecipeState> get copyWith => _$RecipeStateCopyWithImpl<RecipeState>(this as RecipeState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'RecipeState'))
    ..add(DiagnosticsProperty('isLoading', isLoading))..add(DiagnosticsProperty('recipes', recipes))..add(DiagnosticsProperty('allRecipes', allRecipes))..add(DiagnosticsProperty('errorMessage', errorMessage))..add(DiagnosticsProperty('expiringIngredientsUsedCount', expiringIngredientsUsedCount))..add(DiagnosticsProperty('searchQuery', searchQuery))..add(DiagnosticsProperty('showOnlyWithMyIngredients', showOnlyWithMyIngredients))..add(DiagnosticsProperty('selectedFilters', selectedFilters))..add(DiagnosticsProperty('hasLoadedCache', hasLoadedCache))..add(DiagnosticsProperty('lastGeneratedAt', lastGeneratedAt))..add(DiagnosticsProperty('recipeSource', recipeSource));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipeState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.recipes, recipes)&&const DeepCollectionEquality().equals(other.allRecipes, allRecipes)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.expiringIngredientsUsedCount, expiringIngredientsUsedCount) || other.expiringIngredientsUsedCount == expiringIngredientsUsedCount)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.showOnlyWithMyIngredients, showOnlyWithMyIngredients) || other.showOnlyWithMyIngredients == showOnlyWithMyIngredients)&&const DeepCollectionEquality().equals(other.selectedFilters, selectedFilters)&&(identical(other.hasLoadedCache, hasLoadedCache) || other.hasLoadedCache == hasLoadedCache)&&const DeepCollectionEquality().equals(other.lastGeneratedAt, lastGeneratedAt)&&const DeepCollectionEquality().equals(other.recipeSource, recipeSource));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(recipes),const DeepCollectionEquality().hash(allRecipes),errorMessage,expiringIngredientsUsedCount,searchQuery,showOnlyWithMyIngredients,const DeepCollectionEquality().hash(selectedFilters),hasLoadedCache,const DeepCollectionEquality().hash(lastGeneratedAt),const DeepCollectionEquality().hash(recipeSource));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'RecipeState(isLoading: $isLoading, recipes: $recipes, allRecipes: $allRecipes, errorMessage: $errorMessage, expiringIngredientsUsedCount: $expiringIngredientsUsedCount, searchQuery: $searchQuery, showOnlyWithMyIngredients: $showOnlyWithMyIngredients, selectedFilters: $selectedFilters, hasLoadedCache: $hasLoadedCache, lastGeneratedAt: $lastGeneratedAt, recipeSource: $recipeSource)';
}


}

/// @nodoc
abstract mixin class $RecipeStateCopyWith<$Res>  {
  factory $RecipeStateCopyWith(RecipeState value, $Res Function(RecipeState) _then) = _$RecipeStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, List<Recipe> recipes, List<Recipe> allRecipes, String? errorMessage, int? expiringIngredientsUsedCount, String searchQuery, bool showOnlyWithMyIngredients, Map<String, Set<String>> selectedFilters, bool hasLoadedCache, Map<String, DateTime> lastGeneratedAt, Map<String, String> recipeSource
});




}
/// @nodoc
class _$RecipeStateCopyWithImpl<$Res>
    implements $RecipeStateCopyWith<$Res> {
  _$RecipeStateCopyWithImpl(this._self, this._then);

  final RecipeState _self;
  final $Res Function(RecipeState) _then;

/// Create a copy of RecipeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? recipes = null,Object? allRecipes = null,Object? errorMessage = freezed,Object? expiringIngredientsUsedCount = freezed,Object? searchQuery = null,Object? showOnlyWithMyIngredients = null,Object? selectedFilters = null,Object? hasLoadedCache = null,Object? lastGeneratedAt = null,Object? recipeSource = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,recipes: null == recipes ? _self.recipes : recipes // ignore: cast_nullable_to_non_nullable
as List<Recipe>,allRecipes: null == allRecipes ? _self.allRecipes : allRecipes // ignore: cast_nullable_to_non_nullable
as List<Recipe>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,expiringIngredientsUsedCount: freezed == expiringIngredientsUsedCount ? _self.expiringIngredientsUsedCount : expiringIngredientsUsedCount // ignore: cast_nullable_to_non_nullable
as int?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,showOnlyWithMyIngredients: null == showOnlyWithMyIngredients ? _self.showOnlyWithMyIngredients : showOnlyWithMyIngredients // ignore: cast_nullable_to_non_nullable
as bool,selectedFilters: null == selectedFilters ? _self.selectedFilters : selectedFilters // ignore: cast_nullable_to_non_nullable
as Map<String, Set<String>>,hasLoadedCache: null == hasLoadedCache ? _self.hasLoadedCache : hasLoadedCache // ignore: cast_nullable_to_non_nullable
as bool,lastGeneratedAt: null == lastGeneratedAt ? _self.lastGeneratedAt : lastGeneratedAt // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,recipeSource: null == recipeSource ? _self.recipeSource : recipeSource // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// @nodoc


class _RecipeState extends RecipeState with DiagnosticableTreeMixin {
  const _RecipeState({this.isLoading = false, final  List<Recipe> recipes = const [], final  List<Recipe> allRecipes = const [], this.errorMessage, this.expiringIngredientsUsedCount, this.searchQuery = '', this.showOnlyWithMyIngredients = false, final  Map<String, Set<String>> selectedFilters = const {}, this.hasLoadedCache = false, final  Map<String, DateTime> lastGeneratedAt = const {}, final  Map<String, String> recipeSource = const {}}): _recipes = recipes,_allRecipes = allRecipes,_selectedFilters = selectedFilters,_lastGeneratedAt = lastGeneratedAt,_recipeSource = recipeSource,super._();
  

@override@JsonKey() final  bool isLoading;
 final  List<Recipe> _recipes;
@override@JsonKey() List<Recipe> get recipes {
  if (_recipes is EqualUnmodifiableListView) return _recipes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recipes);
}

 final  List<Recipe> _allRecipes;
@override@JsonKey() List<Recipe> get allRecipes {
  if (_allRecipes is EqualUnmodifiableListView) return _allRecipes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allRecipes);
}

@override final  String? errorMessage;
// Smart mode specific
@override final  int? expiringIngredientsUsedCount;
// Explore mode specific
@override@JsonKey() final  String searchQuery;
@override@JsonKey() final  bool showOnlyWithMyIngredients;
// Map of category value to Set of selected filter values
 final  Map<String, Set<String>> _selectedFilters;
// Map of category value to Set of selected filter values
@override@JsonKey() Map<String, Set<String>> get selectedFilters {
  if (_selectedFilters is EqualUnmodifiableMapView) return _selectedFilters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_selectedFilters);
}

// ✅ RESOLVED: Comprehensive filter criteria already implemented:
// - Recipe type, preparation time, difficulty, diet type, sustainability
// - Sorting by name, cooking time, difficulty (in favorite_recipes_provider.dart)
// - Search functionality, category filtering, ingredient availability toggle
// Cache and source tracking
@override@JsonKey() final  bool hasLoadedCache;
 final  Map<String, DateTime> _lastGeneratedAt;
@override@JsonKey() Map<String, DateTime> get lastGeneratedAt {
  if (_lastGeneratedAt is EqualUnmodifiableMapView) return _lastGeneratedAt;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_lastGeneratedAt);
}

 final  Map<String, String> _recipeSource;
@override@JsonKey() Map<String, String> get recipeSource {
  if (_recipeSource is EqualUnmodifiableMapView) return _recipeSource;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_recipeSource);
}


/// Create a copy of RecipeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeStateCopyWith<_RecipeState> get copyWith => __$RecipeStateCopyWithImpl<_RecipeState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'RecipeState'))
    ..add(DiagnosticsProperty('isLoading', isLoading))..add(DiagnosticsProperty('recipes', recipes))..add(DiagnosticsProperty('allRecipes', allRecipes))..add(DiagnosticsProperty('errorMessage', errorMessage))..add(DiagnosticsProperty('expiringIngredientsUsedCount', expiringIngredientsUsedCount))..add(DiagnosticsProperty('searchQuery', searchQuery))..add(DiagnosticsProperty('showOnlyWithMyIngredients', showOnlyWithMyIngredients))..add(DiagnosticsProperty('selectedFilters', selectedFilters))..add(DiagnosticsProperty('hasLoadedCache', hasLoadedCache))..add(DiagnosticsProperty('lastGeneratedAt', lastGeneratedAt))..add(DiagnosticsProperty('recipeSource', recipeSource));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipeState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other._recipes, _recipes)&&const DeepCollectionEquality().equals(other._allRecipes, _allRecipes)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.expiringIngredientsUsedCount, expiringIngredientsUsedCount) || other.expiringIngredientsUsedCount == expiringIngredientsUsedCount)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.showOnlyWithMyIngredients, showOnlyWithMyIngredients) || other.showOnlyWithMyIngredients == showOnlyWithMyIngredients)&&const DeepCollectionEquality().equals(other._selectedFilters, _selectedFilters)&&(identical(other.hasLoadedCache, hasLoadedCache) || other.hasLoadedCache == hasLoadedCache)&&const DeepCollectionEquality().equals(other._lastGeneratedAt, _lastGeneratedAt)&&const DeepCollectionEquality().equals(other._recipeSource, _recipeSource));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(_recipes),const DeepCollectionEquality().hash(_allRecipes),errorMessage,expiringIngredientsUsedCount,searchQuery,showOnlyWithMyIngredients,const DeepCollectionEquality().hash(_selectedFilters),hasLoadedCache,const DeepCollectionEquality().hash(_lastGeneratedAt),const DeepCollectionEquality().hash(_recipeSource));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'RecipeState(isLoading: $isLoading, recipes: $recipes, allRecipes: $allRecipes, errorMessage: $errorMessage, expiringIngredientsUsedCount: $expiringIngredientsUsedCount, searchQuery: $searchQuery, showOnlyWithMyIngredients: $showOnlyWithMyIngredients, selectedFilters: $selectedFilters, hasLoadedCache: $hasLoadedCache, lastGeneratedAt: $lastGeneratedAt, recipeSource: $recipeSource)';
}


}

/// @nodoc
abstract mixin class _$RecipeStateCopyWith<$Res> implements $RecipeStateCopyWith<$Res> {
  factory _$RecipeStateCopyWith(_RecipeState value, $Res Function(_RecipeState) _then) = __$RecipeStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, List<Recipe> recipes, List<Recipe> allRecipes, String? errorMessage, int? expiringIngredientsUsedCount, String searchQuery, bool showOnlyWithMyIngredients, Map<String, Set<String>> selectedFilters, bool hasLoadedCache, Map<String, DateTime> lastGeneratedAt, Map<String, String> recipeSource
});




}
/// @nodoc
class __$RecipeStateCopyWithImpl<$Res>
    implements _$RecipeStateCopyWith<$Res> {
  __$RecipeStateCopyWithImpl(this._self, this._then);

  final _RecipeState _self;
  final $Res Function(_RecipeState) _then;

/// Create a copy of RecipeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? recipes = null,Object? allRecipes = null,Object? errorMessage = freezed,Object? expiringIngredientsUsedCount = freezed,Object? searchQuery = null,Object? showOnlyWithMyIngredients = null,Object? selectedFilters = null,Object? hasLoadedCache = null,Object? lastGeneratedAt = null,Object? recipeSource = null,}) {
  return _then(_RecipeState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,recipes: null == recipes ? _self._recipes : recipes // ignore: cast_nullable_to_non_nullable
as List<Recipe>,allRecipes: null == allRecipes ? _self._allRecipes : allRecipes // ignore: cast_nullable_to_non_nullable
as List<Recipe>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,expiringIngredientsUsedCount: freezed == expiringIngredientsUsedCount ? _self.expiringIngredientsUsedCount : expiringIngredientsUsedCount // ignore: cast_nullable_to_non_nullable
as int?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,showOnlyWithMyIngredients: null == showOnlyWithMyIngredients ? _self.showOnlyWithMyIngredients : showOnlyWithMyIngredients // ignore: cast_nullable_to_non_nullable
as bool,selectedFilters: null == selectedFilters ? _self._selectedFilters : selectedFilters // ignore: cast_nullable_to_non_nullable
as Map<String, Set<String>>,hasLoadedCache: null == hasLoadedCache ? _self.hasLoadedCache : hasLoadedCache // ignore: cast_nullable_to_non_nullable
as bool,lastGeneratedAt: null == lastGeneratedAt ? _self._lastGeneratedAt : lastGeneratedAt // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,recipeSource: null == recipeSource ? _self._recipeSource : recipeSource // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
