/// INFO: Reminder models for meal planning functionality
library;

import 'package:flutter/material.dart';

/// Enum for reminder types
enum ReminderType {
  preparation,
  shopping,
  prepping,
  cooking,
  custom
}

/// Extension for reminder type properties
extension ReminderTypeExtension on ReminderType {
  String get name {
    switch (this) {
      case ReminderType.preparation:
        return 'Preparación';
      case ReminderType.shopping:
        return 'Compras';
      case ReminderType.prepping:
        return 'Preparar ingredientes';
      case ReminderType.cooking:
        return 'Cocinar';
      case ReminderType.custom:
        return 'Personalizado';
    }
  }

  IconData get icon {
    switch (this) {
      case ReminderType.preparation:
        return Icons.checklist;
      case ReminderType.shopping:
        return Icons.shopping_cart;
      case ReminderType.prepping:
        return Icons.kitchen;
      case ReminderType.cooking:
        return Icons.restaurant;
      case ReminderType.custom:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (this) {
      case ReminderType.preparation:
        return Colors.blue;
      case ReminderType.shopping:
        return Colors.green;
      case ReminderType.prepping:
        return Colors.orange;
      case ReminderType.cooking:
        return Colors.red;
      case ReminderType.custom:
        return Colors.purple;
    }
  }
}

/// Meal reminder model
class MealReminder {
  final String id;
  final String title;
  final String? description;
  final ReminderType type;
  final DateTime scheduledTime;
  final Duration beforeMealTime;
  final bool isActive;
  final String recipeId;
  final String? customMessage;

  const MealReminder({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.scheduledTime,
    required this.beforeMealTime,
    this.isActive = true,
    required this.recipeId,
    this.customMessage,
  });

  MealReminder copyWith({
    String? id,
    String? title,
    String? description,
    ReminderType? type,
    DateTime? scheduledTime,
    Duration? beforeMealTime,
    bool? isActive,
    String? recipeId,
    String? customMessage,
  }) {
    return MealReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      beforeMealTime: beforeMealTime ?? this.beforeMealTime,
      isActive: isActive ?? this.isActive,
      recipeId: recipeId ?? this.recipeId,
      customMessage: customMessage ?? this.customMessage,
    );
  }

  factory MealReminder.fromJson(Map<String, dynamic> json) {
    return MealReminder(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: ReminderType.values.firstWhere(
        (e) => e.toString() == 'ReminderType.${json['type']}',
        orElse: () => ReminderType.custom,
      ),
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      beforeMealTime: Duration(minutes: json['beforeMealTimeMinutes'] as int),
      isActive: json['isActive'] as bool? ?? true,
      recipeId: json['recipeId'] as String,
      customMessage: json['customMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'scheduledTime': scheduledTime.toIso8601String(),
      'beforeMealTimeMinutes': beforeMealTime.inMinutes,
      'isActive': isActive,
      'recipeId': recipeId,
      'customMessage': customMessage,
    };
  }

  /// Generate reminder message based on type and recipe
  String get reminderMessage {
    if (customMessage != null && customMessage!.isNotEmpty) {
      return customMessage!;
    }

    switch (type) {
      case ReminderType.preparation:
        return 'Es hora de revisar los ingredientes para "$title"';
      case ReminderType.shopping:
        return 'Recuerda comprar los ingredientes para "$title"';
      case ReminderType.prepping:
        return 'Prepara los ingredientes para "$title"';
      case ReminderType.cooking:
        return 'Es hora de cocinar "$title"';
      case ReminderType.custom:
        return 'Recordatorio: $title';
    }
  }

  /// Check if reminder should trigger now
  bool shouldTrigger(DateTime now) {
    if (!isActive) return false;
    
    final triggerTime = scheduledTime.subtract(beforeMealTime);
    return now.isAfter(triggerTime) && now.isBefore(triggerTime.add(const Duration(minutes: 5)));
  }

  /// Get time until reminder triggers
  Duration timeUntilTrigger(DateTime now) {
    final triggerTime = scheduledTime.subtract(beforeMealTime);
    return triggerTime.difference(now);
  }
}

/// Predefined reminder templates
class ReminderTemplates {
  static List<MealReminder> getDefaultReminders({
    required String recipeId,
    required String recipeName,
    required DateTime mealTime,
  }) {
    return [
      MealReminder(
        id: '${recipeId}_shopping',
        title: recipeName,
        type: ReminderType.shopping,
        scheduledTime: mealTime,
        beforeMealTime: const Duration(days: 1),
        recipeId: recipeId,
        description: 'Comprar ingredientes necesarios',
      ),
      MealReminder(
        id: '${recipeId}_prep',
        title: recipeName,
        type: ReminderType.prepping,
        scheduledTime: mealTime,
        beforeMealTime: const Duration(hours: 2),
        recipeId: recipeId,
        description: 'Preparar y lavar ingredientes',
      ),
      MealReminder(
        id: '${recipeId}_cook',
        title: recipeName,
        type: ReminderType.cooking,
        scheduledTime: mealTime,
        beforeMealTime: const Duration(minutes: 30),
        recipeId: recipeId,
        description: 'Comenzar a cocinar',
      ),
    ];
  }

  static MealReminder createCustomReminder({
    required String recipeId,
    required String title,
    required DateTime mealTime,
    required Duration beforeMealTime,
    String? customMessage,
  }) {
    return MealReminder(
      id: '${recipeId}_custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      type: ReminderType.custom,
      scheduledTime: mealTime,
      beforeMealTime: beforeMealTime,
      recipeId: recipeId,
      customMessage: customMessage,
    );
  }
}

/// Reminder time options for UI
class ReminderTimeOptions {
  static final List<Duration> predefinedTimes = [
    const Duration(minutes: 5),
    const Duration(minutes: 15),
    const Duration(minutes: 30),
    const Duration(hours: 1),
    const Duration(hours: 2),
    const Duration(hours: 4),
    const Duration(days: 1),
  ];

  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} día${duration.inDays > 1 ? 's' : ''} antes';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hora${duration.inHours > 1 ? 's' : ''} antes';
    } else {
      return '${duration.inMinutes} minuto${duration.inMinutes > 1 ? 's' : ''} antes';
    }
  }
}