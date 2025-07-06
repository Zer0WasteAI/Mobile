import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/meal_plan_models.dart';
import '../providers/meal_planning_providers.dart';

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
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onDateSelected(date),
        borderRadius: BorderRadius.circular(16),
        splashColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          color: _getDayBackgroundColor(isSelected, isToday, isPast),
          borderRadius: BorderRadius.circular(16),
          border: _getDayBorder(isSelected, isToday),
          boxShadow: _getDayBoxShadow(isSelected, isToday),
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
      ),
    );
  }

  Widget _buildDayHeader(DateTime date, bool isSelected, bool isToday, bool isPast) {
    final weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final dayName = weekdays[date.weekday - 1];
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getHeaderBackgroundColor(isSelected, isToday),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Text(
            dayName,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _getDayTextColor(isSelected, isToday, isPast),
              fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getDateNumberBackground(isSelected, isToday),
              shape: BoxShape.circle,
              border: isToday && !isSelected ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ) : null,
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _getDateNumberTextColor(isSelected, isToday, isPast),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (isToday) ...[
            const SizedBox(height: 4),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white 
                    : Theme.of(context).colorScheme.primary,
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
    final isToday = _isSameDay(date, DateTime.now());
    final isSelected = _isSameDay(date, widget.selectedDate);
    
    return InkWell(
      onTap: isPast ? null : () => widget.onViewDay(date),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: _getEmptyStateColor(isPast, isToday, isSelected),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getEmptyStateBorderColor(isPast, isToday, isSelected),
            style: isPast ? BorderStyle.solid : BorderStyle.solid,
            width: isPast ? 1 : 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getEmptyStateIconBackgroundColor(isPast, isToday, isSelected),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPast ? Icons.event_busy : Icons.add_circle,
                  color: _getEmptyStateIconColor(isPast, isToday, isSelected),
                  size: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isPast ? 'Sin plan' : 'Agregar',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _getEmptyStateTextColor(isPast, isToday, isSelected),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRealMealIcons(DateTime date, int mealCount) {
    if (mealCount == 0) return [];
    
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final mealPlanAsync = ref.watch(mealPlanByDateProvider(dateKey));
    
    return mealPlanAsync.when(
      data: (mealPlan) {
        if (mealPlan == null) return [];
        
        // Obtener tipos únicos de comidas que realmente existen
        final List<Widget> icons = [];
        final meals = mealPlan.meals;
        
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
      },
      loading: () => [],
      error: (_, _) => [],
    );
  }

  Widget _buildRealMealIcon(MealType mealType) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: mealType.color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: mealType.color.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: mealType.color.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        mealType.icon,
        size: 14,
        color: mealType.color,
      ),
    );
  }

  Widget _buildDayFooter(DateTime date) {
    final mealCount = _getRealMealCount(date);
    final isSelected = _isSameDay(date, widget.selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getFooterBackgroundColor(isSelected, isToday, mealCount > 0),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: Column(
        children: [
          if (mealCount > 0) ...[
            Text(
              '$mealCount comida${mealCount > 1 ? 's' : ''}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: _getFooterTextColor(isSelected, isToday),
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
          ],
          SizedBox(
            width: double.infinity,
            height: 28,
            child: AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 100),
              child: ElevatedButton(
                onPressed: () => widget.onViewDay(date),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getButtonBackgroundColor(isSelected, isToday, mealCount > 0),
                  foregroundColor: _getButtonTextColor(isSelected, isToday, mealCount > 0),
                  elevation: isSelected ? 3 : (isToday ? 2 : 1),
                  shadowColor: _getButtonBackgroundColor(isSelected, isToday, mealCount > 0).withValues(alpha: 0.4),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  mealCount > 0 ? 'Ver detalle' : 'Agregar',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
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
      return Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
    }
    if (isToday) {
      return Theme.of(context).colorScheme.secondary.withValues(alpha: 0.08);
    }
    if (isPast) {
      return Theme.of(context).colorScheme.surface.withValues(alpha: 0.5);
    }
    return Theme.of(context).colorScheme.surface;
  }

  Color _getDayTextColor(bool isSelected, bool isToday, bool isPast) {
    if (isSelected) {
      return Theme.of(context).colorScheme.primary;
    }
    if (isPast) {
      return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  // Nuevas funciones para mejor styling
  Border? _getDayBorder(bool isSelected, bool isToday) {
    if (isSelected) {
      return Border.all(
        color: Theme.of(context).colorScheme.primary,
        width: 2,
      );
    }
    if (isToday) {
      return Border.all(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
        width: 1,
      );
    }
    return null;
  }

  List<BoxShadow> _getDayBoxShadow(bool isSelected, bool isToday) {
    if (isSelected) {
      return [
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          blurRadius: 24,
          offset: const Offset(0, 12),
          spreadRadius: 2,
        ),
      ];
    }
    if (isToday) {
      return [
        BoxShadow(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.25),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
        BoxShadow(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
    }
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  Color? _getHeaderBackgroundColor(bool isSelected, bool isToday) {
    if (isSelected) {
      return Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);
    }
    if (isToday) {
      return Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1);
    }
    return null;
  }

  Color? _getDateNumberBackground(bool isSelected, bool isToday) {
    if (isSelected) {
      return Theme.of(context).colorScheme.primary;
    }
    if (isToday) {
      return Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2);
    }
    return null;
  }

  Color _getDateNumberTextColor(bool isSelected, bool isToday, bool isPast) {
    if (isSelected) {
      return Colors.white;
    }
    if (isToday) {
      return Theme.of(context).colorScheme.primary;
    }
    if (isPast) {
      return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  // Footer styling functions
  Color? _getFooterBackgroundColor(bool isSelected, bool isToday, bool hasMeals) {
    if (isSelected) {
      return Theme.of(context).colorScheme.primary.withValues(alpha: 0.2);
    }
    if (isToday) {
      return Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15);
    }
    return Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
  }

  Color _getFooterTextColor(bool isSelected, bool isToday) {
    if (isSelected) {
      return Theme.of(context).colorScheme.primary;
    }
    if (isToday) {
      return Theme.of(context).colorScheme.secondary;
    }
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
  }

  Color _getButtonBackgroundColor(bool isSelected, bool isToday, bool hasMeals) {
    if (isSelected) {
      return Theme.of(context).colorScheme.primary;
    }
    if (isToday) {
      return Theme.of(context).colorScheme.secondary;
    }
    if (hasMeals) {
      return Theme.of(context).colorScheme.primary.withValues(alpha: 0.8);
    }
    return Theme.of(context).colorScheme.primary.withValues(alpha: 0.6);
  }

  Color _getButtonTextColor(bool isSelected, bool isToday, bool hasMeals) {
    if (isSelected || isToday || hasMeals) {
      return Colors.white;
    }
    return Colors.white.withValues(alpha: 0.9);
  }

  // Empty state styling functions
  Color _getEmptyStateColor(bool isPast, bool isToday, bool isSelected) {
    if (isPast) {
      return Colors.grey.withValues(alpha: 0.08);
    }
    if (isSelected) {
      return Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);
    }
    if (isToday) {
      return Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12);
    }
    return Theme.of(context).colorScheme.primary.withValues(alpha: 0.08);
  }

  Color _getEmptyStateBorderColor(bool isPast, bool isToday, bool isSelected) {
    if (isPast) {
      return Colors.grey.withValues(alpha: 0.2);
    }
    if (isSelected) {
      return Theme.of(context).colorScheme.primary.withValues(alpha: 0.4);
    }
    if (isToday) {
      return Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4);
    }
    return Theme.of(context).colorScheme.primary.withValues(alpha: 0.3);
  }

  Color _getEmptyStateIconBackgroundColor(bool isPast, bool isToday, bool isSelected) {
    if (isPast) {
      return Colors.grey.withValues(alpha: 0.1);
    }
    if (isSelected) {
      return Theme.of(context).colorScheme.primary.withValues(alpha: 0.2);
    }
    if (isToday) {
      return Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2);
    }
    return Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);
  }

  Color _getEmptyStateIconColor(bool isPast, bool isToday, bool isSelected) {
    if (isPast) {
      return Colors.grey.withValues(alpha: 0.6);
    }
    if (isSelected) {
      return Theme.of(context).colorScheme.primary;
    }
    if (isToday) {
      return Theme.of(context).colorScheme.secondary;
    }
    return Theme.of(context).colorScheme.primary.withValues(alpha: 0.8);
  }

  Color _getEmptyStateTextColor(bool isPast, bool isToday, bool isSelected) {
    if (isPast) {
      return Colors.grey.withValues(alpha: 0.6);
    }
    if (isSelected) {
      return Theme.of(context).colorScheme.primary;
    }
    if (isToday) {
      return Theme.of(context).colorScheme.secondary;
    }
    return Theme.of(context).colorScheme.primary.withValues(alpha: 0.8);
  }

  // Real data methods - Connected with actual meal planning providers
  int _getRealMealCount(DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final mealPlanAsync = ref.watch(mealPlanByDateProvider(dateKey));
    
    return mealPlanAsync.when(
      data: (mealPlan) => mealPlan?.meals.allMeals.length ?? 0,
      loading: () => 0,
      error: (_, _) => 0,
    );
  }

}