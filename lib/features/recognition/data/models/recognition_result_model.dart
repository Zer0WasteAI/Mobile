import 'package:json_annotation/json_annotation.dart';
import 'package:zer0_waste_ai/features/recognition/domain/models/allergy_alert.dart';

part 'recognition_result_model.g.dart';

@JsonSerializable()
class RecognitionResultModel {
  @JsonKey(name: 'recognized_items')
  final List<RecognizedItemModel> recognizedItems;
  @JsonKey(name: 'recognition_id')
  final String recognitionId;
  @JsonKey(name: 'allergy_alerts', defaultValue: [])
  final List<AllergyAlert> allergyAlerts;
  @JsonKey(name: 'has_allergens', defaultValue: false)
  final bool hasAllergens;
  @JsonKey(name: 'processing_time')
  final String? processingTime;
  @JsonKey(name: 'total_detected')
  final int? totalDetected;

  const RecognitionResultModel({
    required this.recognizedItems,
    required this.recognitionId,
    this.allergyAlerts = const [],
    this.hasAllergens = false,
    this.processingTime,
    this.totalDetected,
  });

  factory RecognitionResultModel.fromJson(Map<String, dynamic> json) =>
      _$RecognitionResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecognitionResultModelToJson(this);

  RecognitionResultModel copyWith({
    List<RecognizedItemModel>? recognizedItems,
    String? recognitionId,
    List<AllergyAlert>? allergyAlerts,
    bool? hasAllergens,
    String? processingTime,
    int? totalDetected,
  }) {
    return RecognitionResultModel(
      recognizedItems: recognizedItems ?? this.recognizedItems,
      recognitionId: recognitionId ?? this.recognitionId,
      allergyAlerts: allergyAlerts ?? this.allergyAlerts,
      hasAllergens: hasAllergens ?? this.hasAllergens,
      processingTime: processingTime ?? this.processingTime,
      totalDetected: totalDetected ?? this.totalDetected,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecognitionResultModel &&
        other.recognizedItems == recognizedItems &&
        other.recognitionId == recognitionId &&
        other.allergyAlerts == allergyAlerts &&
        other.hasAllergens == hasAllergens;
  }

  @override
  int get hashCode =>
      Object.hash(recognizedItems, recognitionId, allergyAlerts, hasAllergens);

  @override
  String toString() {
    return 'RecognitionResultModel(recognizedItems: $recognizedItems, recognitionId: $recognitionId, allergyAlerts: $allergyAlerts, hasAllergens: $hasAllergens)';
  }
}

@JsonSerializable()
class RecognizedItemModel {
  final String name;
  final double confidence;
  @JsonKey(name: 'bounding_box')
  final BoundingBoxModel? boundingBox;
  @JsonKey(name: 'image_path')
  final String? imagePath;
  @JsonKey(name: 'allergy_alert', defaultValue: false)
  final bool allergyAlert;
  @JsonKey(name: 'allergens', defaultValue: [])
  final List<String> allergens;
  @JsonKey(name: 'category')
  final String? category;

  const RecognizedItemModel({
    required this.name,
    required this.confidence,
    this.boundingBox,
    this.imagePath,
    this.allergyAlert = false,
    this.allergens = const [],
    this.category,
  });

  factory RecognizedItemModel.fromJson(Map<String, dynamic> json) =>
      _$RecognizedItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecognizedItemModelToJson(this);

