import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    String? displayName,
    String? photoURL,
    @Default(false) bool emailVerified,
    @Default([]) List<String> favoriteRecipes,
    @Default([]) List<String> allergies,
    @Default([]) List<Map<String, dynamic>> allergyItems,
    @Default([]) List<String> specialDiets,
    @Default([]) List<Map<String, dynamic>> specialDietItems,
    String? cookingLevel,
    @Default([]) List<String> preferredFoodTypes,
    @Default([]) List<Map<String, dynamic>> preferredFoodTypeItems,
    @Default(false) bool initialPreferencesCompleted,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    @Default(false) bool needsAdditionalInfo,
    @Default('email') String providerId,
    @Default('es') String language,
    @Default('metric') String measurementUnit,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
