// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recognition_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecognitionResult _$RecognitionResultFromJson(Map<String, dynamic> json) =>
    _RecognitionResult(
      recognitionId: json['recognitionId'] as String,
      results:
          (json['results'] as List<dynamic>)
              .map(
                (e) => FoodRecognitionItem.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      processedImageUrl: json['processedImageUrl'] as String?,
    );

Map<String, dynamic> _$RecognitionResultToJson(_RecognitionResult instance) =>
    <String, dynamic>{
      'recognitionId': instance.recognitionId,
      'results': instance.results,
      'processedImageUrl': instance.processedImageUrl,
    };

_FoodRecognitionItem _$FoodRecognitionItemFromJson(Map<String, dynamic> json) =>
    _FoodRecognitionItem(
      foodName: json['foodName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      boundingBox:
          json['boundingBox'] == null
              ? null
              : BoundingBox.fromJson(
                json['boundingBox'] as Map<String, dynamic>,
              ),
      nutritionalInfo:
          json['nutritionalInfo'] == null
              ? null
              : NutritionalInfo.fromJson(
                json['nutritionalInfo'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$FoodRecognitionItemToJson(
  _FoodRecognitionItem instance,
) => <String, dynamic>{
  'foodName': instance.foodName,
  'confidence': instance.confidence,
  'boundingBox': instance.boundingBox,
  'nutritionalInfo': instance.nutritionalInfo,
};

_BoundingBox _$BoundingBoxFromJson(Map<String, dynamic> json) => _BoundingBox(
  xMin: (json['xMin'] as num).toInt(),
  yMin: (json['yMin'] as num).toInt(),
  xMax: (json['xMax'] as num).toInt(),
  yMax: (json['yMax'] as num).toInt(),
);

Map<String, dynamic> _$BoundingBoxToJson(_BoundingBox instance) =>
    <String, dynamic>{
      'xMin': instance.xMin,
      'yMin': instance.yMin,
      'xMax': instance.xMax,
      'yMax': instance.yMax,
    };

_NutritionalInfo _$NutritionalInfoFromJson(Map<String, dynamic> json) =>
    _NutritionalInfo(
      calories: (json['calories'] as num).toDouble(),
      proteinG: (json['proteinG'] as num).toDouble(),
      fatG: (json['fatG'] as num?)?.toDouble(),
      carbohydratesG: (json['carbohydratesG'] as num?)?.toDouble(),
      fiberG: (json['fiberG'] as num?)?.toDouble(),
      sugarG: (json['sugarG'] as num?)?.toDouble(),
      sodiumMg: (json['sodiumMg'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$NutritionalInfoToJson(_NutritionalInfo instance) =>
    <String, dynamic>{
      'calories': instance.calories,
      'proteinG': instance.proteinG,
      'fatG': instance.fatG,
      'carbohydratesG': instance.carbohydratesG,
      'fiberG': instance.fiberG,
      'sugarG': instance.sugarG,
      'sodiumMg': instance.sodiumMg,
    };
