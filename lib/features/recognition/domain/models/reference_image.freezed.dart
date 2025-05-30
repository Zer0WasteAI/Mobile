// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reference_image.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReferenceImage {

 String get imageId; String get imageUrl; String? get label; String? get category; DateTime get createdAt;
/// Create a copy of ReferenceImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReferenceImageCopyWith<ReferenceImage> get copyWith => _$ReferenceImageCopyWithImpl<ReferenceImage>(this as ReferenceImage, _$identity);

  /// Serializes this ReferenceImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReferenceImage&&(identical(other.imageId, imageId) || other.imageId == imageId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.label, label) || other.label == label)&&(identical(other.category, category) || other.category == category)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageId,imageUrl,label,category,createdAt);

@override
String toString() {
  return 'ReferenceImage(imageId: $imageId, imageUrl: $imageUrl, label: $label, category: $category, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ReferenceImageCopyWith<$Res>  {
  factory $ReferenceImageCopyWith(ReferenceImage value, $Res Function(ReferenceImage) _then) = _$ReferenceImageCopyWithImpl;
@useResult
$Res call({
 String imageId, String imageUrl, String? label, String? category, DateTime createdAt
});




}
/// @nodoc
class _$ReferenceImageCopyWithImpl<$Res>
    implements $ReferenceImageCopyWith<$Res> {
  _$ReferenceImageCopyWithImpl(this._self, this._then);

  final ReferenceImage _self;
  final $Res Function(ReferenceImage) _then;

/// Create a copy of ReferenceImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imageId = null,Object? imageUrl = null,Object? label = freezed,Object? category = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
imageId: null == imageId ? _self.imageId : imageId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ReferenceImage implements ReferenceImage {
  const _ReferenceImage({required this.imageId, required this.imageUrl, this.label, this.category, required this.createdAt});
  factory _ReferenceImage.fromJson(Map<String, dynamic> json) => _$ReferenceImageFromJson(json);

@override final  String imageId;
@override final  String imageUrl;
@override final  String? label;
@override final  String? category;
@override final  DateTime createdAt;

/// Create a copy of ReferenceImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReferenceImageCopyWith<_ReferenceImage> get copyWith => __$ReferenceImageCopyWithImpl<_ReferenceImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReferenceImageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReferenceImage&&(identical(other.imageId, imageId) || other.imageId == imageId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.label, label) || other.label == label)&&(identical(other.category, category) || other.category == category)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageId,imageUrl,label,category,createdAt);

@override
String toString() {
  return 'ReferenceImage(imageId: $imageId, imageUrl: $imageUrl, label: $label, category: $category, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ReferenceImageCopyWith<$Res> implements $ReferenceImageCopyWith<$Res> {
  factory _$ReferenceImageCopyWith(_ReferenceImage value, $Res Function(_ReferenceImage) _then) = __$ReferenceImageCopyWithImpl;
@override @useResult
$Res call({
 String imageId, String imageUrl, String? label, String? category, DateTime createdAt
});




}
/// @nodoc
class __$ReferenceImageCopyWithImpl<$Res>
    implements _$ReferenceImageCopyWith<$Res> {
  __$ReferenceImageCopyWithImpl(this._self, this._then);

  final _ReferenceImage _self;
  final $Res Function(_ReferenceImage) _then;

/// Create a copy of ReferenceImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imageId = null,Object? imageUrl = null,Object? label = freezed,Object? category = freezed,Object? createdAt = null,}) {
  return _then(_ReferenceImage(
imageId: null == imageId ? _self.imageId : imageId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
