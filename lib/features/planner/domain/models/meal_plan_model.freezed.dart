// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_plan_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MealPlan {

 String get id; DateTime get date; Map<String, PlannedMeal> get meals; DateTime get createdAt; DateTime get updatedAt; NutritionalSummary get nutritionalSummary;
/// Create a copy of MealPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MealPlanCopyWith<MealPlan> get copyWith => _$MealPlanCopyWithImpl<MealPlan>(this as MealPlan, _$identity);

  /// Serializes this MealPlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MealPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.meals, meals)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.nutritionalSummary, nutritionalSummary) || other.nutritionalSummary == nutritionalSummary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,const DeepCollectionEquality().hash(meals),createdAt,updatedAt,nutritionalSummary);

@override
String toString() {
  return 'MealPlan(id: $id, date: $date, meals: $meals, createdAt: $createdAt, updatedAt: $updatedAt, nutritionalSummary: $nutritionalSummary)';
}


}

/// @nodoc
abstract mixin class $MealPlanCopyWith<$Res>  {
  factory $MealPlanCopyWith(MealPlan value, $Res Function(MealPlan) _then) = _$MealPlanCopyWithImpl;
@useResult
$Res call({
 String id, DateTime date, Map<String, PlannedMeal> meals, DateTime createdAt, DateTime updatedAt, NutritionalSummary nutritionalSummary
});


$NutritionalSummaryCopyWith<$Res> get nutritionalSummary;

}
/// @nodoc
class _$MealPlanCopyWithImpl<$Res>
    implements $MealPlanCopyWith<$Res> {
  _$MealPlanCopyWithImpl(this._self, this._then);

  final MealPlan _self;
  final $Res Function(MealPlan) _then;

/// Create a copy of MealPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? meals = null,Object? createdAt = null,Object? updatedAt = null,Object? nutritionalSummary = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,meals: null == meals ? _self.meals : meals // ignore: cast_nullable_to_non_nullable
as Map<String, PlannedMeal>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,nutritionalSummary: null == nutritionalSummary ? _self.nutritionalSummary : nutritionalSummary // ignore: cast_nullable_to_non_nullable
as NutritionalSummary,
  ));
}
/// Create a copy of MealPlan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionalSummaryCopyWith<$Res> get nutritionalSummary {
  
  return $NutritionalSummaryCopyWith<$Res>(_self.nutritionalSummary, (value) {
    return _then(_self.copyWith(nutritionalSummary: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _MealPlan implements MealPlan {
  const _MealPlan({required this.id, required this.date, required final  Map<String, PlannedMeal> meals, required this.createdAt, required this.updatedAt, required this.nutritionalSummary}): _meals = meals;
  factory _MealPlan.fromJson(Map<String, dynamic> json) => _$MealPlanFromJson(json);

@override final  String id;
@override final  DateTime date;
 final  Map<String, PlannedMeal> _meals;
@override Map<String, PlannedMeal> get meals {
  if (_meals is EqualUnmodifiableMapView) return _meals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_meals);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  NutritionalSummary nutritionalSummary;

/// Create a copy of MealPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MealPlanCopyWith<_MealPlan> get copyWith => __$MealPlanCopyWithImpl<_MealPlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MealPlanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MealPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other._meals, _meals)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.nutritionalSummary, nutritionalSummary) || other.nutritionalSummary == nutritionalSummary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,const DeepCollectionEquality().hash(_meals),createdAt,updatedAt,nutritionalSummary);

@override
String toString() {
  return 'MealPlan(id: $id, date: $date, meals: $meals, createdAt: $createdAt, updatedAt: $updatedAt, nutritionalSummary: $nutritionalSummary)';
}


}

/// @nodoc
abstract mixin class _$MealPlanCopyWith<$Res> implements $MealPlanCopyWith<$Res> {
  factory _$MealPlanCopyWith(_MealPlan value, $Res Function(_MealPlan) _then) = __$MealPlanCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime date, Map<String, PlannedMeal> meals, DateTime createdAt, DateTime updatedAt, NutritionalSummary nutritionalSummary
});


@override $NutritionalSummaryCopyWith<$Res> get nutritionalSummary;

}
/// @nodoc
class __$MealPlanCopyWithImpl<$Res>
    implements _$MealPlanCopyWith<$Res> {
  __$MealPlanCopyWithImpl(this._self, this._then);

  final _MealPlan _self;
  final $Res Function(_MealPlan) _then;

/// Create a copy of MealPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? meals = null,Object? createdAt = null,Object? updatedAt = null,Object? nutritionalSummary = null,}) {
  return _then(_MealPlan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,meals: null == meals ? _self._meals : meals // ignore: cast_nullable_to_non_nullable
as Map<String, PlannedMeal>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,nutritionalSummary: null == nutritionalSummary ? _self.nutritionalSummary : nutritionalSummary // ignore: cast_nullable_to_non_nullable
as NutritionalSummary,
  ));
}

/// Create a copy of MealPlan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionalSummaryCopyWith<$Res> get nutritionalSummary {
  
  return $NutritionalSummaryCopyWith<$Res>(_self.nutritionalSummary, (value) {
    return _then(_self.copyWith(nutritionalSummary: value));
  });
}
}


