// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReferenceImage _$ReferenceImageFromJson(Map<String, dynamic> json) =>
    _ReferenceImage(
      imageId: json['imageId'] as String,
      imageUrl: json['imageUrl'] as String,
      label: json['label'] as String?,
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ReferenceImageToJson(_ReferenceImage instance) =>
    <String, dynamic>{
      'imageId': instance.imageId,
      'imageUrl': instance.imageUrl,
      'label': instance.label,
      'category': instance.category,
      'createdAt': instance.createdAt.toIso8601String(),
    };
