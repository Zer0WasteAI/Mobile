// ignore_for_file: unused_local_variable, unused_element

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_providers.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_screen_providers.dart';
import 'package:zer0_waste_ai/features/planner/presentation/widgets/planner_widget_builders.dart';
import 'package:zer0_waste_ai/features/planner/presentation/widgets/planner_dialog_manager.dart';
import 'package:zer0_waste_ai/features/planner/presentation/widgets/tutorial/planner_tutorial_manager.dart';
import 'package:zer0_waste_ai/features/planner/presentation/widgets/analytics/planner_analytics_manager.dart';
import 'package:zer0_waste_ai/features/planner/presentation/widgets/calendar/week_selector.dart';
import 'package:zer0_waste_ai/features/planner/presentation/screens/recipe_library_screen.dart';

// Extensión para capitalizar strings (con nombre único para evitar conflicto)
extension StringExtensionPlanner on String {
  String capitalizePlanner() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}

// All providers and models are now imported from their proper locations

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inicializar los datos de localización para español
    initializeDateFormatting('es_ES', null);

    // Verificar si hay una fecha seleccionada desde la home
    final selectedDate = ref.watch(selectedDateProvider);
    // Si hay una fecha seleccionada, usar esa fecha para el proveedor de la semana actual
    if (selectedDate != null) {
      // Obtener el lunes de la semana de la fecha seleccionada
      final monday = selectedDate.subtract(
        Duration(days: selectedDate.weekday - 1),
      );
      // Actualizar el proveedor de la semana actual y limpiar el proveedor de la fecha seleccionada
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentWeekProvider.notifier).state = monday;
        ref.read(selectedDateProvider.notifier).state = null;
        // También seleccionar el día
        ref.read(selectedDayProvider.notifier).state = selectedDate;
      });
    }

    final currentWeek = ref.watch(currentWeekProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : const Color(0xFFFAF9F6);
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    // Estado de expansión del calendario
    final isCalendarExpanded = ref.watch(isCalendarExpandedProvider);

    // Verificar si es la primera vez que el usuario utiliza la app
    final isFirstTimeUser = ref.read(isFirstPlanningProvider);

    // Verificar si ya se mostró la guía de iconos
    final hasShownIconGuide = ref.watch(hasShownIconGuideProvider);

    // Mostrar el tutorial de onboarding si es la primera vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isFirstTimeUser) {
        PlannerTutorialManager.showOnboardingTutorial(context, ref);
      } else if (!hasShownIconGuide) {
        PlannerTutorialManager.showOnboardingTutorial(context, ref);
      }
    });

    // Calcular los días de la semana
    final weekDays = List.generate(
      7,
      (index) => currentWeek.add(Duration(days: index)),
    );

    // Obtener el día seleccionado
    final selectedDay = ref.watch(selectedDayProvider);

    // Si no hay día seleccionado, seleccionar el día actual si está en esta semana
    // o el primer día de la semana si no
    if (selectedDay == null) {
      final today = DateTime.now();
      final inCurrentWeek = weekDays.any(
        (day) =>
            day.year == today.year &&
            day.month == today.month &&
            day.day == today.day,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (inCurrentWeek) {
          ref.read(selectedDayProvider.notifier).state = today;
        } else {
          ref.read(selectedDayProvider.notifier).state = weekDays.first;
        }
      });
    }

    // Verificar si hay una comida seleccionada desde la home
    final selectedMeal = ref.watch(selectedMealProvider);
    // Si hay una comida seleccionada, mostrar sus detalles y limpiar el proveedor
    if (selectedMeal != null) {
      // Formatear la fecha actual para usarla como clave
      final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Asegurarse que el mapa del proveedor existe
      final mealPlans = ref.read(mealPlansProvider);
      // ignore: unnecessary_null_comparison
      if (mealPlans != null) {
        // Obtener las comidas planificadas para la fecha
        final mealsForDate = mealPlans[dateKey] ?? [];

        // Verificar si la comida seleccionada existe en el planificador
        final mealExists = mealsForDate.any(
          (meal) => meal.id == selectedMeal.id,
        );

        // Mostrar los detalles después de que se construya el widget solo si la comida existe
        if (mealExists) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Mostrar detalles usando el método estático del widget builder
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(selectedMeal.name),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selectedMeal.imageUrl.isNotEmpty)
                      Image.network(selectedMeal.imageUrl, height: 100),
                    const SizedBox(height: 16),
                    Text('Ingredientes: ${selectedMeal.ingredients.join(', ')}'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            );
            // Limpiar el proveedor de la comida seleccionada
            ref.read(selectedMealProvider.notifier).state = null;
          });
        }
      }

      // Siempre limpiar el proveedor para evitar intentos repetidos
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedMealProvider.notifier).state = null;
      });
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Volver',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          // Botón de ayuda para mostrar la guía de iconos
          IconButton(
            icon: Icon(Icons.help_outline, color: textColor),
            onPressed: () => PlannerTutorialManager.showOnboardingTutorial(context, ref),
            tooltip: 'Guía de iconos',
          ),
          // Botón de historial
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.history_outlined, color: textColor),
                // Posicionar un indicador visual si hay historial
                if (ref.watch(planningHistoryProvider).isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BFA5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => PlannerAnalyticsManager.showPlanningHistory(context, ref),
            tooltip: 'Historial de planificación',
          ),
          // Botón de biblioteca de recetas
          IconButton(
            icon: Icon(Icons.restaurant_menu, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecipeLibraryScreen(),
                ),
              );
            },
            tooltip: 'Biblioteca de recetas',
          ),
          // Botón de planificación de comidas
          IconButton(
            icon: Icon(Icons.calendar_today, color: textColor),
            onPressed: () {
              Navigator.pushNamed(context, '/meal-planning');
            },
            tooltip: 'Planificación de Comidas',
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: textColor),
            onPressed: () => PlannerAnalyticsManager.showShoppingList(context, ref),
            tooltip: 'Lista de compra',
          ),
          IconButton(
            icon: Icon(Icons.analytics_outlined, color: textColor),
            onPressed: () => PlannerAnalyticsManager.showStats(context, ref),
            tooltip: 'Estadísticas de impacto',
          ),
        ],
      ),
      body: Column(
        children: [
          // Título de la pantalla
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              'Planificación Semanal',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),

          // Sección del calendario con funcionalidad de toggle
          Column(
            children: [
              // Selector de semana (siempre visible)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy', 'es_ES').format(currentWeek),
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const WeekSelector(),
                  ],
                ),
              ),

              // Días de la semana (visibles solo cuando está expandido)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isCalendarExpanded ? 98 : 0, // 90 + 8 de margen
                curve: Curves.easeInOut,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: PlannerWidgetBuilders.buildWeekDays(
                    context,
                    ref,
                    weekDays,
                    selectedDay,
                  ),
                ),
              ),

              // Botón de toggle más grande y fácil de presionar
              InkWell(
                onTap: () {
                  ref.read(isCalendarExpandedProvider.notifier).state =
                      !isCalendarExpanded;
                },
                child: Container(
                  width: double.infinity,
                  height: 30,
                  alignment: Alignment.center,
                  child: Container(
                    width: 50,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isCalendarExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Vista de día seleccionado
          if (selectedDay != null)
            Expanded(
              child: () {
                // Obtener las comidas del día
                final dateKey = DateFormat('yyyy-MM-dd').format(selectedDay);
                final mealPlans = ref.watch(mealPlansProvider);
                final dayMeals = mealPlans[dateKey];
                
                return PlannerWidgetBuilders.buildDayPlanner(
                  context,
                  ref,
                  selectedDay,
                  dayMeals,
                );
              }(),
            ),
        ],
      ),
    );
  }

  // Mostrar un selector de mes/semana
  // Mostrar diálogo para agregar una comida
  void _showAddMealDialog(
    BuildContext context,
    WidgetRef ref,
    DateTime day, {
    MealType? initialType,
  }) {
    final dateKey = DateFormat('yyyy-MM-dd').format(day);

    PlannerDialogManager.showAddMealDialog(
      context,
      ref,
      day,
      initialType ?? MealType.breakfast,
    );
  }

  // Método original reemplazado - contenido removido
  void _showAddMealDialogOriginal(
    BuildContext context,
    WidgetRef ref,
    DateTime day, {
    MealType? initialType,
  }) {
    final dateKey = DateFormat('yyyy-MM-dd').format(day);
    final formattedDate = DateFormat('EEEE d MMMM', 'es_ES').format(day);

    // Comida seleccionada actualmente para agregar
    MealPlan? selectedMeal;

    // Obtener todas las recetas, favoritos y recientes
    final allRecipes = ref.read(allRecipesProvider);
    final favorites = ref.read(favoriteRecipesProvider);
    final recents = ref.read(recentRecipesProvider);

    // Filtrar por tipo de comida (si se especificó)
    final filteredAll =
        initialType != null
            ? allRecipes.where((recipe) => recipe.type == initialType).toList()
            : allRecipes;

    final filteredFavorites =
        initialType != null
            ? favorites.where((recipe) => recipe.type == initialType).toList()
            : favorites;

    final filteredRecents =
        initialType != null
            ? recents.where((recipe) => recipe.type == initialType).toList()
            : recents;

    // Definir las pestañas
    const tabs = ['Todas', 'Favoritas', 'Recientes'];
    int selectedTabIndex = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              // Determinar qué lista mostrar según la pestaña seleccionada
              List<MealPlan> currentList;
              switch (selectedTabIndex) {
                case 1:
                  currentList = filteredFavorites;
                  break;
                case 2:
                  currentList = filteredRecents;
                  break;
                case 0:
                default:
                  currentList = filteredAll;
              }

              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Indicador visual para arrastrar
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Título y fecha
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Añadir comida',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          Text(
                            formattedDate.capitalizePlanner(),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: const Color(0xFF00BFA5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Filtro por tipo de comida
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: MealType.values.length,
                          itemBuilder: (context, index) {
                            final type = MealType.values[index];
                            final isSelected = initialType == type;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(type.name),
                                selected: isSelected,
                                backgroundColor: Colors.grey.shade100,
                                selectedColor: type.color.withValues(
                                  alpha: 0.2,
                                ),
                                onSelected: (selected) {
                                  setState(() {
                                    initialType = selected ? type : null;
                                  });
                                },
                                labelStyle: GoogleFonts.inter(
                                  fontSize: 12,
                                  color:
                                      isSelected
                                          ? type.color
                                          : Colors.grey.shade700,
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
                    ),

                    const SizedBox(height: 8),

                    // Pestañas para alternar entre Todas, Favoritas, Recientes
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: List.generate(
                          tabs.length,
                          (index) => Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedTabIndex = index;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color:
                                          selectedTabIndex == index
                                              ? const Color(0xFF00BFA5)
                                              : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  tabs[index],
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight:
                                        selectedTabIndex == index
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                    color:
                                        selectedTabIndex == index
                                            ? const Color(0xFF00BFA5)
                                            : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Lista de recetas según la pestaña seleccionada
                    Expanded(
                      child:
                          currentList.isEmpty
                              ? _buildEmptyRecipesState(context)
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: currentList.length,
                                itemBuilder: (context, index) {
                                  final recipe = currentList[index];
                                  final isSelected =
                                      selectedMeal?.id == recipe.id;

                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedMeal =
                                            isSelected ? null : recipe;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? const Color(
                                                  0xFF00BFA5,
                                                ).withValues(alpha: 0.05)
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? const Color(0xFF00BFA5)
                                                  : Colors.grey.shade200,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          // Imagen o icono
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  bottomLeft: Radius.circular(
                                                    10,
                                                  ),
                                                ),
                                            child: SizedBox(
                                              width: 80,
                                              height: 80,
                                              child:
                                                  recipe.imageUrl.startsWith(
                                                        'assets/',
                                                      )
                                                      ? Image.asset(
                                                        recipe.imageUrl,
                                                        fit: BoxFit.cover,
                                                      )
                                                      : Container(
                                                        color: recipe.type.color
                                                            .withValues(
                                                              alpha: 0.2,
                                                            ),
                                                        child: Icon(
                                                          recipe.type.icon,
                                                          color:
                                                              recipe.type.color,
                                                          size: 40,
                                                        ),
                                                      ),
                                            ),
                                          ),
                                          // Información
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Etiqueta de tipo
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: recipe.type.color
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      recipe.type.name,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            recipe.type.color,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  // Nombre
                                                  Text(
                                                    recipe.name,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  // Detalles
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.schedule,
                                                        size: 12,
                                                        color: Colors.grey,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${recipe.prepTimeMinutes} min',
                                                        style:
                                                            GoogleFonts.inter(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade600,
                                                            ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Icon(
                                                        Icons
                                                            .local_fire_department,
                                                        size: 12,
                                                        color: Colors.grey,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${recipe.calories} kcal',
                                                        style:
                                                            GoogleFonts.inter(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade600,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Indicador de selección
                                          if (isSelected)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                right: 12,
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF00BFA5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),

                    // Botón de IA
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom: 10,
                      ),
                      child: Row(
                        children: [
                          // Botón Sugerir con IA
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _showAiSuggestionDialog(context, initialType, (
                                  suggestedMeal,
                                ) {
                                  setState(() {
                                    selectedMeal = suggestedMeal;
                                  });
                                }, ref);
                              },
                              icon: Icon(
                                Icons.auto_awesome,
                                color: const Color(0xFF00BFA5),
                              ),
                              label: Text('Sugerir con IA'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: const Color(0xFF00BFA5),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),

                          // Espacio entre botones
                          const SizedBox(width: 10),

                          // Botón Explorar más recetas
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Cerrar diálogo actual
                                Navigator.pop(context);
                                // Abrir biblioteca de recetas
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const RecipeLibraryScreen(),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.restaurant_menu,
                                color: const Color(0xFF00BFA5),
                              ),
                              label: Text('Explorar más'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: const Color(0xFF00BFA5),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Botón para agregar
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: ElevatedButton(
                        onPressed:
                            selectedMeal == null
                                ? null
                                : () {
                                  // Cerrar el diálogo
                                  Navigator.pop(context);

                                  // Actualizar fecha de último uso
                                  ref
                                      .read(allRecipesProvider.notifier)
                                      .updateLastUsed(selectedMeal!.id);

                                  // Agregar la comida directamente
                                  ref.read(mealPlansProvider.notifier)
                                      .addMeal(dateKey, selectedMeal!);
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BFA5),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: const Text('Agregar a mi plan'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  // Widget para mostrar un estado vacío cuando no hay recetas
  Widget _buildEmptyRecipesState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_food, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No se encontraron recetas',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Prueba con otro filtro o añade recetas nuevas',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Método para abrir la biblioteca de recetas en modo selección
  void _openRecipeLibraryForSelection(
    BuildContext context,
    WidgetRef ref,
    DateTime day,
    MealType? initialType,
  ) {
    final dateKey = DateFormat('yyyy-MM-dd').format(day);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => RecipeLibraryScreen(
              selectionMode: true,
              initialMealType: initialType,
              onRecipeSelected: (MealPlan selectedRecipe) {
                // Actualizar fecha de último uso
                ref
                    .read(allRecipesProvider.notifier)
                    .updateLastUsed(selectedRecipe.id);

                // Agregar la comida directamente
                ref.read(mealPlansProvider.notifier)
                    .addMeal(dateKey, selectedRecipe);

                // Regresar a la pantalla anterior después de seleccionar
                Navigator.pop(context);
              },
            ),
      ),
    );
  }

  // Mostrar diálogo para sugerencias IA
  void _showAiSuggestionDialog(
    BuildContext context,
    MealType? initialType,
    Function(MealPlan) onSelect,
    WidgetRef ref,
  ) {
    final ingredients = TextEditingController();
    final dietaryTags = <String>[];
    final mealType = initialType ?? MealType.lunch;

    // Todas las etiquetas dietéticas disponibles
    final allDietaryTags = [
      'Vegetariano',
      'Vegano',
      'Sin gluten',
      'Sin lácteos',
      'Alto en proteínas',
    ];

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

                      SizedBox(height: 16),

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
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            allDietaryTags.map((tag) {
                              final isSelected = dietaryTags.contains(tag);
                              return FilterChip(
                                label: Text(tag),
                                selected: isSelected,
                                backgroundColor: Colors.grey.shade100,
                                selectedColor: const Color(
                                  0xFF00BFA5,
                                ).withValues(alpha: 0.2),
                                checkmarkColor: const Color(0xFF00BFA5),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      dietaryTags.add(tag);
                                    } else {
                                      dietaryTags.remove(tag);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                      ),

                      SizedBox(height: 24),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Preparar parámetros para la sugerencia
                          Builder(
                            builder: (context) {
                              final params = <String, dynamic>{
                                'mealType': mealType,
                                'dietaryTags': dietaryTags,
                                'availableIngredients':
                                    ingredients.text.isEmpty
                                        ? null
                                        : ingredients.text
                                            .split(',')
                                            .map((e) => e.trim())
                                            .toList(),
                              };

                              return Column(
                                children: [
                                  // Botón para generar
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // Invalidar el provider para generar nuevas sugerencias
                                      ref.invalidate(
                                        aiSuggestionsProvider(params),
                                      );
                                    },
                                    icon: Icon(Icons.autorenew),
                                    label: Text('Generar sugerencia'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00BFA5),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 20),

                                  // Resultado de la sugerencia
                                  ref
                                      .watch(aiSuggestionsProvider(params))
                                      .when(
                                        data: (suggestions) {
                                          if (suggestions.isEmpty) {
                                            return Text(
                                              'No se encontraron sugerencias con esos criterios',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            );
                                          }

                                          // Mostrar la primera sugerencia
                                          final suggestion = suggestions.first;

                                          return Column(
                                            children: [
                                              // Título de sugerencia
                                              Text(
                                                'Te recomendamos:',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              SizedBox(height: 12),

                                              // Receta sugerida
                                              Container(
                                                padding: EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.grey.shade200,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    // Imagen
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child: Image.asset(
                                                        suggestion.imageUrl,
                                                        width: 80,
                                                        height: 80,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    SizedBox(width: 16),

                                                    // Info
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 2,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: suggestion
                                                                  .type
                                                                  .color
                                                                  .withValues(
                                                                    alpha: 0.1,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    4,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              suggestion
                                                                  .type
                                                                  .name,
                                                              style: GoogleFonts.inter(
                                                                fontSize: 10,
                                                                color:
                                                                    suggestion
                                                                        .type
                                                                        .color,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            suggestion.name,
                                                            style:
                                                                GoogleFonts.inter(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            suggestion
                                                                    .ingredients
                                                                    .take(3)
                                                                    .join(
                                                                      ', ',
                                                                    ) +
                                                                (suggestion
                                                                            .ingredients
                                                                            .length >
                                                                        3
                                                                    ? '...'
                                                                    : ''),
                                                            style: GoogleFonts.inter(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade600,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              SizedBox(height: 16),

                                              // Botón para seleccionar
                                              OutlinedButton(
                                                onPressed: () {
                                                  // Seleccionar esta receta
                                                  onSelect(suggestion);
                                                  Navigator.pop(context);
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: const Color(
                                                    0xFF00BFA5,
                                                  ),
                                                  side: BorderSide(
                                                    color: const Color(
                                                      0xFF00BFA5,
                                                    ),
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  minimumSize: Size(
                                                    double.infinity,
                                                    44,
                                                  ),
                                                ),
                                                child: Text('Usar esta receta'),
                                              ),
                                            ],
                                          );
                                        },
                                        loading:
                                            () => Center(
                                              child: Column(
                                                children: [
                                                  CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(
                                                          const Color(
                                                            0xFF00BFA5,
                                                          ),
                                                        ),
                                                  ),
                                                  SizedBox(height: 16),
                                                  Text(
                                                    'Buscando la mejor receta para ti...',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        error:
                                            (error, stack) => Text(
                                              'Error al generar sugerencias. Inténtalo de nuevo.',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: Colors.red,
                                              ),
                                            ),
                                      ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  // Mostrar diálogo para editar una comida
  void _showEditMealDialog(
    BuildContext context,
    WidgetRef ref,
    MealPlan meal,
    String dateKey,
  ) {
    final formattedDate = DateFormat(
      'EEEE d MMMM',
      'es_ES',
    ).format(DateFormat('yyyy-MM-dd').parse(dateKey));

    // Obtener todas las recetas
    final allRecipes = ref.read(allRecipesProvider);

    // Filtrar recetas del mismo tipo
    final recipes =
        allRecipes.where((recipe) => recipe.type == meal.type).toList();

    // Comida seleccionada actualmente
    MealPlan selectedMeal = meal;

    // Obtener favoritos y recientes
    final favorites =
        ref
            .read(favoriteRecipesProvider)
            .where((r) => r.type == meal.type)
            .toList();
    final recents =
        ref
            .read(recentRecipesProvider)
            .where((r) => r.type == meal.type)
            .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return DefaultTabController(
                length: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Indicador visual para arrastrar
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Título y fecha
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Reemplazar comida',
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                            Text(
                              formattedDate.capitalizePlanner(),
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: const Color(0xFF00BFA5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Comida actual a reemplazar
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.swap_horiz,
                              color: Colors.amber.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Vas a reemplazar: ${meal.name}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.amber.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tabs para categorías
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TabBar(
                          indicatorColor: const Color(0xFF00BFA5),
                          labelColor: const Color(0xFF00BFA5),
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(text: 'Todas'),
                            Tab(text: 'Favoritas'),
                            Tab(text: 'Recientes'),
                          ],
                        ),
                      ),

                      // Lista de recetas según tab seleccionada
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Todas las recetas
                            _buildRecipeList(recipes, selectedMeal, (meal) => setState(() => selectedMeal = meal)),

                            // Favoritas
                            _buildRecipeList(favorites, selectedMeal, (meal) => setState(() => selectedMeal = meal)),

                            // Recientes
                            _buildRecipeList(recents, selectedMeal, (meal) => setState(() => selectedMeal = meal)),
                          ],
                        ),
                      ),

                      // Botón de IA
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Mostrar diálogo de sugerencia IA
                            _showAiSuggestionDialog(context, meal.type, (
                              suggestedMeal,
                            ) {
                              setState(() {
                                selectedMeal = suggestedMeal;
                              });
                            }, ref);
                          },
                          icon: Icon(
                            Icons.auto_awesome,
                            color: const Color(0xFF00BFA5),
                          ),
                          label: Text('Sugerir con IA'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: const Color(0xFF00BFA5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                      // Botón para reemplazar
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: ElevatedButton(
                          onPressed: () {
                            // Cerrar el diálogo
                            Navigator.pop(context);

                            // Actualizar fecha de uso
                            ref
                                .read(allRecipesProvider.notifier)
                                .updateLastUsed(selectedMeal.id);

                            // Actualizar el plan reemplazando la comida anterior con la nueva seleccionada
                            ref
                                .read(mealPlansProvider.notifier)
                                .editMeal(dateKey, meal, selectedMeal);

                            // Mostrar confirmación
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Comida reemplazada correctamente',
                                ),
                                backgroundColor: const Color(0xFF00BFA5),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BFA5),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Reemplazar comida'),
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

  /// Construir lista de recetas
  Widget _buildRecipeList(List<MealPlan> recipes, MealPlan? selectedMeal, Function(MealPlan) onMealSelected) {
    if (recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No hay recetas disponibles', style: GoogleFonts.inter(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        final isSelected = selectedMeal?.id == recipe.id;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.lightPrimary.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.lightPrimary : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ListTile(
            leading: recipe.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      recipe.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.restaurant,
                        color: Colors.grey[400],
                      ),
                    ),
                  )
                : Icon(Icons.restaurant, color: Colors.grey[400]),
            title: Text(
              recipe.name,
              style: GoogleFonts.inter(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.lightPrimary : null,
              ),
            ),
            subtitle: Text(
              '${recipe.prepTimeMinutes} min • ${recipe.calories} cal',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            trailing: isSelected 
                ? Icon(Icons.check_circle, color: AppColors.lightPrimary)
                : null,
            onTap: () => onMealSelected(recipe),
          ),
        );
      },
    );
  }

}
