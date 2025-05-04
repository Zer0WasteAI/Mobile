// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$InventoryState {
  List<InventoryItem> get items => throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;
  ItemCategory get categoryFilter => throw _privateConstructorUsedError;
  Set<StorageType> get storageFilter => throw _privateConstructorUsedError;
  ExpirationStatus get expirationStatusFilter =>
      throw _privateConstructorUsedError;
  InventorySortCriteria get sortCriteria => throw _privateConstructorUsedError;
  bool get sortAscending =>
      throw _privateConstructorUsedError; // Default A-Z for name
  Set<String> get recentlyAddedIds => throw _privateConstructorUsedError;
  Map<String, String> get userSelectedBatchOverrides =>
      throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of InventoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InventoryStateCopyWith<InventoryState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryStateCopyWith<$Res> {
  factory $InventoryStateCopyWith(
    InventoryState value,
    $Res Function(InventoryState) then,
  ) = _$InventoryStateCopyWithImpl<$Res, InventoryState>;
  @useResult
  $Res call({
    List<InventoryItem> items,
    String searchQuery,
    ItemCategory categoryFilter,
    Set<StorageType> storageFilter,
    ExpirationStatus expirationStatusFilter,
    InventorySortCriteria sortCriteria,
    bool sortAscending,
    Set<String> recentlyAddedIds,
    Map<String, String> userSelectedBatchOverrides,
    bool isLoading,
    String? errorMessage,
  });
}

/// @nodoc
class _$InventoryStateCopyWithImpl<$Res, $Val extends InventoryState>
    implements $InventoryStateCopyWith<$Res> {
  _$InventoryStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InventoryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? searchQuery = null,
    Object? categoryFilter = null,
    Object? storageFilter = null,
    Object? expirationStatusFilter = null,
    Object? sortCriteria = null,
    Object? sortAscending = null,
    Object? recentlyAddedIds = null,
    Object? userSelectedBatchOverrides = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            items:
                null == items
                    ? _value.items
                    : items // ignore: cast_nullable_to_non_nullable
                        as List<InventoryItem>,
            searchQuery:
                null == searchQuery
                    ? _value.searchQuery
                    : searchQuery // ignore: cast_nullable_to_non_nullable
                        as String,
            categoryFilter:
                null == categoryFilter
                    ? _value.categoryFilter
                    : categoryFilter // ignore: cast_nullable_to_non_nullable
                        as ItemCategory,
            storageFilter:
                null == storageFilter
                    ? _value.storageFilter
                    : storageFilter // ignore: cast_nullable_to_non_nullable
                        as Set<StorageType>,
            expirationStatusFilter:
                null == expirationStatusFilter
                    ? _value.expirationStatusFilter
                    : expirationStatusFilter // ignore: cast_nullable_to_non_nullable
                        as ExpirationStatus,
            sortCriteria:
                null == sortCriteria
                    ? _value.sortCriteria
                    : sortCriteria // ignore: cast_nullable_to_non_nullable
                        as InventorySortCriteria,
            sortAscending:
                null == sortAscending
                    ? _value.sortAscending
                    : sortAscending // ignore: cast_nullable_to_non_nullable
                        as bool,
            recentlyAddedIds:
                null == recentlyAddedIds
                    ? _value.recentlyAddedIds
                    : recentlyAddedIds // ignore: cast_nullable_to_non_nullable
                        as Set<String>,
            userSelectedBatchOverrides:
                null == userSelectedBatchOverrides
                    ? _value.userSelectedBatchOverrides
                    : userSelectedBatchOverrides // ignore: cast_nullable_to_non_nullable
                        as Map<String, String>,
            isLoading:
                null == isLoading
                    ? _value.isLoading
                    : isLoading // ignore: cast_nullable_to_non_nullable
                        as bool,
            errorMessage:
                freezed == errorMessage
                    ? _value.errorMessage
                    : errorMessage // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InventoryStateImplCopyWith<$Res>
    implements $InventoryStateCopyWith<$Res> {
  factory _$$InventoryStateImplCopyWith(
    _$InventoryStateImpl value,
    $Res Function(_$InventoryStateImpl) then,
  ) = __$$InventoryStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<InventoryItem> items,
    String searchQuery,
    ItemCategory categoryFilter,
    Set<StorageType> storageFilter,
    ExpirationStatus expirationStatusFilter,
    InventorySortCriteria sortCriteria,
    bool sortAscending,
    Set<String> recentlyAddedIds,
    Map<String, String> userSelectedBatchOverrides,
    bool isLoading,
    String? errorMessage,
  });
}

