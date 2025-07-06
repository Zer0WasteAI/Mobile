import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_providers.dart';
import 'package:zer0_waste_ai/features/planner/application/providers/meal_planning_providers.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan_models.dart';

/// Widget que muestra la planificación de comidas para el día actual
/// y proporciona un acceso rápido al planificador semanal completo
class DailyPlannerWidget extends ConsumerStatefulWidget {
  const DailyPlannerWidget({super.key});

  @override
  ConsumerState<DailyPlannerWidget> createState() => _DailyPlannerWidgetState();
}

class _DailyPlannerWidgetState extends ConsumerState<DailyPlannerWidget> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // Cargar los datos de planificación después del primer build
    Future(() {
      ref.read(mealPlanningProvider.notifier).loadAllMealPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Inicializar los datos de localización para español
    initializeDateFormatting('es_ES', null);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final cardColor = isDark ? Colors.grey.shade900 : Colors.white;

    // Obtener la fecha actual
    final today = DateTime.now();
    final dateKey = DateFormat('yyyy-MM-dd').format(today);

    // Obtener el estado de planificación de comidas
    final mealPlanningState = ref.watch(mealPlanningProvider);

    // Obtener las comidas planificadas para hoy desde el nuevo provider
    final todayMealPlan = mealPlanningState.mealPlans[dateKey];
    final todayMeals = todayMealPlan?.meals.allMeals ?? [];

    // Organizar las comidas por tipo usando el nuevo modelo
    final mealsByType = <String, List<Meal>>{};
    for (final meal in todayMeals) {
      final mealType = _getMealTypeFromMeal(meal);
      mealsByType[mealType] = [...(mealsByType[mealType] ?? []), meal];
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header - Siempre visible
          InkWell(
            onTap: () {
              if (todayMeals.isEmpty) {
                // Si no hay comidas, ir directamente al planificador de comidas
                context.pushNamed('mealPlanning');
              } else {
                // Si hay comidas, expandir/colapsar el widget
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              }
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icono principal
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Información principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Plan de hoy',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            if (todayMeals.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${todayMeals.length} ${todayMeals.length == 1 ? 'comida' : 'comidas'}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          todayMeals.isEmpty
                              ? 'No hay comidas planificadas'
                              : _buildMealSummary(mealsByType),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Mostrar calorías totales si hay comidas
                        if (todayMealPlan != null && todayMeals.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  size: 12,
                                  color: AppColors.breakfastColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${todayMealPlan.meals.totalCalories} kcal',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.breakfastColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Iconos de comidas o botón de acción
                  if (todayMeals.isEmpty)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(selectedDateProvider.notifier).state = today;
                          context.pushNamed('unifiedPlanning');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(100, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Planificar',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMealTypeIcons(context, mealsByType),
                        const SizedBox(width: 8),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 18,
                          color: Colors.grey.shade500,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Contenido expandible - Solo se muestra si hay comidas y está expandido
          if (_isExpanded && todayMeals.isNotEmpty)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                children: [
                  const Divider(height: 1),

                  // Lista de comidas por tipo
                  ...mealsByType.entries.map(
                    (entry) => _buildMealTypeSection(
                      context,
                      entry.key,
                      entry.value,
                      isDark,
                      textColor,
                      secondaryTextColor,
                    ),
                  ),

                  // Botón para ir al planificador completo
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Navegar y preseleccionar la fecha actual
                              ref.read(selectedDateProvider.notifier).state =
                                  today;
                              context.pushNamed('unifiedPlanning');
                            },
                            icon: Icon(
                              Icons.auto_awesome,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: Text(
                              'Abrir Mi Planificador',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
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
        ],
      ),
    );
  }

  // Obtener el tipo de comida desde el objeto Meal
  String _getMealTypeFromMeal(Meal meal) {
    // Determinar el tipo basado en el título de la receta o algún campo
    // Por ahora, usaremos una lógica simple basada en el título
    final title = meal.recipeTitle.toLowerCase();
    if (title.contains('desayuno') || title.contains('breakfast')) {
      return 'Desayuno';
    } else if (title.contains('almuerzo') || title.contains('lunch')) {
      return 'Almuerzo';
    } else if (title.contains('cena') || title.contains('dinner')) {
      return 'Cena';
    } else {
      return 'Comida'; // Tipo genérico
    }
  }

  // Construir resumen de comidas como texto
  String _buildMealSummary(Map<String, List<Meal>> mealsByType) {
    final parts = <String>[];

    mealsByType.forEach((type, meals) {
      parts.add(
        '${meals.length} ${type.toLowerCase()}${meals.length > 1 ? 's' : ''}',
      );
    });

    return parts.join(', ');
  }

  // Construir iconos de tipos de comida
  Widget _buildMealTypeIcons(
    BuildContext context,
    Map<String, List<Meal>> mealsByType,
  ) {
    final icons = <Widget>[];

    // Mostrar máximo 3 tipos
    final displayTypes = mealsByType.keys.take(3).toList();

    for (final type in displayTypes) {
      final color = _getMealTypeColor(type);
      final icon = _getMealTypeIcon(type);

      icons.add(
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.2),
            radius: 14,
            child: Icon(icon, size: 14, color: color),
          ),
        ),
      );
    }

    // Indicador de más tipos si hay más de 3
    if (mealsByType.length > 3) {
      icons.add(
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '+${mealsByType.length - 3}',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
      );
    }

    return Row(mainAxisSize: MainAxisSize.min, children: icons);
  }

  // Obtener color para tipo de comida
  Color _getMealTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'desayuno':
        return AppColors.breakfastColor;
      case 'almuerzo':
        return AppColors.lunchColor;
      case 'cena':
        return AppColors.dinnerColor;
      default:
        return AppColors.genericMealColor;
    }
  }

  // Obtener icono para tipo de comida
  IconData _getMealTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'desayuno':
        return Icons.breakfast_dining;
      case 'almuerzo':
        return Icons.lunch_dining;
      case 'cena':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }

  // Construir sección para un tipo de comida
  Widget _buildMealTypeSection(
    BuildContext context,
    String type,
    List<Meal> meals,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final color = _getMealTypeColor(type);
    final icon = _getMealTypeIcon(type);

    return Container(
      color:
          isDark
              ? Colors.grey.shade900.withValues(alpha: 0.5)
              : Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado del tipo
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.2),
                radius: 12,
                child: Icon(icon, size: 12, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                type,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              if (meals.length > 1)
                Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${meals.length}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Lista de comidas de este tipo
          ...meals.map(
            (meal) => _buildMealItem(
              context,
              meal,
              isDark,
              textColor,
              secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // Construir item individual de comida
  Widget _buildMealItem(
    BuildContext context,
    Meal meal,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Icono de la comida
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.restaurant,
              size: 16,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 12),

          // Información de la comida
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.recipeTitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${meal.calories} kcal',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.breakfastColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${meal.prepTime} min',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Botón de acción
          IconButton(
            icon: Icon(Icons.more_vert, size: 16, color: Colors.grey.shade500),
            onPressed: () {
              // Mostrar opciones para la comida
              _showMealOptions(context, meal);
            },
          ),
        ],
      ),
    );
  }

  // Mostrar opciones para una comida específica
  void _showMealOptions(BuildContext context, Meal meal) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.visibility),
                  title: const Text('Ver detalles'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navegar a detalles de la comida
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.pop(context);
                    context.pushNamed('mealPlanning');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Eliminar comida
                    _deleteMeal(meal);
                  },
                ),
              ],
            ),
          ),
    );
  }

  // Eliminar una comida
  void _deleteMeal(Meal meal) {
    // Aquí implementarías la lógica para eliminar la comida
    // usando el provider correspondiente
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Comida "${meal.recipeTitle}" eliminada'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            // Lógica para deshacer
          },
        ),
      ),
    );
  }
}

// Extensión para capitalizar strings
extension StringExtension on String {
  String capitalize() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}
