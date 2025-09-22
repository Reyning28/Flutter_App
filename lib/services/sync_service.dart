import 'dart:async';

import '../data/db/db_helper.dart';
import '../models/task.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  SyncService._internal();

  factory SyncService() => _instance;

  // Stream para notificar cambios de sincronización
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;

  // Sincronizar datos del usuario
  Future<void> syncUserData(int userId) async {
    _updateStatus(SyncStatus.syncing);

    try {
      // Aquí implementarías la lógica de sincronización con un servidor
      // Por ahora solo simulamos el proceso

      await Future.delayed(const Duration(seconds: 2));

      // Simular sincronización de tareas
      await _dbHelper.getTasksByUserId(userId);

      // TODO: Enviar tareas al servidor
      // TODO: Recibir tareas actualizadas del servidor
      // TODO: Actualizar base de datos local

      _updateStatus(SyncStatus.completed);
    } catch (error) {
      _updateStatus(SyncStatus.error);
      rethrow;
    }
  }

  // Sincronizar una tarea específica
  Future<void> syncTask(Task task) async {
    try {
      // TODO: Implementar sincronización de tarea individual
      await Future.delayed(const Duration(milliseconds: 500));

      // Simular envío al servidor
      // print('Syncing task: ${task.title}');
    } catch (error) {
      // print('Error syncing task: $error');
      rethrow;
    }
  }

  // Sincronización automática en segundo plano
  Timer? _autoSyncTimer;

  void startAutoSync(
    int userId, {
    Duration interval = const Duration(minutes: 15),
  }) {
    stopAutoSync();

    _autoSyncTimer = Timer.periodic(interval, (timer) {
      if (_currentStatus != SyncStatus.syncing) {
        syncUserData(userId).catchError((error) {
          // print('Auto sync error: $error');
        });
      }
    });
  }

  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }

  // Verificar conectividad
  Future<bool> hasInternetConnection() async {
    try {
      // TODO: Implementar verificación real de conectividad
      // Por ahora siempre retorna true
      return true;
    } catch (error) {
      return false;
    }
  }

  // Obtener datos pendientes de sincronización
  Future<List<Task>> getPendingSyncTasks(int userId) async {
    // TODO: Implementar lógica para obtener tareas que necesitan sincronización
    // Por ahora retorna todas las tareas
    return await _dbHelper.getTasksByUserId(userId);
  }

  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _syncStatusController.add(status);
  }

  void dispose() {
    stopAutoSync();
    _syncStatusController.close();
  }
}

enum SyncStatus { idle, syncing, completed, error }
