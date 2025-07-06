import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../providers/meal_planning_providers.dart';

class UnifiedCalendarWidget extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const UnifiedCalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  ConsumerState<UnifiedCalendarWidget> createState() => _UnifiedCalendarWidgetState();
}

class _UnifiedCalendarWidgetState extends ConsumerState<UnifiedCalendarWidget> {
  late DateTime _focusedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    final mealPlanDates = ref.watch(mealPlanDatesProvider);

    return Column(
      children: [
        _buildCalendarHeader(),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TableCalendar<String>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(widget.selectedDate, day),
              calendarFormat: _calendarFormat,
              startingDayOfWeek: StartingDayOfWeek.monday,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Mes',
                CalendarFormat.week: 'Semana',
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(color: Colors.red[400]),
                holidayTextStyle: TextStyle(color: Colors.red[800]),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                markerDecoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: Icon(Icons.chevron_left),
                rightChevronIcon: Icon(Icons.chevron_right),
              ),
              eventLoader: (day) {
                return mealPlanDates.when(
                  data: (dates) {
                    final dayString = DateFormat('yyyy-MM-dd').format(day);
                    return dates.contains(dayString) ? ['has_plan'] : [];
                  },
                  loading: () => [],
                  error: (_, _) => [],
                );
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
                widget.onDateSelected(selectedDay);
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
            ),
          ),
        ),
        _buildLegend(),
        _buildQuickActions(),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            Theme.of(context).primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Planificación de Comidas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                DateFormat('MMMM yyyy', 'es_ES').format(_focusedDay),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _calendarFormat == CalendarFormat.month 
                    ? Icons.view_week 
                    : Icons.view_module,
                ),
                onPressed: () {
                  setState(() {
                    _calendarFormat = _calendarFormat == CalendarFormat.month
                        ? CalendarFormat.week
                        : CalendarFormat.month;
                  });
                },
                tooltip: _calendarFormat == CalendarFormat.month 
                  ? 'Vista Semanal' 
                  : 'Vista Mensual',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(
            color: Theme.of(context).primaryColor,
            label: 'Día Seleccionado',
            icon: Icons.today,
          ),
          _buildLegendItem(
            color: Colors.green,
            label: 'Con Plan',
            icon: Icons.restaurant_menu,
          ),
          _buildLegendItem(
            color: Colors.grey,
            label: 'Sin Plan',
            icon: Icons.add_circle_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _goToToday(),
              icon: const Icon(Icons.today),
              label: const Text('Hoy'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _planWeek(),
              icon: const Icon(Icons.view_week),
              label: const Text('Plan Semanal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToToday() {
    final today = DateTime.now();
    setState(() {
      _focusedDay = today;
    });
    widget.onDateSelected(today);
  }

  void _planWeek() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Plan Semanal'),
        content: Text(
          'Generar plan automático para la semana del ${DateFormat('dd/MM/yyyy').format(_getWeekStart(_focusedDay))}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateWeeklyPlan();
            },
            child: const Text('Generar'),
          ),
        ],
      ),
    );
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _generateWeeklyPlan() {
    // Generate weekly meal plan
    // Implementation depends on meal planning provider
  }
}