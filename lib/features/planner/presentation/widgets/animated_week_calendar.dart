import 'package:flutter/material.dart';

class AnimatedWeekCalendar extends StatefulWidget {
  final AnimationController controller;
  final DateTime selectedDate;
  final bool isExpanded;
  final Function(DateTime) onDateSelected;
  final Map<DateTime, bool> planningIndicators;
  final VoidCallback? onPreviousWeek;
  final VoidCallback? onNextWeek;

  const AnimatedWeekCalendar({
    super.key,
    required this.controller,
    required this.selectedDate,
    required this.isExpanded,
    required this.onDateSelected,
    required this.planningIndicators,
    this.onPreviousWeek,
    this.onNextWeek,
  });

  @override
  State<AnimatedWeekCalendar> createState() => _AnimatedWeekCalendarState();
}

class _AnimatedWeekCalendarState extends State<AnimatedWeekCalendar> {
  late DateTime _currentWeekStart;
  late PageController _pageController;
  
  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getWeekStart(widget.selectedDate);
    _pageController = PageController(initialPage: 1000); // Start in middle for infinite scroll
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  List<DateTime> _getWeekDays(DateTime weekStart) {
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  bool _isToday(DateTime date) {
    return _isSameDay(date, DateTime.now());
  }

  String _getWeekTitle(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    
    if (weekStart.month == weekEnd.month) {
      return '${weekStart.day} - ${weekEnd.day} ${months[weekStart.month - 1]}';
    } else {
      return '${weekStart.day} ${months[weekStart.month - 1]} - ${weekEnd.day} ${months[weekEnd.month - 1]}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expandAnimation = Tween<double>(begin: 80, end: 160).animate(
      CurvedAnimation(parent: widget.controller, curve: Curves.easeInOut),
    );

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return Container(
          height: expandAnimation.value,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Week Title Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: widget.onPreviousWeek,
                      icon: Icon(
                        Icons.chevron_left,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _getWeekTitle(_currentWeekStart),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onNextWeek,
                      icon: Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Week Days Row
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _getWeekDays(_currentWeekStart).map((date) {
                      return Expanded(
                        child: _buildDayItem(context, date, theme),
                      );
                    }).toList(),
                  ),
                ),
              ),
              
              // Expanded Calendar (when isExpanded is true)
              if (widget.isExpanded)
                Expanded(
                  child: _buildExpandedCalendar(context, theme),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayItem(BuildContext context, DateTime date, ThemeData theme) {
    final isSelected = _isSameDay(date, widget.selectedDate);
    final isToday = _isToday(date);
    final hasPlanning = widget.planningIndicators[date] ?? false;
    
    const dayNames = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    
    return GestureDetector(
      onTap: () => widget.onDateSelected(date),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day name
            Text(
              dayNames[date.weekday - 1],
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            
            // Day number with selection indicator
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : isToday
                        ? theme.colorScheme.primary.withValues(alpha: 0.2)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: isToday && !isSelected
                    ? Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      )
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : isToday
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  // Planning indicator dot
                  if (hasPlanning)
                    Positioned(
                      bottom: 4,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(3),
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

  Widget _buildExpandedCalendar(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  // Navigate to previous month
                },
                icon: const Icon(Icons.chevron_left),
                label: const Text('Anterior'),
              ),
              Text(
                'Enero 2024',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Navigate to next month
                },
                icon: const Icon(Icons.chevron_right),
                label: const Text('Siguiente'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Mini calendar grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
              ),
              itemCount: 35, // 5 weeks × 7 days
              itemBuilder: (context, index) {
                // Calculate date for this grid position
                final date = DateTime.now().add(Duration(days: index - 15));
                return _buildMiniCalendarDay(context, date, theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCalendarDay(BuildContext context, DateTime date, ThemeData theme) {
    final isSelected = _isSameDay(date, widget.selectedDate);
    final isToday = _isToday(date);
    final hasPlanning = widget.planningIndicators[date] ?? false;
    
    return GestureDetector(
      onTap: () => widget.onDateSelected(date),
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : isToday
                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${date.day}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            // Planning indicator
            if (hasPlanning)
              Positioned(
                bottom: 2,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}