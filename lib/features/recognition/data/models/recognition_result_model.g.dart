// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recognition_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecognitionResultModel _$RecognitionResultModelFromJson(
  Map<String, dynamic> json,
) => RecognitionResultModel(
  recognizedItems:
      (json['recognized_items'] as List<dynamic>)
          .map((e) => RecognizedItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
  recognitionId: json['recognition_id'] as String,
  allergyAlerts:
      (json['allergy_alerts'] as List<dynamic>?)
          ?.map((e) => AllergyAlert.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  hasAllergens: json['has_allergens'] as bool? ?? false,
  processingTime: json['processing_time'] as String?,
  totalDetected: (json['total_detected'] as num?)?.toInt(),
);

Map<String, dynamic> _$RecognitionResultModelToJson(
  RecognitionResultModel instance,
) => <String, dynamic>{
  'recognized_items': instance.recognizedItems,
  'recognition_id': instance.recognitionId,
  'allergy_alerts': instance.allergyAlerts,
  'has_allergens': instance.hasAllergens,
  'processing_time': instance.processingTime,
  'total_detected': instance.totalDetected,
};

RecognizedItemModel _$RecognizedItemModelFromJson(Map<String, dynamic> json) =>
    RecognizedItemModel(
      name: json['name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      boundingBox:
          json['bounding_box'] == null
              ? null
              : BoundingBoxModel.fromJson(
                json['bounding_box'] as Map<String, dynamic>,
              ),
      imagePath: json['image_path'] as String?,
      allergyAlert: json['allergy_alert'] as bool? ?? false,
      allergens:
          (json['allergens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      category: json['category'] as String?,
    );

Map<String, dynamic> _$RecognizedItemModelToJson(
  RecognizedItemModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'confidence': instance.confidence,
  'bounding_box': instance.boundingBox,
  'image_path': instance.imagePath,
  'allergy_alert': instance.allergyAlert,
  'allergens': instance.allergens,
  'category': instance.category,
};

ImageUploadResultModel _$ImageUploadResultModelFromJson(
  Map<String, dynamic> json,
) => ImageUploadResultModel(
  message: json['message'] as String,
  image: UploadedImageModel.fromJson(json['image'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ImageUploadResultModelToJson(
  ImageUploadResultModel instance,
) => <String, dynamic>{'message': instance.message, 'image': instance.image};

UploadedImageModel _$UploadedImageModelFromJson(Map<String, dynamic> json) =>
    UploadedImageModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      imagePath: json['image_path'] as String,
      imageType: json['image_type'] as String,
      storagePath: json['storage_path'] as String,
    );

Map<String, dynamic> _$UploadedImageModelToJson(UploadedImageModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'image_path': instance.imagePath,
      'image_type': instance.imageType,
      'storage_path': instance.storagePath,
    };

SimilarImageModel _$SimilarImageModelFromJson(Map<String, dynamic> json) =>
    SimilarImageModel(
      name: json['name'] as String,
      imagePath: json['image_path'] as String,
      imageType: json['image_type'] as String,
    );

Map<String, dynamic> _$SimilarImageModelToJson(SimilarImageModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'image_path': instance.imagePath,
      'image_type': instance.imageType,
    };

BoundingBoxModel _$BoundingBoxModelFromJson(Map<String, dynamic> json) =>
    BoundingBoxModel(
      xMin: (json['x_min'] as num).toInt(),
      yMin: (json['y_min'] as num).toInt(),
      xMax: (json['x_max'] as num).toInt(),
      yMax: (json['y_max'] as num).toInt(),
    );

Map<String, dynamic> _$BoundingBoxModelToJson(BoundingBoxModel instance) =>
    <String, dynamic>{
      'x_min': instance.xMin,
      'y_min': instance.yMin,
      'x_max': instance.xMax,
      'y_max': instance.yMax,
    };

IngredientRecognitionResultModel _$IngredientRecognitionResultModelFromJson(
  Map<String, dynamic> json,
) => IngredientRecognitionResultModel(
  ingredients:
      (json['ingredients'] as List<dynamic>)
          .map(
            (e) =>
                RecognizedIngredientModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
  allergyAlerts:
      (json['allergy_alerts'] as List<dynamic>?)
          ?.map((e) => AllergyAlert.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  hasAllergens: json['has_allergens'] as bool? ?? false,
  processingTime: json['processing_time'] as String?,
  totalDetected: (json['total_detected'] as num?)?.toInt(),
);

Map<String, dynamic> _$IngredientRecognitionResultModelToJson(
  IngredientRecognitionResultModel instance,
) => <String, dynamic>{
  'ingredients': instance.ingredients,
  'allergy_alerts': instance.allergyAlerts,
  'has_allergens': instance.hasAllergens,
  'processing_time': instance.processingTime,
  'total_detected': instance.totalDetected,
};

RecognizedIngredientModel _$RecognizedIngredientModelFromJson(
  Map<String, dynamic> json,
) => RecognizedIngredientModel(
  name: json['name'] as String,
  quantity: (json['quantity'] as num).toDouble(),
  typeUnit: json['type_unit'] as String,
  storageType: json['storage_type'] as String,
  expirationTime: (json['expiration_time'] as num).toInt(),
  timeUnit: json['time_unit'] as String,
  tips: json['tips'] as String,
  imagePath: json['image_path'] as String?,
  expirationDate: json['expiration_date'] as String?,
  addedAt: json['added_at'] as String?,
  allergyAlert: json['allergy_alert'] as bool? ?? false,
  allergens:
      (json['allergens'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  confidence: (json['confidence'] as num?)?.toDouble(),
);

Map<String, dynamic> _$RecognizedIngredientModelToJson(
  RecognizedIngredientModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'quantity': instance.quantity,
  'type_unit': instance.typeUnit,
  'storage_type': instance.storageType,
  'expiration_time': instance.expirationTime,
  'time_unit': instance.timeUnit,
  'tips': instance.tips,
  'image_path': instance.imagePath,
  'expiration_date': instance.expirationDate,
  'added_at': instance.addedAt,
  'allergy_alert': instance.allergyAlert,
  'allergens': instance.allergens,
  'confidence': instance.confidence,
};

FoodRecognitionResultModel _$FoodRecognitionResultModelFromJson(
  Map<String, dynamic> json,
) => FoodRecognitionResultModel(
  foods:
      (json['foods'] as List<dynamic>)
          .map((e) => RecognizedFoodModel.fromJson(e as Map<String, dynamic>))
          .toList(),
  allergyAlerts:
      (json['allergy_alerts'] as List<dynamic>?)
          ?.map((e) => AllergyAlert.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  hasAllergens: json['has_allergens'] as bool? ?? false,
  processingTime: json['processing_time'] as String?,
  totalDetected: (json['total_detected'] as num?)?.toInt(),
);

Map<String, dynamic> _$FoodRecognitionResultModelToJson(
  FoodRecognitionResultModel instance,
) => <String, dynamic>{
  'foods': instance.foods,
  'allergy_alerts': instance.allergyAlerts,
  'has_allergens': instance.hasAllergens,
  'processing_time': instance.processingTime,
  'total_detected': instance.totalDetected,
};

RecognizedFoodModel _$RecognizedFoodModelFromJson(Map<String, dynamic> json) =>
    RecognizedFoodModel(
      name: json['name'] as String,
      mainIngredients:
          (json['main_ingredients'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      category: json['category'] as String,
      calories: (json['calories'] as num).toInt(),
      description: json['description'] as String,
      storageType: json['storage_type'] as String,
      expirationTime: (json['expiration_time'] as num).toInt(),
      timeUnit: json['time_unit'] as String,
      tips: json['tips'] as String,
      servingQuantity: (json['serving_quantity'] as num).toDouble(),
      imagePath: json['image_path'] as String?,
      expirationDate: json['expiration_date'] as String?,
      addedAt: json['added_at'] as String?,
      allergyAlert: json['allergy_alert'] as bool? ?? false,
      allergens:
          (json['allergens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      confidence: (json['confidence'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$RecognizedFoodModelToJson(
  RecognizedFoodModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'main_ingredients': instance.mainIngredients,
  'category': instance.category,
  'calories': instance.calories,
  'description': instance.description,
  'storage_type': instance.storageType,
  'expiration_time': instance.expirationTime,
  'time_unit': instance.timeUnit,
  'tips': instance.tips,
  'serving_quantity': instance.servingQuantity,
  'image_path': instance.imagePath,
  'expiration_date': instance.expirationDate,
  'added_at': instance.addedAt,
  'allergy_alert': instance.allergyAlert,
  'allergens': instance.allergens,
  'confidence': instance.confidence,
};
