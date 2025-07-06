// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InventoryItem {

 String get id; String get name; String get image; double get quantity; String get unitType; DateTime? get expirationDate; StorageType get storageType; ItemCategory get category; String? get imageUrl; String? get tips; DateTime get addedDate; String? get description; int? get calories; int? get servingQuantity; List<String>? get mainIngredients; String? get foodCategory; String? get sustainabilityNote;
/// Create a copy of InventoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryItemCopyWith<InventoryItem> get copyWith => _$InventoryItemCopyWithImpl<InventoryItem>(this as InventoryItem, _$identity);

  /// Serializes this InventoryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.image, image) || other.image == image)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitType, unitType) || other.unitType == unitType)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&(identical(other.storageType, storageType) || other.storageType == storageType)&&(identical(other.category, category) || other.category == category)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.tips, tips) || other.tips == tips)&&(identical(other.addedDate, addedDate) || other.addedDate == addedDate)&&(identical(other.description, description) || other.description == description)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.servingQuantity, servingQuantity) || other.servingQuantity == servingQuantity)&&const DeepCollectionEquality().equals(other.mainIngredients, mainIngredients)&&(identical(other.foodCategory, foodCategory) || other.foodCategory == foodCategory)&&(identical(other.sustainabilityNote, sustainabilityNote) || other.sustainabilityNote == sustainabilityNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,image,quantity,unitType,expirationDate,storageType,category,imageUrl,tips,addedDate,description,calories,servingQuantity,const DeepCollectionEquality().hash(mainIngredients),foodCategory,sustainabilityNote);

@override
String toString() {
  return 'InventoryItem(id: $id, name: $name, image: $image, quantity: $quantity, unitType: $unitType, expirationDate: $expirationDate, storageType: $storageType, category: $category, imageUrl: $imageUrl, tips: $tips, addedDate: $addedDate, description: $description, calories: $calories, servingQuantity: $servingQuantity, mainIngredients: $mainIngredients, foodCategory: $foodCategory, sustainabilityNote: $sustainabilityNote)';
}


}

