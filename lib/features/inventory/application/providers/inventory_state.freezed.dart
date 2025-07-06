// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InventoryState {

 List<InventoryItem> get items; String get searchQuery; ItemCategory get categoryFilter; Set<StorageType> get storageFilter; ExpirationStatus get expirationStatusFilter; InventorySortCriteria get sortCriteria; bool get sortAscending; Set<String> get recentlyAddedIds; Map<String, String> get userSelectedBatchOverrides; bool get isLoading; String? get errorMessage;
/// Create a copy of InventoryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryStateCopyWith<InventoryState> get copyWith => _$InventoryStateCopyWithImpl<InventoryState>(this as InventoryState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryState&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.categoryFilter, categoryFilter) || other.categoryFilter == categoryFilter)&&const DeepCollectionEquality().equals(other.storageFilter, storageFilter)&&(identical(other.expirationStatusFilter, expirationStatusFilter) || other.expirationStatusFilter == expirationStatusFilter)&&(identical(other.sortCriteria, sortCriteria) || other.sortCriteria == sortCriteria)&&(identical(other.sortAscending, sortAscending) || other.sortAscending == sortAscending)&&const DeepCollectionEquality().equals(other.recentlyAddedIds, recentlyAddedIds)&&const DeepCollectionEquality().equals(other.userSelectedBatchOverrides, userSelectedBatchOverrides)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),searchQuery,categoryFilter,const DeepCollectionEquality().hash(storageFilter),expirationStatusFilter,sortCriteria,sortAscending,const DeepCollectionEquality().hash(recentlyAddedIds),const DeepCollectionEquality().hash(userSelectedBatchOverrides),isLoading,errorMessage);

@override
String toString() {
  return 'InventoryState(items: $items, searchQuery: $searchQuery, categoryFilter: $categoryFilter, storageFilter: $storageFilter, expirationStatusFilter: $expirationStatusFilter, sortCriteria: $sortCriteria, sortAscending: $sortAscending, recentlyAddedIds: $recentlyAddedIds, userSelectedBatchOverrides: $userSelectedBatchOverrides, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $InventoryStateCopyWith<$Res>  {
  factory $InventoryStateCopyWith(InventoryState value, $Res Function(InventoryState) _then) = _$InventoryStateCopyWithImpl;
@useResult
$Res call({
 List<InventoryItem> items, String searchQuery, ItemCategory categoryFilter, Set<StorageType> storageFilter, ExpirationStatus expirationStatusFilter, InventorySortCriteria sortCriteria, bool sortAscending, Set<String> recentlyAddedIds, Map<String, String> userSelectedBatchOverrides, bool isLoading, String? errorMessage
});




}
/// @nodoc
class _$InventoryStateCopyWithImpl<$Res>
    implements $InventoryStateCopyWith<$Res> {
  _$InventoryStateCopyWithImpl(this._self, this._then);

  final InventoryState _self;
  final $Res Function(InventoryState) _then;

/// Create a copy of InventoryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? searchQuery = null,Object? categoryFilter = null,Object? storageFilter = null,Object? expirationStatusFilter = null,Object? sortCriteria = null,Object? sortAscending = null,Object? recentlyAddedIds = null,Object? userSelectedBatchOverrides = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<InventoryItem>,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,categoryFilter: null == categoryFilter ? _self.categoryFilter : categoryFilter // ignore: cast_nullable_to_non_nullable
as ItemCategory,storageFilter: null == storageFilter ? _self.storageFilter : storageFilter // ignore: cast_nullable_to_non_nullable
as Set<StorageType>,expirationStatusFilter: null == expirationStatusFilter ? _self.expirationStatusFilter : expirationStatusFilter // ignore: cast_nullable_to_non_nullable
as ExpirationStatus,sortCriteria: null == sortCriteria ? _self.sortCriteria : sortCriteria // ignore: cast_nullable_to_non_nullable
as InventorySortCriteria,sortAscending: null == sortAscending ? _self.sortAscending : sortAscending // ignore: cast_nullable_to_non_nullable
as bool,recentlyAddedIds: null == recentlyAddedIds ? _self.recentlyAddedIds : recentlyAddedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,userSelectedBatchOverrides: null == userSelectedBatchOverrides ? _self.userSelectedBatchOverrides : userSelectedBatchOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc


class _InventoryState implements InventoryState {
  const _InventoryState({final  List<InventoryItem> items = const [], this.searchQuery = '', this.categoryFilter = ItemCategory.all, final  Set<StorageType> storageFilter = const {}, this.expirationStatusFilter = ExpirationStatus.all, this.sortCriteria = InventorySortCriteria.addedDate, this.sortAscending = false, final  Set<String> recentlyAddedIds = const {}, final  Map<String, String> userSelectedBatchOverrides = const {}, this.isLoading = false, this.errorMessage}): _items = items,_storageFilter = storageFilter,_recentlyAddedIds = recentlyAddedIds,_userSelectedBatchOverrides = userSelectedBatchOverrides;
  

 final  List<InventoryItem> _items;
@override@JsonKey() List<InventoryItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  String searchQuery;
@override@JsonKey() final  ItemCategory categoryFilter;
 final  Set<StorageType> _storageFilter;
@override@JsonKey() Set<StorageType> get storageFilter {
  if (_storageFilter is EqualUnmodifiableSetView) return _storageFilter;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_storageFilter);
}

@override@JsonKey() final  ExpirationStatus expirationStatusFilter;
@override@JsonKey() final  InventorySortCriteria sortCriteria;
@override@JsonKey() final  bool sortAscending;
 final  Set<String> _recentlyAddedIds;
@override@JsonKey() Set<String> get recentlyAddedIds {
  if (_recentlyAddedIds is EqualUnmodifiableSetView) return _recentlyAddedIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_recentlyAddedIds);
}

 final  Map<String, String> _userSelectedBatchOverrides;
