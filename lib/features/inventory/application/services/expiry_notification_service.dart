import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/core/services/notification_service.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider_config.dart';

/// Servicio para gestionar notificaciones de ingredientes próximos a vencer
class ExpiryNotificationService {
  final Ref _ref;
  final NotificationService _notificationService;

  ExpiryNotificationService(this._ref, this._notificationService);

  /// Verifica ingredientes próximos a vencer y envía notificaciones
  Future<void> checkExpiringIngredients() async {
    try {
      final inventoryState = _ref.read(inventoryStateProvider);
      final items = inventoryState.items;
      
      final now = DateTime.now();
      
      for (final item in items) {
        if (item.expirationDate != null) {
          final daysUntilExpiry = item.expirationDate!.difference(now).inDays;
          
          // Notificar si vence en 1, 2 o 3 días
          if (daysUntilExpiry >= 0 && daysUntilExpiry <= 3) {
            await _notificationService.notifyIngredientExpiring(
              ingredientName: item.name,
              daysUntilExpiry: daysUntilExpiry,
            );
            
            print('🔔 Notificación enviada: ${item.name} vence en $daysUntilExpiry días');
          }
        }
      }
    } catch (e) {
      print('❌ Error verificando ingredientes próximos a vencer: $e');
    }
  }

  /// Programa recordatorios diarios para verificar ingredientes
  Future<void> scheduleDailyExpiryCheck() async {
    try {
      // Programar notificación para revisar inventario cada día a las 9:00 AM
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final scheduledTime = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        9, // 9:00 AM
        0,
      );

      await _notificationService.scheduleNotification(
        id: 1001, // ID fijo para recordatorio diario
        title: '📦 Revisa tu inventario',
        body: 'Verifica si tienes ingredientes próximos a vencer',
        scheduledDate: scheduledTime,
        payload: 'daily_inventory_check',
      );

      print('✅ Recordatorio diario programado para ${scheduledTime.toString()}');
    } catch (e) {
      print('❌ Error programando recordatorio diario: $e');
    }
  }

  /// Notifica cuando se añade un ingrediente que vence pronto
  Future<void> notifyNewExpiringIngredient(String ingredientName, DateTime expiryDate) async {
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    
    if (daysUntilExpiry <= 7) {
      String title = '⚠️ Ingrediente agregado próximo a vencer';
      String body = '$ingredientName vence en $daysUntilExpiry ${daysUntilExpiry == 1 ? 'día' : 'días'}. ¡Planifica usarlo pronto!';
      
      await _notificationService.showLocalNotification(
        id: ingredientName.hashCode + 1000,
        title: title,
        body: body,
        payload: 'new_expiring_ingredient:$ingredientName',
      );
    }
  }

  /// Cancela notificaciones de un ingrediente específico
  Future<void> cancelIngredientNotifications(String ingredientName) async {
    await _notificationService.cancelNotification(ingredientName.hashCode);
    await _notificationService.cancelNotification(ingredientName.hashCode + 1000);
  }
}

/// Provider para el servicio de notificaciones de vencimiento
final expiryNotificationServiceProvider = Provider<ExpiryNotificationService>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  return ExpiryNotificationService(ref, notificationService);
});