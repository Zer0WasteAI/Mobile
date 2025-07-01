import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../widgets/meals/daily_meal_planner_widget.dart';
import '../widgets/unified_planning_widget.dart';
import '../../domain/models/meal_plan_models.dart';
import '../providers/planner_providers.dart';

class UnifiedMealPlanningScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const UnifiedMealPlanningScreen({super.key, this.initialDate});

  @override
  ConsumerState<UnifiedMealPlanningScreen> createState() =>
      _UnifiedMealPlanningScreenState();
}

class _UnifiedMealPlanningScreenState
    extends ConsumerState<UnifiedMealPlanningScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late AnimationController _headerAnimationController;
  late PageController _pageController;

  bool _isWeeklyView = true;
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedWeekStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _focusedWeekStart = _getWeekStart(_selectedDate);

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pageController = PageController();

    _fabAnimationController.forward();
    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _headerAnimationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [_buildAppBar(colorScheme, textTheme), _buildMainContent()],
      ),
      floatingActionButton: _buildSmartFAB(),
    );
  }

  Widget _buildAppBar(ColorScheme colorScheme, TextTheme textTheme) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    'Mi Planificador',
                    style: textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getHeaderSubtitle(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  _buildViewToggle(colorScheme),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.onPrimary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToggleButton(
              'Semanal',
              Icons.view_week,
              _isWeeklyView,
              () => _toggleView(true),
              colorScheme,
            ),
            _buildToggleButton(
              'Diario',
              Icons.today,
              !_isWeeklyView,
              () => _toggleView(false),
              colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.onPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? colorScheme.primary : colorScheme.onPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colorScheme.primary : colorScheme.onPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SliverFillRemaining(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1, 0), end: Offset.zero),
            ),
            child: child,
          );
        },
        child: _isWeeklyView ? _buildWeeklyView() : _buildDailyView(),
      ),
    );
  }

  Widget _buildWeeklyView() {
    return Container(
      key: const ValueKey('weekly'),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildWeekNavigation(),
          const SizedBox(height: 16),
          Expanded(
            child: UnifiedPlanningWidget(
              focusedWeekStart: _focusedWeekStart,
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
                ref.read(selectedDateProvider.notifier).state = date;
              },
              onViewDay: (date) {
                setState(() {
                  _selectedDate = date;
                  _isWeeklyView = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyView() {
    return Container(
      key: const ValueKey('daily'),
      child: DailyMealPlannerWidget(
        selectedDate: _selectedDate,
        onDateChanged: (date) {
          setState(() {
            _selectedDate = date;
            _focusedWeekStart = _getWeekStart(date);
          });
          ref.read(selectedDateProvider.notifier).state = date;
        },
      ),
    );
  }

  Widget _buildWeekNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _previousWeek,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Semana anterior',
          ),
          Column(
            children: [
              Text(
                _getWeekTitle(),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                _getWeekRange(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _nextWeek,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Próxima semana',
          ),
        ],
      ),
    );
  }

  Widget _buildSmartFAB() {
    return ScaleTransition(
      scale: _fabAnimationController,
      child: FloatingActionButton.extended(
        onPressed: _handleFABAction,
        icon: Icon(_getFABIcon()),
        label: Text(_getFABLabel()),
        backgroundColor: _getFABColor(),
        elevation: 8,
      ),
    );
  }

  // Helper methods
  String _getHeaderSubtitle() {
    if (_isWeeklyView) {
      return 'Planifica toda la semana de un vistazo\n${_getWeekRange()}';
    } else {
      return 'Gestiona las comidas del día\n${DateFormat('EEEE, d MMMM', 'es_ES').format(_selectedDate)}';
    }
  }

  String _getWeekTitle() {
    final now = DateTime.now();
    final weekStart = _getWeekStart(now);

    if (_focusedWeekStart.isAtSameMomentAs(weekStart)) {
      return 'Esta semana';
    } else if (_focusedWeekStart.isAfter(weekStart)) {
      final diff = _focusedWeekStart.difference(weekStart).inDays ~/ 7;
      return diff == 1 ? 'Próxima semana' : 'En $diff semanas';
    } else {
      final diff = weekStart.difference(_focusedWeekStart).inDays ~/ 7;
      return diff == 1 ? 'Semana pasada' : 'Hace $diff semanas';
    }
  }

  String _getWeekRange() {
    final weekEnd = _focusedWeekStart.add(const Duration(days: 6));
    final startFormat = DateFormat('d MMM', 'es_ES');
    final endFormat = DateFormat('d MMM', 'es_ES');

    return '${startFormat.format(_focusedWeekStart)} - ${endFormat.format(weekEnd)}';
  }

  void _toggleView(bool isWeekly) {
    if (_isWeeklyView != isWeekly) {
      setState(() {
        _isWeeklyView = isWeekly;
      });
    }
  }

  void _previousWeek() {
    setState(() {
      _focusedWeekStart = _focusedWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _focusedWeekStart = _focusedWeekStart.add(const Duration(days: 7));
    });
  }

  // FAB methods
  IconData _getFABIcon() {
    if (_isWeeklyView) {
      return Icons.auto_awesome;
    } else {
      return Icons.add_circle;
    }
  }

  String _getFABLabel() {
    if (_isWeeklyView) {
      return 'Generar Menú Semanal';
    } else {
      return 'Agregar Comida';
    }
  }

  Color _getFABColor() {
    final colorScheme = Theme.of(context).colorScheme;
    if (_isWeeklyView) {
      return colorScheme.secondary;
    } else {
      return colorScheme.primary;
    }
  }

  void _handleFABAction() {
    if (_isWeeklyView) {
      _showWeeklyPlanDialog();
    } else {
      _showAddMealDialog();
    }
  }

  void _showWeeklyPlanDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Plan Automático Semanal',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Crea automáticamente desayuno, almuerzo y cena para todos los días de la semana ${_getWeekRange()}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildPlanOptions(),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildPlanOptions() {
    return Column(
      children: [
        _buildPlanOption(
          'Plan Balanceado',
          'Genera 21 comidas (7 días × 3 comidas) con balance nutricional perfecto',
          Icons.balance,
          Colors.green,
          () => _generateWeeklyPlan('balanced'),
        ),
        const SizedBox(height: 12),
        _buildPlanOption(
          'Plan Rápido',
          'Genera 21 comidas de preparación rápida (menos de 30 minutos)',
          Icons.timer,
          Colors.orange,
          () => _generateWeeklyPlan('quick'),
        ),
        const SizedBox(height: 12),
        _buildPlanOption(
          'Plan con mi Inventario',
          'Genera comidas usando los ingredientes que ya tienes disponibles',
          Icons.inventory,
          Colors.blue,
          () => _generateWeeklyPlan('inventory'),
        ),
      ],
    );
  }

  Widget _buildPlanOption(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMealDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Agregar Comida',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          DateFormat(
                            'EEEE, d MMMM',
                            'es_ES',
                          ).format(_selectedDate),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '¿Qué tipo de comida quieres planificar?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildMealTypeGrid(),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildMealTypeGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildMealTypeCard(MealType.breakfast),
        _buildMealTypeCard(MealType.lunch),
        _buildMealTypeCard(MealType.dinner),
        _buildMealTypeCard(MealType.snack),
      ],
    );
  }

  Widget _buildMealTypeCard(MealType mealType) {
    return InkWell(
      onTap: () => _addMeal(mealType),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: mealType.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: mealType.color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(mealType.icon, color: mealType.color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mealType.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: mealType.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addMeal(MealType mealType) {
    Navigator.pop(context);
    context.pushNamed(
      'recipeGeneration',
      queryParameters: {
        'date': _selectedDate.toIso8601String(),
        'mealType': mealType.toString().split('.').last,
      },
    );
  }

  void _generateWeeklyPlan(String planType) {
    Navigator.pop(context);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Generando plan $planType...'),
              ],
            ),
          ),
    );

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Plan $planType generado exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }
}
