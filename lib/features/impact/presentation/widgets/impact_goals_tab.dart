import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/impact/application/providers/impact_providers.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/impact_goal.dart';
import 'dart:math';

/// Widget para la pestaña "Objetivos" del panel de impacto ambiental
class ImpactGoalsTab extends ConsumerWidget {
  const ImpactGoalsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(impactGoalsProvider);
    final activeGoalId = ref.watch(activeGoalProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    // Separar objetivos activos e inactivos
    final activeGoals =
        goals.where((goal) => goal.isActive && !goal.isCompleted).toList();
    final completedGoals = goals.where((goal) => goal.isCompleted).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección de nuevo objetivo
          _buildNewGoalSection(context, primaryColor, textColor),
          const SizedBox(height: 24),

          // Objetivos activos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Objetivos activos',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (activeGoals.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'No tienes objetivos activos. ¡Crea uno nuevo!',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: textColor.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeGoals.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final goal = activeGoals[index];
                return _GoalCard(
                  goal: goal,
                  isActive: goal.id == activeGoalId,
                  onTap: () {
                    ref.read(activeGoalProvider.notifier).state = goal.id;
                  },
                );
              },
            ),

          const SizedBox(height: 24),

          // Objetivos completados
          if (completedGoals.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Objetivos completados',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: completedGoals.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final goal = completedGoals[index];
                return _CompletedGoalCard(goal: goal);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNewGoalSection(
    BuildContext context,
    Color primaryColor,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          _showCreateGoalDialog(context);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryColor.withOpacity(0.5), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_rounded, color: primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crear nuevo objetivo',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Define tus propias metas de impacto ambiental',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: primaryColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const _CreateGoalDialog();
      },
    );
  }
}

/// Diálogo para crear un nuevo objetivo
class _CreateGoalDialog extends ConsumerStatefulWidget {
  const _CreateGoalDialog();

  @override
  _CreateGoalDialogState createState() => _CreateGoalDialogState();
}

