// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Recipe {

 String get id; String get name; String get description; String? get imageUrl; String get emoji; List<String> get ingredients; List<String> get instructions; int? get requiredIngredientsCount; int? get availableIngredientsCount; bool get usesExpiringItems; int get cookingTime; String get difficulty; String get dietType; List<String> get categories; int get servings; Map<String, String> get nutrients; List<String> get tags;
/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeCopyWith<Recipe> get copyWith => _$RecipeCopyWithImpl<Recipe>(this as Recipe, _$identity);

  /// Serializes this Recipe to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Recipe&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&const DeepCollectionEquality().equals(other.ingredients, ingredients)&&const DeepCollectionEquality().equals(other.instructions, instructions)&&(identical(other.requiredIngredientsCount, requiredIngredientsCount) || other.requiredIngredientsCount == requiredIngredientsCount)&&(identical(other.availableIngredientsCount, availableIngredientsCount) || other.availableIngredientsCount == availableIngredientsCount)&&(identical(other.usesExpiringItems, usesExpiringItems) || other.usesExpiringItems == usesExpiringItems)&&(identical(other.cookingTime, cookingTime) || other.cookingTime == cookingTime)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.dietType, dietType) || other.dietType == dietType)&&const DeepCollectionEquality().equals(other.categories, categories)&&(identical(other.servings, servings) || other.servings == servings)&&const DeepCollectionEquality().equals(other.nutrients, nutrients)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,imageUrl,emoji,const DeepCollectionEquality().hash(ingredients),const DeepCollectionEquality().hash(instructions),requiredIngredientsCount,availableIngredientsCount,usesExpiringItems,cookingTime,difficulty,dietType,const DeepCollectionEquality().hash(categories),servings,const DeepCollectionEquality().hash(nutrients),const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'Recipe(id: $id, name: $name, description: $description, imageUrl: $imageUrl, emoji: $emoji, ingredients: $ingredients, instructions: $instructions, requiredIngredientsCount: $requiredIngredientsCount, availableIngredientsCount: $availableIngredientsCount, usesExpiringItems: $usesExpiringItems, cookingTime: $cookingTime, difficulty: $difficulty, dietType: $dietType, categories: $categories, servings: $servings, nutrients: $nutrients, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $RecipeCopyWith<$Res>  {
  factory $RecipeCopyWith(Recipe value, $Res Function(Recipe) _then) = _$RecipeCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String? imageUrl, String emoji, List<String> ingredients, List<String> instructions, int? requiredIngredientsCount, int? availableIngredientsCount, bool usesExpiringItems, int cookingTime, String difficulty, String dietType, List<String> categories, int servings, Map<String, String> nutrients, List<String> tags
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? imageUrl = freezed,Object? emoji = null,Object? ingredients = null,Object? instructions = null,Object? requiredIngredientsCount = freezed,Object? availableIngredientsCount = freezed,Object? usesExpiringItems = null,Object? cookingTime = null,Object? difficulty = null,Object? dietType = null,Object? categories = null,Object? servings = null,Object? nutrients = null,Object? tags = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,ingredients: null == ingredients ? _self.ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<String>,instructions: null == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as List<String>,requiredIngredientsCount: freezed == requiredIngredientsCount ? _self.requiredIngredientsCount : requiredIngredientsCount // ignore: cast_nullable_to_non_nullable
as int?,availableIngredientsCount: freezed == availableIngredientsCount ? _self.availableIngredientsCount : availableIngredientsCount // ignore: cast_nullable_to_non_nullable
as int?,usesExpiringItems: null == usesExpiringItems ? _self.usesExpiringItems : usesExpiringItems // ignore: cast_nullable_to_non_nullable
as bool,cookingTime: null == cookingTime ? _self.cookingTime : cookingTime // ignore: cast_nullable_to_non_nullable
as int,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,dietType: null == dietType ? _self.dietType : dietType // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,servings: null == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as int,nutrients: null == nutrients ? _self.nutrients : nutrients // ignore: cast_nullable_to_non_nullable
as Map<String, String>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Recipe extends Recipe {
  const _Recipe({required this.id, required this.name, required this.description, this.imageUrl, this.emoji = '🍲', required final  List<String> ingredients, final  List<String> instructions = const [], this.requiredIngredientsCount, this.availableIngredientsCount, this.usesExpiringItems = false, this.cookingTime = 30, this.difficulty = 'Medio', this.dietType = 'Omnívora', final  List<String> categories = const ['General'], this.servings = 2, final  Map<String, String> nutrients = const {}, final  List<String> tags = const []}): _ingredients = ingredients,_instructions = instructions,_categories = categories,_nutrients = nutrients,_tags = tags,super._();
  factory _Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

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

 final  List<String> _instructions;
@override@JsonKey() List<String> get instructions {
  if (_instructions is EqualUnmodifiableListView) return _instructions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_instructions);
}

