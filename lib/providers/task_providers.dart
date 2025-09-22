import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/storage/storage_service.dart';
import '../models/task.dart';
import '../services/notifications_service.dart';

// Provider para el servicio de tareas
final taskServiceProvider = Provider<TaskService>((ref) => TaskService());

// Provider para la lista de tareas
final tasksProvider = AsyncNotifierProvider<TasksNotifier, List<Task>>(() {
  return TasksNotifier();
});

// Provider para filtros de tareas
final taskFilterProvider = NotifierProvider<TaskFilterNotifier, TaskFilter>(TaskFilterNotifier.new);

// Provider para tareas filtradas
final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final filter = ref.watch(taskFilterProvider);
  
  return tasks.when(
    data: (taskList) {
      final filtered = _filterTasks(taskList, filter);
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

enum TaskFilter {
  all,
  pending,
  completed,
  overdue,
  today,
}

class TaskFilterNotifier extends Notifier<TaskFilter> {
  @override
  TaskFilter build() => TaskFilter.all;

  void setFilter(TaskFilter filter) {
    state = filter;
  }
}

List<Task> _filterTasks(List<Task> tasks, TaskFilter filter) {
  switch (filter) {
    case TaskFilter.all:
      return tasks;
    case TaskFilter.pending:
      return tasks.where((task) => task.status == TaskStatus.pending).toList();
    case TaskFilter.completed:
      return tasks.where((task) => task.status == TaskStatus.completed).toList();
    case TaskFilter.overdue:
      return tasks.where((task) => task.isOverdue).toList();
    case TaskFilter.today:
      return tasks.where((task) => task.isDueToday).toList();
  }
}

class TasksNotifier extends AsyncNotifier<List<Task>> {
  final TaskService _taskService = TaskService();

  @override
  Future<List<Task>> build() async {
    // Inicialmente retorna lista vacía
    // Se cargará cuando se llame loadTasks
    return [];
  }

  // Cargar tareas por usuario
  Future<void> loadTasks(int userId) async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _taskService.getTasksByUserId(userId);
      state = AsyncValue.data(tasks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Agregar nueva tarea
  Future<void> addTask(Task task) async {
    try {
      final newTask = await _taskService.createTask(task);
      final currentTasks = state.value ?? [];
      state = AsyncValue.data([...currentTasks, newTask]);
      
      // Programar notificación si tiene recordatorio
      await _taskService.scheduleNotificationIfNeeded(newTask);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Actualizar tarea
  Future<void> updateTask(Task task) async {
    try {
      await _taskService.updateTask(task);
      final currentTasks = state.value ?? [];
      final updatedTasks = currentTasks.map((t) => t.id == task.id ? task : t).toList();
      state = AsyncValue.data(updatedTasks);
      
      // Actualizar notificación si tiene recordatorio
      await _taskService.scheduleNotificationIfNeeded(task);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Eliminar tarea
  Future<void> deleteTask(int taskId) async {
    try {
      await _taskService.deleteTask(taskId);
      final currentTasks = state.value ?? [];
      final filteredTasks = currentTasks.where((task) => task.id != taskId).toList();
      state = AsyncValue.data(filteredTasks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Marcar tarea como completada/pendiente
  Future<void> toggleTaskStatus(int taskId) async {
    final currentTasks = state.value ?? [];
    final taskIndex = currentTasks.indexWhere((task) => task.id == taskId);
    
    if (taskIndex != -1) {
      final task = currentTasks[taskIndex];
      final updatedTask = task.status == TaskStatus.completed
          ? task.markAsPending()
          : task.markAsCompleted();
      
      await updateTask(updatedTask);
    }
  }
}

class TaskService {
  final StorageService _storage = StorageServiceImpl();
  final NotificationsService _notifications = NotificationsService();

  // Obtener tareas por usuario
  Future<List<Task>> getTasksByUserId(int userId) async {
    return await _storage.getTasksByUserId(userId);
  }

  // Crear nueva tarea
  Future<Task> createTask(Task task) async {
    final id = await _storage.insertTask(task);
    return task.copyWith(id: id);
  }

  // Actualizar tarea
  Future<void> updateTask(Task task) async {
    await _storage.updateTask(task);
  }

  // Eliminar tarea
  Future<void> deleteTask(int taskId) async {
    await _storage.deleteTask(taskId);
    // Cancelar notificación si existe
    await _notifications.cancelTaskReminder(taskId);
  }

  // Programar notificación si es necesario
  Future<void> scheduleNotificationIfNeeded(Task task) async {
    try {
      if (task.reminderDate != null && task.status == TaskStatus.pending) {
        await _notifications.scheduleTaskReminder(task);
        print('Notificación programada para tarea: ${task.title}');
      }
    } catch (e) {
      print('Error programando notificación: $e');
    }
  }
}