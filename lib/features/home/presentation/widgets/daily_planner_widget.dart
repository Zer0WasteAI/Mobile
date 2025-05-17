import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/planner/presentation/screens/planner_screen.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_providers.dart';

/// Widget que muestra la planificación de comidas para el día actual
/// y proporciona un acceso rápido al planificador semanal completo
class DailyPlannerWidget extends ConsumerStatefulWidget {
  const DailyPlannerWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<DailyPlannerWidget> createState() => _DailyPlannerWidgetState();
}

class _DailyPlannerWidgetState extends ConsumerState<DailyPlannerWidget> {
  bool _isExpanded = false;

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
    final dayName = DateFormat('EEEE', 'es_ES').format(today).capitalize();

    // Obtener las comidas planificadas para hoy con manejo de nulo
    final mealPlans = ref.watch(mealPlansProvider);
    final todayMeals =
        mealPlans != null ? (mealPlans[dateKey] ?? <MealPlan>[]) : <MealPlan>[];

    // Organizar las comidas por tipo
    final mealsByType = <MealType, List<MealPlan>>{};
    for (final meal in todayMeals) {
      mealsByType[meal.type] = [...(mealsByType[meal.type] ?? []), meal];
    }

    // Ordenar los tipos de comida en orden: desayuno, almuerzo, cena, snacks
    final orderedMealTypes = [
      MealType.breakfast,
      MealType.lunch,
      MealType.dinner,
      MealType.snack,
    ];

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
                // Si no hay comidas, ir directamente al planificador
                context.pushNamed('planner');
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
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Indicador de día
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          today.day.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          dayName.substring(0, 3),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: primaryColor,
                          ),
                        ),
                      ],
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
                                  color: primaryColor.withOpacity(0.1),
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
                      ],
                    ),
                  ),

                  // Iconos de comidas o botón de acción
                  if (todayMeals.isEmpty)
                    ElevatedButton(
                      onPressed: () => context.pushNamed('planner'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(36, 36),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Icon(Icons.add, size: 18),
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

          // Contenido expandido - Solo visible cuando hay comidas y está expandido
          if (todayMeals.isNotEmpty && _isExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 1),
                  // Detalles de comidas por tipo (en orden específico)
                  ...orderedMealTypes
                      .where((type) => mealsByType.containsKey(type))
                      .map(
                        (type) => _buildMealTypeSection(
                          context,
                          type,
                          mealsByType[type]!,
                          isDark,
                          textColor,
                          secondaryTextColor,
                        ),
                      ),
                  // Botón para ir al planificador
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextButton.icon(
                      onPressed: () {
                        // Navegar y preseleccionar la fecha actual
                        ref.read(selectedDateProvider.notifier).state = today;
                        context.pushNamed('planner');
                      },
                      icon: Icon(
                        Icons.edit_calendar_outlined,
                        size: 16,
                        color: primaryColor,
                      ),
                      label: Text(
                        'Editar plan en el planificador',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: primaryColor.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Construir resumen de comidas como texto
  String _buildMealSummary(Map<MealType, List<MealPlan>> mealsByType) {
    final parts = <String>[];

    mealsByType.forEach((type, meals) {
      parts.add(
        '${meals.length} ${type.name.toLowerCase()}${meals.length > 1 ? 's' : ''}',
      );
    });

    return parts.join(', ');
  }

  // Construir iconos de tipos de comida
  Widget _buildMealTypeIcons(
    BuildContext context,
    Map<MealType, List<MealPlan>> mealsByType,
  ) {
    final icons = <Widget>[];

    // Mostrar máximo 3 tipos
    final displayTypes = mealsByType.keys.take(3).toList();

    for (final type in displayTypes) {
      icons.add(
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: CircleAvatar(
            backgroundColor: type.color.withOpacity(0.2),
            radius: 14,
            child: Icon(type.icon, size: 14, color: type.color),
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
            color: Colors.grey.withOpacity(0.2),
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

  // Construir sección para un tipo de comida
  Widget _buildMealTypeSection(
    BuildContext context,
    MealType type,
    List<MealPlan> meals,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Container(
      color:
          isDark ? Colors.grey.shade900.withOpacity(0.5) : Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado del tipo
          Row(
            children: [
              CircleAvatar(
                backgroundColor: type.color.withOpacity(0.2),
                radius: 12,
                child: Icon(type.icon, size: 12, color: type.color),
              ),
              const SizedBox(width: 8),
              Text(
                type.name,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: type.color,
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
                    color: type.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${meals.length}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: type.color,
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

  // Construir item de comida individual
  Widget _buildMealItem(
    BuildContext context,
    MealPlan meal,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return InkWell(
      onTap: () {
        // Al tocar una comida, mostrar sus detalles en el planificador
        ref.read(selectedMealProvider.notifier).state = meal;
        context.pushNamed('planner');
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la comida
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(meal.imageUrl),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Información de la comida
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${meal.ingredients.length} ingredientes',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: secondaryTextColor,
                    ),
                  ),

                  // Chips de ingredientes principales (máximo 3)
                  if (meal.ingredients.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children:
                            meal.ingredients
                                .take(3)
                                .map(
                                  (ingredient) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isDark
                                              ? Colors.grey.shade800
                                              : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      ingredient,
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        color:
                                            isDark
                                                ? Colors.grey.shade300
                                                : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                ],
              ),
            ),

            // Recordatorio (si existe)
            if (meal.reminders != null && meal.reminders!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active,
                  size: 12,
                  color: Colors.amber.shade800,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Extensión para capitalizar fechas en español
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
