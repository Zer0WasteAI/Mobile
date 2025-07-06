// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_preferences_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserPreferencesModel {

 String get language; String get measurementUnit; String? get cookingLevel; List<String> get allergies; List<Map<String, dynamic>> get allergyItems;// For more structured allergy data
 List<String> get specialDiets; List<Map<String, dynamic>> get specialDietItems;// For more structured diet data
 List<String> get preferredFoodTypes; List<Map<String, dynamic>> get preferredFoodTypeItems;
/// Create a copy of UserPreferencesModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserPreferencesModelCopyWith<UserPreferencesModel> get copyWith => _$UserPreferencesModelCopyWithImpl<UserPreferencesModel>(this as UserPreferencesModel, _$identity);

  /// Serializes this UserPreferencesModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserPreferencesModel&&(identical(other.language, language) || other.language == language)&&(identical(other.measurementUnit, measurementUnit) || other.measurementUnit == measurementUnit)&&(identical(other.cookingLevel, cookingLevel) || other.cookingLevel == cookingLevel)&&const DeepCollectionEquality().equals(other.allergies, allergies)&&const DeepCollectionEquality().equals(other.allergyItems, allergyItems)&&const DeepCollectionEquality().equals(other.specialDiets, specialDiets)&&const DeepCollectionEquality().equals(other.specialDietItems, specialDietItems)&&const DeepCollectionEquality().equals(other.preferredFoodTypes, preferredFoodTypes)&&const DeepCollectionEquality().equals(other.preferredFoodTypeItems, preferredFoodTypeItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,language,measurementUnit,cookingLevel,const DeepCollectionEquality().hash(allergies),const DeepCollectionEquality().hash(allergyItems),const DeepCollectionEquality().hash(specialDiets),const DeepCollectionEquality().hash(specialDietItems),const DeepCollectionEquality().hash(preferredFoodTypes),const DeepCollectionEquality().hash(preferredFoodTypeItems));

@override
String toString() {
  return 'UserPreferencesModel(language: $language, measurementUnit: $measurementUnit, cookingLevel: $cookingLevel, allergies: $allergies, allergyItems: $allergyItems, specialDiets: $specialDiets, specialDietItems: $specialDietItems, preferredFoodTypes: $preferredFoodTypes, preferredFoodTypeItems: $preferredFoodTypeItems)';
}


}

/// @nodoc
abstract mixin class $UserPreferencesModelCopyWith<$Res>  {
  factory $UserPreferencesModelCopyWith(UserPreferencesModel value, $Res Function(UserPreferencesModel) _then) = _$UserPreferencesModelCopyWithImpl;
@useResult
$Res call({
 String language, String measurementUnit, String? cookingLevel, List<String> allergies, List<Map<String, dynamic>> allergyItems, List<String> specialDiets, List<Map<String, dynamic>> specialDietItems, List<String> preferredFoodTypes, List<Map<String, dynamic>> preferredFoodTypeItems
});




}
/// @nodoc
class _$UserPreferencesModelCopyWithImpl<$Res>
    implements $UserPreferencesModelCopyWith<$Res> {
  _$UserPreferencesModelCopyWithImpl(this._self, this._then);

  final UserPreferencesModel _self;
  final $Res Function(UserPreferencesModel) _then;

/// Create a copy of UserPreferencesModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? language = null,Object? measurementUnit = null,Object? cookingLevel = freezed,Object? allergies = null,Object? allergyItems = null,Object? specialDiets = null,Object? specialDietItems = null,Object? preferredFoodTypes = null,Object? preferredFoodTypeItems = null,}) {
  return _then(_self.copyWith(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,measurementUnit: null == measurementUnit ? _self.measurementUnit : measurementUnit // ignore: cast_nullable_to_non_nullable
as String,cookingLevel: freezed == cookingLevel ? _self.cookingLevel : cookingLevel // ignore: cast_nullable_to_non_nullable
as String?,allergies: null == allergies ? _self.allergies : allergies // ignore: cast_nullable_to_non_nullable
as List<String>,allergyItems: null == allergyItems ? _self.allergyItems : allergyItems // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,specialDiets: null == specialDiets ? _self.specialDiets : specialDiets // ignore: cast_nullable_to_non_nullable
as List<String>,specialDietItems: null == specialDietItems ? _self.specialDietItems : specialDietItems // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,preferredFoodTypes: null == preferredFoodTypes ? _self.preferredFoodTypes : preferredFoodTypes // ignore: cast_nullable_to_non_nullable
as List<String>,preferredFoodTypeItems: null == preferredFoodTypeItems ? _self.preferredFoodTypeItems : preferredFoodTypeItems // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _UserPreferencesModel implements UserPreferencesModel {
  const _UserPreferencesModel({this.language = 'es', this.measurementUnit = 'metric', this.cookingLevel, final  List<String> allergies = const [], final  List<Map<String, dynamic>> allergyItems = const [], final  List<String> specialDiets = const [], final  List<Map<String, dynamic>> specialDietItems = const [], final  List<String> preferredFoodTypes = const [], final  List<Map<String, dynamic>> preferredFoodTypeItems = const []}): _allergies = allergies,_allergyItems = allergyItems,_specialDiets = specialDiets,_specialDietItems = specialDietItems,_preferredFoodTypes = preferredFoodTypes,_preferredFoodTypeItems = preferredFoodTypeItems;
  factory _UserPreferencesModel.fromJson(Map<String, dynamic> json) => _$UserPreferencesModelFromJson(json);

@override@JsonKey() final  String language;
@override@JsonKey() final  String measurementUnit;
@override final  String? cookingLevel;
 final  List<String> _allergies;
@override@JsonKey() List<String> get allergies {
  if (_allergies is EqualUnmodifiableListView) return _allergies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allergies);
}

 final  List<Map<String, dynamic>> _allergyItems;
@override@JsonKey() List<Map<String, dynamic>> get allergyItems {
  if (_allergyItems is EqualUnmodifiableListView) return _allergyItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allergyItems);
}

// For more structured allergy data
 final  List<String> _specialDiets;
// For more structured allergy data
@override@JsonKey() List<String> get specialDiets {
  if (_specialDiets is EqualUnmodifiableListView) return _specialDiets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_specialDiets);
}

 final  List<Map<String, dynamic>> _specialDietItems;
