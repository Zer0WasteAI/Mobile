import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../widgets/calendar/unified_calendar_widget.dart';
import '../widgets/meals/daily_meal_planner_widget.dart';
import '../widgets/analytics/meal_analytics_widget.dart';
import '../../domain/models/meal_plan_models.dart';

class UnifiedMealPlanningScreen extends ConsumerStatefulWidget {
  const UnifiedMealPlanningScreen({super.key});

  @override
  ConsumerState<UnifiedMealPlanningScreen> createState() => _UnifiedMealPlanningScreenState();
}

class _UnifiedMealPlanningScreenState extends ConsumerState<UnifiedMealPlanningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planificación de Comidas'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.calendar_month),
              text: 'Calendario',
            ),
            Tab(
              icon: Icon(Icons.restaurant_menu),
              text: 'Planificar',
            ),
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Análisis',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Calendar View
          UnifiedCalendarWidget(
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
              // Switch to planning tab when date is selected
              _tabController.animateTo(1);
            },
          ),
          
          // Tab 2: Daily Planning
          DailyMealPlannerWidget(
            selectedDate: _selectedDate,
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          
          // Tab 3: Analytics
          MealAnalyticsWidget(
            selectedDate: _selectedDate,
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        switch (_tabController.index) {
          case 0: // Calendar tab
            return FloatingActionButton.extended(
              onPressed: () => _showQuickPlanDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Plan Rápido'),
              backgroundColor: Theme.of(context).primaryColor,
            );
          case 1: // Planning tab
            return FloatingActionButton.extended(
              onPressed: () => _showAddMealDialog(),
              icon: const Icon(Icons.restaurant),
              label: const Text('Agregar Comida'),
              backgroundColor: Colors.green,
            );
          case 2: // Analytics tab
            return FloatingActionButton.extended(
              onPressed: () => _exportAnalytics(),
              icon: const Icon(Icons.file_download),
              label: const Text('Exportar'),
              backgroundColor: Colors.blue,
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  void _showQuickPlanDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Plan Rápido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Crear plan automático para ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
            const SizedBox(height: 16),
            const Text('¿Generar plan basado en tus preferencias?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateAutomaticPlan();
            },
            child: const Text('Generar'),
          ),
        ],
      ),
    );
  }

  void _showAddMealDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Comida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(MealType.breakfast.icon, color: MealType.breakfast.color),
              title: Text(MealType.breakfast.name),
              onTap: () => _addMeal(MealType.breakfast),
            ),
            ListTile(
              leading: Icon(MealType.lunch.icon, color: MealType.lunch.color),
              title: Text(MealType.lunch.name),
              onTap: () => _addMeal(MealType.lunch),
            ),
            ListTile(
              leading: Icon(MealType.dinner.icon, color: MealType.dinner.color),
              title: Text(MealType.dinner.name),
              onTap: () => _addMeal(MealType.dinner),
            ),
            ListTile(
              leading: Icon(MealType.snack.icon, color: MealType.snack.color),
              title: Text(MealType.snack.name),
              onTap: () => _addMeal(MealType.snack),
            ),
          ],
        ),
      ),
    );
  }

  void _addMeal(MealType mealType) {
    Navigator.pop(context);
    // Navigate to recipe selection for this meal type
    // Implementation depends on recipe selection screen
  }

  void _generateAutomaticPlan() {
    // Generate automatic meal plan using AI
    // Implementation depends on meal planning provider
  }

  void _exportAnalytics() {
    // Export analytics data
    // Implementation depends on analytics functionality
  }
}