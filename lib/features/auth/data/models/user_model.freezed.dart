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

 String get id; String get email; String? get displayName; String? get photoURL; String? get phone; bool get emailVerified; List<String> get favoriteRecipes; UserPreferencesModel get prefs; bool get initialPreferencesCompleted; DateTime? get createdAt; DateTime? get lastLoginAt; bool get needsAdditionalInfo; String get providerId; String? get accessToken; String? get refreshToken;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoURL, photoURL) || other.photoURL == photoURL)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&const DeepCollectionEquality().equals(other.favoriteRecipes, favoriteRecipes)&&(identical(other.prefs, prefs) || other.prefs == prefs)&&(identical(other.initialPreferencesCompleted, initialPreferencesCompleted) || other.initialPreferencesCompleted == initialPreferencesCompleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&(identical(other.needsAdditionalInfo, needsAdditionalInfo) || other.needsAdditionalInfo == needsAdditionalInfo)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,displayName,photoURL,phone,emailVerified,const DeepCollectionEquality().hash(favoriteRecipes),prefs,initialPreferencesCompleted,createdAt,lastLoginAt,needsAdditionalInfo,providerId,accessToken,refreshToken);

@override
String toString() {
  return 'UserModel(id: $id, email: $email, displayName: $displayName, photoURL: $photoURL, phone: $phone, emailVerified: $emailVerified, favoriteRecipes: $favoriteRecipes, prefs: $prefs, initialPreferencesCompleted: $initialPreferencesCompleted, createdAt: $createdAt, lastLoginAt: $lastLoginAt, needsAdditionalInfo: $needsAdditionalInfo, providerId: $providerId, accessToken: $accessToken, refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String id, String email, String? displayName, String? photoURL, String? phone, bool emailVerified, List<String> favoriteRecipes, UserPreferencesModel prefs, bool initialPreferencesCompleted, DateTime? createdAt, DateTime? lastLoginAt, bool needsAdditionalInfo, String providerId, String? accessToken, String? refreshToken
});


$UserPreferencesModelCopyWith<$Res> get prefs;

}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? displayName = freezed,Object? photoURL = freezed,Object? phone = freezed,Object? emailVerified = null,Object? favoriteRecipes = null,Object? prefs = null,Object? initialPreferencesCompleted = null,Object? createdAt = freezed,Object? lastLoginAt = freezed,Object? needsAdditionalInfo = null,Object? providerId = null,Object? accessToken = freezed,Object? refreshToken = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,photoURL: freezed == photoURL ? _self.photoURL : photoURL // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,favoriteRecipes: null == favoriteRecipes ? _self.favoriteRecipes : favoriteRecipes // ignore: cast_nullable_to_non_nullable
as List<String>,prefs: null == prefs ? _self.prefs : prefs // ignore: cast_nullable_to_non_nullable
as UserPreferencesModel,initialPreferencesCompleted: null == initialPreferencesCompleted ? _self.initialPreferencesCompleted : initialPreferencesCompleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,needsAdditionalInfo: null == needsAdditionalInfo ? _self.needsAdditionalInfo : needsAdditionalInfo // ignore: cast_nullable_to_non_nullable
as bool,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserPreferencesModelCopyWith<$Res> get prefs {
  
  return $UserPreferencesModelCopyWith<$Res>(_self.prefs, (value) {
    return _then(_self.copyWith(prefs: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _UserModel extends UserModel {
  const _UserModel({required this.id, required this.email, this.displayName, this.photoURL, this.phone, this.emailVerified = false, final  List<String> favoriteRecipes = const [], this.prefs = const UserPreferencesModel(), this.initialPreferencesCompleted = false, this.createdAt, this.lastLoginAt, this.needsAdditionalInfo = false, this.providerId = 'email', this.accessToken, this.refreshToken}): _favoriteRecipes = favoriteRecipes,super._();
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  String id;
@override final  String email;
@override final  String? displayName;
@override final  String? photoURL;
@override final  String? phone;
@override@JsonKey() final  bool emailVerified;
 final  List<String> _favoriteRecipes;
@override@JsonKey() List<String> get favoriteRecipes {
  if (_favoriteRecipes is EqualUnmodifiableListView) return _favoriteRecipes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_favoriteRecipes);
}

@override@JsonKey() final  UserPreferencesModel prefs;
@override@JsonKey() final  bool initialPreferencesCompleted;
@override final  DateTime? createdAt;
@override final  DateTime? lastLoginAt;
@override@JsonKey() final  bool needsAdditionalInfo;
@override@JsonKey() final  String providerId;
@override final  String? accessToken;
@override final  String? refreshToken;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoURL, photoURL) || other.photoURL == photoURL)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&const DeepCollectionEquality().equals(other._favoriteRecipes, _favoriteRecipes)&&(identical(other.prefs, prefs) || other.prefs == prefs)&&(identical(other.initialPreferencesCompleted, initialPreferencesCompleted) || other.initialPreferencesCompleted == initialPreferencesCompleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&(identical(other.needsAdditionalInfo, needsAdditionalInfo) || other.needsAdditionalInfo == needsAdditionalInfo)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,displayName,photoURL,phone,emailVerified,const DeepCollectionEquality().hash(_favoriteRecipes),prefs,initialPreferencesCompleted,createdAt,lastLoginAt,needsAdditionalInfo,providerId,accessToken,refreshToken);

@override
String toString() {
  return 'UserModel(id: $id, email: $email, displayName: $displayName, photoURL: $photoURL, phone: $phone, emailVerified: $emailVerified, favoriteRecipes: $favoriteRecipes, prefs: $prefs, initialPreferencesCompleted: $initialPreferencesCompleted, createdAt: $createdAt, lastLoginAt: $lastLoginAt, needsAdditionalInfo: $needsAdditionalInfo, providerId: $providerId, accessToken: $accessToken, refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String? displayName, String? photoURL, String? phone, bool emailVerified, List<String> favoriteRecipes, UserPreferencesModel prefs, bool initialPreferencesCompleted, DateTime? createdAt, DateTime? lastLoginAt, bool needsAdditionalInfo, String providerId, String? accessToken, String? refreshToken
});


@override $UserPreferencesModelCopyWith<$Res> get prefs;

}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? displayName = freezed,Object? photoURL = freezed,Object? phone = freezed,Object? emailVerified = null,Object? favoriteRecipes = null,Object? prefs = null,Object? initialPreferencesCompleted = null,Object? createdAt = freezed,Object? lastLoginAt = freezed,Object? needsAdditionalInfo = null,Object? providerId = null,Object? accessToken = freezed,Object? refreshToken = freezed,}) {
  return _then(_UserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,photoURL: freezed == photoURL ? _self.photoURL : photoURL // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,favoriteRecipes: null == favoriteRecipes ? _self._favoriteRecipes : favoriteRecipes // ignore: cast_nullable_to_non_nullable
as List<String>,prefs: null == prefs ? _self.prefs : prefs // ignore: cast_nullable_to_non_nullable
as UserPreferencesModel,initialPreferencesCompleted: null == initialPreferencesCompleted ? _self.initialPreferencesCompleted : initialPreferencesCompleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,needsAdditionalInfo: null == needsAdditionalInfo ? _self.needsAdditionalInfo : needsAdditionalInfo // ignore: cast_nullable_to_non_nullable
as bool,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserPreferencesModelCopyWith<$Res> get prefs {
  
  return $UserPreferencesModelCopyWith<$Res>(_self.prefs, (value) {
    return _then(_self.copyWith(prefs: value));
  });
}
}

// dart format on