@override@JsonKey() Map<String, String> get userSelectedBatchOverrides {
  if (_userSelectedBatchOverrides is EqualUnmodifiableMapView) return _userSelectedBatchOverrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_userSelectedBatchOverrides);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;

/// Create a copy of InventoryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryStateCopyWith<_InventoryState> get copyWith => __$InventoryStateCopyWithImpl<_InventoryState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryState&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.categoryFilter, categoryFilter) || other.categoryFilter == categoryFilter)&&const DeepCollectionEquality().equals(other._storageFilter, _storageFilter)&&(identical(other.expirationStatusFilter, expirationStatusFilter) || other.expirationStatusFilter == expirationStatusFilter)&&(identical(other.sortCriteria, sortCriteria) || other.sortCriteria == sortCriteria)&&(identical(other.sortAscending, sortAscending) || other.sortAscending == sortAscending)&&const DeepCollectionEquality().equals(other._recentlyAddedIds, _recentlyAddedIds)&&const DeepCollectionEquality().equals(other._userSelectedBatchOverrides, _userSelectedBatchOverrides)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),searchQuery,categoryFilter,const DeepCollectionEquality().hash(_storageFilter),expirationStatusFilter,sortCriteria,sortAscending,const DeepCollectionEquality().hash(_recentlyAddedIds),const DeepCollectionEquality().hash(_userSelectedBatchOverrides),isLoading,errorMessage);

@override
String toString() {
  return 'InventoryState(items: $items, searchQuery: $searchQuery, categoryFilter: $categoryFilter, storageFilter: $storageFilter, expirationStatusFilter: $expirationStatusFilter, sortCriteria: $sortCriteria, sortAscending: $sortAscending, recentlyAddedIds: $recentlyAddedIds, userSelectedBatchOverrides: $userSelectedBatchOverrides, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$InventoryStateCopyWith<$Res> implements $InventoryStateCopyWith<$Res> {
  factory _$InventoryStateCopyWith(_InventoryState value, $Res Function(_InventoryState) _then) = __$InventoryStateCopyWithImpl;
@override @useResult
$Res call({
 List<InventoryItem> items, String searchQuery, ItemCategory categoryFilter, Set<StorageType> storageFilter, ExpirationStatus expirationStatusFilter, InventorySortCriteria sortCriteria, bool sortAscending, Set<String> recentlyAddedIds, Map<String, String> userSelectedBatchOverrides, bool isLoading, String? errorMessage
});




}
/// @nodoc
class __$InventoryStateCopyWithImpl<$Res>
    implements _$InventoryStateCopyWith<$Res> {
  __$InventoryStateCopyWithImpl(this._self, this._then);

  final _InventoryState _self;
  final $Res Function(_InventoryState) _then;

/// Create a copy of InventoryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? searchQuery = null,Object? categoryFilter = null,Object? storageFilter = null,Object? expirationStatusFilter = null,Object? sortCriteria = null,Object? sortAscending = null,Object? recentlyAddedIds = null,Object? userSelectedBatchOverrides = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_InventoryState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<InventoryItem>,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,categoryFilter: null == categoryFilter ? _self.categoryFilter : categoryFilter // ignore: cast_nullable_to_non_nullable
as ItemCategory,storageFilter: null == storageFilter ? _self._storageFilter : storageFilter // ignore: cast_nullable_to_non_nullable
as Set<StorageType>,expirationStatusFilter: null == expirationStatusFilter ? _self.expirationStatusFilter : expirationStatusFilter // ignore: cast_nullable_to_non_nullable
as ExpirationStatus,sortCriteria: null == sortCriteria ? _self.sortCriteria : sortCriteria // ignore: cast_nullable_to_non_nullable
as InventorySortCriteria,sortAscending: null == sortAscending ? _self.sortAscending : sortAscending // ignore: cast_nullable_to_non_nullable
as bool,recentlyAddedIds: null == recentlyAddedIds ? _self._recentlyAddedIds : recentlyAddedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,userSelectedBatchOverrides: null == userSelectedBatchOverrides ? _self._userSelectedBatchOverrides : userSelectedBatchOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
