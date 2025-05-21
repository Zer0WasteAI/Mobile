// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

 String get id; String get email; String? get displayName; String? get photoURL; bool get emailVerified; List<String> get favoriteRecipes; List<String> get allergies; List<Map<String, dynamic>> get allergyItems; List<String> get specialDiets; List<Map<String, dynamic>> get specialDietItems; String? get cookingLevel; List<String> get preferredFoodTypes; List<Map<String, dynamic>> get preferredFoodTypeItems; bool get initialPreferencesCompleted; DateTime? get createdAt; DateTime? get lastLoginAt; bool get needsAdditionalInfo; String get providerId; String get language; String get measurementUnit;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoURL, photoURL) || other.photoURL == photoURL)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&const DeepCollectionEquality().equals(other.favoriteRecipes, favoriteRecipes)&&const DeepCollectionEquality().equals(other.allergies, allergies)&&const DeepCollectionEquality().equals(other.allergyItems, allergyItems)&&const DeepCollectionEquality().equals(other.specialDiets, specialDiets)&&const DeepCollectionEquality().equals(other.specialDietItems, specialDietItems)&&(identical(other.cookingLevel, cookingLevel) || other.cookingLevel == cookingLevel)&&const DeepCollectionEquality().equals(other.preferredFoodTypes, preferredFoodTypes)&&const DeepCollectionEquality().equals(other.preferredFoodTypeItems, preferredFoodTypeItems)&&(identical(other.initialPreferencesCompleted, initialPreferencesCompleted) || other.initialPreferencesCompleted == initialPreferencesCompleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&(identical(other.needsAdditionalInfo, needsAdditionalInfo) || other.needsAdditionalInfo == needsAdditionalInfo)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.language, language) || other.language == language)&&(identical(other.measurementUnit, measurementUnit) || other.measurementUnit == measurementUnit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,email,displayName,photoURL,emailVerified,const DeepCollectionEquality().hash(favoriteRecipes),const DeepCollectionEquality().hash(allergies),const DeepCollectionEquality().hash(allergyItems),const DeepCollectionEquality().hash(specialDiets),const DeepCollectionEquality().hash(specialDietItems),cookingLevel,const DeepCollectionEquality().hash(preferredFoodTypes),const DeepCollectionEquality().hash(preferredFoodTypeItems),initialPreferencesCompleted,createdAt,lastLoginAt,needsAdditionalInfo,providerId,language,measurementUnit]);

