import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/meal_plan_models.dart';
import '../../application/providers/meal_planning_providers.dart';

class UnifiedPlanningWidget extends ConsumerStatefulWidget {
  final DateTime focusedWeekStart;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onViewDay;

  const UnifiedPlanningWidget({
    super.key,
    required this.focusedWeekStart,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onViewDay,
  });

  @override
  ConsumerState<UnifiedPlanningWidget> createState() => _UnifiedPlanningWidgetState();
}

class _UnifiedPlanningWidgetState extends ConsumerState<UnifiedPlanningWidget> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildWeekDaysHeader(),
        const SizedBox(height: 16),
        Expanded(
          child: _buildWeekGrid(),
        ),
      ],
    );
  }

  Widget _buildWeekDaysHeader() {
    const weekDays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: weekDays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeekGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(7, (dayIndex) {
          final date = widget.focusedWeekStart.add(Duration(days: dayIndex));
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _buildDayColumn(date),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayColumn(DateTime date) {
    final isSelected = _isSameDay(date, widget.selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    final isPast = date.isBefore(DateTime.now()) && !isToday;
    
    return GestureDetector(
      onTap: () => widget.onDateSelected(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _getDayBackgroundColor(isSelected, isToday, isPast),
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ) : null,
          boxShadow: isSelected ? [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildDayHeader(date, isSelected, isToday, isPast),
            Expanded(
              child: _buildDayMeals(date),
            ),
            _buildDayFooter(date),
          ],
        ),
      ),
    );
  }

  Widget _buildDayHeader(DateTime date, bool isSelected, bool isToday, bool isPast) {
    final weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final dayName = weekdays[date.weekday - 1];
    
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            dayName,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _getDayTextColor(isSelected, isToday, isPast),
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${date.day}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: _getDayTextColor(isSelected, isToday, isPast),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isToday) ...[
            const SizedBox(height: 2),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDayMeals(DateTime date) {
    final mealCount = _getRealMealCount(date);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          if (mealCount == 0) ...[
            Expanded(
              child: _buildEmptyMealsState(date),
            ),
          ] else ...[
            // Solo mostrar iconos reales cuando hay comidas planificadas
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mostrar iconos basados en las comidas reales del provider
                  ..._buildRealMealIcons(date, mealCount),
                  
                  // Si hay más de 3 comidas, mostrar indicador
                  if (mealCount > 3) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${mealCount - 3}',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyMealsState(DateTime date) {
    final isPast = date.isBefore(DateTime.now()) && !_isSameDay(date, DateTime.now());
    
    return InkWell(
      onTap: isPast ? null : () => widget.onViewDay(date),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isPast 
              ? Colors.grey.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPast 
                ? Colors.grey.withValues(alpha: 0.3)
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPast ? Icons.remove_circle_outline : Icons.add_circle_outline,
              color: isPast 
                  ? Colors.grey.withValues(alpha: 0.5)
                  : Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              isPast ? 'Sin plan' : 'Planificar',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isPast 
                    ? Colors.grey.withValues(alpha: 0.6)
                    : Theme.of(context).colorScheme.primary,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRealMealIcons(DateTime date, int mealCount) {
    if (mealCount == 0) return [];
    
    final mealPlanningState = ref.watch(mealPlanningProvider);
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final dayPlan = mealPlanningState.mealPlans[dateKey];
    
    if (dayPlan == null) return [];
    
    // Obtener tipos únicos de comidas que realmente existen
    final List<Widget> icons = [];
    final meals = dayPlan.meals;
    
    // Solo mostrar iconos para comidas que realmente existen (verificar null primero)
    if (meals.breakfast != null) {
      icons.add(_buildRealMealIcon(MealType.breakfast));
    }
    if (meals.lunch != null) {
      if (icons.isNotEmpty) icons.add(const SizedBox(height: 4));
      icons.add(_buildRealMealIcon(MealType.lunch));
    }
    if (meals.dinner != null) {
      if (icons.isNotEmpty) icons.add(const SizedBox(height: 4));
      icons.add(_buildRealMealIcon(MealType.dinner));
    }
    
    return icons;
  }

  Widget _buildRealMealIcon(MealType mealType) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: mealType.color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: mealType.color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Icon(
        mealType.icon,
        size: 12,
        color: mealType.color,
      ),
    );
  }

  Widget _buildDayFooter(DateTime date) {
    final calories = _getRealCalories(date);
    final mealCount = _getRealMealCount(date);
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: Column(
        children: [
          if (mealCount > 0) ...[
            Column(
              children: [
                Text(
                  '$calories kcal',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$mealCount comida${mealCount > 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          SizedBox(
            width: double.infinity,
            height: 24,
            child: ElevatedButton(
              onPressed: () => widget.onViewDay(date),
              style: ElevatedButton.styleFrom(
                backgroundColor: mealCount > 0 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                mealCount > 0 ? 'Ver detalle' : 'Agregar',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  Color _getDayBackgroundColor(bool isSelected, bool isToday, bool isPast) {
    if (isSelected) {
      return Theme.of(context).colorScheme.primaryContainer;
    }
    if (isToday) {
      return Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3);
    }
    if (isPast) {
      return Theme.of(context).colorScheme.surface.withValues(alpha: 0.5);
    }
    return Theme.of(context).colorScheme.surface;
  }

  Color _getDayTextColor(bool isSelected, bool isToday, bool isPast) {
    if (isSelected) {
      return Theme.of(context).colorScheme.onPrimaryContainer;
    }
    if (isPast) {
      return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  // Real data methods - Connected with actual meal planning providers
  int _getRealMealCount(DateTime date) {
    final mealPlanningState = ref.watch(mealPlanningProvider);
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final dayPlan = mealPlanningState.mealPlans[dateKey];
    
    // Solo contar comidas que realmente existen
    return dayPlan?.meals.allMeals.length ?? 0;
  }

  int _getRealCalories(DateTime date) {
    final mealPlanningState = ref.watch(mealPlanningProvider);
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final dayPlan = mealPlanningState.mealPlans[dateKey];
    
    // Solo mostrar calorías si hay comidas reales
    return dayPlan?.meals.totalCalories ?? 0;
  }
}