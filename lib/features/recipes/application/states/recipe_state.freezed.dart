// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Recipe {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  List<String> get ingredients =>
      throw _privateConstructorUsedError; // List of ingredient names or IDs
  // Smart mode specific fields (might be null in explore mode)
  int? get requiredIngredientsCount => throw _privateConstructorUsedError;
  int? get availableIngredientsCount => throw _privateConstructorUsedError;
  bool get usesExpiringItems => throw _privateConstructorUsedError;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecipeCopyWith<Recipe> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeCopyWith<$Res> {
  factory $RecipeCopyWith(Recipe value, $Res Function(Recipe) then) =
      _$RecipeCopyWithImpl<$Res, Recipe>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String? imageUrl,
    String emoji,
    List<String> ingredients,
    int? requiredIngredientsCount,
    int? availableIngredientsCount,
    bool usesExpiringItems,
  });
}

/// @nodoc
class _$RecipeCopyWithImpl<$Res, $Val extends Recipe>
    implements $RecipeCopyWith<$Res> {
  _$RecipeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? imageUrl = freezed,
    Object? emoji = null,
    Object? ingredients = null,
    Object? requiredIngredientsCount = freezed,
    Object? availableIngredientsCount = freezed,
    Object? usesExpiringItems = null,
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
            description:
                null == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String,
            imageUrl:
                freezed == imageUrl
                    ? _value.imageUrl
                    : imageUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            emoji:
                null == emoji
                    ? _value.emoji
                    : emoji // ignore: cast_nullable_to_non_nullable
                        as String,
            ingredients:
                null == ingredients
                    ? _value.ingredients
                    : ingredients // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            requiredIngredientsCount:
                freezed == requiredIngredientsCount
                    ? _value.requiredIngredientsCount
                    : requiredIngredientsCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            availableIngredientsCount:
                freezed == availableIngredientsCount
                    ? _value.availableIngredientsCount
                    : availableIngredientsCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            usesExpiringItems:
                null == usesExpiringItems
                    ? _value.usesExpiringItems
                    : usesExpiringItems // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecipeImplCopyWith<$Res> implements $RecipeCopyWith<$Res> {
  factory _$$RecipeImplCopyWith(
    _$RecipeImpl value,
    $Res Function(_$RecipeImpl) then,
  ) = __$$RecipeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String? imageUrl,
    String emoji,
    List<String> ingredients,
    int? requiredIngredientsCount,
    int? availableIngredientsCount,
    bool usesExpiringItems,
  });
}

