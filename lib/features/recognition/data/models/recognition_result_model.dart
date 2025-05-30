import 'package:json_annotation/json_annotation.dart';

part 'recognition_result_model.g.dart';

@JsonSerializable()
class RecognitionResultModel {
  @JsonKey(name: 'recognized_items')
  final List<RecognizedItemModel> recognizedItems;
  @JsonKey(name: 'recognition_id')
  final String recognitionId;

  const RecognitionResultModel({
    required this.recognizedItems,
    required this.recognitionId,
  });

  factory RecognitionResultModel.fromJson(Map<String, dynamic> json) =>
      _$RecognitionResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecognitionResultModelToJson(this);

  RecognitionResultModel copyWith({
    List<RecognizedItemModel>? recognizedItems,
    String? recognitionId,
  }) {
    return RecognitionResultModel(
      recognizedItems: recognizedItems ?? this.recognizedItems,
      recognitionId: recognitionId ?? this.recognitionId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecognitionResultModel &&
        other.recognizedItems == recognizedItems &&
        other.recognitionId == recognitionId;
  }

  @override
  int get hashCode => recognizedItems.hashCode ^ recognitionId.hashCode;

  @override
  String toString() {
    return 'RecognitionResultModel(recognizedItems: $recognizedItems, recognitionId: $recognitionId)';
  }
}

@JsonSerializable()
class RecognizedItemModel {
  final String name;
  final double confidence;
  final String category;

  const RecognizedItemModel({
    required this.name,
    required this.confidence,
    required this.category,
  });

  factory RecognizedItemModel.fromJson(Map<String, dynamic> json) =>
      _$RecognizedItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecognizedItemModelToJson(this);

  RecognizedItemModel copyWith({
    String? name,
    double? confidence,
    String? category,
  }) {
    return RecognizedItemModel(
      name: name ?? this.name,
      confidence: confidence ?? this.confidence,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecognizedItemModel &&
        other.name == name &&
        other.confidence == confidence &&
        other.category == category;
  }

  @override
  int get hashCode => name.hashCode ^ confidence.hashCode ^ category.hashCode;

  @override
  String toString() {
    return 'RecognizedItemModel(name: $name, confidence: $confidence, category: $category)';
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
