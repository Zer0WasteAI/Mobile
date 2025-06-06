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
  final String name;
  final double quantity;
  @JsonKey(name: 'type_unit')
  final String typeUnit;
  @JsonKey(name: 'storage_type')
  final String storageType;
  @JsonKey(name: 'expiration_time')
  final int expirationTime;
  @JsonKey(name: 'time_unit')
  final String timeUnit;
  final String tips;
  @JsonKey(name: 'image_path')
  final String? imagePath;
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
    required this.name,
    required this.quantity,
    required this.typeUnit,
    required this.storageType,
    required this.expirationTime,
    required this.timeUnit,
    required this.tips,
    this.imagePath,
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
  final String name;
  @JsonKey(name: 'main_ingredients')
  final List<String> mainIngredients;
  final String category;
  final int calories;
  final String description;
  @JsonKey(name: 'storage_type')
  final String storageType;
  @JsonKey(name: 'expiration_time')
  final int expirationTime;
  @JsonKey(name: 'time_unit')
  final String timeUnit;
  final String tips;
  @JsonKey(name: 'serving_quantity')
  final double servingQuantity;
  @JsonKey(name: 'image_path')
  final String? imagePath;
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
    required this.name,
    required this.mainIngredients,
    required this.category,
    required this.calories,
    required this.description,
    required this.storageType,
    required this.expirationTime,
    required this.timeUnit,
    required this.tips,
    required this.servingQuantity,
    this.imagePath,
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