@override@JsonKey() List<Map<String, dynamic>> get specialDietItems {
  if (_specialDietItems is EqualUnmodifiableListView) return _specialDietItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_specialDietItems);
}

// For more structured diet data
 final  List<String> _preferredFoodTypes;
// For more structured diet data
@override@JsonKey() List<String> get preferredFoodTypes {
  if (_preferredFoodTypes is EqualUnmodifiableListView) return _preferredFoodTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_preferredFoodTypes);
}

 final  List<Map<String, dynamic>> _preferredFoodTypeItems;
@override@JsonKey() List<Map<String, dynamic>> get preferredFoodTypeItems {
  if (_preferredFoodTypeItems is EqualUnmodifiableListView) return _preferredFoodTypeItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_preferredFoodTypeItems);
}


/// Create a copy of UserPreferencesModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserPreferencesModelCopyWith<_UserPreferencesModel> get copyWith => __$UserPreferencesModelCopyWithImpl<_UserPreferencesModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserPreferencesModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserPreferencesModel&&(identical(other.language, language) || other.language == language)&&(identical(other.measurementUnit, measurementUnit) || other.measurementUnit == measurementUnit)&&(identical(other.cookingLevel, cookingLevel) || other.cookingLevel == cookingLevel)&&const DeepCollectionEquality().equals(other._allergies, _allergies)&&const DeepCollectionEquality().equals(other._allergyItems, _allergyItems)&&const DeepCollectionEquality().equals(other._specialDiets, _specialDiets)&&const DeepCollectionEquality().equals(other._specialDietItems, _specialDietItems)&&const DeepCollectionEquality().equals(other._preferredFoodTypes, _preferredFoodTypes)&&const DeepCollectionEquality().equals(other._preferredFoodTypeItems, _preferredFoodTypeItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,language,measurementUnit,cookingLevel,const DeepCollectionEquality().hash(_allergies),const DeepCollectionEquality().hash(_allergyItems),const DeepCollectionEquality().hash(_specialDiets),const DeepCollectionEquality().hash(_specialDietItems),const DeepCollectionEquality().hash(_preferredFoodTypes),const DeepCollectionEquality().hash(_preferredFoodTypeItems));

@override
String toString() {
  return 'UserPreferencesModel(language: $language, measurementUnit: $measurementUnit, cookingLevel: $cookingLevel, allergies: $allergies, allergyItems: $allergyItems, specialDiets: $specialDiets, specialDietItems: $specialDietItems, preferredFoodTypes: $preferredFoodTypes, preferredFoodTypeItems: $preferredFoodTypeItems)';
}


}

/// @nodoc
abstract mixin class _$UserPreferencesModelCopyWith<$Res> implements $UserPreferencesModelCopyWith<$Res> {
  factory _$UserPreferencesModelCopyWith(_UserPreferencesModel value, $Res Function(_UserPreferencesModel) _then) = __$UserPreferencesModelCopyWithImpl;
@override @useResult
$Res call({
 String language, String measurementUnit, String? cookingLevel, List<String> allergies, List<Map<String, dynamic>> allergyItems, List<String> specialDiets, List<Map<String, dynamic>> specialDietItems, List<String> preferredFoodTypes, List<Map<String, dynamic>> preferredFoodTypeItems
});




}
/// @nodoc
class __$UserPreferencesModelCopyWithImpl<$Res>
    implements _$UserPreferencesModelCopyWith<$Res> {
  __$UserPreferencesModelCopyWithImpl(this._self, this._then);

  final _UserPreferencesModel _self;
  final $Res Function(_UserPreferencesModel) _then;

/// Create a copy of UserPreferencesModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? language = null,Object? measurementUnit = null,Object? cookingLevel = freezed,Object? allergies = null,Object? allergyItems = null,Object? specialDiets = null,Object? specialDietItems = null,Object? preferredFoodTypes = null,Object? preferredFoodTypeItems = null,}) {
  return _then(_UserPreferencesModel(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,measurementUnit: null == measurementUnit ? _self.measurementUnit : measurementUnit // ignore: cast_nullable_to_non_nullable
as String,cookingLevel: freezed == cookingLevel ? _self.cookingLevel : cookingLevel // ignore: cast_nullable_to_non_nullable
as String?,allergies: null == allergies ? _self._allergies : allergies // ignore: cast_nullable_to_non_nullable
as List<String>,allergyItems: null == allergyItems ? _self._allergyItems : allergyItems // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,specialDiets: null == specialDiets ? _self._specialDiets : specialDiets // ignore: cast_nullable_to_non_nullable
as List<String>,specialDietItems: null == specialDietItems ? _self._specialDietItems : specialDietItems // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,preferredFoodTypes: null == preferredFoodTypes ? _self._preferredFoodTypes : preferredFoodTypes // ignore: cast_nullable_to_non_nullable
as List<String>,preferredFoodTypeItems: null == preferredFoodTypeItems ? _self._preferredFoodTypeItems : preferredFoodTypeItems // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}


}

// dart format on
