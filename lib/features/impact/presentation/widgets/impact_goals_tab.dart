import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/impact/application/providers/impact_providers.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/impact_goal.dart';

/// Widget para la pestaña "Objetivos" del panel de impacto ambiental
class ImpactGoalsTab extends ConsumerStatefulWidget {
  const ImpactGoalsTab({super.key});

  @override
  ConsumerState<ImpactGoalsTab> createState() => _ImpactGoalsTabState();
}

class _ImpactGoalsTabState extends ConsumerState<ImpactGoalsTab> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  GoalMetricType _selectedMetricType = GoalMetricType.foodSaved;
  GoalDuration _selectedDuration = GoalDuration.weekly;
  double _targetValue = 5.0;

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(impactGoalsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            'Mis Objetivos',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Define metas para maximizar tu impacto ambiental',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Botón para crear nuevo objetivo
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  () => _showCreateGoalDialog(context, primaryColor, textColor),
              icon: const Icon(Icons.add),
              label: const Text('Crear Nuevo Objetivo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Lista de objetivos
          if (goals.isEmpty)
            _buildEmptyState(primaryColor, textColor)
          else
            ...goals.map(
              (goal) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildGoalCard(goal, primaryColor, textColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color primaryColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.flag_outlined,
            size: 48,
            color: primaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes objetivos aún',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer objetivo para comenzar a medir tu impacto ambiental',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(dynamic goal, Color primaryColor, Color textColor) {
    final isCompleted = goal.isCompleted;
    final isExpired = goal.isExpired;

    Color cardColor;
    if (isCompleted) {
      cardColor = Colors.green.withValues(alpha: 0.1);
    } else if (isExpired) {
      cardColor = Colors.red.withValues(alpha: 0.1);
    } else {
      cardColor = primaryColor.withValues(alpha: 0.05);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isCompleted
                  ? Colors.green.withValues(alpha: 0.3)
                  : isExpired
                  ? Colors.red.withValues(alpha: 0.3)
                  : primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Completado',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              else if (isExpired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Expirado',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            goal.description,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),

          // Barra de progreso
          LinearProgressIndicator(
            value: goal.progress,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation(
              isCompleted ? Colors.green : primaryColor,
            ),
            minHeight: 6,
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(goal.progress * 100).toStringAsFixed(1)}% completado',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isCompleted ? Colors.green : primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${goal.currentValue.toStringAsFixed(1)} / ${goal.targetValue.toStringAsFixed(1)} ${_getMetricUnit(goal.metricType)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),

          if (goal.endDate != null) ...[
            const SizedBox(height: 8),
            Text(
              'Fecha límite: ${_formatDate(goal.endDate!)}',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: textColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCreateGoalDialog(
    BuildContext context,
    Color primaryColor,
    Color textColor,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Crear Nuevo Objetivo',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título del objetivo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Selector de tipo de métrica
                  DropdownButtonFormField<GoalMetricType>(
                    value: _selectedMetricType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de métrica',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        GoalMetricType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_getMetricTypeLabel(type)),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMetricType = value!;
                        _targetValue = _getDefaultTargetValue(
                          _selectedMetricType,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Selector de duración
                  DropdownButtonFormField<GoalDuration>(
                    value: _selectedDuration,
                    decoration: const InputDecoration(
                      labelText: 'Duración',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        GoalDuration.values.map((duration) {
                          return DropdownMenuItem(
                            value: duration,
                            child: Text(_getDurationLabel(duration)),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDuration = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Slider para valor objetivo
                  Text(
                    'Valor objetivo: ${_targetValue.toStringAsFixed(1)} ${_getMetricUnit(_selectedMetricType)}',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                  Slider(
                    value: _targetValue,
                    min: _getMinValueForMetric(_selectedMetricType),
                    max: _getMaxValueForMetric(_selectedMetricType),
                    divisions: _getDivisionsForMetric(_selectedMetricType),
                    onChanged: (value) {
                      setState(() {
                        _targetValue = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  _createGoal();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Crear'),
              ),
            ],
          ),
    );
  }

  String _getMetricTypeLabel(GoalMetricType type) {
    switch (type) {
      case GoalMetricType.foodSaved:
        return 'Alimentos salvados';
      case GoalMetricType.co2Avoided:
        return 'CO₂ evitado';
      case GoalMetricType.waterSaved:
        return 'Agua ahorrada';
      case GoalMetricType.cookingWithExpiring:
        return 'Cocinar con ingredientes por vencer';
      case GoalMetricType.ingredientsSaved:
        return 'Ingredientes salvados';
    }
  }

  String _getDurationLabel(GoalDuration duration) {
    switch (duration) {
      case GoalDuration.daily:
        return 'Diario';
      case GoalDuration.weekly:
        return 'Semanal';
      case GoalDuration.monthly:
        return 'Mensual';
      case GoalDuration.quarterly:
        return 'Trimestral';
      case GoalDuration.yearly:
        return 'Anual';
      case GoalDuration.noLimit:
        return 'Sin límite';
    }
  }

  double _getDefaultTargetValue(GoalMetricType type) {
    switch (type) {
      case GoalMetricType.foodSaved:
        return 5.0;
      case GoalMetricType.co2Avoided:
        return 10.0;
      case GoalMetricType.waterSaved:
        return 500.0;
      case GoalMetricType.cookingWithExpiring:
      case GoalMetricType.ingredientsSaved:
        return 10.0;
    }
  }

  double _getMinValueForMetric(GoalMetricType type) {
    switch (type) {
      case GoalMetricType.foodSaved:
        return 1.0;
      case GoalMetricType.co2Avoided:
        return 1.0;
      case GoalMetricType.waterSaved:
        return 100.0;
      case GoalMetricType.cookingWithExpiring:
      case GoalMetricType.ingredientsSaved:
        return 1.0;
    }
  }

  double _getMaxValueForMetric(GoalMetricType type) {
    switch (type) {
      case GoalMetricType.foodSaved:
        return 50.0;
      case GoalMetricType.co2Avoided:
        return 100.0;
      case GoalMetricType.waterSaved:
        return 5000.0;
      case GoalMetricType.cookingWithExpiring:
      case GoalMetricType.ingredientsSaved:
        return 30.0;
    }
  }

  int _getDivisionsForMetric(GoalMetricType type) {
    switch (type) {
      case GoalMetricType.foodSaved:
        return 50;
      case GoalMetricType.co2Avoided:
        return 100;
      case GoalMetricType.waterSaved:
        return 50;
      case GoalMetricType.cookingWithExpiring:
      case GoalMetricType.ingredientsSaved:
        return 30;
    }
  }

  String _getMetricUnit(GoalMetricType type) {
    switch (type) {
      case GoalMetricType.foodSaved:
        return 'kg';
      case GoalMetricType.co2Avoided:
        return 'kg';
      case GoalMetricType.waterSaved:
        return 'L';
      case GoalMetricType.cookingWithExpiring:
      case GoalMetricType.ingredientsSaved:
        return '';
    }
  }

  void _createGoal() {
    if (_titleController.text.isEmpty) return;

    DateTime? endDate;
    switch (_selectedDuration) {
      case GoalDuration.daily:
        endDate = DateTime.now().add(const Duration(days: 1));
        break;
      case GoalDuration.weekly:
        endDate = DateTime.now().add(const Duration(days: 7));
        break;
      case GoalDuration.monthly:
        endDate = DateTime.now().add(const Duration(days: 30));
        break;
      case GoalDuration.quarterly:
        endDate = DateTime.now().add(const Duration(days: 90));
        break;
      case GoalDuration.yearly:
        endDate = DateTime.now().add(const Duration(days: 365));
        break;
      case GoalDuration.noLimit:
        endDate = null;
        break;
    }

    final newGoal = createNewGoal(
      title: _titleController.text,
      description:
          _descriptionController.text.isEmpty
              ? 'Mi objetivo de impacto ambiental'
              : _descriptionController.text,
      metricType: _selectedMetricType,
      targetValue: _targetValue,
      endDate: endDate,
    );

    // Agregar el nuevo objetivo a la lista
    ref.read(impactGoalsProvider.notifier).addGoal(newGoal);

    // Limpiar formulario
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedMetricType = GoalMetricType.foodSaved;
      _selectedDuration = GoalDuration.weekly;
      _targetValue = 5.0;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
