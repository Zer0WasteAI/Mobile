import 'package:freezed_annotation/freezed_annotation.dart';

part 'recognition_result.freezed.dart';
part 'recognition_result.g.dart';

@freezed
abstract class RecognitionResult with _$RecognitionResult {
  const factory RecognitionResult({
    required String recognitionId,
    required List<FoodRecognitionItem> results,
    String? processedImageUrl,
    @Default([]) List<AllergyAlert> allergyAlerts,
    @Default(false) bool hasAllergens,
  }) = _RecognitionResult;

  factory RecognitionResult.fromJson(Map<String, dynamic> json) =>
      _$RecognitionResultFromJson(json);
}

@freezed
abstract class FoodRecognitionItem with _$FoodRecognitionItem {
  const factory FoodRecognitionItem({
    required String foodName,
    required double confidence,
    BoundingBox? boundingBox,
    NutritionalInfo? nutritionalInfo,
    @Default(false) bool allergyAlert,
    @Default([]) List<String> allergens,
  }) = _FoodRecognitionItem;

  factory FoodRecognitionItem.fromJson(Map<String, dynamic> json) =>
      _$FoodRecognitionItemFromJson(json);
}

@freezed
abstract class BoundingBox with _$BoundingBox {
  const factory BoundingBox({
    required int xMin,
    required int yMin,
    required int xMax,
    required int yMax,
  }) = _BoundingBox;

  factory BoundingBox.fromJson(Map<String, dynamic> json) =>
      _$BoundingBoxFromJson(json);
}

@freezed
abstract class NutritionalInfo with _$NutritionalInfo {
  const factory NutritionalInfo({
    required double calories,
    required double proteinG,
    double? fatG,
    double? carbohydratesG,
    double? fiberG,
    double? sugarG,
    double? sodiumMg,
    // Add more nutritional fields as needed
  }) = _NutritionalInfo;

  factory NutritionalInfo.fromJson(Map<String, dynamic> json) =>
      _$NutritionalInfoFromJson(json);
}

@freezed
abstract class AllergyAlert with _$AllergyAlert {
  const factory AllergyAlert({
    required String item,
    required List<String> allergens,
    required String message,
    required double confidence,
  }) = _AllergyAlert;

  factory AllergyAlert.fromJson(Map<String, dynamic> json) =>
      _$AllergyAlertFromJson(json);
}
 