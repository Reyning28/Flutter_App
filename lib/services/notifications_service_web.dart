import 'dart:html' as html;

import '../models/task.dart';

class NotificationsService {
  static final NotificationsService _instance =
      NotificationsService._internal();
  NotificationsService._internal();
  factory NotificationsService() => _instance;

  Future<void> initialize() async {
    try {
      final permission = await html.Notification.requestPermission();
      if (permission == 'granted') {
        print('Permisos de notificación concedidos en web');
      } else {
        print('Permisos de notificación denegados en web');
      }
    } catch (e) {
      print('Error inicializando notificaciones web: $e');
    }
  }

  Future<void> scheduleTaskReminder(Task task) async {
    if (task.reminderDate == null) return;
    try {
      final now = DateTime.now();
      final reminderTime = task.reminderDate!;
      if (reminderTime.isAfter(now)) {
        final delay = reminderTime.difference(now);
        Future.delayed(delay, () {
          showNotification(
            'Recordatorio de Tarea',
            body: task.title,
            icon: '/favicon.png',
          );
        });
        print('Notificación web programada para: $reminderTime');
      } else {
        await showNotification(
          'Recordatorio de Tarea',
          body: task.title,
          icon: '/favicon.png',
        );
      }
    } catch (e) {
      print('Error programando notificación web: $e');
    }
  }

  Future<void> showNotification(
    String title, {
    String? body,
    String? icon,
  }) async {
    try {
      if (html.Notification.permission == 'granted') {
        html.Notification(title, body: body, icon: icon);
      } else {
        print('Permisos de notificación no concedidos');
      }
    } catch (e) {
      print('Error mostrando notificación web: $e');
    }
  }

  Future<void> cancelTaskReminder(int taskId) async {
    // No implementado para web
  }

  Future<bool> requestPermissions() async {
    final permission = await html.Notification.requestPermission();
    return permission == 'granted';
  }
}
