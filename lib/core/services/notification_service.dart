import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Servicio para manejar notificaciones push y locales
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;
  String? _fcmToken;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configurar notificaciones locales
      await _initializeLocalNotifications();
      
      // Configurar Firebase Cloud Messaging
      await _initializeFirebaseMessaging();
      
      _isInitialized = true;
      print('✅ NotificationService inicializado correctamente');
    } catch (e) {
      print('❌ Error inicializando NotificationService: $e');
    }
  }

  /// Inicializa las notificaciones locales
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Solicitar permisos para notificaciones
    await _requestNotificationPermissions();
  }

  /// Inicializa Firebase Cloud Messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Solicitar permisos
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Permisos de notificación concedidos');
      
      // Obtener FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      print('📱 FCM Token: $_fcmToken');
      
      // Configurar handlers para mensajes
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      
      // Configurar handler para cuando la app está terminada
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
    } else {
      print('⚠️ Permisos de notificación denegados');
    }
  }

  /// Solicita permisos de notificación específicos del sistema
  Future<void> _requestNotificationPermissions() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
  }

  /// Maneja notificaciones cuando la app está en primer plano
  void _handleForegroundMessage(RemoteMessage message) {
    print('🔔 Notificación recibida en primer plano: ${message.notification?.title}');
    
    // Mostrar notificación local cuando la app está activa
    if (message.notification != null) {
      showLocalNotification(
        title: message.notification!.title ?? 'Zer0 Waste AI',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Maneja notificaciones cuando la app está en segundo plano
  void _handleBackgroundMessage(RemoteMessage message) {
    print('🔔 Notificación abierta desde segundo plano: ${message.notification?.title}');
    // Aquí puedes manejar la navegación o acciones específicas
  }

  /// Maneja el tap en notificaciones locales
  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notificación local presionada: ${response.payload}');
    // Aquí puedes manejar la navegación según el payload
  }

  /// Muestra una notificación local
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'zer0_waste_ai_channel',
      'Zer0 Waste AI Notifications',
      channelDescription: 'Notificaciones de la app Zer0 Waste AI',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Programa una notificación para una fecha específica
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'zer0_waste_ai_scheduled',
      'Recordatorios Zer0 Waste AI',
      channelDescription: 'Recordatorios programados de Zer0 Waste AI',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      payload: payload,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Cancela una notificación programada
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancela todas las notificaciones programadas
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Notificación para ingrediente próximo a vencer
  Future<void> notifyIngredientExpiring({
    required String ingredientName,
    required int daysUntilExpiry,
  }) async {
    String title = '🥬 Ingrediente próximo a vencer';
    String body = '$ingredientName vence en $daysUntilExpiry ${daysUntilExpiry == 1 ? 'día' : 'días'}. ¡Úsalo pronto!';
    
    await showLocalNotification(
      id: ingredientName.hashCode,
      title: title,
      body: body,
      payload: 'ingredient_expiry:$ingredientName',
    );
  }

  /// Notificación para recordatorio de comida planificada
  Future<void> notifyMealReminder({
    required String mealName,
    required String mealType,
    required DateTime mealTime,
  }) async {
    String title = '🍽️ Hora de $mealType';
    String body = 'Tienes planificada: $mealName. ¡Es hora de cocinar!';
    
    await scheduleNotification(
      id: mealName.hashCode,
      title: title,
      body: body,
      scheduledDate: mealTime,
      payload: 'meal_reminder:$mealName',
    );
  }

  /// Notificación para felicitar al usuario por preparar una comida
  Future<void> notifyMealPrepared({
    required String mealName,
    required double co2Saved,
    required double waterSaved,
  }) async {
    String title = '🎉 ¡Comida preparada!';
    String body = '$mealName preparada. Ahorraste ${co2Saved.toStringAsFixed(1)}kg CO₂ y ${waterSaved.toStringAsFixed(0)}L agua.';
    
    await showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      payload: 'meal_prepared:$mealName',
    );
  }

  /// Notificación para recordatorio de revisión de inventario
  Future<void> notifyInventoryCheck() async {
    String title = '📦 Revisa tu inventario';
    String body = 'Es un buen momento para revisar tus ingredientes y planificar nuevas comidas.';
    
    await showLocalNotification(
      id: 999999,
      title: title,
      body: body,
      payload: 'inventory_check',
    );
  }

  /// Notificación para logros de sostenibilidad
  Future<void> notifySustainabilityAchievement({
    required String achievement,
    required String description,
  }) async {
    String title = '🌱 ¡Nuevo logro desbloqueado!';
    String body = '$achievement: $description';
    
    await showLocalNotification(
      id: achievement.hashCode,
      title: title,
      body: body,
      payload: 'achievement:$achievement',
    );
  }

  /// Obtiene el FCM token
  String? get fcmToken => _fcmToken;

  /// Verifica si el servicio está inicializado
  bool get isInitialized => _isInitialized;
}

/// Handler para notificaciones en segundo plano (función global requerida)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 Notificación en segundo plano: ${message.notification?.title}');
}

/// Provider para el servicio de notificaciones
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});