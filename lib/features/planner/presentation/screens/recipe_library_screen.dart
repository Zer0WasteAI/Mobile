// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_providers.dart';
import 'package:zer0_waste_ai/features/planner/presentation/screens/planner_screen.dart';
import 'package:zer0_waste_ai/features/recipes/presentation/screens/create_recipe_screen.dart';
import 'package:intl/intl.dart';
import 'package:zer0_waste_ai/features/navigation/presentation/widgets/safe_navigation_buttons.dart';

class RecipeLibraryScreen extends ConsumerStatefulWidget {
  final bool selectionMode;
  final MealType? initialMealType;
  final Function(MealPlan)? onRecipeSelected;

  const RecipeLibraryScreen({
    super.key,
    this.selectionMode = false,
    this.initialMealType,
    this.onRecipeSelected,
  });

  @override
  ConsumerState<RecipeLibraryScreen> createState() =>
      _RecipeLibraryScreenState();
}

class _RecipeLibraryScreenState extends ConsumerState<RecipeLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _showFilterPanel = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(_onSearchChanged);

    // Aplicar filtro inicial de tipo de comida si está presente
    if (widget.initialMealType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Configurar un filtro por tipo de comida
        final currentFilters = ref.read(recipeFiltersProvider);
        ref.read(recipeFiltersProvider.notifier).state = currentFilters
            .copyWith(mealType: widget.initialMealType);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(recipeFiltersProvider.notifier).state = ref
        .read(recipeFiltersProvider)
        .copyWith(
          searchQuery:
              _searchController.text.isEmpty ? null : _searchController.text,
          clearSearch: _searchController.text.isEmpty,
        );
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black87;
    final primaryColor = const Color(0xFF00BFA5);

    final recipes = ref.watch(filteredRecipesProvider);
    final favorites = ref.watch(favoriteRecipesProvider);
    final recents = ref.watch(recentRecipesProvider);
    final filters = ref.watch(recipeFiltersProvider);

    final dietaryTags = [
      'Vegetariano',
      'Vegano',
      'Sin gluten',
      'Sin lácteos',
      'Sin azúcar',
      'Alto en proteínas',
      'Bajo en calorías',
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: SafeBackButton(iconColor: textColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title:
            widget.selectionMode
                ? Text(
                  'Seleccionar receta',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                )
                : null,
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: textColor),
            onPressed: () {
              setState(() {
                _showFilterPanel = !_showFilterPanel;
              });
            },
            tooltip: 'Filtros',
          ),
          if (!widget.selectionMode)
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: textColor),
              onPressed: () {
                // Navigate to create recipe screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateRecipeScreen(),
                  ),
                );
              },
              tooltip: 'Crear receta',
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la pantalla (solo si no está en modo selección)
          if (!widget.selectionMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                'Biblioteca de Recetas',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),

          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar recetas o ingredientes',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                        : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Panel de filtros
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showFilterPanel ? 180 : 0,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título de filtros
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filtros',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (filters.hasFilters)
                          TextButton(
                            onPressed: () {
                              ref.read(recipeFiltersProvider.notifier).state =
                                  RecipeFilters();
                              _searchController.clear();
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Limpiar todos'),
                          ),
                      ],
                    ),
                  ),

                  // Etiquetas dietéticas
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        dietaryTags.map((tag) {
                          final isSelected = filters.dietaryTags.contains(tag);
                          return FilterChip(
                            label: Text(tag),
                            selected: isSelected,
                            onSelected: (selected) {
                              final currentTags = [...filters.dietaryTags];
                              if (selected) {
                                currentTags.add(tag);
                              } else {
                                currentTags.remove(tag);
                              }
                              ref.read(recipeFiltersProvider.notifier).state =
                                  filters.copyWith(dietaryTags: currentTags);
                            },
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: primaryColor.withValues(alpha: 0.2),
                            checkmarkColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            labelStyle: GoogleFonts.inter(
                              color:
                                  isSelected
                                      ? primaryColor
                                      : Colors.grey.shade800,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                  ),

                  // Tiempo y calorías
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        // Tiempo de preparación
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tiempo máximo',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade100,
                                ),
                                child: DropdownButton<int?>(
                                  value: filters.maxPrepTimeMinutes,
                                  isExpanded: true,
                                  underline: SizedBox(),
                                  hint: Text('Cualquiera'),
                                  items: [
                                    DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('Cualquiera'),
                                    ),
                                    DropdownMenuItem<int?>(
                                      value: 15,
                                      child: Text('15 minutos'),
                                    ),
                                    DropdownMenuItem<int?>(
                                      value: 30,
                                      child: Text('30 minutos'),
                                    ),
                                    DropdownMenuItem<int?>(
                                      value: 60,
                                      child: Text('1 hora'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    ref
                                        .read(recipeFiltersProvider.notifier)
                                        .state = filters.copyWith(
                                      maxPrepTimeMinutes: value,
                                      clearPrepTime: value == null,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        // Calorías
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Calorías máximas',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade100,
                                ),
                                child: DropdownButton<int?>(
                                  value: filters.maxCalories,
                                  isExpanded: true,
                                  underline: SizedBox(),
                                  hint: Text('Cualquiera'),
                                  items: [
                                    DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('Cualquiera'),
                                    ),
                                    DropdownMenuItem<int?>(
                                      value: 300,
                                      child: Text('300 kcal'),
                                    ),
                                    DropdownMenuItem<int?>(
                                      value: 500,
                                      child: Text('500 kcal'),
                                    ),
                                    DropdownMenuItem<int?>(
                                      value: 800,
                                      child: Text('800 kcal'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    ref
                                        .read(recipeFiltersProvider.notifier)
                                        .state = filters.copyWith(
                                      maxCalories: value,
                                      clearCalories: value == null,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tabs de categorías
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: TabBar(
              controller: _tabController,
              indicatorColor: primaryColor,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey,
              labelStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              tabs: [
                Tab(text: 'Todas'),
                Tab(text: 'Favoritas'),
                Tab(text: 'Recientes'),
                Tab(text: 'Sugeridas IA'),
              ],
            ),
          ),

          // Contenido de las tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Todas las recetas
                _buildRecipeGrid(recipes, ref),

                // Favoritas
                favorites.isEmpty
                    ? _buildEmptyState(
                      'No tienes recetas favoritas',
                      'Marca tus recetas favoritas dando click en el ícono de corazón',
                    )
                    : _buildRecipeGrid(favorites, ref),

                // Recientes
                recents.isEmpty
                    ? _buildEmptyState(
                      'No hay recetas recientes',
                      'Las recetas que uses aparecerán aquí',
                    )
                    : _buildRecipeGrid(recents, ref),

                // Sugeridas por IA
                _buildAISuggestions(ref),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Si estamos en modo selección, volver sin seleccionar
          if (widget.selectionMode) {
            Navigator.pop(context);
          } else {
            // Generar sugerencia con IA
            _showAiSuggestionDialog(context, ref);
          }
        },
        backgroundColor: primaryColor,
        tooltip: widget.selectionMode ? 'Volver' : 'Generar con IA',
        child: Icon(
          widget.selectionMode ? Icons.arrow_back : Icons.auto_awesome,
        ),
      ),
    );
  }

  // Grid de recetas
  Widget _buildRecipeGrid(List<MealPlan> recipes, WidgetRef ref) {
    if (recipes.isEmpty) {
      return _buildEmptyState(
        'No se encontraron recetas',
        'Intenta con otros filtros o agrega tus propias recetas',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return _buildRecipeCard(recipe, ref);
      },
    );
  }

  // Tarjeta de receta
  Widget _buildRecipeCard(MealPlan recipe, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // Si estamos en modo selección, llamar al callback con la receta seleccionada
        if (widget.selectionMode && widget.onRecipeSelected != null) {
          widget.onRecipeSelected!(recipe);
        } else {
          // Ver detalles de la receta
          _showRecipeDetails(context, recipe, ref);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado con icono (altura fija)
                Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: recipe.type.color.withValues(alpha: 0.2),
                  ),
                  child: Stack(
                    children: [
                      // Icono del tipo de comida
                      Center(
                        child: Icon(
                          _getIconForRecipe(recipe),
                          size: 48,
                          color: recipe.type.color,
                        ),
                      ),
                      // Etiqueta de tipo
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: recipe.type.color.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            recipe.type.name,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      // Botón de favorito (solo si no estamos en modo selección)
                      if (!widget.selectionMode)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () {
                              ref
                                  .read(allRecipesProvider.notifier)
                                  .toggleFavorite(recipe.id);
                            },
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                recipe.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    recipe.isFavorite
                                        ? Colors.red
                                        : Colors.grey,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      // Mostrar botón de selección si estamos en modo selección
                      if (widget.selectionMode)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_circle_outline,
                              color: const Color(0xFF00BFA5),
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Contenido (resto de la tarjeta)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre de la receta
                        Text(
                          recipe.name,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 6),

                        // Tiempo y calorías
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 12, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              '${recipe.prepTimeMinutes} min',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.local_fire_department,
                              size: 12,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 4),
                            Text(
                              recipe.calories > 0
                                  ? '${recipe.calories} kcal'
                                  : 'Desconocido',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Etiquetas dietéticas (máximo 1 línea, máximo 2 etiquetas)
                        if (recipe.dietaryTags.isNotEmpty)
                          SizedBox(
                            height: 22,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children:
                                  recipe.dietaryTags.take(2).map((tag) {
                                    return Container(
                                      margin: EdgeInsets.only(right: 4),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: Colors.green.shade100,
                                        ),
                                      ),
                                      child: Text(
                                        tag,
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          )
                        else
                          SizedBox(height: 22),

                        // Botón para añadir al plan (siempre visible al final)
                        Spacer(),
                        if (!widget.selectionMode)
                          InkWell(
                            onTap: () {
                              // Actualizar fecha de último uso
                              ref
                                  .read(allRecipesProvider.notifier)
                                  .updateLastUsed(recipe.id);

                              // Mostrar diálogo para añadir al plan
                              _showAddToPlanDialog(context, recipe, ref);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00BFA5).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(
                                    0xFF00BFA5,
                                  ).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    size: 14,
                                    color: const Color(0xFF00BFA5),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Añadir al plan',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF00BFA5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Método para mostrar diálogo de añadir al plan
  void _showAddToPlanDialog(
    BuildContext context,
    MealPlan recipe,
    WidgetRef ref,
  ) {
    // Obtener la fecha actual por defecto
    final today = DateTime.now();
    DateTime selectedDate = today;

    // Formatear la fecha actual como clave
    String dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(
                  'Añadir al plan',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                content: Container(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información sobre la receta
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: recipe.type.color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              recipe.type.icon,
                              color: recipe.type.color,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: recipe.type.color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    recipe.type.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: recipe.type.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Selección de fecha
                      Text(
                        'Selecciona el día:',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),

                      // Opciones de fechas (hoy, mañana, otro día)
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedDate = today;
                            dateKey = DateFormat(
                              'yyyy-MM-dd',
                            ).format(selectedDate);
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color:
                                selectedDate.day == today.day
                                    ? const Color(0xFF00BFA5).withValues(alpha: 0.1)
                                    : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  selectedDate.day == today.day
                                      ? const Color(0xFF00BFA5)
                                      : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.today,
                                size: 18,
                                color:
                                    selectedDate.day == today.day
                                        ? const Color(0xFF00BFA5)
                                        : Colors.grey.shade600,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Hoy',
                                style: GoogleFonts.inter(
                                  fontWeight:
                                      selectedDate.day == today.day
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                  color:
                                      selectedDate.day == today.day
                                          ? const Color(0xFF00BFA5)
                                          : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 8),

                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedDate = today.add(Duration(days: 1));
                            dateKey = DateFormat(
                              'yyyy-MM-dd',
                            ).format(selectedDate);
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color:
                                selectedDate.day ==
                                        today.add(Duration(days: 1)).day
                                    ? const Color(0xFF00BFA5).withValues(alpha: 0.1)
                                    : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  selectedDate.day ==
                                          today.add(Duration(days: 1)).day
                                      ? const Color(0xFF00BFA5)
                                      : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.event,
                                size: 18,
                                color:
                                    selectedDate.day ==
                                            today.add(Duration(days: 1)).day
                                        ? const Color(0xFF00BFA5)
                                        : Colors.grey.shade600,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Mañana',
                                style: GoogleFonts.inter(
                                  fontWeight:
                                      selectedDate.day ==
                                              today.add(Duration(days: 1)).day
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                  color:
                                      selectedDate.day ==
                                              today.add(Duration(days: 1)).day
                                          ? const Color(0xFF00BFA5)
                                          : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 8),

                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: today,
                            firstDate: today,
                            lastDate: today.add(Duration(days: 30)),
                          );

                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                              dateKey = DateFormat(
                                'yyyy-MM-dd',
                              ).format(selectedDate);
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color:
                                selectedDate.day != today.day &&
                                        selectedDate.day !=
                                            today.add(Duration(days: 1)).day
                                    ? const Color(0xFF00BFA5).withValues(alpha: 0.1)
                                    : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  selectedDate.day != today.day &&
                                          selectedDate.day !=
                                              today.add(Duration(days: 1)).day
                                      ? const Color(0xFF00BFA5)
                                      : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                size: 18,
                                color:
                                    selectedDate.day != today.day &&
                                            selectedDate.day !=
                                                today.add(Duration(days: 1)).day
                                        ? const Color(0xFF00BFA5)
                                        : Colors.grey.shade600,
                              ),
                              SizedBox(width: 8),
                              Text(
                                selectedDate.day != today.day &&
                                        selectedDate.day !=
                                            today.add(Duration(days: 1)).day
                                    ? DateFormat(
                                      'EEEE d MMMM',
                                      'es_ES',
                                    ).format(selectedDate).capitalizePlanner()
                                    : 'Otro día',
                                style: GoogleFonts.inter(
                                  fontWeight:
                                      selectedDate.day != today.day &&
                                              selectedDate.day !=
                                                  today
                                                      .add(Duration(days: 1))
                                                      .day
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                  color:
                                      selectedDate.day != today.day &&
                                              selectedDate.day !=
                                                  today
                                                      .add(Duration(days: 1))
                                                      .day
                                          ? const Color(0xFF00BFA5)
                                          : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.inter(color: Colors.grey.shade700),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);

                      // Agregar la comida al plan con las mismas validaciones que en el planificador
                      _addMealToPlan(context, ref, recipe, dateKey);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Añadir'),
                  ),
                ],
              );
            },
          ),
    );
  }

  // Método para añadir comida al plan con validaciones
  void _addMealToPlan(
    BuildContext context,
    WidgetRef ref,
    MealPlan meal,
    String dateKey,
  ) {
    // Obtener todos los planes de comida existentes
    final allMealPlans = ref.read(mealPlansProvider);

    // Obtener las preferencias del usuario
    final preferences = ref.read(userPlanningPreferencesProvider);

    // Realizar todas las validaciones
    final validations = MealPlanValidator.validateMealPlan(
      newMeal: meal,
      dateKey: dateKey,
      allMealPlans: allMealPlans,
      preferences: preferences,
    );

    // Guardar los resultados de la validación
    ref.read(lastValidationResultsProvider.notifier).state = validations;

    // Verificar si hay errores (validaciones que no son válidas)
    final hasErrors = validations.any((v) => !v.isValid);

    if (hasErrors) {
      // Mostrar diálogo de error
      _showValidationDialog(
        context,
        validations.where((v) => !v.isValid).toList(),
        onContinue: null, // No hay opción de continuar si hay errores
      );
      return;
    }

    // Verificar si hay advertencias
    final warnings =
        validations
            .where((v) => v.isValid && v.severity == ValidationSeverity.warning)
            .toList();

    if (warnings.isNotEmpty) {
      // Mostrar diálogo de advertencia con opción de continuar
      _showValidationDialog(
        context,
        warnings,
        onContinue: () {
          // Agregar la comida al plan
          ref.read(mealPlansProvider.notifier).addMeal(dateKey, meal);

          // Registrar la planificación en el historial si es la primera vez
          final weekKey = DateFormat('yyyy-MM-dd').format(
            DateTime.parse(
              dateKey,
            ).subtract(Duration(days: DateTime.parse(dateKey).weekday - 1)),
          );

          if (!ref
              .read(planningHistoryProvider.notifier)
              .hasWeekInHistory(weekKey)) {
            ref
                .read(planningHistoryProvider.notifier)
                .addWeekToHistory(weekKey);
          }

          // Cerrar el diálogo
          Navigator.pop(context);

          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '¡Comida agregada a tu plan!',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF00BFA5),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      );
      return;
    }

    // Si no hay errores ni advertencias, agregar directamente
    ref.read(mealPlansProvider.notifier).addMeal(dateKey, meal);

    // Registrar la planificación en el historial si es la primera vez
    final weekKey = DateFormat('yyyy-MM-dd').format(
      DateTime.parse(
        dateKey,
      ).subtract(Duration(days: DateTime.parse(dateKey).weekday - 1)),
    );

    if (!ref.read(planningHistoryProvider.notifier).hasWeekInHistory(weekKey)) {
      ref.read(planningHistoryProvider.notifier).addWeekToHistory(weekKey);
    }

    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '¡Comida agregada a tu plan!',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00BFA5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Método para mostrar diálogo de validación
  void _showValidationDialog(
    BuildContext context,
    List<MealPlanValidation> validations, {
    VoidCallback? onContinue,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              onContinue == null ? 'No se puede continuar' : 'Advertencias',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            content: Container(
              width: double.maxFinite,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    onContinue == null
                        ? 'Por favor, corrige los siguientes errores:'
                        : 'Se han encontrado las siguientes advertencias:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: validations.length,
                      itemBuilder: (context, index) {
                        final validation = validations[index];
                        final color =
                            validation.severity == ValidationSeverity.error
                                ? Colors.red.shade700
                                : Colors.orange.shade800;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                validation.severity == ValidationSeverity.error
                                    ? Icons.error_outline
                                    : Icons.warning_amber_outlined,
                                size: 20,
                                color: color,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  validation.message,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.inter(color: Colors.grey.shade700),
                ),
              ),
              if (onContinue != null)
                ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Continuar de todos modos'),
                ),
            ],
          ),
    );
  }

  // Método para obtener el icono adecuado según la receta
  IconData _getIconForRecipe(MealPlan recipe) {
    // Primero verificamos el tipo de comida
    switch (recipe.type) {
      case MealType.breakfast:
        return Icons.breakfast_dining;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.cookie;
    }
  }

  // Estado vacío
  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 64, color: Colors.grey.shade300),
            SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Sugerencias IA
  Widget _buildAISuggestions(WidgetRef ref) {
    // Crear parámetros para la sugerencia IA
    // Aquí usamos solo el tipo de comida para simplificar
    final params = <String, dynamic>{
      'mealType': MealType.lunch,
      'dietaryTags': ref.read(recipeFiltersProvider).dietaryTags,
    };

    return ref
        .watch(aiSuggestionsProvider(params))
        .when(
          data: (suggestions) {
            if (suggestions.isEmpty) {
              return _buildEmptyState(
                'No hay sugerencias disponibles',
                'Intenta modificar tus preferencias o añade más ingredientes',
              );
            }
            return _buildRecipeGrid(suggestions, ref);
          },
          loading:
              () => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Generando sugerencias inteligentes...',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
          error:
              (error, stack) => _buildEmptyState(
                'Error al generar sugerencias',
                'Por favor intenta de nuevo más tarde',
              ),
        );
  }

  // Diálogo para sugerencias personalizadas
  void _showAiSuggestionDialog(BuildContext context, WidgetRef ref) {
    final ingredients = TextEditingController();
    final selectedDietary = <String>[];
    MealType selectedType = MealType.lunch;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✨ Sugerencia Inteligente',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Nuestra IA te recomendará recetas basadas en tus preferencias y los ingredientes que ya tienes',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Selección de tipo de comida
                      Text(
                        'Tipo de comida',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: MealType.values.length,
                          itemBuilder: (context, index) {
                            final type = MealType.values[index];
                            final isSelected = selectedType == type;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(type.name),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      selectedType = type;
                                    });
                                  }
                                },
                                backgroundColor: Colors.grey.shade100,
                                selectedColor: type.color.withValues(alpha: 0.2),
                                labelStyle: GoogleFonts.inter(
                                  color:
                                      isSelected
                                          ? type.color
                                          : Colors.grey.shade800,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 16),

                      // Ingredientes disponibles
                      Row(
                        children: [
                          Text(
                            'Ingredientes disponibles',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '(Opcional)',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Si no ingresas ingredientes, te recomendaremos recetas populares',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: ingredients,
                        decoration: InputDecoration(
                          hintText: 'Escribe ingredientes separados por comas',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        maxLines: 2,
                      ),

                      SizedBox(height: 20),

                      // Preferencias dietéticas
                      Row(
                        children: [
                          Text(
                            'Preferencias dietéticas',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '(Opcional)',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Selecciona si tienes alguna preferencia dietética específica',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 12),

                      // Aquí irían los chips de preferencias dietéticas
                      SizedBox(height: 20),

                      // Botón para generar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);

                            // Navegar a la tab de sugerencias IA
                            _tabController.animateTo(3);

                            // Actualizar parámetros
                            final params = <String, dynamic>{
                              'mealType': selectedType,
                              'dietaryTags': selectedDietary,
                              'availableIngredients':
                                  ingredients.text.isNotEmpty
                                      ? ingredients.text
                                          .split(',')
                                          .map((e) => e.trim())
                                          .toList()
                                      : null,
                            };

                            // Invalidar el provider para que se regeneren las sugerencias
                            ref.invalidate(aiSuggestionsProvider(params));
                          },
                          icon: Icon(Icons.auto_awesome),
                          label: Text('Generar Sugerencias'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BFA5),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  void _showRecipeDetails(
    BuildContext context,
    MealPlan recipe,
    WidgetRef ref,
  ) {
    // Mostrar detalles de la receta en un bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen y header
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: recipe.type.color.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Icono representativo
                      Center(
                        child: Icon(
                          _getIconForRecipe(recipe),
                          size: 64,
                          color: recipe.type.color,
                        ),
                      ),
                      // Botón de cerrar
                      Positioned(
                        top: 12,
                        right: 12,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.black54),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      // Tipo de comida
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: recipe.type.color.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                recipe.type.icon,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                recipe.type.name,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenido
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView(
                      children: [
                        // Nombre de la receta
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                recipe.name,
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Botón de favorito
                            IconButton(
                              icon: Icon(
                                recipe.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    recipe.isFavorite
                                        ? Colors.red
                                        : Colors.grey,
                              ),
                              onPressed: () {
                                ref
                                    .read(allRecipesProvider.notifier)
                                    .toggleFavorite(recipe.id);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Detalles de la receta
                        Row(
                          children: [
                            _buildDetailItem(
                              Icons.schedule,
                              '${recipe.prepTimeMinutes} min',
                              'Tiempo',
                            ),
                            const SizedBox(width: 16),
                            _buildDetailItem(
                              Icons.local_fire_department,
                              recipe.calories > 0
                                  ? '${recipe.calories} kcal'
                                  : 'Desconocido',
                              'Calorías',
                            ),
                            const SizedBox(width: 16),
                            _buildDetailItem(
                              Icons.star,
                              recipe.difficulty,
                              'Dificultad',
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Etiquetas dietéticas
                        if (recipe.dietaryTags.isNotEmpty) ...[
                          Text(
                            'Etiquetas dietéticas',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                recipe.dietaryTags.map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.green.shade100,
                                      ),
                                    ),
                                    child: Text(
                                      tag,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Ingredientes
                        Text(
                          'Ingredientes',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...recipe.ingredients.map((ingredient) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00BFA5),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    ingredient,
                                    style: GoogleFonts.inter(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // Botones de acción
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      if (!widget.selectionMode) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Podemos agregar lógica para editar la receta aquí
                            },
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Editar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (widget.selectionMode &&
                                widget.onRecipeSelected != null) {
                              Navigator.pop(context);
                              widget.onRecipeSelected!(recipe);
                            } else {
                              // Podemos agregar lógica para usar la receta aquí
                              // Por ejemplo, ir al planificador con esta receta
                              final today = DateTime.now();
                              // ignore: unused_local_variable
                              final dateKey = DateFormat(
                                'yyyy-MM-dd',
                              ).format(today);

                              // Cerrar el diálogo
                              Navigator.pop(context);

                              // Mostrar el diálogo de añadir comida al plan
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Añadir al plan'),
                                      content: const Text(
                                        '¿Quieres añadir esta receta a tu plan de hoy?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            // Navegar al planificador
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        const PlannerScreen(),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF00BFA5,
                                            ),
                                          ),
                                          child: const Text('Añadir'),
                                        ),
                                      ],
                                    ),
                              );
                            }
                          },
                          icon: Icon(
                            widget.selectionMode ? Icons.check : Icons.add,
                          ),
                          label: Text(
                            widget.selectionMode
                                ? 'Seleccionar'
                                : 'Añadir al plan',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BFA5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Widget auxiliar para mostrar detalles de la receta
  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00BFA5), size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