/// @nodoc
class __$$RecipeImplCopyWithImpl<$Res>
    extends _$RecipeCopyWithImpl<$Res, _$RecipeImpl>
    implements _$$RecipeImplCopyWith<$Res> {
  __$$RecipeImplCopyWithImpl(
    _$RecipeImpl _value,
    $Res Function(_$RecipeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? imageUrl = freezed,
    Object? emoji = null,
    Object? ingredients = null,
    Object? requiredIngredientsCount = freezed,
    Object? availableIngredientsCount = freezed,
    Object? usesExpiringItems = null,
  }) {
    return _then(
      _$RecipeImpl(
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
        description:
            null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String,
        imageUrl:
            freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        emoji:
            null == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                    as String,
        ingredients:
            null == ingredients
                ? _value._ingredients
                : ingredients // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        requiredIngredientsCount:
            freezed == requiredIngredientsCount
                ? _value.requiredIngredientsCount
                : requiredIngredientsCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        availableIngredientsCount:
            freezed == availableIngredientsCount
                ? _value.availableIngredientsCount
                : availableIngredientsCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        usesExpiringItems:
            null == usesExpiringItems
                ? _value.usesExpiringItems
                : usesExpiringItems // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc

class _$RecipeImpl with DiagnosticableTreeMixin implements _Recipe {
  const _$RecipeImpl({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.emoji = '🍲',
    required final List<String> ingredients,
    this.requiredIngredientsCount,
    this.availableIngredientsCount,
    this.usesExpiringItems = false,
  }) : _ingredients = ingredients;

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String? imageUrl;
  @override
  @JsonKey()
  final String emoji;
  final List<String> _ingredients;
  @override
  List<String> get ingredients {
    if (_ingredients is EqualUnmodifiableListView) return _ingredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredients);
  }

  // List of ingredient names or IDs
  // Smart mode specific fields (might be null in explore mode)
  @override
  final int? requiredIngredientsCount;
  @override
  final int? availableIngredientsCount;
  @override
  @JsonKey()
  final bool usesExpiringItems;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Recipe(id: $id, name: $name, description: $description, imageUrl: $imageUrl, emoji: $emoji, ingredients: $ingredients, requiredIngredientsCount: $requiredIngredientsCount, availableIngredientsCount: $availableIngredientsCount, usesExpiringItems: $usesExpiringItems)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Recipe'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('imageUrl', imageUrl))
      ..add(DiagnosticsProperty('emoji', emoji))
      ..add(DiagnosticsProperty('ingredients', ingredients))
      ..add(
        DiagnosticsProperty(
          'requiredIngredientsCount',
          requiredIngredientsCount,
        ),
      )
      ..add(
        DiagnosticsProperty(
          'availableIngredientsCount',
          availableIngredientsCount,
        ),
      )
      ..add(DiagnosticsProperty('usesExpiringItems', usesExpiringItems));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            const DeepCollectionEquality().equals(
              other._ingredients,
              _ingredients,
            ) &&
            (identical(
                  other.requiredIngredientsCount,
                  requiredIngredientsCount,
                ) ||
                other.requiredIngredientsCount == requiredIngredientsCount) &&
            (identical(
                  other.availableIngredientsCount,
                  availableIngredientsCount,
                ) ||
                other.availableIngredientsCount == availableIngredientsCount) &&
            (identical(other.usesExpiringItems, usesExpiringItems) ||
                other.usesExpiringItems == usesExpiringItems));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    imageUrl,
    emoji,
    const DeepCollectionEquality().hash(_ingredients),
    requiredIngredientsCount,
    availableIngredientsCount,
    usesExpiringItems,
  );

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeImplCopyWith<_$RecipeImpl> get copyWith =>
      __$$RecipeImplCopyWithImpl<_$RecipeImpl>(this, _$identity);
}

abstract class _Recipe implements Recipe {
  const factory _Recipe({
    required final String id,
    required final String name,
    required final String description,
    final String? imageUrl,
    final String emoji,
    required final List<String> ingredients,
    final int? requiredIngredientsCount,
    final int? availableIngredientsCount,
    final bool usesExpiringItems,
  }) = _$RecipeImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String? get imageUrl;
  @override
  String get emoji;
  @override
  List<String> get ingredients; // List of ingredient names or IDs
  // Smart mode specific fields (might be null in explore mode)
  @override
  int? get requiredIngredientsCount;
  @override
  int? get availableIngredientsCount;
  @override
  bool get usesExpiringItems;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecipeImplCopyWith<_$RecipeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RecipeState {
  bool get isLoading => throw _privateConstructorUsedError;
  List<Recipe> get recipes => throw _privateConstructorUsedError;
  String? get errorMessage =>
      throw _privateConstructorUsedError; // Smart mode specific
  int? get expiringIngredientsUsedCount =>
      throw _privateConstructorUsedError; // Explore mode specific
  String get searchQuery => throw _privateConstructorUsedError;
  bool get showOnlyWithMyIngredients =>
      throw _privateConstructorUsedError; // Map of category value to Set of selected filter values
  // e.g., {"Tipo de receta": {"entrada", "postre"}, "Tiempo de preparación": {"short_time"}}
  Map<String, Set<String>>? get selectedFilters =>
      throw _privateConstructorUsedError;

  /// Create a copy of RecipeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecipeStateCopyWith<RecipeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeStateCopyWith<$Res> {
  factory $RecipeStateCopyWith(
    RecipeState value,
    $Res Function(RecipeState) then,
  ) = _$RecipeStateCopyWithImpl<$Res, RecipeState>;
  @useResult
  $Res call({
    bool isLoading,
    List<Recipe> recipes,
    String? errorMessage,
    int? expiringIngredientsUsedCount,
    String searchQuery,
    bool showOnlyWithMyIngredients,
    Map<String, Set<String>>? selectedFilters,
  });
}

/// @nodoc
class _$RecipeStateCopyWithImpl<$Res, $Val extends RecipeState>
    implements $RecipeStateCopyWith<$Res> {
  _$RecipeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecipeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? recipes = null,
    Object? errorMessage = freezed,
    Object? expiringIngredientsUsedCount = freezed,
    Object? searchQuery = null,
    Object? showOnlyWithMyIngredients = null,
    Object? selectedFilters = freezed,
  }) {
    return _then(
      _value.copyWith(
            isLoading:
                null == isLoading
                    ? _value.isLoading
                    : isLoading // ignore: cast_nullable_to_non_nullable
                        as bool,
            recipes:
                null == recipes
                    ? _value.recipes
                    : recipes // ignore: cast_nullable_to_non_nullable
                        as List<Recipe>,
            errorMessage:
                freezed == errorMessage
                    ? _value.errorMessage
                    : errorMessage // ignore: cast_nullable_to_non_nullable
                        as String?,
            expiringIngredientsUsedCount:
                freezed == expiringIngredientsUsedCount
                    ? _value.expiringIngredientsUsedCount
                    : expiringIngredientsUsedCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            searchQuery:
                null == searchQuery
                    ? _value.searchQuery
                    : searchQuery // ignore: cast_nullable_to_non_nullable
                        as String,
            showOnlyWithMyIngredients:
                null == showOnlyWithMyIngredients
                    ? _value.showOnlyWithMyIngredients
                    : showOnlyWithMyIngredients // ignore: cast_nullable_to_non_nullable
                        as bool,
            selectedFilters:
                freezed == selectedFilters
                    ? _value.selectedFilters
                    : selectedFilters // ignore: cast_nullable_to_non_nullable
                        as Map<String, Set<String>>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecipeStateImplCopyWith<$Res>
    implements $RecipeStateCopyWith<$Res> {
  factory _$$RecipeStateImplCopyWith(
    _$RecipeStateImpl value,
    $Res Function(_$RecipeStateImpl) then,
  ) = __$$RecipeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isLoading,
    List<Recipe> recipes,
    String? errorMessage,
    int? expiringIngredientsUsedCount,
    String searchQuery,
    bool showOnlyWithMyIngredients,
    Map<String, Set<String>>? selectedFilters,
  });
}

/// @nodoc
class __$$RecipeStateImplCopyWithImpl<$Res>
    extends _$RecipeStateCopyWithImpl<$Res, _$RecipeStateImpl>
    implements _$$RecipeStateImplCopyWith<$Res> {
  __$$RecipeStateImplCopyWithImpl(
    _$RecipeStateImpl _value,
    $Res Function(_$RecipeStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecipeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? recipes = null,
    Object? errorMessage = freezed,
    Object? expiringIngredientsUsedCount = freezed,
    Object? searchQuery = null,
    Object? showOnlyWithMyIngredients = null,
    Object? selectedFilters = freezed,
  }) {
    return _then(
      _$RecipeStateImpl(
        isLoading:
            null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                    as bool,
        recipes:
            null == recipes
                ? _value._recipes
                : recipes // ignore: cast_nullable_to_non_nullable
                    as List<Recipe>,
        errorMessage:
            freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                    as String?,
        expiringIngredientsUsedCount:
            freezed == expiringIngredientsUsedCount
                ? _value.expiringIngredientsUsedCount
                : expiringIngredientsUsedCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        searchQuery:
            null == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                    as String,
        showOnlyWithMyIngredients:
            null == showOnlyWithMyIngredients
                ? _value.showOnlyWithMyIngredients
                : showOnlyWithMyIngredients // ignore: cast_nullable_to_non_nullable
                    as bool,
        selectedFilters:
            freezed == selectedFilters
                ? _value._selectedFilters
                : selectedFilters // ignore: cast_nullable_to_non_nullable
                    as Map<String, Set<String>>?,
      ),
    );
  }
}

/// @nodoc

class _$RecipeStateImpl with DiagnosticableTreeMixin implements _RecipeState {
  const _$RecipeStateImpl({
    this.isLoading = false,
    final List<Recipe> recipes = const [],
    this.errorMessage,
    this.expiringIngredientsUsedCount,
    this.searchQuery = '',
    this.showOnlyWithMyIngredients = false,
    final Map<String, Set<String>>? selectedFilters,
  }) : _recipes = recipes,
       _selectedFilters = selectedFilters;

  @override
  @JsonKey()
  final bool isLoading;
  final List<Recipe> _recipes;
  @override
  @JsonKey()
  List<Recipe> get recipes {
    if (_recipes is EqualUnmodifiableListView) return _recipes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recipes);
  }

  @override
  final String? errorMessage;
  // Smart mode specific
  @override
  final int? expiringIngredientsUsedCount;
  // Explore mode specific
  @override
  @JsonKey()
  final String searchQuery;
  @override
  @JsonKey()
  final bool showOnlyWithMyIngredients;
  // Map of category value to Set of selected filter values
  // e.g., {"Tipo de receta": {"entrada", "postre"}, "Tiempo de preparación": {"short_time"}}
  final Map<String, Set<String>>? _selectedFilters;
  // Map of category value to Set of selected filter values
  // e.g., {"Tipo de receta": {"entrada", "postre"}, "Tiempo de preparación": {"short_time"}}
  @override
  Map<String, Set<String>>? get selectedFilters {
    final value = _selectedFilters;
    if (value == null) return null;
    if (_selectedFilters is EqualUnmodifiableMapView) return _selectedFilters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'RecipeState(isLoading: $isLoading, recipes: $recipes, errorMessage: $errorMessage, expiringIngredientsUsedCount: $expiringIngredientsUsedCount, searchQuery: $searchQuery, showOnlyWithMyIngredients: $showOnlyWithMyIngredients, selectedFilters: $selectedFilters)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'RecipeState'))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('recipes', recipes))
      ..add(DiagnosticsProperty('errorMessage', errorMessage))
      ..add(
        DiagnosticsProperty(
          'expiringIngredientsUsedCount',
          expiringIngredientsUsedCount,
        ),
      )
      ..add(DiagnosticsProperty('searchQuery', searchQuery))
      ..add(
        DiagnosticsProperty(
          'showOnlyWithMyIngredients',
          showOnlyWithMyIngredients,
        ),
      )
      ..add(DiagnosticsProperty('selectedFilters', selectedFilters));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality().equals(other._recipes, _recipes) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(
                  other.expiringIngredientsUsedCount,
                  expiringIngredientsUsedCount,
                ) ||
                other.expiringIngredientsUsedCount ==
                    expiringIngredientsUsedCount) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(
                  other.showOnlyWithMyIngredients,
                  showOnlyWithMyIngredients,
                ) ||
                other.showOnlyWithMyIngredients == showOnlyWithMyIngredients) &&
            const DeepCollectionEquality().equals(
              other._selectedFilters,
              _selectedFilters,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isLoading,
    const DeepCollectionEquality().hash(_recipes),
    errorMessage,
    expiringIngredientsUsedCount,
    searchQuery,
    showOnlyWithMyIngredients,
    const DeepCollectionEquality().hash(_selectedFilters),
  );

  /// Create a copy of RecipeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeStateImplCopyWith<_$RecipeStateImpl> get copyWith =>
      __$$RecipeStateImplCopyWithImpl<_$RecipeStateImpl>(this, _$identity);
}

abstract class _RecipeState implements RecipeState {
  const factory _RecipeState({
    final bool isLoading,
    final List<Recipe> recipes,
    final String? errorMessage,
    final int? expiringIngredientsUsedCount,
    final String searchQuery,
    final bool showOnlyWithMyIngredients,
    final Map<String, Set<String>>? selectedFilters,
  }) = _$RecipeStateImpl;

  @override
  bool get isLoading;
  @override
  List<Recipe> get recipes;
  @override
  String? get errorMessage; // Smart mode specific
  @override
  int? get expiringIngredientsUsedCount; // Explore mode specific
  @override
  String get searchQuery;
  @override
  bool get showOnlyWithMyIngredients; // Map of category value to Set of selected filter values
  // e.g., {"Tipo de receta": {"entrada", "postre"}, "Tiempo de preparación": {"short_time"}}
  @override
  Map<String, Set<String>>? get selectedFilters;

  /// Create a copy of RecipeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecipeStateImplCopyWith<_$RecipeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
