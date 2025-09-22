import 'dart:async';
import '../models/task.dart';
import '../data/storage/storage_service.dart';
import 'notifications_service.dart';

class TaskReminderService {
  static final TaskReminderService _instance = TaskReminderService._internal();
  factory TaskReminderService() => _instance;
  TaskReminderService._internal();

  final StorageService _storage = StorageServiceImpl();
  final NotificationsService _notifications = NotificationsService();
  Timer? _reminderTimer;

  // Iniciar el servicio de recordatorios
  void startReminderService(int userId) {
    // Revisar cada 30 minutos
    _reminderTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _checkOverdueTasks(userId);
    });
    
    // Revisar inmediatamente al iniciar
    _checkOverdueTasks(userId);
  }

  // Detener el servicio
  void stopReminderService() {
    _reminderTimer?.cancel();
    _reminderTimer = null;
  }

  // Revisar tareas vencidas
  Future<void> _checkOverdueTasks(int userId) async {
    try {
      final tasks = await _storage.getTasksByUserId(userId);
      final now = DateTime.now();
      
      for (final task in tasks) {
        // Revisar tareas vencidas que no han sido completadas
        if (task.status == TaskStatus.pending && 
            task.dueDate != null && 
            task.dueDate!.isBefore(now)) {
          
          // Verificar si ya enviamos notificación hoy
          if (!_wasNotificationSentToday(task)) {
            await _sendOverdueNotification(task);
            _markNotificationSent(task);
          }
        }
        
        // Revisar recordatorios pendientes
        if (task.status == TaskStatus.pending && 
            task.reminderDate != null && 
            _shouldSendReminder(task.reminderDate!, now)) {
          
          await _sendReminderNotification(task);
        }
      }
    } catch (e) {
      print('Error revisando tareas vencidas: $e');
    }
  }

  // Enviar notificación de tarea vencida
  Future<void> _sendOverdueNotification(Task task) async {
    final daysPast = DateTime.now().difference(task.dueDate!).inDays;
    final message = daysPast == 0 
        ? 'La tarea "${task.title}" vence hoy'
        : 'La tarea "${task.title}" venció hace $daysPast día${daysPast > 1 ? 's' : ''}';
    
    await _notifications.showNotification(
      id: task.id! + 10000, // ID diferente para notificaciones de vencimiento
      title: '⚠️ Tarea Vencida',
      body: message,
      payload: 'overdue_${task.id}',
    );
  }

  // Enviar notificación de recordatorio
  Future<void> _sendReminderNotification(Task task) async {
    await _notifications.showNotification(
      id: task.id! + 20000, // ID diferente para recordatorios
      title: '🔔 Recordatorio',
      body: 'No olvides: ${task.title}',
      payload: 'reminder_${task.id}',
    );
  }

  // Verificar si debe enviar recordatorio
  bool _shouldSendReminder(DateTime reminderDate, DateTime now) {
    // Enviar si la fecha de recordatorio ya pasó (con margen de 5 minutos)
    final difference = now.difference(reminderDate).inMinutes;
    return difference >= 0 && difference <= 5;
  }

  // Verificar si ya se envió notificación hoy (simplificado)
  bool _wasNotificationSentToday(Task task) {
    // En una implementación real, guardarías esto en SharedPreferences
    // Por ahora, asumimos que no se ha enviado
    return false;
  }

  // Marcar notificación como enviada (simplificado)
  void _markNotificationSent(Task task) {
    // En una implementación real, guardarías esto en SharedPreferences
    print('Notificación de vencimiento enviada para: ${task.title}');
  }

  // Programar recordatorio inmediato para prueba
  Future<void> sendTestReminder(String title, String message) async {
    await _notifications.showNotification(
      id: 99999,
      title: title,
      body: message,
    );
  }
}