/// @nodoc
mixin _$PlannedMeal {

 String get recipeId; int get servings; String? get notes; Map<String, String>? get modifications; MealType get type; MealStatus get status; DateTime? get preparedAt; Map<String, dynamic>? get impactData;
/// Create a copy of PlannedMeal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlannedMealCopyWith<PlannedMeal> get copyWith => _$PlannedMealCopyWithImpl<PlannedMeal>(this as PlannedMeal, _$identity);

  /// Serializes this PlannedMeal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlannedMeal&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.servings, servings) || other.servings == servings)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.modifications, modifications)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.preparedAt, preparedAt) || other.preparedAt == preparedAt)&&const DeepCollectionEquality().equals(other.impactData, impactData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recipeId,servings,notes,const DeepCollectionEquality().hash(modifications),type,status,preparedAt,const DeepCollectionEquality().hash(impactData));

@override
String toString() {
  return 'PlannedMeal(recipeId: $recipeId, servings: $servings, notes: $notes, modifications: $modifications, type: $type, status: $status, preparedAt: $preparedAt, impactData: $impactData)';
}


}

/// @nodoc
abstract mixin class $PlannedMealCopyWith<$Res>  {
  factory $PlannedMealCopyWith(PlannedMeal value, $Res Function(PlannedMeal) _then) = _$PlannedMealCopyWithImpl;
@useResult
$Res call({
 String recipeId, int servings, String? notes, Map<String, String>? modifications, MealType type, MealStatus status, DateTime? preparedAt, Map<String, dynamic>? impactData
});




}
/// @nodoc
class _$PlannedMealCopyWithImpl<$Res>
    implements $PlannedMealCopyWith<$Res> {
  _$PlannedMealCopyWithImpl(this._self, this._then);

  final PlannedMeal _self;
  final $Res Function(PlannedMeal) _then;

/// Create a copy of PlannedMeal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recipeId = null,Object? servings = null,Object? notes = freezed,Object? modifications = freezed,Object? type = null,Object? status = null,Object? preparedAt = freezed,Object? impactData = freezed,}) {
  return _then(_self.copyWith(
recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,servings: null == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,modifications: freezed == modifications ? _self.modifications : modifications // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MealType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MealStatus,preparedAt: freezed == preparedAt ? _self.preparedAt : preparedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,impactData: freezed == impactData ? _self.impactData : impactData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _PlannedMeal implements PlannedMeal {
  const _PlannedMeal({required this.recipeId, required this.servings, this.notes, final  Map<String, String>? modifications, required this.type, this.status = MealStatus.planned, this.preparedAt, final  Map<String, dynamic>? impactData}): _modifications = modifications,_impactData = impactData;
  factory _PlannedMeal.fromJson(Map<String, dynamic> json) => _$PlannedMealFromJson(json);

@override final  String recipeId;
@override final  int servings;
@override final  String? notes;
 final  Map<String, String>? _modifications;
@override Map<String, String>? get modifications {
  final value = _modifications;
  if (value == null) return null;
  if (_modifications is EqualUnmodifiableMapView) return _modifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  MealType type;
@override@JsonKey() final  MealStatus status;
@override final  DateTime? preparedAt;
 final  Map<String, dynamic>? _impactData;
@override Map<String, dynamic>? get impactData {
  final value = _impactData;
  if (value == null) return null;
  if (_impactData is EqualUnmodifiableMapView) return _impactData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of PlannedMeal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlannedMealCopyWith<_PlannedMeal> get copyWith => __$PlannedMealCopyWithImpl<_PlannedMeal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlannedMealToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlannedMeal&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.servings, servings) || other.servings == servings)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._modifications, _modifications)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.preparedAt, preparedAt) || other.preparedAt == preparedAt)&&const DeepCollectionEquality().equals(other._impactData, _impactData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recipeId,servings,notes,const DeepCollectionEquality().hash(_modifications),type,status,preparedAt,const DeepCollectionEquality().hash(_impactData));

@override
String toString() {
  return 'PlannedMeal(recipeId: $recipeId, servings: $servings, notes: $notes, modifications: $modifications, type: $type, status: $status, preparedAt: $preparedAt, impactData: $impactData)';
}


}

