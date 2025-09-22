import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;

import '../core/constants.dart';
import '../models/task.dart';

class NotificationsService {
  static final NotificationsService _instance = NotificationsService._internal();
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  NotificationsService._internal();

  factory NotificationsService() => _instance;

  // Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    if (kIsWeb) {
      await _initializeWeb();
    } else {
      await _initializeMobile();
    }
  }

  // Inicializar para web
  Future<void> _initializeWeb() async {
    try {
      // Solicitar permisos de notificación en web
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

  // Inicializar para móvil
  Future<void> _initializeMobile() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Crear canal de notificación para Android
    await _createNotificationChannel();
  }

  // Crear canal de notificación
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      description: AppConstants.notificationChannelDescription,
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  // Manejar tap en notificación
  static void _onNotificationTapped(NotificationResponse response) {
    // TODO: Implementar navegación a la tarea específica
    // print('Notification tapped: ${response.payload}');
  }

  // Programar recordatorio para una tarea
  Future<void> scheduleTaskReminder(Task task) async {
    if (task.reminderDate == null) return;

    if (kIsWeb) {
      await _scheduleWebNotification(task);
    } else {
      await _scheduleMobileNotification(task);
    }
  }

  // Programar notificación web
  Future<void> _scheduleWebNotification(Task task) async {
    try {
      final now = DateTime.now();
      final reminderTime = task.reminderDate!;
      
      if (reminderTime.isAfter(now)) {
        final delay = reminderTime.difference(now);
        
        // Programar notificación web con setTimeout
        Future.delayed(delay, () {
          _showWebNotification(
            title: 'Recordatorio de Tarea',
            body: task.title,
            icon: '/favicon.png',
          );
        });
        
        print('Notificación web programada para: $reminderTime');
      } else {
        // Si la fecha ya pasó, mostrar inmediatamente
        await _showWebNotification(
          title: 'Recordatorio de Tarea',
          body: task.title,
          icon: '/favicon.png',
        );
      }
    } catch (e) {
      print('Error programando notificación web: $e');
    }
  }

  // Mostrar notificación web
  Future<void> _showWebNotification({
    required String title,
    required String body,
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

  // Programar notificación móvil
  Future<void> _scheduleMobileNotification(Task task) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
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

    // Por ahora mostrar inmediatamente (en producción usarías zonedSchedule)
    await _notifications.show(
      task.id ?? 0,
      'Recordatorio de Tarea',
      task.title,
      notificationDetails,
      payload: task.id.toString(),
    );
  }

  // Cancelar recordatorio de tarea
  Future<void> cancelTaskReminder(int taskId) async {
    await _notifications.cancel(taskId);
  }

  // Mostrar notificación inmediata
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) {
      await _showWebNotification(title: title, body: body);
    } else {
      const androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
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

      await _notifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    }
  }

  // Solicitar permisos (principalmente para iOS)
  Future<bool> requestPermissions() async {
    final result = await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return result ?? true;
  }


}