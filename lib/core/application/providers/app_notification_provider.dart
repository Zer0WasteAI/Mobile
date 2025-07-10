import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/core/services/notification_service.dart';
import 'package:zer0_waste_ai/features/inventory/application/services/expiry_notification_service.dart';
import 'package:zer0_waste_ai/features/planner/application/services/meal_notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;

/// Provider para gestionar la inicialización y configuración global de notificaciones
class AppNotificationManager {
  final Ref _ref;
  bool _isInitialized = false;

  AppNotificationManager(this._ref);

  /// Inicializa todo el sistema de notificaciones
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Inicializar timezone data
      tz.initializeTimeZones();
      
      // Inicializar el servicio base de notificaciones
      final notificationService = _ref.read(notificationServiceProvider);
      await notificationService.initialize();
      
      // Configurar servicios específicos
      await _setupInventoryNotifications();
      await _setupMealNotifications();
      
      _isInitialized = true;
      print('✅ AppNotificationManager inicializado correctamente');
    } catch (e) {
      print('❌ Error inicializando AppNotificationManager: $e');
    }
  }

  /// Configura notificaciones de inventario
  Future<void> _setupInventoryNotifications() async {
    try {
      final expiryService = _ref.read(expiryNotificationServiceProvider);
      
      // Verificar ingredientes próximos a vencer al inicializar
      await expiryService.checkExpiringIngredients();
      
      // Programar verificación diaria
      await expiryService.scheduleDailyExpiryCheck();
      
      print('✅ Notificaciones de inventario configuradas');
    } catch (e) {
      print('⚠️ Error configurando notificaciones de inventario: $e');
    }
  }

  /// Configura notificaciones de planificación de comidas
  Future<void> _setupMealNotifications() async {
    try {
      final mealService = _ref.read(mealNotificationServiceProvider);
      
      // Programar recordatorio semanal de planificación
      await mealService.scheduleWeeklyPlanningReminder();
      
      print('✅ Notificaciones de comidas configuradas');
    } catch (e) {
      print('⚠️ Error configurando notificaciones de comidas: $e');
    }
  }

  /// Programa notificaciones cuando el usuario añade ingredientes
  Future<void> onIngredientAdded(String ingredientName, DateTime? expiryDate) async {
    if (!_isInitialized || expiryDate == null) return;
    
    try {
      final expiryService = _ref.read(expiryNotificationServiceProvider);
      await expiryService.notifyNewExpiringIngredient(ingredientName, expiryDate);
    } catch (e) {
      print('⚠️ Error notificando ingrediente añadido: $e');
    }
  }

  /// Programa notificaciones cuando el usuario planifica comidas
  Future<void> onMealPlanCreated(DateTime date, dynamic meals) async {
    if (!_isInitialized) return;
    
    try {
      final mealService = _ref.read(mealNotificationServiceProvider);
      await mealService.scheduleMealReminders(date, meals);
    } catch (e) {
      print('⚠️ Error programando recordatorios de comidas: $e');
    }
  }

  /// Cancela notificaciones cuando el usuario elimina ingredientes
  Future<void> onIngredientRemoved(String ingredientName) async {
    if (!_isInitialized) return;
    
    try {
      final expiryService = _ref.read(expiryNotificationServiceProvider);
      await expiryService.cancelIngredientNotifications(ingredientName);
    } catch (e) {
      print('⚠️ Error cancelando notificaciones de ingrediente: $e');
    }
  }

  /// Cancela notificaciones cuando el usuario elimina un plan de comidas
  Future<void> onMealPlanDeleted(DateTime date) async {
    if (!_isInitialized) return;
    
    try {
      final mealService = _ref.read(mealNotificationServiceProvider);
      await mealService.cancelMealReminders(date);
    } catch (e) {
      print('⚠️ Error cancelando recordatorios de comidas: $e');
    }
  }

  /// Envía notificación de logros de sostenibilidad
  Future<void> notifySustainabilityMilestone({
    required int totalMealsCooked,
    required double totalCO2Saved,
    required double totalWaterSaved,
  }) async {
    if (!_isInitialized) return;

    try {
      final notificationService = _ref.read(notificationServiceProvider);
      
      String achievement = '';
      String description = '';

      if (totalMealsCooked >= 50) {
        achievement = 'Chef Sostenible';
        description = '¡Has cocinado $totalMealsCooked comidas sostenibles!';
      } else if (totalCO2Saved >= 100) {
        achievement = 'Héroe del Clima';
        description = '¡Has ahorrado ${totalCO2Saved.toStringAsFixed(1)}kg de CO₂!';
      } else if (totalWaterSaved >= 5000) {
        achievement = 'Guardián del Agua';
        description = '¡Has ahorrado ${totalWaterSaved.toStringAsFixed(0)}L de agua!';
      } else if (totalMealsCooked >= 10) {
        achievement = 'Cocinero Verde';
        description = '¡Has cocinado $totalMealsCooked comidas eco-friendly!';
      }

      if (achievement.isNotEmpty) {
        await notificationService.notifySustainabilityAchievement(
          achievement: achievement,
          description: description,
        );
      }
    } catch (e) {
      print('⚠️ Error notificando logro de sostenibilidad: $e');
    }
  }

  /// Verifica el estado de inicialización
  bool get isInitialized => _isInitialized;
}

/// Provider para el gestor global de notificaciones
final appNotificationManagerProvider = Provider<AppNotificationManager>((ref) {
  return AppNotificationManager(ref);
});