/// @nodoc
abstract mixin class _$PlannedMealCopyWith<$Res> implements $PlannedMealCopyWith<$Res> {
  factory _$PlannedMealCopyWith(_PlannedMeal value, $Res Function(_PlannedMeal) _then) = __$PlannedMealCopyWithImpl;
@override @useResult
$Res call({
 String recipeId, int servings, String? notes, Map<String, String>? modifications, MealType type, MealStatus status, DateTime? preparedAt, Map<String, dynamic>? impactData
});




}
/// @nodoc
class __$PlannedMealCopyWithImpl<$Res>
    implements _$PlannedMealCopyWith<$Res> {
  __$PlannedMealCopyWithImpl(this._self, this._then);

  final _PlannedMeal _self;
  final $Res Function(_PlannedMeal) _then;

/// Create a copy of PlannedMeal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recipeId = null,Object? servings = null,Object? notes = freezed,Object? modifications = freezed,Object? type = null,Object? status = null,Object? preparedAt = freezed,Object? impactData = freezed,}) {
  return _then(_PlannedMeal(
recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,servings: null == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,modifications: freezed == modifications ? _self._modifications : modifications // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MealType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MealStatus,preparedAt: freezed == preparedAt ? _self.preparedAt : preparedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,impactData: freezed == impactData ? _self._impactData : impactData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$NutritionalSummary {

 double get calories; double get protein; double get carbs; double get fats; double get fiber; double get sugar;
/// Create a copy of NutritionalSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NutritionalSummaryCopyWith<NutritionalSummary> get copyWith => _$NutritionalSummaryCopyWithImpl<NutritionalSummary>(this as NutritionalSummary, _$identity);

  /// Serializes this NutritionalSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NutritionalSummary&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.fats, fats) || other.fats == fats)&&(identical(other.fiber, fiber) || other.fiber == fiber)&&(identical(other.sugar, sugar) || other.sugar == sugar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,calories,protein,carbs,fats,fiber,sugar);

@override
String toString() {
  return 'NutritionalSummary(calories: $calories, protein: $protein, carbs: $carbs, fats: $fats, fiber: $fiber, sugar: $sugar)';
}


}

/// @nodoc
abstract mixin class $NutritionalSummaryCopyWith<$Res>  {
  factory $NutritionalSummaryCopyWith(NutritionalSummary value, $Res Function(NutritionalSummary) _then) = _$NutritionalSummaryCopyWithImpl;
@useResult
$Res call({
 double calories, double protein, double carbs, double fats, double fiber, double sugar
});




}
/// @nodoc
class _$NutritionalSummaryCopyWithImpl<$Res>
    implements $NutritionalSummaryCopyWith<$Res> {
  _$NutritionalSummaryCopyWithImpl(this._self, this._then);

  final NutritionalSummary _self;
  final $Res Function(NutritionalSummary) _then;

/// Create a copy of NutritionalSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? calories = null,Object? protein = null,Object? carbs = null,Object? fats = null,Object? fiber = null,Object? sugar = null,}) {
  return _then(_self.copyWith(
calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as double,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as double,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as double,fats: null == fats ? _self.fats : fats // ignore: cast_nullable_to_non_nullable
as double,fiber: null == fiber ? _self.fiber : fiber // ignore: cast_nullable_to_non_nullable
as double,sugar: null == sugar ? _self.sugar : sugar // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _NutritionalSummary implements NutritionalSummary {
  const _NutritionalSummary({required this.calories, required this.protein, required this.carbs, required this.fats, required this.fiber, required this.sugar});
  factory _NutritionalSummary.fromJson(Map<String, dynamic> json) => _$NutritionalSummaryFromJson(json);

@override final  double calories;
@override final  double protein;
@override final  double carbs;
@override final  double fats;
@override final  double fiber;
@override final  double sugar;

/// Create a copy of NutritionalSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NutritionalSummaryCopyWith<_NutritionalSummary> get copyWith => __$NutritionalSummaryCopyWithImpl<_NutritionalSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NutritionalSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NutritionalSummary&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.fats, fats) || other.fats == fats)&&(identical(other.fiber, fiber) || other.fiber == fiber)&&(identical(other.sugar, sugar) || other.sugar == sugar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,calories,protein,carbs,fats,fiber,sugar);

@override
String toString() {
  return 'NutritionalSummary(calories: $calories, protein: $protein, carbs: $carbs, fats: $fats, fiber: $fiber, sugar: $sugar)';
}


}

/// @nodoc
abstract mixin class _$NutritionalSummaryCopyWith<$Res> implements $NutritionalSummaryCopyWith<$Res> {
  factory _$NutritionalSummaryCopyWith(_NutritionalSummary value, $Res Function(_NutritionalSummary) _then) = __$NutritionalSummaryCopyWithImpl;
@override @useResult
$Res call({
 double calories, double protein, double carbs, double fats, double fiber, double sugar
});




}
/// @nodoc
class __$NutritionalSummaryCopyWithImpl<$Res>
    implements _$NutritionalSummaryCopyWith<$Res> {
  __$NutritionalSummaryCopyWithImpl(this._self, this._then);

  final _NutritionalSummary _self;
  final $Res Function(_NutritionalSummary) _then;

/// Create a copy of NutritionalSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? calories = null,Object? protein = null,Object? carbs = null,Object? fats = null,Object? fiber = null,Object? sugar = null,}) {
  return _then(_NutritionalSummary(
calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as double,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as double,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as double,fats: null == fats ? _self.fats : fats // ignore: cast_nullable_to_non_nullable
as double,fiber: null == fiber ? _self.fiber : fiber // ignore: cast_nullable_to_non_nullable
as double,sugar: null == sugar ? _self.sugar : sugar // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
