/// INFO: Widget for displaying list of reminders
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/reminder_models.dart';
import '../../providers/reminder_providers.dart';

class ReminderListWidget extends ConsumerWidget {
  final DateTime? filterDate;
  final String? filterRecipeId;
  final bool showUpcomingOnly;

  const ReminderListWidget({
    super.key,
    this.filterDate,
    this.filterRecipeId,
    this.showUpcomingOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<MealReminder> reminders;
    
    if (showUpcomingOnly) {
      reminders = ref.watch(upcomingRemindersProvider);
    } else if (filterDate != null) {
      reminders = ref.watch(remindersByDateProvider(filterDate!));
    } else if (filterRecipeId != null) {
      reminders = ref.watch(remindersByRecipeProvider(filterRecipeId!));
    } else {
      reminders = ref.watch(activeRemindersProvider);
    }

    if (reminders.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        return _buildReminderCard(context, ref, reminders[index]);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            showUpcomingOnly 
                ? 'No hay recordatorios próximos'
                : 'No hay recordatorios configurados',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            showUpcomingOnly
                ? 'Los recordatorios aparecerán aquí cuando se acerque la hora'
                : 'Agrega recordatorios desde el planificador de comidas',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, WidgetRef ref, MealReminder reminder) {
    final now = DateTime.now();
    final triggerTime = reminder.scheduledTime.subtract(reminder.beforeMealTime);
    final timeUntilTrigger = reminder.timeUntilTrigger(now);
    final isOverdue = triggerTime.isBefore(now) && reminder.isActive;
    final willTriggerToday = triggerTime.day == now.day && 
                            triggerTime.month == now.month && 
                            triggerTime.year == now.year;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOverdue 
              ? Colors.red.withValues(alpha: 0.3)
              : reminder.type.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showReminderDetails(context, reminder),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with type and actions
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: reminder.type.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      reminder.type.icon,
                      color: reminder.type.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.type.name,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: reminder.type.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          reminder.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: const Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.red[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _editReminder(context, ref, reminder);
                          break;
                        case 'delete':
                          _deleteReminder(context, ref, reminder);
                          break;
                      }
                    },
                  ),
                ],
              ),
              
              if (reminder.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  reminder.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Time information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Comida: ${DateFormat('HH:mm - dd/MM').format(reminder.scheduledTime)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isOverdue ? Icons.warning : Icons.alarm,
                          size: 16,
                          color: isOverdue ? Colors.red : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isOverdue
                                ? 'Recordatorio vencido'
                                : 'Recordar: ${DateFormat('HH:mm - dd/MM').format(triggerTime)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isOverdue ? Colors.red : null,
                              fontWeight: isOverdue ? FontWeight.w600 : null,
                            ),
                          ),
                        ),
                        if (!isOverdue && reminder.isActive)
                          _buildTimeUntilChip(timeUntilTrigger, willTriggerToday),
                      ],
                    ),
                  ],
                ),
              ),

              // Status chip
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: reminder.isActive 
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          reminder.isActive ? Icons.check_circle : Icons.cancel,
                          size: 12,
                          color: reminder.isActive ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reminder.isActive ? 'Activo' : 'Completado',
                          style: TextStyle(
                            fontSize: 10,
                            color: reminder.isActive ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    ReminderTimeOptions.formatDuration(reminder.beforeMealTime),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
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

  Widget _buildTimeUntilChip(Duration timeUntil, bool isToday) {
    Color chipColor;
    String timeText;
    
    if (timeUntil.isNegative) {
      chipColor = Colors.red;
      timeText = 'Vencido';
    } else if (timeUntil.inMinutes < 60) {
      chipColor = Colors.orange;
      timeText = '${timeUntil.inMinutes}m';
    } else if (timeUntil.inHours < 24) {
      chipColor = isToday ? Colors.blue : Colors.green;
      timeText = '${timeUntil.inHours}h';
    } else {
      chipColor = Colors.green;
      timeText = '${timeUntil.inDays}d';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        timeText,
        style: TextStyle(
          fontSize: 10,
          color: chipColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showReminderDetails(BuildContext context, MealReminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(reminder.type.icon, color: reminder.type.color),
            const SizedBox(width: 8),
            Expanded(child: Text(reminder.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${reminder.type.name}'),
            const SizedBox(height: 8),
            Text('Mensaje: ${reminder.reminderMessage}'),
            const SizedBox(height: 8),
            Text('Comida: ${DateFormat('dd/MM/yyyy HH:mm').format(reminder.scheduledTime)}'),
            const SizedBox(height: 8),
            Text('Recordar: ${ReminderTimeOptions.formatDuration(reminder.beforeMealTime)}'),
            if (reminder.description != null) ...[
              const SizedBox(height: 8),
              Text('Descripción: ${reminder.description}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _editReminder(BuildContext context, WidgetRef ref, MealReminder reminder) {
    showDialog(
      context: context,
      builder: (context) => _EditReminderDialog(reminder: reminder, ref: ref),
    );
  }

  void _deleteReminder(BuildContext context, WidgetRef ref, MealReminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Recordatorio'),
        content: Text('¿Estás seguro de que deseas eliminar el recordatorio "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(activeRemindersProvider.notifier).removeReminder(reminder.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Recordatorio eliminado'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

/// Dialog for editing an existing reminder
class _EditReminderDialog extends StatefulWidget {
  final MealReminder reminder;
  final WidgetRef ref;

  const _EditReminderDialog({
    required this.reminder,
    required this.ref,
  });

  @override
  State<_EditReminderDialog> createState() => _EditReminderDialogState();
}

class _EditReminderDialogState extends State<_EditReminderDialog> {
  late TextEditingController _titleController;
  late TextEditingController _messageController;
  late ReminderType _selectedType;
  late Duration _selectedBeforeTime;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.reminder.title);
    _messageController = TextEditingController(text: widget.reminder.customMessage ?? '');
    _selectedType = widget.reminder.type;
    _selectedBeforeTime = widget.reminder.beforeMealTime;
    _isActive = widget.reminder.isActive;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(_selectedType.icon, color: _selectedType.color),
          const SizedBox(width: 8),
          const Text('Editar Recordatorio'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Type selector
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

            // Custom message field
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Mensaje personalizado (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Active status
            SwitchListTile(
              title: const Text('Recordatorio activo'),
              subtitle: Text(_isActive ? 'Se activará según configuración' : 'Desactivado'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedType.color,
            foregroundColor: Colors.white,
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _saveChanges() {
    final updatedReminder = widget.reminder.copyWith(
      title: _titleController.text,
      type: _selectedType,
      beforeMealTime: _selectedBeforeTime,
      isActive: _isActive,
      customMessage: _messageController.text.isEmpty ? null : _messageController.text,
    );

    widget.ref.read(activeRemindersProvider.notifier).updateReminder(
      widget.reminder.id,
      updatedReminder,
    );

    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recordatorio actualizado'),
        backgroundColor: Colors.green,
      ),
    );
  }
}