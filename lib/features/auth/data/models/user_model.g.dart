// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String?,
  photoURL: json['photoURL'] as String?,
  phone: json['phone'] as String?,
  emailVerified: json['emailVerified'] as bool? ?? false,
  favoriteRecipes:
      (json['favoriteRecipes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  prefs:
      json['prefs'] == null
          ? const UserPreferencesModel()
          : UserPreferencesModel.fromJson(
            json['prefs'] as Map<String, dynamic>,
          ),
  initialPreferencesCompleted:
      json['initialPreferencesCompleted'] as bool? ?? false,
  streak: (json['streak'] as num?)?.toInt() ?? 0,
  achievements: (json['achievements'] as num?)?.toInt() ?? 0,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  lastLoginAt:
      json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
  needsAdditionalInfo: json['needsAdditionalInfo'] as bool? ?? false,
  providerId: json['providerId'] as String? ?? 'email',
  accessToken: json['accessToken'] as String?,
  refreshToken: json['refreshToken'] as String?,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoURL': instance.photoURL,
      'phone': instance.phone,
      'emailVerified': instance.emailVerified,
      'favoriteRecipes': instance.favoriteRecipes,
      'prefs': instance.prefs,
      'initialPreferencesCompleted': instance.initialPreferencesCompleted,
      'streak': instance.streak,
      'achievements': instance.achievements,
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'needsAdditionalInfo': instance.needsAdditionalInfo,
      'providerId': instance.providerId,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };
