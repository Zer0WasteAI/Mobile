/// INFO: Dialog for creating and managing reminders
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/reminder_models.dart';
import '../../../domain/models/meal_plan_models.dart';
import '../../providers/reminder_providers.dart';

class ReminderDialog extends ConsumerStatefulWidget {
  final SimpleRecipe recipe;
  final DateTime mealTime;
  final List<MealReminder>? existingReminders;

  const ReminderDialog({
    super.key,
    required this.recipe,
    required this.mealTime,
    this.existingReminders,
  });

  @override
  ConsumerState<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends ConsumerState<ReminderDialog> {
  final List<MealReminder> _selectedReminders = [];
  final TextEditingController _customTitleController = TextEditingController();
  final TextEditingController _customMessageController = TextEditingController();
  
  ReminderType _selectedType = ReminderType.cooking;
  Duration _selectedBeforeTime = const Duration(minutes: 30);
  bool _showCustomForm = false;

  @override
  void initState() {
    super.initState();
    _initializeDefaultReminders();
  }

  @override
  void dispose() {
    _customTitleController.dispose();
    _customMessageController.dispose();
    super.dispose();
  }

  void _initializeDefaultReminders() {
    final settings = ref.read(reminderSettingsProvider);
    
    // Add default reminders based on settings
    for (final type in settings.defaultTypes) {
      Duration beforeTime;
      switch (type) {
        case ReminderType.shopping:
          beforeTime = settings.defaultShoppingTime;
          break;
        case ReminderType.prepping:
          beforeTime = settings.defaultPrepTime;
          break;
        case ReminderType.cooking:
          beforeTime = settings.defaultCookingTime;
          break;
        case ReminderType.preparation:
          beforeTime = const Duration(hours: 2);
          break;
        case ReminderType.custom:
          continue; // Skip custom type in defaults
      }

      final reminder = MealReminder(
        id: '${widget.recipe.id}_${type.toString().split('.').last}_${widget.mealTime.millisecondsSinceEpoch}',
        title: widget.recipe.name,
        type: type,
        scheduledTime: widget.mealTime,
        beforeMealTime: beforeTime,
        recipeId: widget.recipe.id,
        description: _getDescriptionForType(type),
      );

      _selectedReminders.add(reminder);
    }
  }

  String _getDescriptionForType(ReminderType type) {
    switch (type) {
      case ReminderType.preparation:
        return 'Revisar receta y preparar espacio de trabajo';
      case ReminderType.shopping:
        return 'Comprar ingredientes necesarios';
      case ReminderType.prepping:
        return 'Lavar y preparar ingredientes';
      case ReminderType.cooking:
        return 'Comenzar a cocinar';
      case ReminderType.custom:
        return 'Recordatorio personalizado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMealInfo(),
                    const SizedBox(height: 20),
                    _buildDefaultReminders(),
                    const SizedBox(height: 20),
                    _buildCustomReminderSection(),
                    if (_showCustomForm) ...[
                      const SizedBox(height: 16),
                      _buildCustomReminderForm(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.notifications_active,
          color: Theme.of(context).primaryColor,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configurar Recordatorios',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Configura cuando recibir notificaciones',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildMealInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.recipe.type.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.recipe.type.icon,
              color: widget.recipe.type.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.recipe.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.recipe.type.name} - ${DateFormat('EEEE, dd MMMM HH:mm', 'es_ES').format(widget.mealTime)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultReminders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recordatorios Sugeridos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._selectedReminders.map((reminder) => _buildReminderTile(reminder)),
      ],
    );
  }

  Widget _buildReminderTile(MealReminder reminder) {
    final isSelected = _selectedReminders.contains(reminder);
    final triggerTime = reminder.scheduledTime.subtract(reminder.beforeMealTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? reminder.type.color.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? reminder.type.color : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              if (!_selectedReminders.contains(reminder)) {
                _selectedReminders.add(reminder);
              }
            } else {
              _selectedReminders.remove(reminder);
            }
          });
        },
        activeColor: reminder.type.color,
        title: Row(
          children: [
            Icon(
              reminder.type.icon,
              color: reminder.type.color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              reminder.type.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reminder.description ?? ''),
            const SizedBox(height: 4),
            Text(
              'Recordar ${ReminderTimeOptions.formatDuration(reminder.beforeMealTime)} (${DateFormat('HH:mm').format(triggerTime)})',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recordatorio Personalizado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showCustomForm = !_showCustomForm;
                });
              },
              icon: Icon(_showCustomForm ? Icons.remove : Icons.add),
              label: Text(_showCustomForm ? 'Cancelar' : 'Agregar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomReminderForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reminder type selector
          Text(
            'Tipo de recordatorio',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ReminderType.values.map((type) {
              return FilterChip(
                label: Text(type.name),
                selected: _selectedType == type,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedType = type);
                  }
                },
                backgroundColor: Colors.white,
                selectedColor: type.color.withValues(alpha: 0.2),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Time selector
          Text(
            'Tiempo antes de la comida',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ReminderTimeOptions.predefinedTimes.map((duration) {
              return FilterChip(
                label: Text(ReminderTimeOptions.formatDuration(duration)),
                selected: _selectedBeforeTime == duration,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedBeforeTime = duration);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Custom title
          TextField(
            controller: _customTitleController,
            decoration: InputDecoration(
              labelText: 'Título (opcional)',
              hintText: 'Ej: Preparar ingredientes especiales',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Custom message
          TextField(
            controller: _customMessageController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Mensaje personalizado (opcional)',
              hintText: 'Ej: No olvides sacar la carne del congelador',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Add custom reminder button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addCustomReminder,
              icon: const Icon(Icons.add),
              label: const Text('Agregar Recordatorio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedType.color,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _selectedReminders.isNotEmpty ? _saveReminders : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Guardar (${_selectedReminders.length})'),
          ),
        ),
      ],
    );
  }

  void _addCustomReminder() {
    final title = _customTitleController.text.isEmpty 
        ? widget.recipe.name 
        : _customTitleController.text;
    
    final customReminder = MealReminder(
      id: '${widget.recipe.id}_custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      type: _selectedType,
      scheduledTime: widget.mealTime,
      beforeMealTime: _selectedBeforeTime,
      recipeId: widget.recipe.id,
      description: _selectedType.name,
      customMessage: _customMessageController.text.isEmpty 
          ? null 
          : _customMessageController.text,
    );

    setState(() {
      _selectedReminders.add(customReminder);
      _showCustomForm = false;
      _customTitleController.clear();
      _customMessageController.clear();
    });
  }

  void _saveReminders() {
    final reminderNotifier = ref.read(activeRemindersProvider.notifier);
    reminderNotifier.addReminders(_selectedReminders);
    
    Navigator.pop(context, _selectedReminders);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedReminders.length} recordatorios configurados'),
        backgroundColor: Colors.green,
      ),
    );
  }
}