@override
String toString() {
  return 'UserModel(id: $id, email: $email, displayName: $displayName, photoURL: $photoURL, emailVerified: $emailVerified, favoriteRecipes: $favoriteRecipes, allergies: $allergies, allergyItems: $allergyItems, specialDiets: $specialDiets, specialDietItems: $specialDietItems, cookingLevel: $cookingLevel, preferredFoodTypes: $preferredFoodTypes, preferredFoodTypeItems: $preferredFoodTypeItems, initialPreferencesCompleted: $initialPreferencesCompleted, createdAt: $createdAt, lastLoginAt: $lastLoginAt, needsAdditionalInfo: $needsAdditionalInfo, providerId: $providerId, language: $language, measurementUnit: $measurementUnit)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String id, String email, String? displayName, String? photoURL, bool emailVerified, List<String> favoriteRecipes, List<String> allergies, List<Map<String, dynamic>> allergyItems, List<String> specialDiets, List<Map<String, dynamic>> specialDietItems, String? cookingLevel, List<String> preferredFoodTypes, List<Map<String, dynamic>> preferredFoodTypeItems, bool initialPreferencesCompleted, DateTime? createdAt, DateTime? lastLoginAt, bool needsAdditionalInfo, String providerId, String language, String measurementUnit
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? displayName = freezed,Object? photoURL = freezed,Object? emailVerified = null,Object? favoriteRecipes = null,Object? allergies = null,Object? allergyItems = null,Object? specialDiets = null,Object? specialDietItems = null,Object? cookingLevel = freezed,Object? preferredFoodTypes = null,Object? preferredFoodTypeItems = null,Object? initialPreferencesCompleted = null,Object? createdAt = freezed,Object? lastLoginAt = freezed,Object? needsAdditionalInfo = null,Object? providerId = null,Object? language = null,Object? measurementUnit = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,photoURL: freezed == photoURL ? _self.photoURL : photoURL // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,favoriteRecipes: null == favoriteRecipes ? _self.favoriteRecipes : favoriteRecipes // ignore: cast_nullable_to_non_nullable
as List<String>,allergies: null == allergies ? _self.allergies : allergies // ignore: cast_nullable_to_non_nullable
as List<String>,allergyItems: null == allergyItems ? _self.allergyItems : allergyItems // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,specialDiets: null == specialDiets ? _self.specialDiets : specialDiets // ignore: cast_nullable_to_non_nullable
as List<String>,specialDietItems: null == specialDietItems ? _self.specialDietItems : specialDietItems // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,cookingLevel: freezed == cookingLevel ? _self.cookingLevel : cookingLevel // ignore: cast_nullable_to_non_nullable
as String?,preferredFoodTypes: null == preferredFoodTypes ? _self.preferredFoodTypes : preferredFoodTypes // ignore: cast_nullable_to_non_nullable
as List<String>,preferredFoodTypeItems: null == preferredFoodTypeItems ? _self.preferredFoodTypeItems : preferredFoodTypeItems // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,initialPreferencesCompleted: null == initialPreferencesCompleted ? _self.initialPreferencesCompleted : initialPreferencesCompleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,needsAdditionalInfo: null == needsAdditionalInfo ? _self.needsAdditionalInfo : needsAdditionalInfo // ignore: cast_nullable_to_non_nullable
as bool,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,measurementUnit: null == measurementUnit ? _self.measurementUnit : measurementUnit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _UserModel implements UserModel {
  const _UserModel({required this.id, required this.email, this.displayName, this.photoURL, this.emailVerified = false, final  List<String> favoriteRecipes = const [], final  List<String> allergies = const [], final  List<Map<String, dynamic>> allergyItems = const [], final  List<String> specialDiets = const [], final  List<Map<String, dynamic>> specialDietItems = const [], this.cookingLevel, final  List<String> preferredFoodTypes = const [], final  List<Map<String, dynamic>> preferredFoodTypeItems = const [], this.initialPreferencesCompleted = false, this.createdAt, this.lastLoginAt, this.needsAdditionalInfo = false, this.providerId = 'email', this.language = 'es', this.measurementUnit = 'metric'}): _favoriteRecipes = favoriteRecipes,_allergies = allergies,_allergyItems = allergyItems,_specialDiets = specialDiets,_specialDietItems = specialDietItems,_preferredFoodTypes = preferredFoodTypes,_preferredFoodTypeItems = preferredFoodTypeItems;
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  String id;
@override final  String email;
@override final  String? displayName;
@override final  String? photoURL;
@override@JsonKey() final  bool emailVerified;
 final  List<String> _favoriteRecipes;
@override@JsonKey() List<String> get favoriteRecipes {
  if (_favoriteRecipes is EqualUnmodifiableListView) return _favoriteRecipes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_favoriteRecipes);
}

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

 final  List<String> _specialDiets;
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

@override final  String? cookingLevel;
 final  List<String> _preferredFoodTypes;
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

@override@JsonKey() final  bool initialPreferencesCompleted;
@override final  DateTime? createdAt;
@override final  DateTime? lastLoginAt;
@override@JsonKey() final  bool needsAdditionalInfo;
@override@JsonKey() final  String providerId;
@override@JsonKey() final  String language;
@override@JsonKey() final  String measurementUnit;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoURL, photoURL) || other.photoURL == photoURL)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&const DeepCollectionEquality().equals(other._favoriteRecipes, _favoriteRecipes)&&const DeepCollectionEquality().equals(other._allergies, _allergies)&&const DeepCollectionEquality().equals(other._allergyItems, _allergyItems)&&const DeepCollectionEquality().equals(other._specialDiets, _specialDiets)&&const DeepCollectionEquality().equals(other._specialDietItems, _specialDietItems)&&(identical(other.cookingLevel, cookingLevel) || other.cookingLevel == cookingLevel)&&const DeepCollectionEquality().equals(other._preferredFoodTypes, _preferredFoodTypes)&&const DeepCollectionEquality().equals(other._preferredFoodTypeItems, _preferredFoodTypeItems)&&(identical(other.initialPreferencesCompleted, initialPreferencesCompleted) || other.initialPreferencesCompleted == initialPreferencesCompleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&(identical(other.needsAdditionalInfo, needsAdditionalInfo) || other.needsAdditionalInfo == needsAdditionalInfo)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.language, language) || other.language == language)&&(identical(other.measurementUnit, measurementUnit) || other.measurementUnit == measurementUnit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,email,displayName,photoURL,emailVerified,const DeepCollectionEquality().hash(_favoriteRecipes),const DeepCollectionEquality().hash(_allergies),const DeepCollectionEquality().hash(_allergyItems),const DeepCollectionEquality().hash(_specialDiets),const DeepCollectionEquality().hash(_specialDietItems),cookingLevel,const DeepCollectionEquality().hash(_preferredFoodTypes),const DeepCollectionEquality().hash(_preferredFoodTypeItems),initialPreferencesCompleted,createdAt,lastLoginAt,needsAdditionalInfo,providerId,language,measurementUnit]);