/// @nodoc
class __$$InventoryStateImplCopyWithImpl<$Res>
    extends _$InventoryStateCopyWithImpl<$Res, _$InventoryStateImpl>
    implements _$$InventoryStateImplCopyWith<$Res> {
  __$$InventoryStateImplCopyWithImpl(
    _$InventoryStateImpl _value,
    $Res Function(_$InventoryStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InventoryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? searchQuery = null,
    Object? categoryFilter = null,
    Object? storageFilter = null,
    Object? expirationStatusFilter = null,
    Object? sortCriteria = null,
    Object? sortAscending = null,
    Object? recentlyAddedIds = null,
    Object? userSelectedBatchOverrides = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$InventoryStateImpl(
        items:
            null == items
                ? _value._items
                : items // ignore: cast_nullable_to_non_nullable
                    as List<InventoryItem>,
        searchQuery:
            null == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                    as String,
        categoryFilter:
            null == categoryFilter
                ? _value.categoryFilter
                : categoryFilter // ignore: cast_nullable_to_non_nullable
                    as ItemCategory,
        storageFilter:
            null == storageFilter
                ? _value._storageFilter
                : storageFilter // ignore: cast_nullable_to_non_nullable
                    as Set<StorageType>,
        expirationStatusFilter:
            null == expirationStatusFilter
                ? _value.expirationStatusFilter
                : expirationStatusFilter // ignore: cast_nullable_to_non_nullable
                    as ExpirationStatus,
        sortCriteria:
            null == sortCriteria
                ? _value.sortCriteria
                : sortCriteria // ignore: cast_nullable_to_non_nullable
                    as InventorySortCriteria,
        sortAscending:
            null == sortAscending
                ? _value.sortAscending
                : sortAscending // ignore: cast_nullable_to_non_nullable
                    as bool,
        recentlyAddedIds:
            null == recentlyAddedIds
                ? _value._recentlyAddedIds
                : recentlyAddedIds // ignore: cast_nullable_to_non_nullable
                    as Set<String>,
        userSelectedBatchOverrides:
            null == userSelectedBatchOverrides
                ? _value._userSelectedBatchOverrides
                : userSelectedBatchOverrides // ignore: cast_nullable_to_non_nullable
                    as Map<String, String>,
        isLoading:
            null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                    as bool,
        errorMessage:
            freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc

class _$InventoryStateImpl implements _InventoryState {
  const _$InventoryStateImpl({
    final List<InventoryItem> items = const [],
    this.searchQuery = '',
    this.categoryFilter = ItemCategory.all,
    final Set<StorageType> storageFilter = const {},
    this.expirationStatusFilter = ExpirationStatus.all,
    this.sortCriteria = InventorySortCriteria.name,
    this.sortAscending = true,
    final Set<String> recentlyAddedIds = const {},
    final Map<String, String> userSelectedBatchOverrides = const {},
    this.isLoading = false,
    this.errorMessage,
  }) : _items = items,
       _storageFilter = storageFilter,
       _recentlyAddedIds = recentlyAddedIds,
       _userSelectedBatchOverrides = userSelectedBatchOverrides;

  final List<InventoryItem> _items;
  @override
  @JsonKey()
  List<InventoryItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final String searchQuery;
  @override
  @JsonKey()
  final ItemCategory categoryFilter;
  final Set<StorageType> _storageFilter;
  @override
  @JsonKey()
  Set<StorageType> get storageFilter {
    if (_storageFilter is EqualUnmodifiableSetView) return _storageFilter;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_storageFilter);
  }

  @override
  @JsonKey()
  final ExpirationStatus expirationStatusFilter;
  @override
  @JsonKey()
  final InventorySortCriteria sortCriteria;
  @override
  @JsonKey()
  final bool sortAscending;
  // Default A-Z for name
  final Set<String> _recentlyAddedIds;
  // Default A-Z for name
  @override
  @JsonKey()
  Set<String> get recentlyAddedIds {
    if (_recentlyAddedIds is EqualUnmodifiableSetView) return _recentlyAddedIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_recentlyAddedIds);
  }

  final Map<String, String> _userSelectedBatchOverrides;
  @override
  @JsonKey()
  Map<String, String> get userSelectedBatchOverrides {
    if (_userSelectedBatchOverrides is EqualUnmodifiableMapView)
      return _userSelectedBatchOverrides;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_userSelectedBatchOverrides);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'InventoryState(items: $items, searchQuery: $searchQuery, categoryFilter: $categoryFilter, storageFilter: $storageFilter, expirationStatusFilter: $expirationStatusFilter, sortCriteria: $sortCriteria, sortAscending: $sortAscending, recentlyAddedIds: $recentlyAddedIds, userSelectedBatchOverrides: $userSelectedBatchOverrides, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryStateImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.categoryFilter, categoryFilter) ||
                other.categoryFilter == categoryFilter) &&
            const DeepCollectionEquality().equals(
              other._storageFilter,
              _storageFilter,
            ) &&
            (identical(other.expirationStatusFilter, expirationStatusFilter) ||
                other.expirationStatusFilter == expirationStatusFilter) &&
            (identical(other.sortCriteria, sortCriteria) ||
                other.sortCriteria == sortCriteria) &&
            (identical(other.sortAscending, sortAscending) ||
                other.sortAscending == sortAscending) &&
            const DeepCollectionEquality().equals(
              other._recentlyAddedIds,
              _recentlyAddedIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._userSelectedBatchOverrides,
              _userSelectedBatchOverrides,
            ) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    searchQuery,
    categoryFilter,
    const DeepCollectionEquality().hash(_storageFilter),
    expirationStatusFilter,
    sortCriteria,
    sortAscending,
    const DeepCollectionEquality().hash(_recentlyAddedIds),
    const DeepCollectionEquality().hash(_userSelectedBatchOverrides),
    isLoading,
    errorMessage,
  );

  /// Create a copy of InventoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryStateImplCopyWith<_$InventoryStateImpl> get copyWith =>
      __$$InventoryStateImplCopyWithImpl<_$InventoryStateImpl>(
        this,
        _$identity,
      );
}

abstract class _InventoryState implements InventoryState {
  const factory _InventoryState({
    final List<InventoryItem> items,
    final String searchQuery,
    final ItemCategory categoryFilter,
    final Set<StorageType> storageFilter,
    final ExpirationStatus expirationStatusFilter,
    final InventorySortCriteria sortCriteria,
    final bool sortAscending,
    final Set<String> recentlyAddedIds,
    final Map<String, String> userSelectedBatchOverrides,
    final bool isLoading,
    final String? errorMessage,
  }) = _$InventoryStateImpl;

  @override
  List<InventoryItem> get items;
  @override
  String get searchQuery;
  @override
  ItemCategory get categoryFilter;
  @override
  Set<StorageType> get storageFilter;
  @override
  ExpirationStatus get expirationStatusFilter;
  @override
  InventorySortCriteria get sortCriteria;
  @override
  bool get sortAscending; // Default A-Z for name
  @override
  Set<String> get recentlyAddedIds;
  @override
  Map<String, String> get userSelectedBatchOverrides;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;

  /// Create a copy of InventoryState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InventoryStateImplCopyWith<_$InventoryStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
