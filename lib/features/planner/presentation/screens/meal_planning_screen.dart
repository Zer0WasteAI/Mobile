import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan_models.dart';
import 'package:zer0_waste_ai/features/planner/application/providers/meal_planning_providers.dart';

/// INFO: Comprehensive meal planning screen with calendar view and meal management
/// USAGE: Main screen for creating, editing, and managing meal plans
class MealPlanningScreen extends ConsumerStatefulWidget {
  const MealPlanningScreen({super.key});

  @override
  ConsumerState<MealPlanningScreen> createState() => _MealPlanningScreenState();
}

class _MealPlanningScreenState extends ConsumerState<MealPlanningScreen> {
  late PageController _pageController;
  DateTime _selectedDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayFormat = DateFormat('EEEE, MMM d, yyyy');

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Load initial data after first build
    Future(() {
      ref.read(mealPlanningProvider.notifier).loadAllMealPlans();
      ref.read(mealPlanningProvider.notifier).loadAvailableDates();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealPlanningState = ref.watch(mealPlanningProvider);
    final editingState = ref.watch(mealPlanEditingProvider);
    final stats = ref.watch(mealPlanStatsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planificación de Comidas'),
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Volver',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => _showStatsDialog(context, stats),
            tooltip: 'Estadísticas',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(mealPlanningProvider.notifier).loadAllMealPlans();
              ref.read(mealPlanningProvider.notifier).loadAvailableDates();
            },
            tooltip: 'Actualizar',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'weekly_planner':
                  Navigator.pushNamed(context, '/planner');
                  break;
                case 'recipes':
                  Navigator.pushNamed(context, '/recipes');
                  break;
                case 'inventory':
                  Navigator.pushNamed(context, '/inventory');
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'weekly_planner',
                    child: ListTile(
                      leading: Icon(Icons.calendar_view_week),
                      title: Text('Planificador Semanal'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'recipes',
                    child: ListTile(
                      leading: Icon(Icons.restaurant_menu),
                      title: Text('Ver Recetas'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'inventory',
                    child: ListTile(
                      leading: Icon(Icons.inventory),
                      title: Text('Inventario'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Date selector
          _buildDateSelector(context, mealPlanningState),

          // Error display
          if (mealPlanningState.error != null)
            _buildErrorBanner(context, mealPlanningState.error!),

          // Loading indicator
          if (mealPlanningState.isLoading)
            const LinearProgressIndicator(
              backgroundColor: Colors.green,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen),
            ),

          // Main content
          Expanded(
            child:
                editingState.isEditing
                    ? _buildEditingView(context, editingState)
                    : _buildViewingView(context, mealPlanningState),
          ),
        ],
      ),
      floatingActionButton:
          editingState.isEditing
              ? _buildEditingFAB(context, editingState)
              : _buildViewingFAB(context, mealPlanningState),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildDateSelector(BuildContext context, MealPlanningState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.green.shade700,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.subtract(
                      const Duration(days: 1),
                    );
                  });
                  _loadMealPlanForSelectedDate();
                },
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _displayFormat.format(_selectedDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.add(const Duration(days: 1));
                  });
                  _loadMealPlanForSelectedDate();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Date indicators
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final date = _selectedDate.subtract(Duration(days: 3 - index));
                final dateString = _dateFormat.format(date);
                final hasPlans = state.hasDateMealPlan(dateString);
                final isSelected =
                    date.day == _selectedDate.day &&
                    date.month == _selectedDate.month &&
                    date.year == _selectedDate.year;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                    _loadMealPlanForSelectedDate();
                  },
                  child: Container(
                    width: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          hasPlans
                              ? Border.all(color: Colors.orange, width: 2)
                              : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(date),
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Colors.green.shade700
                                    : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Colors.green.shade700
                                    : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (hasPlans)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.orange : Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.red.shade100,
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(error, style: TextStyle(color: Colors.red.shade700)),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red.shade700),
            onPressed: () {
              ref.read(mealPlanningProvider.notifier).clearError();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildViewingView(BuildContext context, MealPlanningState state) {
    final dateString = _dateFormat.format(_selectedDate);
    final mealPlan = state.getMealPlanForDate(dateString);

    if (mealPlan == null) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          _buildSummaryCard(context, mealPlan),
          const SizedBox(height: 16),

          // Meals
          if (mealPlan.meals.breakfast != null)
            _buildMealCard(
              context,
              'Desayuno',
              mealPlan.meals.breakfast!,
              Icons.wb_sunny,
            ),
          if (mealPlan.meals.lunch != null)
            _buildMealCard(
              context,
              'Almuerzo',
              mealPlan.meals.lunch!,
              Icons.wb_sunny_outlined,
            ),
          if (mealPlan.meals.dinner != null)
            _buildMealCard(
              context,
              'Cena',
              mealPlan.meals.dinner!,
              Icons.nightlight_round,
            ),
        ],
      ),
    );
  }

  Widget _buildEditingView(BuildContext context, MealPlanEditingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Editando plan para ${_displayFormat.format(_selectedDate)}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 16),

          // Editing cards
          _buildEditingMealCard(
            context,
            'Desayuno',
            state.meals.breakfast,
            Icons.wb_sunny,
            (meal) {
              ref.read(mealPlanEditingProvider.notifier).updateBreakfast(meal);
            },
          ),
          _buildEditingMealCard(
            context,
            'Almuerzo',
            state.meals.lunch,
            Icons.wb_sunny_outlined,
            (meal) {
              ref.read(mealPlanEditingProvider.notifier).updateLunch(meal);
            },
          ),
          _buildEditingMealCard(
            context,
            'Cena',
            state.meals.dinner,
            Icons.nightlight_round,
            (meal) {
              ref.read(mealPlanEditingProvider.notifier).updateDinner(meal);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No hay plan de comidas para este día',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón + para crear un nuevo plan',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, MealPlanModel mealPlan) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resumen del día',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _startEditing(mealPlan);
                    } else if (value == 'delete') {
                      _confirmDelete(
                        context,
                        _dateFormat.format(_selectedDate),
                      );
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSummaryItem(
                  context,
                  Icons.local_fire_department,
                  '${mealPlan.totalCalories} kcal',
                  'Calorías totales',
                  Colors.orange,
                ),
                const SizedBox(width: 16),
                _buildSummaryItem(
                  context,
                  Icons.restaurant,
                  '${mealPlan.meals.allMeals.length} comidas',
                  'Comidas planificadas',
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(
    BuildContext context,
    String mealType,
    Meal meal,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  mealType,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text('${meal.calories} kcal'),
                  backgroundColor: Colors.orange.shade100,
                  labelStyle: TextStyle(color: Colors.orange.shade700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _cleanRecipeTitle(meal.recipeTitle),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${meal.prepTime} min',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Ingredientes:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children:
                  meal.ingredientsNeeded.map((ingredient) {
                    return Chip(
                      label: Text(ingredient.toString()),
                      backgroundColor: Colors.green.shade50,
                      labelStyle: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditingMealCard(
    BuildContext context,
    String mealType,
    Meal? meal,
    IconData icon,
    Function(Meal?) onMealChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  mealType,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const Spacer(),
                if (meal != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => onMealChanged(null),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (meal != null) ...[
              Text(
                _cleanRecipeTitle(meal.recipeTitle),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text('${meal.calories} kcal'),
                    backgroundColor: Colors.orange.shade100,
                    labelStyle: TextStyle(color: Colors.orange.shade700),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text('${meal.prepTime} min'),
                    backgroundColor: Colors.blue.shade100,
                    labelStyle: TextStyle(color: Colors.blue.shade700),
                  ),
                ],
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.grey.shade500,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Agregar $mealType',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed:
                  () => _showMealSelectionDialog(
                    context,
                    mealType,
                    onMealChanged,
                  ),
              icon: Icon(meal != null ? Icons.edit : Icons.add),
              label: Text(meal != null ? 'Cambiar' : 'Agregar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewingFAB(BuildContext context, MealPlanningState state) {
    final dateString = _dateFormat.format(_selectedDate);
    final hasPlan = state.hasDateMealPlan(dateString);

    return FloatingActionButton.extended(
      onPressed: () {
        if (hasPlan) {
          final mealPlan = state.getMealPlanForDate(dateString);
          _startEditing(mealPlan);
        } else {
          _startCreating();
        }
      },
      icon: Icon(hasPlan ? Icons.edit : Icons.add),
      label: Text(hasPlan ? 'Editar Plan' : 'Crear Plan'),
      backgroundColor: Colors.green.shade700,
      foregroundColor: Colors.white,
    );
  }

  Widget _buildEditingFAB(BuildContext context, MealPlanEditingState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: () {
            ref.read(mealPlanEditingProvider.notifier).cancelEditing();
          },
          backgroundColor: Colors.grey.shade600,
          foregroundColor: Colors.white,
          heroTag: 'cancel',
          child: const Icon(Icons.close),
        ),
        const SizedBox(width: 16),
        FloatingActionButton.extended(
          onPressed: state.hasChanges ? () => _saveMealPlan(state) : null,
          icon: const Icon(Icons.save),
          label: const Text('Guardar'),
          backgroundColor:
              state.hasChanges ? Colors.green.shade700 : Colors.grey.shade400,
          foregroundColor: Colors.white,
          heroTag: 'save',
        ),
      ],
    );
  }

  // Helper methods
  void _loadMealPlanForSelectedDate() {
    final dateString = _dateFormat.format(_selectedDate);
    ref.read(mealPlanningProvider.notifier).loadMealPlanForDate(dateString);
  }

  void _startEditing(MealPlanModel? existingPlan) {
    final dateString = _dateFormat.format(_selectedDate);
    ref
        .read(mealPlanEditingProvider.notifier)
        .startEditing(dateString, existingPlan: existingPlan);
  }

  void _startCreating() {
    final dateString = _dateFormat.format(_selectedDate);
    ref.read(mealPlanEditingProvider.notifier).startEditing(dateString);
  }

  Future<void> _saveMealPlan(MealPlanEditingState state) async {
    if (state.date == null) return;

    final success = await ref
        .read(mealPlanningProvider.notifier)
        .saveOrUpdateMealPlan(date: state.date!, meals: state.meals);

    if (success) {
      ref.read(mealPlanEditingProvider.notifier).cancelEditing();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan de comidas guardado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadMealPlanForSelectedDate();
    }
  }

  void _confirmDelete(BuildContext context, String date) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text(
              '¿Estás seguro de que quieres eliminar el plan de comidas para ${_displayFormat.format(_selectedDate)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(mealPlanningProvider.notifier).deleteMealPlan(date);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Plan de comidas eliminado'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showStatsDialog(BuildContext context, MealPlanStats stats) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Estadísticas de Planificación'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatItem('Planes totales', '${stats.totalMealPlans}'),
                  _buildStatItem('Comidas totales', '${stats.totalMeals}'),
                  _buildStatItem(
                    'Promedio calorías/día',
                    '${stats.averageCaloriesPerDay} kcal',
                  ),
                  _buildStatItem(
                    'Calorías totales',
                    '${stats.totalCalories} kcal',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ingredientes más usados:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...stats.mostUsedIngredients
                      .take(5)
                      .map(
                        (ingredient) => Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Text('• $ingredient'),
                        ),
                      ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showMealSelectionDialog(
    BuildContext context,
    String mealType,
    Function(Meal?) onMealChanged,
  ) {
    // This would show a dialog to select/create a meal
    // For now, we'll create a simple example meal
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Agregar $mealType'),
            content: const Text(
              'Esta funcionalidad se conectaría con el sistema de recetas para seleccionar o crear una comida.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  // Example meal creation
                  final exampleMeal = Meal(
                    recipeTitle: 'Ejemplo de $mealType',
                    ingredientsNeeded: [
                      const MealIngredient(
                        name: 'Ingrediente 1',
                        quantity: 1,
                        unit: 'unidad',
                      ),
                      const MealIngredient(
                        name: 'Ingrediente 2',
                        quantity: 2,
                        unit: 'tazas',
                      ),
                    ],
                    prepTime: 15,
                    calories: 300,
                  );
                  onMealChanged(exampleMeal);
                  Navigator.of(context).pop();
                },
                child: const Text('Agregar Ejemplo'),
              ),
            ],
          ),
    );
  }

  // Método para limpiar el título de la receta
  String _cleanRecipeTitle(String title) {
    // Eliminar patrones como "(1)" o "(2)" al final del título
    return title.replaceAll(RegExp(r'\s*\(\d+\)(\s*\(\d+\))*\s*$'), '');
  }
}