@override
String toString() {
  return 'UserModel(id: $id, email: $email, displayName: $displayName, photoURL: $photoURL, emailVerified: $emailVerified, favoriteRecipes: $favoriteRecipes, allergies: $allergies, allergyItems: $allergyItems, specialDiets: $specialDiets, specialDietItems: $specialDietItems, cookingLevel: $cookingLevel, preferredFoodTypes: $preferredFoodTypes, preferredFoodTypeItems: $preferredFoodTypeItems, initialPreferencesCompleted: $initialPreferencesCompleted, createdAt: $createdAt, lastLoginAt: $lastLoginAt, needsAdditionalInfo: $needsAdditionalInfo, providerId: $providerId, language: $language, measurementUnit: $measurementUnit)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String? displayName, String? photoURL, bool emailVerified, List<String> favoriteRecipes, List<String> allergies, List<Map<String, dynamic>> allergyItems, List<String> specialDiets, List<Map<String, dynamic>> specialDietItems, String? cookingLevel, List<String> preferredFoodTypes, List<Map<String, dynamic>> preferredFoodTypeItems, bool initialPreferencesCompleted, DateTime? createdAt, DateTime? lastLoginAt, bool needsAdditionalInfo, String providerId, String language, String measurementUnit
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? displayName = freezed,Object? photoURL = freezed,Object? emailVerified = null,Object? favoriteRecipes = null,Object? allergies = null,Object? allergyItems = null,Object? specialDiets = null,Object? specialDietItems = null,Object? cookingLevel = freezed,Object? preferredFoodTypes = null,Object? preferredFoodTypeItems = null,Object? initialPreferencesCompleted = null,Object? createdAt = freezed,Object? lastLoginAt = freezed,Object? needsAdditionalInfo = null,Object? providerId = null,Object? language = null,Object? measurementUnit = null,}) {
  return _then(_UserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,photoURL: freezed == photoURL ? _self.photoURL : photoURL // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,favoriteRecipes: null == favoriteRecipes ? _self._favoriteRecipes : favoriteRecipes // ignore: cast_nullable_to_non_nullable
as List<String>,allergies: null == allergies ? _self._allergies : allergies // ignore: cast_nullable_to_non_nullable
as List<String>,allergyItems: null == allergyItems ? _self._allergyItems : allergyItems // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,specialDiets: null == specialDiets ? _self._specialDiets : specialDiets // ignore: cast_nullable_to_non_nullable
as List<String>,specialDietItems: null == specialDietItems ? _self._specialDietItems : specialDietItems // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,cookingLevel: freezed == cookingLevel ? _self.cookingLevel : cookingLevel // ignore: cast_nullable_to_non_nullable
as String?,preferredFoodTypes: null == preferredFoodTypes ? _self._preferredFoodTypes : preferredFoodTypes // ignore: cast_nullable_to_non_nullable
as List<String>,preferredFoodTypeItems: null == preferredFoodTypeItems ? _self._preferredFoodTypeItems : preferredFoodTypeItems // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,initialPreferencesCompleted: null == initialPreferencesCompleted ? _self.initialPreferencesCompleted : initialPreferencesCompleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,needsAdditionalInfo: null == needsAdditionalInfo ? _self.needsAdditionalInfo : needsAdditionalInfo // ignore: cast_nullable_to_non_nullable
as bool,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,measurementUnit: null == measurementUnit ? _self.measurementUnit : measurementUnit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