/// @nodoc
abstract mixin class $InventoryItemCopyWith<$Res>  {
  factory $InventoryItemCopyWith(InventoryItem value, $Res Function(InventoryItem) _then) = _$InventoryItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, String image, double quantity, String unitType, DateTime? expirationDate, StorageType storageType, ItemCategory category, String? imageUrl, String? tips, DateTime addedDate, String? description, int? calories, int? servingQuantity, List<String>? mainIngredients, String? foodCategory, String? sustainabilityNote
});




}
/// @nodoc
class _$InventoryItemCopyWithImpl<$Res>
    implements $InventoryItemCopyWith<$Res> {
  _$InventoryItemCopyWithImpl(this._self, this._then);

  final InventoryItem _self;
  final $Res Function(InventoryItem) _then;

/// Create a copy of InventoryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? image = null,Object? quantity = null,Object? unitType = null,Object? expirationDate = freezed,Object? storageType = null,Object? category = null,Object? imageUrl = freezed,Object? tips = freezed,Object? addedDate = null,Object? description = freezed,Object? calories = freezed,Object? servingQuantity = freezed,Object? mainIngredients = freezed,Object? foodCategory = freezed,Object? sustainabilityNote = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitType: null == unitType ? _self.unitType : unitType // ignore: cast_nullable_to_non_nullable
as String,expirationDate: freezed == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,storageType: null == storageType ? _self.storageType : storageType // ignore: cast_nullable_to_non_nullable
as StorageType,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ItemCategory,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,tips: freezed == tips ? _self.tips : tips // ignore: cast_nullable_to_non_nullable
as String?,addedDate: null == addedDate ? _self.addedDate : addedDate // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,calories: freezed == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int?,servingQuantity: freezed == servingQuantity ? _self.servingQuantity : servingQuantity // ignore: cast_nullable_to_non_nullable
as int?,mainIngredients: freezed == mainIngredients ? _self.mainIngredients : mainIngredients // ignore: cast_nullable_to_non_nullable
as List<String>?,foodCategory: freezed == foodCategory ? _self.foodCategory : foodCategory // ignore: cast_nullable_to_non_nullable
as String?,sustainabilityNote: freezed == sustainabilityNote ? _self.sustainabilityNote : sustainabilityNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _InventoryItem implements InventoryItem {
  const _InventoryItem({required this.id, required this.name, required this.image, required this.quantity, required this.unitType, this.expirationDate, required this.storageType, required this.category, this.imageUrl, this.tips, required this.addedDate, this.description, this.calories, this.servingQuantity, final  List<String>? mainIngredients, this.foodCategory, this.sustainabilityNote}): _mainIngredients = mainIngredients;
  factory _InventoryItem.fromJson(Map<String, dynamic> json) => _$InventoryItemFromJson(json);

@override final  String id;
@override final  String name;
@override final  String image;
@override final  double quantity;
@override final  String unitType;
@override final  DateTime? expirationDate;
@override final  StorageType storageType;
@override final  ItemCategory category;
@override final  String? imageUrl;
@override final  String? tips;
@override final  DateTime addedDate;
@override final  String? description;
@override final  int? calories;
@override final  int? servingQuantity;
 final  List<String>? _mainIngredients;
@override List<String>? get mainIngredients {
  final value = _mainIngredients;
  if (value == null) return null;
  if (_mainIngredients is EqualUnmodifiableListView) return _mainIngredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? foodCategory;
@override final  String? sustainabilityNote;

/// Create a copy of InventoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryItemCopyWith<_InventoryItem> get copyWith => __$InventoryItemCopyWithImpl<_InventoryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InventoryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.image, image) || other.image == image)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitType, unitType) || other.unitType == unitType)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&(identical(other.storageType, storageType) || other.storageType == storageType)&&(identical(other.category, category) || other.category == category)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.tips, tips) || other.tips == tips)&&(identical(other.addedDate, addedDate) || other.addedDate == addedDate)&&(identical(other.description, description) || other.description == description)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.servingQuantity, servingQuantity) || other.servingQuantity == servingQuantity)&&const DeepCollectionEquality().equals(other._mainIngredients, _mainIngredients)&&(identical(other.foodCategory, foodCategory) || other.foodCategory == foodCategory)&&(identical(other.sustainabilityNote, sustainabilityNote) || other.sustainabilityNote == sustainabilityNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,image,quantity,unitType,expirationDate,storageType,category,imageUrl,tips,addedDate,description,calories,servingQuantity,const DeepCollectionEquality().hash(_mainIngredients),foodCategory,sustainabilityNote);

@override
String toString() {
  return 'InventoryItem(id: $id, name: $name, image: $image, quantity: $quantity, unitType: $unitType, expirationDate: $expirationDate, storageType: $storageType, category: $category, imageUrl: $imageUrl, tips: $tips, addedDate: $addedDate, description: $description, calories: $calories, servingQuantity: $servingQuantity, mainIngredients: $mainIngredients, foodCategory: $foodCategory, sustainabilityNote: $sustainabilityNote)';
}


}

/// @nodoc
abstract mixin class _$InventoryItemCopyWith<$Res> implements $InventoryItemCopyWith<$Res> {
  factory _$InventoryItemCopyWith(_InventoryItem value, $Res Function(_InventoryItem) _then) = __$InventoryItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String image, double quantity, String unitType, DateTime? expirationDate, StorageType storageType, ItemCategory category, String? imageUrl, String? tips, DateTime addedDate, String? description, int? calories, int? servingQuantity, List<String>? mainIngredients, String? foodCategory, String? sustainabilityNote
});




}
/// @nodoc
class __$InventoryItemCopyWithImpl<$Res>
    implements _$InventoryItemCopyWith<$Res> {
  __$InventoryItemCopyWithImpl(this._self, this._then);

  final _InventoryItem _self;
  final $Res Function(_InventoryItem) _then;

/// Create a copy of InventoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? image = null,Object? quantity = null,Object? unitType = null,Object? expirationDate = freezed,Object? storageType = null,Object? category = null,Object? imageUrl = freezed,Object? tips = freezed,Object? addedDate = null,Object? description = freezed,Object? calories = freezed,Object? servingQuantity = freezed,Object? mainIngredients = freezed,Object? foodCategory = freezed,Object? sustainabilityNote = freezed,}) {
  return _then(_InventoryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitType: null == unitType ? _self.unitType : unitType // ignore: cast_nullable_to_non_nullable
as String,expirationDate: freezed == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,storageType: null == storageType ? _self.storageType : storageType // ignore: cast_nullable_to_non_nullable
as StorageType,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ItemCategory,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,tips: freezed == tips ? _self.tips : tips // ignore: cast_nullable_to_non_nullable
as String?,addedDate: null == addedDate ? _self.addedDate : addedDate // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,calories: freezed == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int?,servingQuantity: freezed == servingQuantity ? _self.servingQuantity : servingQuantity // ignore: cast_nullable_to_non_nullable
as int?,mainIngredients: freezed == mainIngredients ? _self._mainIngredients : mainIngredients // ignore: cast_nullable_to_non_nullable
as List<String>?,foodCategory: freezed == foodCategory ? _self.foodCategory : foodCategory // ignore: cast_nullable_to_non_nullable
as String?,sustainabilityNote: freezed == sustainabilityNote ? _self.sustainabilityNote : sustainabilityNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