class _CreateGoalDialogState extends ConsumerState<_CreateGoalDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  GoalMetricType _selectedMetricType = GoalMetricType.foodSaved;
  double _targetValue = 10.0;
  GoalDuration _selectedDuration = GoalDuration.monthly;

  // Recompensas calculadas
  int _previewEcoCoinsReward = 0;
  int _previewXpReward = 0;

  @override
  void initState() {
    super.initState();
    // Calcular recompensas iniciales
    _updateRewardsPreview();
  }

  void _updateRewardsPreview() {
    // Calcular fecha límite para la previsualización
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

    // Calcular recompensas basado en el tipo de métrica, valor objetivo y duración
    final rewards = _calculateRewards(
      metricType: _selectedMetricType,
      targetValue: _targetValue,
      endDate: endDate,
    );

    setState(() {
      _previewEcoCoinsReward = rewards['ecoCoins']!;
      _previewXpReward = rewards['xp']!;
    });
  }

  Map<String, int> _calculateRewards({
    required GoalMetricType metricType,
    required double targetValue,
    DateTime? endDate,
  }) {
    // Base de recompensas según tipo (con un pequeño componente aleatorio)
    int baseEcoCoins = 0;
    int baseXP = 0;

    switch (metricType) {
      case GoalMetricType.foodSaved:
        baseEcoCoins = 8 + (Random().nextInt(5)); // 8-12
        baseXP = 40 + (Random().nextInt(20)); // 40-59
        break;
      case GoalMetricType.co2Avoided:
        baseEcoCoins = 12 + (Random().nextInt(6)); // 12-17
        baseXP = 50 + (Random().nextInt(20)); // 50-69
        break;
      case GoalMetricType.waterSaved:
        baseEcoCoins = 7 + (Random().nextInt(4)); // 7-10
        baseXP = 35 + (Random().nextInt(20)); // 35-54
        break;
      case GoalMetricType.cookingWithExpiring:
        baseEcoCoins = 10 + (Random().nextInt(5)); // 10-14
        baseXP = 45 + (Random().nextInt(20)); // 45-64
        break;
      case GoalMetricType.ingredientsSaved:
        baseEcoCoins = 9 + (Random().nextInt(5)); // 9-13
        baseXP = 40 + (Random().nextInt(20)); // 40-59
        break;
    }

    // Ajustar según dificultad (valor objetivo)
    double difficultyMultiplier = 1.0;

    if (metricType == GoalMetricType.foodSaved) {
      if (targetValue > 20)
        difficultyMultiplier = 3.0;
      else if (targetValue > 10)
        difficultyMultiplier = 2.0;
      else if (targetValue > 5)
        difficultyMultiplier = 1.5;
    } else if (metricType == GoalMetricType.co2Avoided) {
      if (targetValue > 50)
        difficultyMultiplier = 3.0;
      else if (targetValue > 25)
        difficultyMultiplier = 2.0;
      else if (targetValue > 10)
        difficultyMultiplier = 1.5;
    } else if (metricType == GoalMetricType.waterSaved) {
      if (targetValue > 2000)
        difficultyMultiplier = 3.0;
      else if (targetValue > 1000)
        difficultyMultiplier = 2.0;
      else if (targetValue > 500)
        difficultyMultiplier = 1.5;
    } else {
      if (targetValue > 15)
        difficultyMultiplier = 3.0;
      else if (targetValue > 10)
        difficultyMultiplier = 2.0;
      else if (targetValue > 5)
        difficultyMultiplier = 1.5;
    }

    // Aplicar multiplicador
    baseEcoCoins = (baseEcoCoins * difficultyMultiplier).round();
    baseXP = (baseXP * difficultyMultiplier).round();

    // Ajustar según duración
    if (endDate != null) {
      final durationInDays = endDate.difference(DateTime.now()).inDays;

      if (durationInDays <= 1) {
        baseEcoCoins = (baseEcoCoins * 1.5).round(); // Diario: +50%
        baseXP = (baseXP * 1.5).round();
      } else if (durationInDays <= 7) {
        baseEcoCoins = (baseEcoCoins * 1.2).round(); // Semanal: +20%
        baseXP = (baseXP * 1.2).round();
      }
    }

    // Factor de suerte (±5%)
    final luckFactor = 0.95 + (Random().nextDouble() * 0.1); // 0.95-1.05
    baseEcoCoins = (baseEcoCoins * luckFactor).round();
    baseXP = (baseXP * luckFactor).round();

    // Garantizar un mínimo
    baseEcoCoins = baseEcoCoins.clamp(5, 1000);
    baseXP = baseXP.clamp(25, 5000);

    return {'ecoCoins': baseEcoCoins, 'xp': baseXP};
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título del diálogo con un ícono
              Row(
                children: [
                  Icon(Icons.add_task, color: primaryColor, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Crear nuevo objetivo',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Campos del formulario
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  hintText: 'Ej. Reducir mi huella de carbono',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe tu objetivo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Tipo de métrica con etiqueta separada
              Text(
                'Tipo de métrica:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<GoalMetricType>(
                      value: _selectedMetricType,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(8),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      items: [
                        DropdownMenuItem(
                          value: GoalMetricType.foodSaved,
                          child: Text('Alimentos salvados (kg)'),
                        ),
                        DropdownMenuItem(
                          value: GoalMetricType.co2Avoided,
                          child: Text('CO2 evitado (kg)'),
                        ),
                        DropdownMenuItem(
                          value: GoalMetricType.waterSaved,
                          child: Text('Agua ahorrada (L)'),
                        ),
                        DropdownMenuItem(
                          value: GoalMetricType.cookingWithExpiring,
                          child: Text('Cocinar con ingredientes a expirar'),
                        ),
                        DropdownMenuItem(
                          value: GoalMetricType.ingredientsSaved,
                          child: Text('Ingredientes salvados'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedMetricType = value;
                          });
                          _updateRewardsPreview();
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Valor objetivo con etiqueta
              Text(
                'Valor objetivo: ${_targetValue.toStringAsFixed(1)}' +
                    (_getMetricUnit(_selectedMetricType).isNotEmpty
                        ? ' ${_getMetricUnit(_selectedMetricType)}'
                        : ''),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _targetValue,
                min: 1.0,
                max: _getMaxValueForMetric(_selectedMetricType),
                divisions: _getDivisionsForMetric(_selectedMetricType),
                label:
                    _targetValue.toStringAsFixed(1) +
                    (_getMetricUnit(_selectedMetricType).isNotEmpty
                        ? ' ${_getMetricUnit(_selectedMetricType)}'
                        : ''),
                onChanged: (value) {
                  setState(() {
                    _targetValue = value;
                  });
                  _updateRewardsPreview();
                },
              ),
              const SizedBox(height: 24),

              // Duración con etiqueta separada
              Text(
                'Duración:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<GoalDuration>(
                      value: _selectedDuration,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(8),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      items: [
                        DropdownMenuItem(
                          value: GoalDuration.daily,
                          child: Text('Diario'),
                        ),
                        DropdownMenuItem(
                          value: GoalDuration.weekly,
                          child: Text('Semanal'),
                        ),
                        DropdownMenuItem(
                          value: GoalDuration.monthly,
                          child: Text('Mensual'),
                        ),
                        DropdownMenuItem(
                          value: GoalDuration.quarterly,
                          child: Text('Trimestral'),
                        ),
                        DropdownMenuItem(
                          value: GoalDuration.yearly,
                          child: Text('Anual'),
                        ),
                        DropdownMenuItem(
                          value: GoalDuration.noLimit,
                          child: Text('Sin límite'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedDuration = value;
                          });
                          _updateRewardsPreview();
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Vista previa de recompensas
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recompensas estimadas:',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // EcoCoins
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.monetization_on_outlined,
                                color: Colors.green,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$_previewEcoCoinsReward EcoCoins',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // XP
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_outline,
                                color: Colors.orange,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$_previewXpReward XP',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Las recompensas se reciben al completar el objetivo',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: secondaryTextColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _createGoal();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('Crear objetivo'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Ajusta el valor máximo según el tipo de métrica
  double _getMaxValueForMetric(GoalMetricType type) {
    switch (type) {
      case GoalMetricType.foodSaved:
        return 50.0; // kg
      case GoalMetricType.co2Avoided:
        return 100.0; // kg
      case GoalMetricType.waterSaved:
        return 5000.0; // L
      case GoalMetricType.cookingWithExpiring:
      case GoalMetricType.ingredientsSaved:
        return 30.0; // Conteos
    }
  }

  // Ajusta el número de divisiones según el tipo de métrica
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

    final newGoal = createNewGoalWithCustomRewards(
      title: _titleController.text,
      description:
          _descriptionController.text.isEmpty
              ? 'Mi objetivo de impacto ambiental'
              : _descriptionController.text,
      metricType: _selectedMetricType,
      targetValue: _targetValue,
      endDate: endDate,
      ecoCoinsReward: _previewEcoCoinsReward,
      xpReward: _previewXpReward,
    );

    // Agregar el nuevo objetivo a la lista
    final currentGoals = ref.read(impactGoalsProvider);
    ref.read(impactGoalsProvider.notifier).state = [...currentGoals, newGoal];

    // Establecer como objetivo activo
    ref.read(activeGoalProvider.notifier).state = newGoal.id;

    // Marcar como nuevo objetivo para destacarlo
    ref.read(newGoalIdProvider.notifier).state = newGoal.id;

    // Programar la eliminación de la marca después de 15 segundos
    Future.delayed(const Duration(seconds: 15), () {
      if (ref.read(newGoalIdProvider) == newGoal.id) {
        ref.read(newGoalIdProvider.notifier).state = null;
      }
    });
  }
}

/// Tarjeta para mostrar un objetivo activo
class _GoalCard extends ConsumerWidget {
  final ImpactGoal goal;
  final bool isActive;
  final VoidCallback onTap;

  const _GoalCard({
    required this.goal,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;

    // Comprobar si este objetivo es nuevo
    final isNewGoal = ref.watch(newGoalIdProvider) == goal.id;

    Color metricColor;
    IconData metricIcon;

    switch (goal.metricType) {
      case GoalMetricType.foodSaved:
        metricColor = Colors.green;
        metricIcon = Icons.restaurant;
        break;
      case GoalMetricType.co2Avoided:
        metricColor = Colors.blue;
        metricIcon = Icons.cloud_outlined;
        break;
      case GoalMetricType.waterSaved:
        metricColor = Colors.lightBlue;
        metricIcon = Icons.water_drop_outlined;
        break;
      case GoalMetricType.cookingWithExpiring:
        metricColor = Colors.orange;
        metricIcon = Icons.kitchen;
        break;
      case GoalMetricType.ingredientsSaved:
        metricColor = Colors.purple;
        metricIcon = Icons.inventory_2_outlined;
        break;
    }

    return Card(
      elevation: isNewGoal ? 4 : 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isNewGoal
                  ? Colors.amber
                  : (isActive ? metricColor : Colors.transparent),
          width: isNewGoal ? 2.0 : (isActive ? 1.5 : 0),
        ),
      ),
      color: cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: metricColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(metricIcon, color: metricColor, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      goal.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (isNewGoal)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.fiber_new,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'NUEVO',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: metricColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ACTIVO',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: metricColor,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                goal.description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildProgressBar(context, goal, metricColor),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getMetricLabel(goal.metricType),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),
                  Text(
                    '${goal.currentValue.toStringAsFixed(1)} / ${goal.targetValue.toStringAsFixed(1)} ${_getMetricUnit(goal.metricType)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: metricColor,
                    ),
                  ),
                ],
              ),
              if (goal.endDate != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Fecha límite: ${_formatDate(goal.endDate!)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],

              // Sección de recompensas
              const SizedBox(height: 12),
              Divider(height: 1, color: secondaryTextColor.withOpacity(0.2)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recompensas al completar:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // EcoCoins
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monetization_on_outlined,
                          color: Colors.green,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${goal.ecoCoinsReward} EcoCoins',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // XP
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_outline,
                          color: Colors.orange,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${goal.xpReward} XP',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, ImpactGoal goal, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: goal.progress,
        backgroundColor: color.withOpacity(0.2),
        valueColor: AlwaysStoppedAnimation<Color>(color),
        minHeight: 8,
      ),
    );
  }

  String _getMetricLabel(GoalMetricType type) {
    switch (type) {
      case GoalMetricType.foodSaved:
        return 'Alimentos salvados';
      case GoalMetricType.co2Avoided:
        return 'CO2 evitado';
      case GoalMetricType.waterSaved:
        return 'Agua ahorrada';
      case GoalMetricType.cookingWithExpiring:
        return 'Cocinando con ingredientes expirando';
      case GoalMetricType.ingredientsSaved:
        return 'Ingredientes salvados';
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Tarjeta para mostrar un objetivo completado
class _CompletedGoalCard extends StatelessWidget {
  final ImpactGoal goal;

  const _CompletedGoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;

    final completedColor = Colors.green;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: completedColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.green,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: textColor.withOpacity(0.5),
                      decorationThickness: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¡Objetivo completado!',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: completedColor,
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
}
