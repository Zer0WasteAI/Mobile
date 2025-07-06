import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_preferences_model.freezed.dart';
part 'user_preferences_model.g.dart';

@freezed
abstract class UserPreferencesModel with _$UserPreferencesModel {
  const factory UserPreferencesModel({
    @Default('es') String language,
    @Default('metric') String measurementUnit,
    String? cookingLevel,
    @Default([]) List<String> allergies,
    @Default([])
    List<Map<String, dynamic>> allergyItems, // For more structured allergy data
    @Default([]) List<String> specialDiets,
    @Default([])
    List<Map<String, dynamic>>
    specialDietItems, // For more structured diet data
    @Default([]) List<String> preferredFoodTypes,
    @Default([])
    List<Map<String, dynamic>>
    preferredFoodTypeItems, // For structured food type data
    // Add any other preferences defined in the guide or by the backend
  }) = _UserPreferencesModel;

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesModelFromJson(json);
}
