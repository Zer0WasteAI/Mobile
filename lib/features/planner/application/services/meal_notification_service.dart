import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/core/services/notification_service.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan_models.dart' as models;

/// Servicio para gestionar notificaciones de comidas planificadas
class MealNotificationService {
  // ignore: unused_field
  final Ref _ref;
  final NotificationService _notificationService;

  MealNotificationService(this._ref, this._notificationService);

  /// Programa recordatorios para todas las comidas planificadas de un día
  Future<void> scheduleMealReminders(DateTime date, models.DailyMeals meals) async {
    try {
      final baseDate = DateTime(date.year, date.month, date.day);
      
      // Programar recordatorio para desayuno (7:00 AM)
      if (meals.breakfast != null) {
        final breakfastTime = baseDate.add(const Duration(hours: 7));
        await _scheduleMealReminder(
          meal: meals.breakfast!,
          mealType: 'desayuno',
          scheduledTime: breakfastTime,
          notificationId: _getMealNotificationId(date, 'breakfast'),
        );
      }

      // Programar recordatorio para almuerzo (12:00 PM)
      if (meals.lunch != null) {
        final lunchTime = baseDate.add(const Duration(hours: 12));
        await _scheduleMealReminder(
          meal: meals.lunch!,
          mealType: 'almuerzo',
          scheduledTime: lunchTime,
          notificationId: _getMealNotificationId(date, 'lunch'),
        );
      }

      // Programar recordatorio para cena (7:00 PM)
      if (meals.dinner != null) {
        final dinnerTime = baseDate.add(const Duration(hours: 19));
        await _scheduleMealReminder(
          meal: meals.dinner!,
          mealType: 'cena',
          scheduledTime: dinnerTime,
          notificationId: _getMealNotificationId(date, 'dinner'),
        );
      }

      print('✅ Recordatorios de comidas programados para ${date.toString().split(' ')[0]}');
    } catch (e) {
      print('❌ Error programando recordatorios de comidas: $e');
    }
  }

  /// Programa un recordatorio específico para una comida
  Future<void> _scheduleMealReminder({
    required models.Meal meal,
    required String mealType,
    required DateTime scheduledTime,
    required int notificationId,
  }) async {
    // Solo programar si la fecha es futura
    if (scheduledTime.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: notificationId,
        title: '🍽️ Hora de $mealType',
        body: 'Tienes planificada: ${meal.recipeTitle}. ¡Es hora de cocinar!',
        scheduledDate: scheduledTime,
        payload: 'meal_reminder:${meal.recipeTitle}:$mealType',
      );
    }
  }

  /// Notifica cuando una comida es marcada como preparada
  Future<void> notifyMealPrepared({
    required String mealName,
    required Map<String, dynamic>? impactData,
  }) async {
    if (impactData != null) {
      final co2Saved = impactData['co2Emissions'] as double? ?? 0.0;
      final waterSaved = impactData['waterUsage'] as double? ?? 0.0;
      final sustainabilityScore = impactData['sustainabilityScore'] as double? ?? 0.0;

      await _notificationService.notifyMealPrepared(
        mealName: mealName,
        co2Saved: co2Saved,
        waterSaved: waterSaved,
      );

      // Notificación adicional para logro de sostenibilidad si el score es alto
      if (sustainabilityScore >= 80) {
        await _notificationService.notifySustainabilityAchievement(
          achievement: 'Comida Sostenible',
          description: '¡Preparaste una comida con ${sustainabilityScore.toStringAsFixed(0)} puntos de sostenibilidad!',
        );
      }
    } else {
      // Notificación básica sin datos de impacto
      await _notificationService.showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        title: '🎉 ¡Comida preparada!',
        body: '$mealName ha sido preparada exitosamente.',
        payload: 'meal_prepared_basic:$mealName',
      );
    }
  }

  /// Cancela recordatorios de comidas para una fecha específica
  Future<void> cancelMealReminders(DateTime date) async {
    try {
      await _notificationService.cancelNotification(_getMealNotificationId(date, 'breakfast'));
      await _notificationService.cancelNotification(_getMealNotificationId(date, 'lunch'));
      await _notificationService.cancelNotification(_getMealNotificationId(date, 'dinner'));
      
      print('✅ Recordatorios cancelados para ${date.toString().split(' ')[0]}');
    } catch (e) {
      print('❌ Error cancelando recordatorios: $e');
    }
  }

  /// Programa recordatorio semanal para planificación de comidas
  Future<void> scheduleWeeklyPlanningReminder() async {
    try {
      // Programar para todos los domingos a las 6:00 PM
      final now = DateTime.now();
      final daysUntilSunday = (7 - now.weekday) % 7;
      final nextSunday = now.add(Duration(days: daysUntilSunday == 0 ? 7 : daysUntilSunday));
      final reminderTime = DateTime(
        nextSunday.year,
        nextSunday.month,
        nextSunday.day,
        18, // 6:00 PM
        0,
      );

      await _notificationService.scheduleNotification(
        id: 2001, // ID fijo para recordatorio semanal
        title: '📅 Planifica tu semana',
        body: '¡Es hora de planificar tus comidas para la próxima semana!',
        scheduledDate: reminderTime,
        payload: 'weekly_planning_reminder',
      );

      print('✅ Recordatorio semanal programado para ${reminderTime.toString()}');
    } catch (e) {
      print('❌ Error programando recordatorio semanal: $e');
    }
  }

  /// Notifica logros relacionados con la planificación de comidas
  Future<void> notifyPlanningAchievement({
    required int mealsPlanned,
    required int consecutiveDays,
  }) async {
    String achievement = '';
    String description = '';

    if (consecutiveDays >= 7) {
      achievement = 'Planificador Constante';
      description = '¡Has planificado comidas durante $consecutiveDays días consecutivos!';
    } else if (mealsPlanned >= 10) {
      achievement = 'Chef Organizado';
      description = '¡Has planificado más de $mealsPlanned comidas!';
    } else if (mealsPlanned >= 5) {
      achievement = 'Buen Planificador';
      description = '¡Has planificado $mealsPlanned comidas esta semana!';
    }

    if (achievement.isNotEmpty) {
      await _notificationService.notifySustainabilityAchievement(
        achievement: achievement,
        description: description,
      );
    }
  }

  /// Genera un ID único para notificaciones de comidas basado en fecha y tipo
  int _getMealNotificationId(DateTime date, String mealType) {
    final dateString = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final typeCode = mealType == 'breakfast' ? 1 : mealType == 'lunch' ? 2 : 3;
    return int.parse('$dateString$typeCode');
  }

  /// Notifica cuando se usa un ingrediente próximo a vencer en una comida
  Future<void> notifyIngredientUsedInMeal({
    required String ingredientName,
    required String mealName,
  }) async {
    await _notificationService.showLocalNotification(
      id: (ingredientName + mealName).hashCode,
      title: '♻️ ¡Excelente elección!',
      body: 'Usaste $ingredientName en $mealName. ¡Evitaste desperdicios!',
      payload: 'ingredient_used:$ingredientName:$mealName',
    );
  }
}

/// Provider para el servicio de notificaciones de comidas
final mealNotificationServiceProvider = Provider<MealNotificationService>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  return MealNotificationService(ref, notificationService);
});