@override final  int? requiredIngredientsCount;
@override final  int? availableIngredientsCount;
@override@JsonKey() final  bool usesExpiringItems;
@override@JsonKey() final  int cookingTime;
@override@JsonKey() final  String difficulty;
@override@JsonKey() final  String dietType;
 final  List<String> _categories;
@override@JsonKey() List<String> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

@override@JsonKey() final  int servings;
 final  Map<String, String> _nutrients;
@override@JsonKey() Map<String, String> get nutrients {
  if (_nutrients is EqualUnmodifiableMapView) return _nutrients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_nutrients);
}

 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeCopyWith<_Recipe> get copyWith => __$RecipeCopyWithImpl<_Recipe>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Recipe&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&const DeepCollectionEquality().equals(other._ingredients, _ingredients)&&const DeepCollectionEquality().equals(other._instructions, _instructions)&&(identical(other.requiredIngredientsCount, requiredIngredientsCount) || other.requiredIngredientsCount == requiredIngredientsCount)&&(identical(other.availableIngredientsCount, availableIngredientsCount) || other.availableIngredientsCount == availableIngredientsCount)&&(identical(other.usesExpiringItems, usesExpiringItems) || other.usesExpiringItems == usesExpiringItems)&&(identical(other.cookingTime, cookingTime) || other.cookingTime == cookingTime)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.dietType, dietType) || other.dietType == dietType)&&const DeepCollectionEquality().equals(other._categories, _categories)&&(identical(other.servings, servings) || other.servings == servings)&&const DeepCollectionEquality().equals(other._nutrients, _nutrients)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,imageUrl,emoji,const DeepCollectionEquality().hash(_ingredients),const DeepCollectionEquality().hash(_instructions),requiredIngredientsCount,availableIngredientsCount,usesExpiringItems,cookingTime,difficulty,dietType,const DeepCollectionEquality().hash(_categories),servings,const DeepCollectionEquality().hash(_nutrients),const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'Recipe(id: $id, name: $name, description: $description, imageUrl: $imageUrl, emoji: $emoji, ingredients: $ingredients, instructions: $instructions, requiredIngredientsCount: $requiredIngredientsCount, availableIngredientsCount: $availableIngredientsCount, usesExpiringItems: $usesExpiringItems, cookingTime: $cookingTime, difficulty: $difficulty, dietType: $dietType, categories: $categories, servings: $servings, nutrients: $nutrients, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$RecipeCopyWith<$Res> implements $RecipeCopyWith<$Res> {
  factory _$RecipeCopyWith(_Recipe value, $Res Function(_Recipe) _then) = __$RecipeCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String? imageUrl, String emoji, List<String> ingredients, List<String> instructions, int? requiredIngredientsCount, int? availableIngredientsCount, bool usesExpiringItems, int cookingTime, String difficulty, String dietType, List<String> categories, int servings, Map<String, String> nutrients, List<String> tags
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? imageUrl = freezed,Object? emoji = null,Object? ingredients = null,Object? instructions = null,Object? requiredIngredientsCount = freezed,Object? availableIngredientsCount = freezed,Object? usesExpiringItems = null,Object? cookingTime = null,Object? difficulty = null,Object? dietType = null,Object? categories = null,Object? servings = null,Object? nutrients = null,Object? tags = null,}) {
  return _then(_Recipe(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,ingredients: null == ingredients ? _self._ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<String>,instructions: null == instructions ? _self._instructions : instructions // ignore: cast_nullable_to_non_nullable
as List<String>,requiredIngredientsCount: freezed == requiredIngredientsCount ? _self.requiredIngredientsCount : requiredIngredientsCount // ignore: cast_nullable_to_non_nullable
as int?,availableIngredientsCount: freezed == availableIngredientsCount ? _self.availableIngredientsCount : availableIngredientsCount // ignore: cast_nullable_to_non_nullable
as int?,usesExpiringItems: null == usesExpiringItems ? _self.usesExpiringItems : usesExpiringItems // ignore: cast_nullable_to_non_nullable
as bool,cookingTime: null == cookingTime ? _self.cookingTime : cookingTime // ignore: cast_nullable_to_non_nullable
as int,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,dietType: null == dietType ? _self.dietType : dietType // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,servings: null == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as int,nutrients: null == nutrients ? _self._nutrients : nutrients // ignore: cast_nullable_to_non_nullable
as Map<String, String>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
