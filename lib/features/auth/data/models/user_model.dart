import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zer0_waste_ai/features/auth/data/models/user_preferences_model.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    String? displayName,
    String? photoURL,
    String? phone,
    @Default(false) bool emailVerified,
    @Default([]) List<String> favoriteRecipes,
    @Default(UserPreferencesModel()) UserPreferencesModel prefs,
    @Default(false) bool initialPreferencesCompleted,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    @Default(false) bool needsAdditionalInfo,
    @Default('email') String providerId,
    String? accessToken,
    String? refreshToken,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  const UserModel._();

  UserModel copyWithTokens({String? accessToken, String? refreshToken}) {
    return copyWith(accessToken: accessToken, refreshToken: refreshToken);
  }

  bool get hasValidTokens => accessToken != null && refreshToken != null;

  factory UserModel.fromBackendProfileResponse(Map<String, dynamic> json) {
    return UserModel(
      id: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['name'] as String?,
      photoURL: json['photo_url'] as String?,
      phone: json['phone'] as String?,
      prefs: UserPreferencesModel.fromJson(
        json['prefs'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  factory UserModel.fromFirebaseAuthAndBackendSignInResponse(
    Map<String, dynamic> backendSignInResponse, {
    String? firebaseUid,
    String? firebaseEmail,
    bool firebaseEmailVerified = false,
    String? firebaseProviderId,
  }) {
    final backendUser = backendSignInResponse['user'] as Map<String, dynamic>;
    return UserModel(
      id: firebaseUid ?? backendUser['uid'] as String,
      email: firebaseEmail ?? backendUser['email'] as String,
      displayName: backendUser['name'] as String?,
      photoURL: backendUser['photo_url'] as String?,
      emailVerified:
          backendUser['email_verified'] as bool? ?? firebaseEmailVerified,
      providerId: firebaseProviderId ?? 'unknown',
      accessToken: backendSignInResponse['access_token'] as String?,
      refreshToken: backendSignInResponse['refresh_token'] as String?,
      prefs: const UserPreferencesModel(),
      createdAt:
          backendUser['createdAt'] != null
              ? DateTime.tryParse(backendUser['createdAt'] as String)
              : null,
      lastLoginAt:
          backendUser['lastLoginAt'] != null
              ? DateTime.tryParse(backendUser['lastLoginAt'] as String)
              : null,
    );
  }
}
