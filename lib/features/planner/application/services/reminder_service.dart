/// INFO: Reminder service for meal planning notifications
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/models/reminder_models.dart';
import '../../domain/models/meal_plan_models.dart';

/// Service for managing meal reminders
class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  final List<MealReminder> _reminders = [];
  final StreamController<MealReminder> _reminderStream = StreamController<MealReminder>.broadcast();
  Timer? _checkTimer;

  /// Stream of triggered reminders
  Stream<MealReminder> get reminderStream => _reminderStream.stream;

  /// Get all active reminders
  List<MealReminder> get activeReminders => _reminders.where((r) => r.isActive).toList();

  /// Initialize the reminder service
  void initialize() {
    _startReminderChecker();
  }

  /// Start the periodic reminder checker
  void _startReminderChecker() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkReminders();
    });
  }

  /// Check if any reminders should trigger
  void _checkReminders() {
    final now = DateTime.now();
    
    for (final reminder in _reminders) {
      if (reminder.shouldTrigger(now)) {
        _triggerReminder(reminder);
      }
    }
  }

  /// Trigger a reminder
  void _triggerReminder(MealReminder reminder) {
    if (kDebugMode) {
      print('Triggering reminder: ${reminder.reminderMessage}');
    }
    
    _reminderStream.add(reminder);
    
    // Mark reminder as triggered (deactivate to prevent repeated triggers)
    final updatedReminder = reminder.copyWith(isActive: false);
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = updatedReminder;
    }
  }

  /// Add a new reminder
  void addReminder(MealReminder reminder) {
    _reminders.add(reminder);
    if (kDebugMode) {
      print('Added reminder: ${reminder.title} at ${reminder.scheduledTime}');
    }
  }

  /// Add multiple reminders
  void addReminders(List<MealReminder> reminders) {
    _reminders.addAll(reminders);
    if (kDebugMode) {
      print('Added ${reminders.length} reminders');
    }
  }

  /// Remove a reminder
  void removeReminder(String reminderId) {
    _reminders.removeWhere((r) => r.id == reminderId);
    if (kDebugMode) {
      print('Removed reminder: $reminderId');
    }
  }

  /// Remove all reminders for a recipe
  void removeRemindersForRecipe(String recipeId) {
    final removedCount = _reminders.length;
    _reminders.removeWhere((r) => r.recipeId == recipeId);
    if (kDebugMode) {
      print('Removed ${removedCount - _reminders.length} reminders for recipe: $recipeId');
    }
  }

  /// Update a reminder
  void updateReminder(String reminderId, MealReminder updatedReminder) {
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      _reminders[index] = updatedReminder;
      if (kDebugMode) {
        print('Updated reminder: $reminderId');
      }
    }
  }

  /// Get reminders for a specific recipe
  List<MealReminder> getRemindersForRecipe(String recipeId) {
    return _reminders.where((r) => r.recipeId == recipeId).toList();
  }

  /// Get reminders for a specific date
  List<MealReminder> getRemindersForDate(DateTime date) {
    return _reminders.where((r) {
      final reminderDate = r.scheduledTime;
      return reminderDate.year == date.year &&
             reminderDate.month == date.month &&
             reminderDate.day == date.day;
    }).toList();
  }

  /// Get upcoming reminders (within next 24 hours)
  List<MealReminder> getUpcomingReminders() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    
    return _reminders.where((r) {
      if (!r.isActive) return false;
      final triggerTime = r.scheduledTime.subtract(r.beforeMealTime);
      return triggerTime.isAfter(now) && triggerTime.isBefore(tomorrow);
    }).toList()
      ..sort((a, b) {
        final aTrigger = a.scheduledTime.subtract(a.beforeMealTime);
        final bTrigger = b.scheduledTime.subtract(b.beforeMealTime);
        return aTrigger.compareTo(bTrigger);
      });
  }

  /// Create default reminders for a meal plan
  void createRemindersForMealPlan({
    required SimpleRecipe recipe,
    required DateTime mealTime,
    List<ReminderType>? reminderTypes,
  }) {
    // Use provided types or defaults
    final types = reminderTypes ?? [
      ReminderType.shopping,
      ReminderType.prepping,
      ReminderType.cooking,
    ];

    final reminders = <MealReminder>[];
    
    for (final type in types) {
      Duration beforeTime;
      switch (type) {
        case ReminderType.shopping:
          beforeTime = const Duration(days: 1);
          break;
        case ReminderType.prepping:
          beforeTime = Duration(minutes: recipe.prepTimeMinutes + 30);
          break;
        case ReminderType.cooking:
          beforeTime = Duration(minutes: recipe.prepTimeMinutes);
          break;
        case ReminderType.preparation:
          beforeTime = const Duration(hours: 2);
          break;
        case ReminderType.custom:
          beforeTime = const Duration(minutes: 30);
          break;
      }

      final reminder = MealReminder(
        id: '${recipe.id}_${type.toString().split('.').last}_${mealTime.millisecondsSinceEpoch}',
        title: recipe.name,
        type: type,
        scheduledTime: mealTime,
        beforeMealTime: beforeTime,
        recipeId: recipe.id,
        description: _getDescriptionForType(type),
      );

      reminders.add(reminder);
    }

    addReminders(reminders);
  }

  /// Get description for reminder type
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

  /// Clear all reminders
  void clearAllReminders() {
    _reminders.clear();
    if (kDebugMode) {
      print('Cleared all reminders');
    }
  }

  /// Dispose the service
  void dispose() {
    _checkTimer?.cancel();
    _reminderStream.close();
  }

  /// Get statistics about reminders
  Map<String, int> getReminderStats() {
    final now = DateTime.now();
    return {
      'total': _reminders.length,
      'active': _reminders.where((r) => r.isActive).length,
      'triggered': _reminders.where((r) => !r.isActive).length,
      'upcoming': getUpcomingReminders().length,
      'overdue': _reminders.where((r) {
        final triggerTime = r.scheduledTime.subtract(r.beforeMealTime);
        return r.isActive && triggerTime.isBefore(now);
      }).length,
    };
  }
}