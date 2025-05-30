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
);

Map<String, dynamic> _$RecognitionResultModelToJson(
  RecognitionResultModel instance,
) => <String, dynamic>{
  'recognized_items': instance.recognizedItems,
  'recognition_id': instance.recognitionId,
};

RecognizedItemModel _$RecognizedItemModelFromJson(Map<String, dynamic> json) =>
    RecognizedItemModel(
      name: json['name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      category: json['category'] as String,
    );

Map<String, dynamic> _$RecognizedItemModelToJson(
  RecognizedItemModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'confidence': instance.confidence,
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
