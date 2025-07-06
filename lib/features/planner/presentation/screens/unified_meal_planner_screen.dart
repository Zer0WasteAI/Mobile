import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/animated_week_calendar.dart';
import '../widgets/daily_meal_plan_view.dart';
import '../widgets/quick_action_bar.dart';
import '../providers/unified_meal_planner_provider.dart';

class UnifiedMealPlannerScreen extends ConsumerStatefulWidget {
  const UnifiedMealPlannerScreen({super.key});

  @override
  ConsumerState<UnifiedMealPlannerScreen> createState() => _UnifiedMealPlannerScreenState();
}

class _UnifiedMealPlannerScreenState extends ConsumerState<UnifiedMealPlannerScreen>
    with TickerProviderStateMixin {
  late AnimationController _weekCalendarController;
  late AnimationController _dailyViewController;
  
  bool _isWeekExpanded = false;
  DateTime _selectedDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _weekCalendarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _dailyViewController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Initialize with today's date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(unifiedMealPlannerProvider.notifier).selectDate(_selectedDate);
    });
  }

  @override
  void dispose() {
    _weekCalendarController.dispose();
    _dailyViewController.dispose();
    super.dispose();
  }

  void _toggleWeekExpansion() {
    setState(() {
      _isWeekExpanded = !_isWeekExpanded;
    });
    
    if (_isWeekExpanded) {
      _weekCalendarController.forward();
    } else {
      _weekCalendarController.reverse();
    }
  }

  void _navigateToDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    
    ref.read(unifiedMealPlannerProvider.notifier).selectDate(date);
    
    // Animate daily view transition
    _dailyViewController.reset();
    _dailyViewController.forward();
    
    // Auto-collapse week view after selection
    if (_isWeekExpanded) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _toggleWeekExpansion();
      });
    }
  }

  void _navigateToPreviousDay() {
    final previousDay = _selectedDate.subtract(const Duration(days: 1));
    _navigateToDate(previousDay);
  }

  void _navigateToNextDay() {
    final nextDay = _selectedDate.add(const Duration(days: 1));
    _navigateToDate(nextDay);
  }

  void _showAddMealDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const AddMealBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plannerState = ref.watch(unifiedMealPlannerProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Planificador de Comidas',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _toggleWeekExpansion,
            icon: AnimatedRotation(
              turns: _isWeekExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.expand_more,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Animated Week Calendar
          AnimatedWeekCalendar(
            controller: _weekCalendarController,
            selectedDate: _selectedDate,
            isExpanded: _isWeekExpanded,
            onDateSelected: _navigateToDate,
            planningIndicators: plannerState.weeklyIndicators,
            onPreviousWeek: () => ref.read(unifiedMealPlannerProvider.notifier).navigateWeek(-1),
            onNextWeek: () => ref.read(unifiedMealPlannerProvider.notifier).navigateWeek(1),
          ),
          
          // Day Navigation Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: _navigateToPreviousDay,
                  icon: Icon(Icons.chevron_left, color: theme.colorScheme.primary),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _toggleWeekExpansion,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatSelectedDate(_selectedDate),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _navigateToNextDay,
                  icon: Icon(Icons.chevron_right, color: theme.colorScheme.primary),
                ),
              ],
            ),
          ),
          
          // Daily Meal Plan View
          Expanded(
            child: plannerState.isLoading 
              ? const Center(child: CircularProgressIndicator())
              : AnimatedBuilder(
                  animation: _dailyViewController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.3, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _dailyViewController,
                        curve: Curves.easeOutCubic,
                      )),
                      child: FadeTransition(
                        opacity: _dailyViewController,
                        child: DailyMealPlanView(
                          date: _selectedDate,
                          mealPlan: plannerState.selectedDayPlan,
                          onMealAdded: (mealType, meal) {
                            ref.read(unifiedMealPlannerProvider.notifier)
                                .addMealToDay(_selectedDate, mealType, meal);
                          },
                          onMealEdited: (mealId, updatedMeal) {
                            ref.read(unifiedMealPlannerProvider.notifier)
                                .editMeal(_selectedDate, mealId, updatedMeal);
                          },
                          onMealDeleted: (mealId) {
                            ref.read(unifiedMealPlannerProvider.notifier)
                                .deleteMeal(_selectedDate, mealId);
                          },
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
      
      // Quick Action Bar
      bottomNavigationBar: QuickActionBar(
        selectedDate: _selectedDate,
        onAddMeal: _showAddMealDialog,
        onToggleWeekView: _toggleWeekExpansion,
        onGenerateRecipes: () {
          context.push('/recipes/generate');
        },
        onViewRecipes: () {
          context.push('/recipes');
        },
      ),
      
      // Floating Action Button for Quick Add
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMealDialog,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Agregar Comida'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  String _formatSelectedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);
    
    if (selectedDay == today) {
      return 'Hoy - ${_formatDateString(date)}';
    } else if (selectedDay == today.add(const Duration(days: 1))) {
      return 'Mañana - ${_formatDateString(date)}';
    } else if (selectedDay == today.subtract(const Duration(days: 1))) {
      return 'Ayer - ${_formatDateString(date)}';
    } else {
      return _formatDateString(date);
    }
  }

  String _formatDateString(DateTime date) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    const weekdays = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
    ];
    
    return '${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
  }
}

class AddMealBottomSheet extends StatelessWidget {
  const AddMealBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Agregar Comida',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Add meal options here
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMealTypeCard(context, 'Desayuno', Icons.wb_sunny, Colors.orange),
                _buildMealTypeCard(context, 'Almuerzo', Icons.restaurant, Colors.green),
                _buildMealTypeCard(context, 'Cena', Icons.nightlight_round, Colors.purple),
                _buildMealTypeCard(context, 'Snack', Icons.local_cafe, Colors.brown),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeCard(BuildContext context, String title, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          // Navigate to meal creation for this type
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}