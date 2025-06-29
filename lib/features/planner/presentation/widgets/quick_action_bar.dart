import 'package:flutter/material.dart';

class QuickActionBar extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onAddMeal;
  final VoidCallback onToggleWeekView;
  final VoidCallback? onGenerateRecipes;
  final VoidCallback? onViewRecipes;
  final VoidCallback? onViewInventory;
  final VoidCallback? onScanFood;

  const QuickActionBar({
    super.key,
    required this.selectedDate,
    required this.onAddMeal,
    required this.onToggleWeekView,
    this.onGenerateRecipes,
    this.onViewRecipes,
    this.onViewInventory,
    this.onScanFood,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Primary Actions Row
              Row(
                children: [
                  // Add Meal Button
                  Expanded(
                    flex: 2,
                    child: _buildPrimaryActionButton(
                      context,
                      onPressed: onAddMeal,
                      icon: Icons.add,
                      label: 'Agregar Comida',
                      color: theme.colorScheme.primary,
                      isMainAction: true,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Toggle Week View Button
                  Expanded(
                    child: _buildPrimaryActionButton(
                      context,
                      onPressed: onToggleWeekView,
                      icon: Icons.calendar_view_week,
                      label: 'Semana',
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Secondary Actions Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSecondaryActionButton(
                    context,
                    onPressed: onScanFood,
                    icon: Icons.camera_alt,
                    label: 'Escanear',
                    color: Colors.blue,
                  ),
                  
                  _buildSecondaryActionButton(
                    context,
                    onPressed: onGenerateRecipes,
                    icon: Icons.auto_awesome,
                    label: 'Generar',
                    color: Colors.purple,
                  ),
                  
                  _buildSecondaryActionButton(
                    context,
                    onPressed: onViewRecipes,
                    icon: Icons.restaurant_menu,
                    label: 'Recetas',
                    color: Colors.green,
                  ),
                  
                  _buildSecondaryActionButton(
                    context,
                    onPressed: onViewInventory,
                    icon: Icons.inventory,
                    label: 'Inventario',
                    color: Colors.orange,
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Date Quick Info
              _buildDateQuickInfo(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryActionButton(
    BuildContext context, {
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
    bool isMainAction = false,
  }) {
    final theme = Theme.of(context);
    
    return Material(
      elevation: isMainAction ? 4 : 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: isMainAction
                  ? [color, color.withValues(alpha: 0.8)]
                  : [color.withValues(alpha: 0.1), color.withValues(alpha: 0.2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isMainAction ? Colors.white : color,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isMainAction ? Colors.white : color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryActionButton(
    BuildContext context, {
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 70,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color.withValues(alpha: 0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateQuickInfo(BuildContext context, ThemeData theme) {
    final now = DateTime.now();
    final isToday = selectedDate.day == now.day &&
                   selectedDate.month == now.month &&
                   selectedDate.year == now.year;
    
    final isTomorrow = selectedDate.day == now.add(const Duration(days: 1)).day &&
                      selectedDate.month == now.add(const Duration(days: 1)).month &&
                      selectedDate.year == now.add(const Duration(days: 1)).year;
    
    String dateText;
    IconData dateIcon;
    Color dateColor;
    
    if (isToday) {
      dateText = 'Planificando para hoy';
      dateIcon = Icons.today;
      dateColor = theme.colorScheme.primary;
    } else if (isTomorrow) {
      dateText = 'Planificando para mañana';
      dateIcon = Icons.wb_sunny;
      dateColor = Colors.orange;
    } else {
      dateText = 'Planificando para ${_formatDateShort(selectedDate)}';
      dateIcon = Icons.calendar_today;
      dateColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: dateColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(dateIcon, size: 16, color: dateColor),
          const SizedBox(width: 6),
          Text(
            dateText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: dateColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateShort(DateTime date) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    
    return '${date.day} ${months[date.month - 1]}';
  }
}

// Extended Quick Action Bar with Smart Suggestions
class SmartQuickActionBar extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onAddMeal;
  final VoidCallback onToggleWeekView;
  final List<String> suggestions;
  final Function(String)? onSuggestionTapped;

  const SmartQuickActionBar({
    super.key,
    required this.selectedDate,
    required this.onAddMeal,
    required this.onToggleWeekView,
    this.suggestions = const [],
    this.onSuggestionTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Smart Suggestions
            if (suggestions.isNotEmpty)
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Sugerencias inteligentes',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: suggestions.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: _buildSuggestionChip(
                              context,
                              suggestions[index],
                              () => onSuggestionTapped?.call(suggestions[index]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            
            // Quick Actions
            QuickActionBar(
              selectedDate: selectedDate,
              onAddMeal: onAddMeal,
              onToggleWeekView: onToggleWeekView,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(
    BuildContext context,
    String suggestion,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              suggestion,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Floating Quick Actions (Alternative Implementation)
class FloatingQuickActions extends StatefulWidget {
  final VoidCallback onAddMeal;
  final VoidCallback onScanFood;
  final VoidCallback onGenerateRecipes;

  const FloatingQuickActions({
    super.key,
    required this.onAddMeal,
    required this.onScanFood,
    required this.onGenerateRecipes,
  });

  @override
  State<FloatingQuickActions> createState() => _FloatingQuickActionsState();
}

class _FloatingQuickActionsState extends State<FloatingQuickActions>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _expandAnimation.value,
              child: Opacity(
                opacity: _expandAnimation.value,
                child: Column(
                  children: [
                    FloatingActionButton(
                      heroTag: 'scan',
                      onPressed: widget.onScanFood,
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.camera_alt),
                    ),
                    const SizedBox(height: 16),
                    FloatingActionButton(
                      heroTag: 'generate',
                      onPressed: widget.onGenerateRecipes,
                      backgroundColor: Colors.purple,
                      child: const Icon(Icons.auto_awesome),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
        FloatingActionButton.extended(
          onPressed: _isExpanded ? widget.onAddMeal : _toggle,
          backgroundColor: theme.colorScheme.primary,
          icon: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            child: Icon(_isExpanded ? Icons.add : Icons.restaurant),
          ),
          label: Text(_isExpanded ? 'Agregar' : 'Comidas'),
        ),
      ],
    );
  }
}