  RecognizedItemModel copyWith({
    String? name,
    double? confidence,
    BoundingBoxModel? boundingBox,
    String? imagePath,
    bool? allergyAlert,
    List<String>? allergens,
    String? category,
  }) {
    return RecognizedItemModel(
      name: name ?? this.name,
      confidence: confidence ?? this.confidence,
      boundingBox: boundingBox ?? this.boundingBox,
      imagePath: imagePath ?? this.imagePath,
      allergyAlert: allergyAlert ?? this.allergyAlert,
      allergens: allergens ?? this.allergens,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecognizedItemModel &&
        other.name == name &&
        other.confidence == confidence &&
        other.boundingBox == boundingBox &&
        other.imagePath == imagePath &&
        other.allergyAlert == allergyAlert &&
        other.allergens == allergens &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(
    name,
    confidence,
    boundingBox,
    imagePath,
    allergyAlert,
    allergens,
    category,
  );

  @override
  String toString() {
    return 'RecognizedItemModel(name: $name, confidence: $confidence, boundingBox: $boundingBox, imagePath: $imagePath, allergyAlert: $allergyAlert, allergens: $allergens, category: $category)';
  }
}

@JsonSerializable()
class ImageUploadResultModel {
  final String message;
  final UploadedImageModel image;

  const ImageUploadResultModel({required this.message, required this.image});

  factory ImageUploadResultModel.fromJson(Map<String, dynamic> json) =>
      _$ImageUploadResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImageUploadResultModelToJson(this);

  ImageUploadResultModel copyWith({
    String? message,
    UploadedImageModel? image,
  }) {
    return ImageUploadResultModel(
      message: message ?? this.message,
      image: image ?? this.image,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageUploadResultModel &&
        other.message == message &&
        other.image == image;
  }

  @override
  int get hashCode => message.hashCode ^ image.hashCode;

  @override
  String toString() {
    return 'ImageUploadResultModel(message: $message, image: $image)';
  }
}

@JsonSerializable()
class UploadedImageModel {
  final String uid;
  final String name;
  @JsonKey(name: 'image_path')
  final String imagePath;
  @JsonKey(name: 'image_type')
  final String imageType;
  @JsonKey(name: 'storage_path')
  final String storagePath;

  const UploadedImageModel({
    required this.uid,
    required this.name,
    required this.imagePath,
    required this.imageType,
    required this.storagePath,
  });

  factory UploadedImageModel.fromJson(Map<String, dynamic> json) =>
      _$UploadedImageModelFromJson(json);

  Map<String, dynamic> toJson() => _$UploadedImageModelToJson(this);

  UploadedImageModel copyWith({
    String? uid,
    String? name,
    String? imagePath,
    String? imageType,
    String? storagePath,
  }) {
    return UploadedImageModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      imageType: imageType ?? this.imageType,
      storagePath: storagePath ?? this.storagePath,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UploadedImageModel &&
        other.uid == uid &&
        other.name == name &&
        other.imagePath == imagePath &&
        other.imageType == imageType &&
        other.storagePath == storagePath;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        imagePath.hashCode ^
        imageType.hashCode ^
        storagePath.hashCode;
  }

  @override
  String toString() {
    return 'UploadedImageModel(uid: $uid, name: $name, imagePath: $imagePath, imageType: $imageType, storagePath: $storagePath)';
  }
}

@JsonSerializable()
class SimilarImageModel {
  final String name;
  @JsonKey(name: 'image_path')
  final String imagePath;
  @JsonKey(name: 'image_type')
  final String imageType;

  const SimilarImageModel({
    required this.name,
    required this.imagePath,
    required this.imageType,
  });

  factory SimilarImageModel.fromJson(Map<String, dynamic> json) =>
      _$SimilarImageModelFromJson(json);

  Map<String, dynamic> toJson() => _$SimilarImageModelToJson(this);

  SimilarImageModel copyWith({
    String? name,
    String? imagePath,
    String? imageType,
  }) {
    return SimilarImageModel(
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      imageType: imageType ?? this.imageType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SimilarImageModel &&
        other.name == name &&
        other.imagePath == imagePath &&
        other.imageType == imageType;
  }

  @override
  int get hashCode => name.hashCode ^ imagePath.hashCode ^ imageType.hashCode;

  @override
  String toString() {
    return 'SimilarImageModel(name: $name, imagePath: $imagePath, imageType: $imageType)';
  }
}

@JsonSerializable()
class ImageGenerationStatusModel {
  final String status; // 🆕 generating, generated, failed
  @JsonKey(name: 'task_id')
  final String taskId; // 🆕 ID para seguimiento
  @JsonKey(name: 'check_images_url')
  final String checkImagesUrl; // 🆕 URL para consultar estado
  @JsonKey(name: 'estimated_time')
  final String estimatedTime; // 🆕 Tiempo estimado

  const ImageGenerationStatusModel({
    required this.status,
    required this.taskId,
    required this.checkImagesUrl,
    required this.estimatedTime,
  });

  factory ImageGenerationStatusModel.fromJson(Map<String, dynamic> json) =>
      _$ImageGenerationStatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImageGenerationStatusModelToJson(this);

  ImageGenerationStatusModel copyWith({
    String? status,
    String? taskId,
    String? checkImagesUrl,
    String? estimatedTime,
  }) {
    return ImageGenerationStatusModel(
      status: status ?? this.status,
      taskId: taskId ?? this.taskId,
      checkImagesUrl: checkImagesUrl ?? this.checkImagesUrl,
      estimatedTime: estimatedTime ?? this.estimatedTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageGenerationStatusModel &&
        other.status == status &&
        other.taskId == taskId &&
        other.checkImagesUrl == checkImagesUrl &&
        other.estimatedTime == estimatedTime;
  }

  @override
  int get hashCode =>
      Object.hash(status, taskId, checkImagesUrl, estimatedTime);

  @override
  String toString() {
    return 'ImageGenerationStatusModel(status: $status, taskId: $taskId, checkImagesUrl: $checkImagesUrl, estimatedTime: $estimatedTime)';
  }
}

@JsonSerializable()
class BoundingBoxModel {
  @JsonKey(name: 'x_min')
  final int xMin;
  @JsonKey(name: 'y_min')
  final int yMin;
  @JsonKey(name: 'x_max')
  final int xMax;
  @JsonKey(name: 'y_max')
  final int yMax;

  const BoundingBoxModel({
    required this.xMin,
    required this.yMin,
    required this.xMax,
    required this.yMax,
  });

  factory BoundingBoxModel.fromJson(Map<String, dynamic> json) =>
      _$BoundingBoxModelFromJson(json);

  Map<String, dynamic> toJson() => _$BoundingBoxModelToJson(this);
}

@JsonSerializable()
class IngredientRecognitionResultModel {
  final List<RecognizedIngredientModel> ingredients;
  @JsonKey(name: 'recognition_id', defaultValue: '')
  final String recognitionId; // 🆕 ID único del reconocimiento
  final ImageGenerationStatusModel? images; // 🆕 Estado de generación asíncrona
  final String? message; // 🆕 Mensaje descriptivo del estado
  @JsonKey(name: 'allergy_alerts', defaultValue: [])
  final List<AllergyAlert> allergyAlerts;
  @JsonKey(name: 'has_allergens', defaultValue: false)
  final bool hasAllergens;
  @JsonKey(name: 'processing_time')
  final String? processingTime;
  @JsonKey(name: 'total_detected')
  final int? totalDetected;

  const IngredientRecognitionResultModel({
    required this.ingredients,
    this.recognitionId = '',
    this.images,
    this.message,
    this.allergyAlerts = const [],
    this.hasAllergens = false,
    this.processingTime,
    this.totalDetected,
  });

  factory IngredientRecognitionResultModel.fromJson(
    Map<String, dynamic> json,
  ) => _$IngredientRecognitionResultModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$IngredientRecognitionResultModelToJson(this);
}

@JsonSerializable()
class RecognizedIngredientModel {
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: 1.0)
  final double quantity;
  @JsonKey(name: 'type_unit', defaultValue: 'unidades')
  final String typeUnit;
  @JsonKey(name: 'storage_type', defaultValue: 'refrigerado')
  final String storageType;
  @JsonKey(name: 'expiration_time', defaultValue: 7)
  final int expirationTime;
  @JsonKey(name: 'time_unit', defaultValue: 'días')
  final String timeUnit;
  @JsonKey(defaultValue: '')
  final String tips;
  @JsonKey(name: 'image_path')
  final String? imagePath;
  @JsonKey(name: 'image_status')
  final String? imageStatus; // 🆕 generating, generated, failed
  @JsonKey(name: 'expiration_date')
  final String? expirationDate;
  @JsonKey(name: 'added_at')
  final String? addedAt;
  @JsonKey(name: 'allergy_alert', defaultValue: false)
  final bool allergyAlert;
  @JsonKey(name: 'allergens', defaultValue: [])
  final List<String> allergens;
  final double? confidence;

  const RecognizedIngredientModel({
    this.name = '',
    this.quantity = 1.0,
    this.typeUnit = 'unidades',
    this.storageType = 'refrigerado',
    this.expirationTime = 7,
    this.timeUnit = 'días',
    this.tips = '',
    this.imagePath,
    this.imageStatus,
    this.expirationDate,
    this.addedAt,
    this.allergyAlert = false,
    this.allergens = const [],
    this.confidence,
  });

  factory RecognizedIngredientModel.fromJson(Map<String, dynamic> json) =>
      _$RecognizedIngredientModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecognizedIngredientModelToJson(this);
}

@JsonSerializable()
class FoodRecognitionResultModel {
  final List<RecognizedFoodModel> foods;
  @JsonKey(name: 'recognition_id', defaultValue: '')
  final String recognitionId; // 🆕 ID único del reconocimiento
  final ImageGenerationStatusModel? images; // 🆕 Estado de generación asíncrona
  final String? message; // 🆕 Mensaje descriptivo del estado
  @JsonKey(name: 'allergy_alerts', defaultValue: [])
  final List<AllergyAlert> allergyAlerts;
  @JsonKey(name: 'has_allergens', defaultValue: false)
  final bool hasAllergens;
  @JsonKey(name: 'processing_time')
  final String? processingTime;
  @JsonKey(name: 'total_detected')
  final int? totalDetected;

  const FoodRecognitionResultModel({
    required this.foods,
    this.recognitionId = '',
    this.images,
    this.message,
    this.allergyAlerts = const [],
    this.hasAllergens = false,
    this.processingTime,
    this.totalDetected,
  });

  factory FoodRecognitionResultModel.fromJson(Map<String, dynamic> json) =>
      _$FoodRecognitionResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$FoodRecognitionResultModelToJson(this);
}

@JsonSerializable()
class RecognizedFoodModel {
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(name: 'main_ingredients', defaultValue: [])
  final List<String> mainIngredients;
  @JsonKey(defaultValue: 'general')
  final String category;
  @JsonKey(defaultValue: 0)
  final int calories;
  @JsonKey(defaultValue: '')
  final String description;
  @JsonKey(name: 'storage_type', defaultValue: 'refrigerado')
  final String storageType;
  @JsonKey(name: 'expiration_time', defaultValue: 7)
  final int expirationTime;
  @JsonKey(name: 'time_unit', defaultValue: 'días')
  final String timeUnit;
  @JsonKey(defaultValue: '')
  final String tips;
  @JsonKey(name: 'serving_quantity', defaultValue: 1.0)
  final double servingQuantity;
  @JsonKey(name: 'image_path')
  final String? imagePath;
  @JsonKey(name: 'image_status')
  final String? imageStatus; // 🆕 generating, generated, failed
  @JsonKey(name: 'expiration_date')
  final String? expirationDate;
  @JsonKey(name: 'added_at')
  final String? addedAt;
  @JsonKey(name: 'allergy_alert', defaultValue: false)
  final bool allergyAlert;
  @JsonKey(name: 'allergens', defaultValue: [])
  final List<String> allergens;
  final double? confidence;

  const RecognizedFoodModel({
    this.name = '',
    this.mainIngredients = const [],
    this.category = 'general',
    this.calories = 0,
    this.description = '',
    this.storageType = 'refrigerado',
    this.expirationTime = 7,
    this.timeUnit = 'días',
    this.tips = '',
    this.servingQuantity = 1.0,
    this.imagePath,
    this.imageStatus,
    this.expirationDate,
    this.addedAt,
    this.allergyAlert = false,
    this.allergens = const [],
    this.confidence,
  });

  factory RecognizedFoodModel.fromJson(Map<String, dynamic> json) =>
      _$RecognizedFoodModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecognizedFoodModelToJson(this);
}

/// 🆕 NEW MODEL: For complete ingredient recognition with environmental impact
@JsonSerializable()
class CompleteIngredientRecognitionResultModel {
  final List<CompleteRecognizedIngredientModel> ingredients;
  @JsonKey(name: 'recognition_id', defaultValue: '')
  final String recognitionId;

  const CompleteIngredientRecognitionResultModel({
    required this.ingredients,
    this.recognitionId = '',
  });

  factory CompleteIngredientRecognitionResultModel.fromJson(
    Map<String, dynamic> json,
  ) => _$CompleteIngredientRecognitionResultModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CompleteIngredientRecognitionResultModelToJson(this);
}

/// 🆕 NEW MODEL: Complete ingredient with environmental impact and utilization ideas
@JsonSerializable()
class CompleteRecognizedIngredientModel {
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: 1.0)
  final double quantity;
  @JsonKey(name: 'type_unit', defaultValue: 'unidades')
  final String typeUnit;
  @JsonKey(name: 'storage_type', defaultValue: 'refrigerado')
  final String storageType;
  @JsonKey(name: 'expiration_time', defaultValue: 7)
  final int expirationTime;
  @JsonKey(name: 'time_unit', defaultValue: 'días')
  final String timeUnit;
  @JsonKey(defaultValue: '')
  final String tips;
  @JsonKey(name: 'image_path')
  final String? imagePath;
  @JsonKey(name: 'environmental_impact')
  final EnvironmentalImpactModel? environmentalImpact;
  @JsonKey(name: 'utilization_ideas', defaultValue: [])
  final List<UtilizationIdeaModel> utilizationIdeas;

  const CompleteRecognizedIngredientModel({
    this.name = '',
    this.quantity = 1.0,
    this.typeUnit = 'unidades',
    this.storageType = 'refrigerado',
    this.expirationTime = 7,
    this.timeUnit = 'días',
    this.tips = '',
    this.imagePath,
    this.environmentalImpact,
    this.utilizationIdeas = const [],
  });

  factory CompleteRecognizedIngredientModel.fromJson(
    Map<String, dynamic> json,
  ) => _$CompleteRecognizedIngredientModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CompleteRecognizedIngredientModelToJson(this);
}

/// 🆕 NEW MODEL: Environmental impact data
@JsonSerializable()
class EnvironmentalImpactModel {
  @JsonKey(name: 'carbon_footprint')
  final FootprintDataModel carbonFootprint;
  @JsonKey(name: 'water_footprint')
  final FootprintDataModel waterFootprint;
  @JsonKey(name: 'sustainability_message')
  final String sustainabilityMessage;

  const EnvironmentalImpactModel({
    required this.carbonFootprint,
    required this.waterFootprint,
    required this.sustainabilityMessage,
  });

  factory EnvironmentalImpactModel.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentalImpactModelFromJson(json);

  Map<String, dynamic> toJson() => _$EnvironmentalImpactModelToJson(this);
}

/// 🆕 NEW MODEL: Footprint data (carbon/water)
@JsonSerializable()
class FootprintDataModel {
  final double value;
  final String unit;
  final String description;

  const FootprintDataModel({
    required this.value,
    required this.unit,
    required this.description,
  });

  factory FootprintDataModel.fromJson(Map<String, dynamic> json) =>
      _$FootprintDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$FootprintDataModelToJson(this);
}

/// 🆕 NEW MODEL: Utilization ideas
@JsonSerializable()
class UtilizationIdeaModel {
  final String title;
  final String description;
  final String type; // "receta", "conservación", etc.

  const UtilizationIdeaModel({
    required this.title,
    required this.description,
    required this.type,
  });

  factory UtilizationIdeaModel.fromJson(Map<String, dynamic> json) =>
      _$UtilizationIdeaModelFromJson(json);

  Map<String, dynamic> toJson() => _$UtilizationIdeaModelToJson(this);
}

/// 🆕 NEW MODEL: Recognition image status response
@JsonSerializable()
class RecognitionImageStatusModel {
  @JsonKey(name: 'task_id')
  final String taskId;
  final String status; // "pending", "processing", "completed", "failed"
  @JsonKey(name: 'progress_percentage')
  final int progressPercentage;
  @JsonKey(name: 'current_step')
  final String currentStep;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'completed_at')
  final String? completedAt;
  @JsonKey(name: 'images_data')
  final List<ImageDataModel> imagesData;
  final String message;

  const RecognitionImageStatusModel({
    required this.taskId,
    required this.status,
    required this.progressPercentage,
    required this.currentStep,
    required this.createdAt,
    this.completedAt,
    this.imagesData = const [],
    required this.message,
  });

  factory RecognitionImageStatusModel.fromJson(Map<String, dynamic> json) =>
      _$RecognitionImageStatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecognitionImageStatusModelToJson(this);
}

/// 🆕 NEW MODEL: Image data in status response
@JsonSerializable()
class ImageDataModel {
  @JsonKey(name: 'ingredient_name')
  final String ingredientName;
  @JsonKey(name: 'image_path')
  final String imagePath;
  @JsonKey(name: 'generation_status')
  final String generationStatus; // "ready", "failed"

  const ImageDataModel({
    required this.ingredientName,
    required this.imagePath,
    required this.generationStatus,
  });

  factory ImageDataModel.fromJson(Map<String, dynamic> json) =>
      _$ImageDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImageDataModelToJson(this);
}

/// 🆕 NEW MODEL: Get recognition images response
@JsonSerializable()
class RecognitionImagesResponseModel {
  @JsonKey(name: 'recognition_id')
  final String recognitionId;
  final List<RecognizedIngredientModel> ingredients;
  @JsonKey(name: 'images_ready')
  final bool imagesReady;
  @JsonKey(name: 'total_ingredients')
  final int totalIngredients;
  @JsonKey(name: 'images_generated')
  final int imagesGenerated;

  const RecognitionImagesResponseModel({
    required this.recognitionId,
    required this.ingredients,
    required this.imagesReady,
    required this.totalIngredients,
    required this.imagesGenerated,
  });

  factory RecognitionImagesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RecognitionImagesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecognitionImagesResponseModelToJson(this);
}
