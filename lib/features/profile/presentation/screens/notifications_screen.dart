import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  static const String routeName = 'notifications';
  static const String routePath = '/notifications';

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _showAll = true;

  // Sample notifications data
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Alerta de caducidad',
      message: 'Los tomates caducarán en 2 días',
      type: NotificationType.expiration,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Nueva receta recomendada',
      message: 'Prueba esta receta con tus ingredientes',
      type: NotificationType.recipe,
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      isRead: true,
    ),
    NotificationItem(
      id: '3',
      title: 'Logro desbloqueado',
      message: '¡Has salvado 2kg de comida este mes!',
      type: NotificationType.achievement,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
    ),
    NotificationItem(
      id: '4',
      title: 'Actualización de inventario',
      message: 'Se actualizó la cantidad de arroz',
      type: NotificationType.inventory,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: 'Recordatorio de comida',
      message: 'Manzanas por consumir pronto',
      type: NotificationType.reminder,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
  ];

  List<NotificationItem> get _filteredNotifications {
    if (_showAll) {
      return _notifications;
    } else {
      return _notifications
          .where((notification) => !notification.isRead)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        title: Text(
          'Notificaciones',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            onPressed: () {
              setState(() {
                for (var notification in _notifications) {
                  notification.isRead = true;
                }
              });
            },
            tooltip: 'Marcar todo como leído',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _filteredNotifications.isEmpty
                        ? 'No hay notificaciones'
                        : '${_filteredNotifications.length} notificaciones',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Switch.adaptive(
                  value: !_showAll,
                  onChanged: (value) {
                    setState(() {
                      _showAll = !value;
                    });
                  },
                  activeColor: const Color(0xFF00BFA5),
                ),
                Text(
                  'Solo no leídas',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _filteredNotifications.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay notificaciones',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _showAll
                                ? 'Recibirás notificaciones aquí'
                                : 'No tienes notificaciones sin leer',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      itemCount: _filteredNotifications.length,
                      separatorBuilder:
                          (context, index) =>
                              Divider(height: 1, color: Colors.grey.shade200),
                      itemBuilder: (context, index) {
                        final notification = _filteredNotifications[index];
                        return _buildNotificationItem(notification);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    final iconData = _getIconForType(notification.type);
    final iconColor = _getColorForType(notification.type);
    final bgColor = _getBgColorForType(notification.type);

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red.shade100,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _notifications.removeWhere((item) => item.id == notification.id);
        });
      },
      child: InkWell(
        onTap: () {
          setState(() {
            notification.isRead = true;
          });
          // Handle navigation to relevant screen based on notification type
        },
        child: Container(
          color: notification.isRead ? Colors.white : const Color(0xFFF5F5F5),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(iconData, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight:
                                  notification.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00BFA5),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getFormattedTime(notification.timestamp),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.expiration:
        return Icons.access_time;
      case NotificationType.recipe:
        return Icons.restaurant;
      case NotificationType.achievement:
        return Icons.emoji_events;
      case NotificationType.inventory:
        return Icons.inventory;
      case NotificationType.reminder:
        return Icons.notifications_active;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.expiration:
        return Colors.orange;
      case NotificationType.recipe:
        return Colors.green;
      case NotificationType.achievement:
        return Colors.amber;
      case NotificationType.inventory:
        return Colors.blue;
      case NotificationType.reminder:
        return Colors.purple;
    }
  }

  Color _getBgColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.expiration:
        return const Color(0xFFFFF3E0); // Light orange
      case NotificationType.recipe:
        return const Color(0xFFE8F5E9); // Light green
      case NotificationType.achievement:
        return const Color(0xFFFFF8E1); // Light amber
      case NotificationType.inventory:
        return const Color(0xFFE3F2FD); // Light blue
      case NotificationType.reminder:
        return const Color(0xFFF3E5F5); // Light purple
    }
  }

  String _getFormattedTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

enum NotificationType { expiration, recipe, achievement, inventory, reminder }

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });
}
