// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recognition_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecognitionResult {

 String get recognitionId; List<FoodRecognitionItem> get results; String? get processedImageUrl;
/// Create a copy of RecognitionResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecognitionResultCopyWith<RecognitionResult> get copyWith => _$RecognitionResultCopyWithImpl<RecognitionResult>(this as RecognitionResult, _$identity);

  /// Serializes this RecognitionResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecognitionResult&&(identical(other.recognitionId, recognitionId) || other.recognitionId == recognitionId)&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.processedImageUrl, processedImageUrl) || other.processedImageUrl == processedImageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recognitionId,const DeepCollectionEquality().hash(results),processedImageUrl);

@override
String toString() {
  return 'RecognitionResult(recognitionId: $recognitionId, results: $results, processedImageUrl: $processedImageUrl)';
}


}

/// @nodoc
abstract mixin class $RecognitionResultCopyWith<$Res>  {
  factory $RecognitionResultCopyWith(RecognitionResult value, $Res Function(RecognitionResult) _then) = _$RecognitionResultCopyWithImpl;
@useResult
$Res call({
 String recognitionId, List<FoodRecognitionItem> results, String? processedImageUrl
});




}
/// @nodoc
class _$RecognitionResultCopyWithImpl<$Res>
    implements $RecognitionResultCopyWith<$Res> {
  _$RecognitionResultCopyWithImpl(this._self, this._then);

  final RecognitionResult _self;
  final $Res Function(RecognitionResult) _then;

/// Create a copy of RecognitionResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recognitionId = null,Object? results = null,Object? processedImageUrl = freezed,}) {
  return _then(_self.copyWith(
recognitionId: null == recognitionId ? _self.recognitionId : recognitionId // ignore: cast_nullable_to_non_nullable
as String,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<FoodRecognitionItem>,processedImageUrl: freezed == processedImageUrl ? _self.processedImageUrl : processedImageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _RecognitionResult implements RecognitionResult {
  const _RecognitionResult({required this.recognitionId, required final  List<FoodRecognitionItem> results, this.processedImageUrl}): _results = results;
  factory _RecognitionResult.fromJson(Map<String, dynamic> json) => _$RecognitionResultFromJson(json);

@override final  String recognitionId;
 final  List<FoodRecognitionItem> _results;
@override List<FoodRecognitionItem> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override final  String? processedImageUrl;

/// Create a copy of RecognitionResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecognitionResultCopyWith<_RecognitionResult> get copyWith => __$RecognitionResultCopyWithImpl<_RecognitionResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecognitionResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecognitionResult&&(identical(other.recognitionId, recognitionId) || other.recognitionId == recognitionId)&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.processedImageUrl, processedImageUrl) || other.processedImageUrl == processedImageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recognitionId,const DeepCollectionEquality().hash(_results),processedImageUrl);

@override
String toString() {
  return 'RecognitionResult(recognitionId: $recognitionId, results: $results, processedImageUrl: $processedImageUrl)';
}


}

/// @nodoc
abstract mixin class _$RecognitionResultCopyWith<$Res> implements $RecognitionResultCopyWith<$Res> {
  factory _$RecognitionResultCopyWith(_RecognitionResult value, $Res Function(_RecognitionResult) _then) = __$RecognitionResultCopyWithImpl;
@override @useResult
$Res call({
 String recognitionId, List<FoodRecognitionItem> results, String? processedImageUrl
});




}
/// @nodoc
class __$RecognitionResultCopyWithImpl<$Res>
    implements _$RecognitionResultCopyWith<$Res> {
  __$RecognitionResultCopyWithImpl(this._self, this._then);

  final _RecognitionResult _self;
  final $Res Function(_RecognitionResult) _then;

/// Create a copy of RecognitionResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recognitionId = null,Object? results = null,Object? processedImageUrl = freezed,}) {
  return _then(_RecognitionResult(
recognitionId: null == recognitionId ? _self.recognitionId : recognitionId // ignore: cast_nullable_to_non_nullable
as String,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<FoodRecognitionItem>,processedImageUrl: freezed == processedImageUrl ? _self.processedImageUrl : processedImageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FoodRecognitionItem {

 String get foodName; double get confidence; BoundingBox? get boundingBox; NutritionalInfo? get nutritionalInfo;
/// Create a copy of FoodRecognitionItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoodRecognitionItemCopyWith<FoodRecognitionItem> get copyWith => _$FoodRecognitionItemCopyWithImpl<FoodRecognitionItem>(this as FoodRecognitionItem, _$identity);

  /// Serializes this FoodRecognitionItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoodRecognitionItem&&(identical(other.foodName, foodName) || other.foodName == foodName)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.boundingBox, boundingBox) || other.boundingBox == boundingBox)&&(identical(other.nutritionalInfo, nutritionalInfo) || other.nutritionalInfo == nutritionalInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,foodName,confidence,boundingBox,nutritionalInfo);

@override
String toString() {
  return 'FoodRecognitionItem(foodName: $foodName, confidence: $confidence, boundingBox: $boundingBox, nutritionalInfo: $nutritionalInfo)';
}


}

/// @nodoc
abstract mixin class $FoodRecognitionItemCopyWith<$Res>  {
  factory $FoodRecognitionItemCopyWith(FoodRecognitionItem value, $Res Function(FoodRecognitionItem) _then) = _$FoodRecognitionItemCopyWithImpl;
@useResult
$Res call({
 String foodName, double confidence, BoundingBox? boundingBox, NutritionalInfo? nutritionalInfo
});


$BoundingBoxCopyWith<$Res>? get boundingBox;$NutritionalInfoCopyWith<$Res>? get nutritionalInfo;

}
/// @nodoc
class _$FoodRecognitionItemCopyWithImpl<$Res>
    implements $FoodRecognitionItemCopyWith<$Res> {
  _$FoodRecognitionItemCopyWithImpl(this._self, this._then);

  final FoodRecognitionItem _self;
  final $Res Function(FoodRecognitionItem) _then;

/// Create a copy of FoodRecognitionItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? foodName = null,Object? confidence = null,Object? boundingBox = freezed,Object? nutritionalInfo = freezed,}) {
  return _then(_self.copyWith(
foodName: null == foodName ? _self.foodName : foodName // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,boundingBox: freezed == boundingBox ? _self.boundingBox : boundingBox // ignore: cast_nullable_to_non_nullable
as BoundingBox?,nutritionalInfo: freezed == nutritionalInfo ? _self.nutritionalInfo : nutritionalInfo // ignore: cast_nullable_to_non_nullable
as NutritionalInfo?,
  ));
}
/// Create a copy of FoodRecognitionItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoundingBoxCopyWith<$Res>? get boundingBox {
    if (_self.boundingBox == null) {
    return null;
  }

  return $BoundingBoxCopyWith<$Res>(_self.boundingBox!, (value) {
    return _then(_self.copyWith(boundingBox: value));
  });
}/// Create a copy of FoodRecognitionItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionalInfoCopyWith<$Res>? get nutritionalInfo {
    if (_self.nutritionalInfo == null) {
    return null;
  }

  return $NutritionalInfoCopyWith<$Res>(_self.nutritionalInfo!, (value) {
    return _then(_self.copyWith(nutritionalInfo: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _FoodRecognitionItem implements FoodRecognitionItem {
  const _FoodRecognitionItem({required this.foodName, required this.confidence, this.boundingBox, this.nutritionalInfo});
  factory _FoodRecognitionItem.fromJson(Map<String, dynamic> json) => _$FoodRecognitionItemFromJson(json);

@override final  String foodName;
@override final  double confidence;
@override final  BoundingBox? boundingBox;
@override final  NutritionalInfo? nutritionalInfo;

/// Create a copy of FoodRecognitionItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoodRecognitionItemCopyWith<_FoodRecognitionItem> get copyWith => __$FoodRecognitionItemCopyWithImpl<_FoodRecognitionItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FoodRecognitionItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FoodRecognitionItem&&(identical(other.foodName, foodName) || other.foodName == foodName)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.boundingBox, boundingBox) || other.boundingBox == boundingBox)&&(identical(other.nutritionalInfo, nutritionalInfo) || other.nutritionalInfo == nutritionalInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,foodName,confidence,boundingBox,nutritionalInfo);

@override
String toString() {
  return 'FoodRecognitionItem(foodName: $foodName, confidence: $confidence, boundingBox: $boundingBox, nutritionalInfo: $nutritionalInfo)';
}


}

/// @nodoc
abstract mixin class _$FoodRecognitionItemCopyWith<$Res> implements $FoodRecognitionItemCopyWith<$Res> {
  factory _$FoodRecognitionItemCopyWith(_FoodRecognitionItem value, $Res Function(_FoodRecognitionItem) _then) = __$FoodRecognitionItemCopyWithImpl;
@override @useResult
$Res call({
 String foodName, double confidence, BoundingBox? boundingBox, NutritionalInfo? nutritionalInfo
});


@override $BoundingBoxCopyWith<$Res>? get boundingBox;@override $NutritionalInfoCopyWith<$Res>? get nutritionalInfo;

}
/// @nodoc
class __$FoodRecognitionItemCopyWithImpl<$Res>
    implements _$FoodRecognitionItemCopyWith<$Res> {
  __$FoodRecognitionItemCopyWithImpl(this._self, this._then);

  final _FoodRecognitionItem _self;
  final $Res Function(_FoodRecognitionItem) _then;

/// Create a copy of FoodRecognitionItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? foodName = null,Object? confidence = null,Object? boundingBox = freezed,Object? nutritionalInfo = freezed,}) {
  return _then(_FoodRecognitionItem(
foodName: null == foodName ? _self.foodName : foodName // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,boundingBox: freezed == boundingBox ? _self.boundingBox : boundingBox // ignore: cast_nullable_to_non_nullable
as BoundingBox?,nutritionalInfo: freezed == nutritionalInfo ? _self.nutritionalInfo : nutritionalInfo // ignore: cast_nullable_to_non_nullable
as NutritionalInfo?,
  ));
}

/// Create a copy of FoodRecognitionItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoundingBoxCopyWith<$Res>? get boundingBox {
    if (_self.boundingBox == null) {
    return null;
  }

  return $BoundingBoxCopyWith<$Res>(_self.boundingBox!, (value) {
    return _then(_self.copyWith(boundingBox: value));
  });
}/// Create a copy of FoodRecognitionItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionalInfoCopyWith<$Res>? get nutritionalInfo {
    if (_self.nutritionalInfo == null) {
    return null;
  }

  return $NutritionalInfoCopyWith<$Res>(_self.nutritionalInfo!, (value) {
    return _then(_self.copyWith(nutritionalInfo: value));
  });
}
}


/// @nodoc
mixin _$BoundingBox {

 int get xMin; int get yMin; int get xMax; int get yMax;
/// Create a copy of BoundingBox
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoundingBoxCopyWith<BoundingBox> get copyWith => _$BoundingBoxCopyWithImpl<BoundingBox>(this as BoundingBox, _$identity);

  /// Serializes this BoundingBox to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BoundingBox&&(identical(other.xMin, xMin) || other.xMin == xMin)&&(identical(other.yMin, yMin) || other.yMin == yMin)&&(identical(other.xMax, xMax) || other.xMax == xMax)&&(identical(other.yMax, yMax) || other.yMax == yMax));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,xMin,yMin,xMax,yMax);

@override
String toString() {
  return 'BoundingBox(xMin: $xMin, yMin: $yMin, xMax: $xMax, yMax: $yMax)';
}


}

/// @nodoc
abstract mixin class $BoundingBoxCopyWith<$Res>  {
  factory $BoundingBoxCopyWith(BoundingBox value, $Res Function(BoundingBox) _then) = _$BoundingBoxCopyWithImpl;
@useResult
$Res call({
 int xMin, int yMin, int xMax, int yMax
});




}
/// @nodoc
class _$BoundingBoxCopyWithImpl<$Res>
    implements $BoundingBoxCopyWith<$Res> {
  _$BoundingBoxCopyWithImpl(this._self, this._then);

  final BoundingBox _self;
  final $Res Function(BoundingBox) _then;

/// Create a copy of BoundingBox
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? xMin = null,Object? yMin = null,Object? xMax = null,Object? yMax = null,}) {
  return _then(_self.copyWith(
xMin: null == xMin ? _self.xMin : xMin // ignore: cast_nullable_to_non_nullable
as int,yMin: null == yMin ? _self.yMin : yMin // ignore: cast_nullable_to_non_nullable
as int,xMax: null == xMax ? _self.xMax : xMax // ignore: cast_nullable_to_non_nullable
as int,yMax: null == yMax ? _self.yMax : yMax // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _BoundingBox implements BoundingBox {
  const _BoundingBox({required this.xMin, required this.yMin, required this.xMax, required this.yMax});
  factory _BoundingBox.fromJson(Map<String, dynamic> json) => _$BoundingBoxFromJson(json);

@override final  int xMin;
@override final  int yMin;
@override final  int xMax;
@override final  int yMax;

/// Create a copy of BoundingBox
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoundingBoxCopyWith<_BoundingBox> get copyWith => __$BoundingBoxCopyWithImpl<_BoundingBox>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BoundingBoxToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BoundingBox&&(identical(other.xMin, xMin) || other.xMin == xMin)&&(identical(other.yMin, yMin) || other.yMin == yMin)&&(identical(other.xMax, xMax) || other.xMax == xMax)&&(identical(other.yMax, yMax) || other.yMax == yMax));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,xMin,yMin,xMax,yMax);

@override
String toString() {
  return 'BoundingBox(xMin: $xMin, yMin: $yMin, xMax: $xMax, yMax: $yMax)';
}


}

/// @nodoc
abstract mixin class _$BoundingBoxCopyWith<$Res> implements $BoundingBoxCopyWith<$Res> {
  factory _$BoundingBoxCopyWith(_BoundingBox value, $Res Function(_BoundingBox) _then) = __$BoundingBoxCopyWithImpl;
@override @useResult
$Res call({
 int xMin, int yMin, int xMax, int yMax
});




}
/// @nodoc
class __$BoundingBoxCopyWithImpl<$Res>
    implements _$BoundingBoxCopyWith<$Res> {
  __$BoundingBoxCopyWithImpl(this._self, this._then);

  final _BoundingBox _self;
  final $Res Function(_BoundingBox) _then;

/// Create a copy of BoundingBox
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? xMin = null,Object? yMin = null,Object? xMax = null,Object? yMax = null,}) {
  return _then(_BoundingBox(
xMin: null == xMin ? _self.xMin : xMin // ignore: cast_nullable_to_non_nullable
as int,yMin: null == yMin ? _self.yMin : yMin // ignore: cast_nullable_to_non_nullable
as int,xMax: null == xMax ? _self.xMax : xMax // ignore: cast_nullable_to_non_nullable
as int,yMax: null == yMax ? _self.yMax : yMax // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$NutritionalInfo {

 double get calories; double get proteinG; double? get fatG; double? get carbohydratesG; double? get fiberG; double? get sugarG; double? get sodiumMg;
/// Create a copy of NutritionalInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NutritionalInfoCopyWith<NutritionalInfo> get copyWith => _$NutritionalInfoCopyWithImpl<NutritionalInfo>(this as NutritionalInfo, _$identity);

  /// Serializes this NutritionalInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NutritionalInfo&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.proteinG, proteinG) || other.proteinG == proteinG)&&(identical(other.fatG, fatG) || other.fatG == fatG)&&(identical(other.carbohydratesG, carbohydratesG) || other.carbohydratesG == carbohydratesG)&&(identical(other.fiberG, fiberG) || other.fiberG == fiberG)&&(identical(other.sugarG, sugarG) || other.sugarG == sugarG)&&(identical(other.sodiumMg, sodiumMg) || other.sodiumMg == sodiumMg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,calories,proteinG,fatG,carbohydratesG,fiberG,sugarG,sodiumMg);

@override
String toString() {
  return 'NutritionalInfo(calories: $calories, proteinG: $proteinG, fatG: $fatG, carbohydratesG: $carbohydratesG, fiberG: $fiberG, sugarG: $sugarG, sodiumMg: $sodiumMg)';
}


}

/// @nodoc
abstract mixin class $NutritionalInfoCopyWith<$Res>  {
  factory $NutritionalInfoCopyWith(NutritionalInfo value, $Res Function(NutritionalInfo) _then) = _$NutritionalInfoCopyWithImpl;
@useResult
$Res call({
 double calories, double proteinG, double? fatG, double? carbohydratesG, double? fiberG, double? sugarG, double? sodiumMg
});




}
/// @nodoc
class _$NutritionalInfoCopyWithImpl<$Res>
    implements $NutritionalInfoCopyWith<$Res> {
  _$NutritionalInfoCopyWithImpl(this._self, this._then);

  final NutritionalInfo _self;
  final $Res Function(NutritionalInfo) _then;

/// Create a copy of NutritionalInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? calories = null,Object? proteinG = null,Object? fatG = freezed,Object? carbohydratesG = freezed,Object? fiberG = freezed,Object? sugarG = freezed,Object? sodiumMg = freezed,}) {
  return _then(_self.copyWith(
calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as double,proteinG: null == proteinG ? _self.proteinG : proteinG // ignore: cast_nullable_to_non_nullable
as double,fatG: freezed == fatG ? _self.fatG : fatG // ignore: cast_nullable_to_non_nullable
as double?,carbohydratesG: freezed == carbohydratesG ? _self.carbohydratesG : carbohydratesG // ignore: cast_nullable_to_non_nullable
as double?,fiberG: freezed == fiberG ? _self.fiberG : fiberG // ignore: cast_nullable_to_non_nullable
as double?,sugarG: freezed == sugarG ? _self.sugarG : sugarG // ignore: cast_nullable_to_non_nullable
as double?,sodiumMg: freezed == sodiumMg ? _self.sodiumMg : sodiumMg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _NutritionalInfo implements NutritionalInfo {
  const _NutritionalInfo({required this.calories, required this.proteinG, this.fatG, this.carbohydratesG, this.fiberG, this.sugarG, this.sodiumMg});
  factory _NutritionalInfo.fromJson(Map<String, dynamic> json) => _$NutritionalInfoFromJson(json);

@override final  double calories;
@override final  double proteinG;
@override final  double? fatG;
@override final  double? carbohydratesG;
@override final  double? fiberG;
@override final  double? sugarG;
@override final  double? sodiumMg;

/// Create a copy of NutritionalInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NutritionalInfoCopyWith<_NutritionalInfo> get copyWith => __$NutritionalInfoCopyWithImpl<_NutritionalInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NutritionalInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NutritionalInfo&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.proteinG, proteinG) || other.proteinG == proteinG)&&(identical(other.fatG, fatG) || other.fatG == fatG)&&(identical(other.carbohydratesG, carbohydratesG) || other.carbohydratesG == carbohydratesG)&&(identical(other.fiberG, fiberG) || other.fiberG == fiberG)&&(identical(other.sugarG, sugarG) || other.sugarG == sugarG)&&(identical(other.sodiumMg, sodiumMg) || other.sodiumMg == sodiumMg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,calories,proteinG,fatG,carbohydratesG,fiberG,sugarG,sodiumMg);

@override
String toString() {
  return 'NutritionalInfo(calories: $calories, proteinG: $proteinG, fatG: $fatG, carbohydratesG: $carbohydratesG, fiberG: $fiberG, sugarG: $sugarG, sodiumMg: $sodiumMg)';
}


}

/// @nodoc
abstract mixin class _$NutritionalInfoCopyWith<$Res> implements $NutritionalInfoCopyWith<$Res> {
  factory _$NutritionalInfoCopyWith(_NutritionalInfo value, $Res Function(_NutritionalInfo) _then) = __$NutritionalInfoCopyWithImpl;
@override @useResult
$Res call({
 double calories, double proteinG, double? fatG, double? carbohydratesG, double? fiberG, double? sugarG, double? sodiumMg
});




}
/// @nodoc
class __$NutritionalInfoCopyWithImpl<$Res>
    implements _$NutritionalInfoCopyWith<$Res> {
  __$NutritionalInfoCopyWithImpl(this._self, this._then);

  final _NutritionalInfo _self;
  final $Res Function(_NutritionalInfo) _then;

/// Create a copy of NutritionalInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? calories = null,Object? proteinG = null,Object? fatG = freezed,Object? carbohydratesG = freezed,Object? fiberG = freezed,Object? sugarG = freezed,Object? sodiumMg = freezed,}) {
  return _then(_NutritionalInfo(
calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as double,proteinG: null == proteinG ? _self.proteinG : proteinG // ignore: cast_nullable_to_non_nullable
as double,fatG: freezed == fatG ? _self.fatG : fatG // ignore: cast_nullable_to_non_nullable
as double?,carbohydratesG: freezed == carbohydratesG ? _self.carbohydratesG : carbohydratesG // ignore: cast_nullable_to_non_nullable
as double?,fiberG: freezed == fiberG ? _self.fiberG : fiberG // ignore: cast_nullable_to_non_nullable
as double?,sugarG: freezed == sugarG ? _self.sugarG : sugarG // ignore: cast_nullable_to_non_nullable
as double?,sodiumMg: freezed == sodiumMg ? _self.sodiumMg : sodiumMg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
