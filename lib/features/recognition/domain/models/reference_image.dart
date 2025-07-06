import 'package:freezed_annotation/freezed_annotation.dart';

part 'reference_image.freezed.dart';
part 'reference_image.g.dart';

@freezed
abstract class ReferenceImage with _$ReferenceImage {
  const factory ReferenceImage({
    required String imageId,
    required String imageUrl,
    String? label,
    String? category,
    required DateTime createdAt,
  }) = _ReferenceImage;

  factory ReferenceImage.fromJson(Map<String, dynamic> json) =>
      _$ReferenceImageFromJson(json);
}
 