import 'package:flutter/material.dart';
import '../../domain/models/meal_plan_model.dart';

class DailyMealPlanView extends StatefulWidget {
  final DateTime date;
  final MealPlanModel? mealPlan;
  final Function(MealType mealType, Map<String, dynamic> meal) onMealAdded;
  final Function(String mealId, Map<String, dynamic> updatedMeal) onMealEdited;
  final Function(String mealId) onMealDeleted;

  const DailyMealPlanView({
    super.key,
    required this.date,
    this.mealPlan,
    required this.onMealAdded,
    required this.onMealEdited,
    required this.onMealDeleted,
  });

  @override
  State<DailyMealPlanView> createState() => _DailyMealPlanViewState();
}

class _DailyMealPlanViewState extends State<DailyMealPlanView>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: Listenable.merge([_slideController, _fadeController]),
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: _fadeController,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily Summary Card
                  _buildDailySummaryCard(context, theme),
                  
                  const SizedBox(height: 16),
                  
                  // Meal Sections
                  _buildMealSection(
                    context,
                    theme,
                    MealType.breakfast,
                    'Desayuno',
                    Icons.wb_sunny,
                    Colors.orange,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildMealSection(
                    context,
                    theme,
                    MealType.lunch,
                    'Almuerzo',
                    Icons.restaurant,
                    Colors.green,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildMealSection(
                    context,
                    theme,
                    MealType.dinner,
                    'Cena',
                    Icons.nightlight_round,
                    Colors.purple,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildMealSection(
                    context,
                    theme,
                    MealType.snack,
                    'Snacks',
                    Icons.local_cafe,
                    Colors.brown,
                  ),
                  
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailySummaryCard(BuildContext context, ThemeData theme) {
    final totalCalories = widget.mealPlan?.totalCalories ?? 0;
    const targetCalories = 2000; // This should come from user preferences
    final calorieProgress = totalCalories / targetCalories;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resumen del Día',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Icon(
                  Icons.analytics_outlined,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Calorie Progress
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calorías',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalCalories / $targetCalories',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: calorieProgress.clamp(0.0, 1.0),
                        backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          calorieProgress > 1.0
                              ? Colors.red
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Meals Count
                Column(
                  children: [
                    Text(
                      'Comidas',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_getMealsCount()}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(
    BuildContext context,
    ThemeData theme,
    MealType mealType,
    String title,
    IconData icon,
    Color color,
  ) {
    final meals = _getMealsForType(mealType);
    final sectionCalories = _getCaloriesForType(mealType);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          '$sectionCalories cal${meals.isNotEmpty ? ' • ${meals.length} comida${meals.length > 1 ? 's' : ''}' : ''}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (sectionCalories > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$sectionCalories cal',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            IconButton(
              onPressed: () => _showAddMealDialog(context, mealType),
              icon: Icon(Icons.add, color: color),
            ),
          ],
        ),
        children: [
          if (meals.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant_outlined,
                      size: 48,
                      color: theme.colorScheme.outline.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No hay comidas planeadas',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => _showAddMealDialog(context, mealType),
                      icon: Icon(Icons.add, color: color),
                      label: Text(
                        'Agregar comida',
                        style: TextStyle(color: color),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...meals.map((meal) => _buildMealItem(context, theme, meal, color)),
        ],
      ),
    );
  }

  Widget _buildMealItem(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> meal,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 50,
              height: 50,
              color: color.withValues(alpha: 0.1),
              child: meal['image_path'] != null
                  ? Image.network(
                      meal['image_path'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.restaurant, color: color),
                    )
                  : Icon(Icons.restaurant, color: color),
            ),
          ),
          title: Text(
            meal['name'] ?? 'Comida sin nombre',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (meal['description'] != null)
                Text(
                  meal['description'],
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              Text(
                '${meal['calories'] ?? 0} cal${meal['servings'] != null ? ' • ${meal['servings']} porción${meal['servings'] > 1 ? 'es' : ''}' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          trailing: PopupMenuButton(
            icon: Icon(Icons.more_vert, color: theme.colorScheme.outline),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: const Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'duplicate',
                child: const Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Duplicar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: const Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) => _handleMealAction(context, meal, value.toString()),
          ),
        ),
      ),
    );
  }

  void _showAddMealDialog(BuildContext context, MealType mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddMealBottomSheet(
        mealType: mealType,
        onMealAdded: (meal) => widget.onMealAdded(mealType, meal),
      ),
    );
  }

  void _handleMealAction(BuildContext context, Map<String, dynamic> meal, String action) {
    switch (action) {
      case 'edit':
        // Open edit meal dialog
        break;
      case 'duplicate':
        // Duplicate meal
        widget.onMealAdded(_getMealType(meal), Map<String, dynamic>.from(meal));
        break;
      case 'delete':
        // Show confirmation dialog
        _showDeleteConfirmation(context, meal);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> meal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar comida'),
        content: Text('¿Estás seguro de que quieres eliminar "${meal['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onMealDeleted(meal['id'].toString());
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMealsForType(MealType mealType) {
    if (widget.mealPlan == null) return [];
    
    switch (mealType) {
      case MealType.breakfast:
        return widget.mealPlan!.meals.breakfast;
      case MealType.lunch:
        return widget.mealPlan!.meals.lunch;
      case MealType.dinner:
        return widget.mealPlan!.meals.dinner;
      case MealType.snack:
        return widget.mealPlan!.meals.snacks;
    }
  }

  int _getCaloriesForType(MealType mealType) {
    final meals = _getMealsForType(mealType);
    return meals.fold<int>(0, (sum, meal) => sum + (meal['calories'] as int? ?? 0));
  }

  int _getMealsCount() {
    if (widget.mealPlan == null) return 0;
    
    return widget.mealPlan!.meals.breakfast.length +
           widget.mealPlan!.meals.lunch.length +
           widget.mealPlan!.meals.dinner.length +
           widget.mealPlan!.meals.snacks.length;
  }

  MealType _getMealType(Map<String, dynamic> meal) {
    // This should be determined by the meal's type property
    // For now, we'll default to lunch
    return MealType.lunch;
  }
}

// MealType enum is defined in meal_plan_model.dart

// Add Meal Bottom Sheet
class AddMealBottomSheet extends StatelessWidget {
  final MealType mealType;
  final Function(Map<String, dynamic>) onMealAdded;

  const AddMealBottomSheet({
    super.key,
    required this.mealType,
    required this.onMealAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
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
                const SizedBox(height: 16),
                Text(
                  'Agregar ${_getMealTypeName(mealType)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Recetas', icon: Icon(Icons.restaurant_menu)),
                      Tab(text: 'Personalizada', icon: Icon(Icons.add_circle)),
                      Tab(text: 'Rápida', icon: Icon(Icons.flash_on)),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildRecipesTab(context),
                        _buildCustomMealTab(context),
                        _buildQuickMealTab(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesTab(BuildContext context) {
    return const Center(
      child: Text('Lista de recetas guardadas aquí'),
    );
  }

  Widget _buildCustomMealTab(BuildContext context) {
    return const Center(
      child: Text('Formulario para crear comida personalizada aquí'),
    );
  }

  Widget _buildQuickMealTab(BuildContext context) {
    return const Center(
      child: Text('Opciones de comida rápida aquí'),
    );
  }

  String _getMealTypeName(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'Desayuno';
      case MealType.lunch:
        return 'Almuerzo';
      case MealType.dinner:
        return 'Cena';
      case MealType.snack:
        return 'Snack';
    }
  }
}