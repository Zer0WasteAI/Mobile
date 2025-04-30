// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InventoryItem _$InventoryItemFromJson(Map<String, dynamic> json) {
  return _InventoryItem.fromJson(json);
}

/// @nodoc
mixin _$InventoryItem {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get image => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  DateTime? get expirationDate => throw _privateConstructorUsedError;
  StorageType get storageType => throw _privateConstructorUsedError;
  ItemCategory get category => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  DateTime get addedDate => throw _privateConstructorUsedError;

  /// Serializes this InventoryItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InventoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InventoryItemCopyWith<InventoryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryItemCopyWith<$Res> {
  factory $InventoryItemCopyWith(
    InventoryItem value,
    $Res Function(InventoryItem) then,
  ) = _$InventoryItemCopyWithImpl<$Res, InventoryItem>;
  @useResult
  $Res call({
    String id,
    String name,
    String image,
    int quantity,
    DateTime? expirationDate,
    StorageType storageType,
    ItemCategory category,
    String? imageUrl,
    DateTime addedDate,
  });
}

/// @nodoc
class _$InventoryItemCopyWithImpl<$Res, $Val extends InventoryItem>
    implements $InventoryItemCopyWith<$Res> {
  _$InventoryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InventoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? image = null,
    Object? quantity = null,
    Object? expirationDate = freezed,
    Object? storageType = null,
    Object? category = null,
    Object? imageUrl = freezed,
    Object? addedDate = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            image:
                null == image
                    ? _value.image
                    : image // ignore: cast_nullable_to_non_nullable
                        as String,
            quantity:
                null == quantity
                    ? _value.quantity
                    : quantity // ignore: cast_nullable_to_non_nullable
                        as int,
            expirationDate:
                freezed == expirationDate
                    ? _value.expirationDate
                    : expirationDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            storageType:
                null == storageType
                    ? _value.storageType
                    : storageType // ignore: cast_nullable_to_non_nullable
                        as StorageType,
            category:
                null == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as ItemCategory,
            imageUrl:
                freezed == imageUrl
                    ? _value.imageUrl
                    : imageUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            addedDate:
                null == addedDate
                    ? _value.addedDate
                    : addedDate // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InventoryItemImplCopyWith<$Res>
    implements $InventoryItemCopyWith<$Res> {
  factory _$$InventoryItemImplCopyWith(
    _$InventoryItemImpl value,
    $Res Function(_$InventoryItemImpl) then,
  ) = __$$InventoryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String image,
    int quantity,
    DateTime? expirationDate,
    StorageType storageType,
    ItemCategory category,
    String? imageUrl,
    DateTime addedDate,
  });
}

/// @nodoc
class __$$InventoryItemImplCopyWithImpl<$Res>
    extends _$InventoryItemCopyWithImpl<$Res, _$InventoryItemImpl>
    implements _$$InventoryItemImplCopyWith<$Res> {
  __$$InventoryItemImplCopyWithImpl(
    _$InventoryItemImpl _value,
    $Res Function(_$InventoryItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InventoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? image = null,
    Object? quantity = null,
    Object? expirationDate = freezed,
    Object? storageType = null,
    Object? category = null,
    Object? imageUrl = freezed,
    Object? addedDate = null,
  }) {
    return _then(
      _$InventoryItemImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        image:
            null == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                    as String,
        quantity:
            null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                    as int,
        expirationDate:
            freezed == expirationDate
                ? _value.expirationDate
                : expirationDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        storageType:
            null == storageType
                ? _value.storageType
                : storageType // ignore: cast_nullable_to_non_nullable
                    as StorageType,
        category:
            null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                    as ItemCategory,
        imageUrl:
            freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        addedDate:
            null == addedDate
                ? _value.addedDate
                : addedDate // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InventoryItemImpl implements _InventoryItem {
  const _$InventoryItemImpl({
    required this.id,
    required this.name,
    required this.image,
    required this.quantity,
    this.expirationDate,
    required this.storageType,
    required this.category,
    this.imageUrl,
    required this.addedDate,
  });

  factory _$InventoryItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$InventoryItemImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String image;
  @override
  final int quantity;
  @override
  final DateTime? expirationDate;
  @override
  final StorageType storageType;
  @override
  final ItemCategory category;
  @override
  final String? imageUrl;
  @override
  final DateTime addedDate;

  @override
  String toString() {
    return 'InventoryItem(id: $id, name: $name, image: $image, quantity: $quantity, expirationDate: $expirationDate, storageType: $storageType, category: $category, imageUrl: $imageUrl, addedDate: $addedDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.expirationDate, expirationDate) ||
                other.expirationDate == expirationDate) &&
            (identical(other.storageType, storageType) ||
                other.storageType == storageType) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.addedDate, addedDate) ||
                other.addedDate == addedDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    image,
    quantity,
    expirationDate,
    storageType,
    category,
    imageUrl,
    addedDate,
  );

  /// Create a copy of InventoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryItemImplCopyWith<_$InventoryItemImpl> get copyWith =>
      __$$InventoryItemImplCopyWithImpl<_$InventoryItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InventoryItemImplToJson(this);
  }
}

abstract class _InventoryItem implements InventoryItem {
  const factory _InventoryItem({
    required final String id,
    required final String name,
    required final String image,
    required final int quantity,
    final DateTime? expirationDate,
    required final StorageType storageType,
    required final ItemCategory category,
    final String? imageUrl,
    required final DateTime addedDate,
  }) = _$InventoryItemImpl;

  factory _InventoryItem.fromJson(Map<String, dynamic> json) =
      _$InventoryItemImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get image;
  @override
  int get quantity;
  @override
  DateTime? get expirationDate;
  @override
  StorageType get storageType;
  @override
  ItemCategory get category;
  @override
  String? get imageUrl;
  @override
  DateTime get addedDate;

  /// Create a copy of InventoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InventoryItemImplCopyWith<_$InventoryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
