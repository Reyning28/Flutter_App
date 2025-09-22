import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import '../../models/task.dart';
import '../db/db_helper.dart';

abstract class StorageService {
  Future<int> insertUser(User user);
  Future<User?> getUserByEmail(String email);
  Future<int> insertTask(Task task);
  Future<List<Task>> getTasksByUserId(int userId);
  Future<int> updateTask(Task task);
  Future<int> deleteTask(int taskId);
}

class StorageServiceImpl implements StorageService {
  static final StorageServiceImpl _instance = StorageServiceImpl._internal();
  factory StorageServiceImpl() => _instance;
  StorageServiceImpl._internal();

  late final StorageService _implementation;
  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) return;

    if (kIsWeb) {
      _implementation = WebStorageService();
    } else {
      _implementation = MobileStorageService();
    }
    _initialized = true;
  }

  @override
  Future<int> insertUser(User user) async {
    await _initialize();
    return _implementation.insertUser(user);
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    await _initialize();
    return _implementation.getUserByEmail(email);
  }

  @override
  Future<int> insertTask(Task task) async {
    await _initialize();
    return _implementation.insertTask(task);
  }

  @override
  Future<List<Task>> getTasksByUserId(int userId) async {
    await _initialize();
    return _implementation.getTasksByUserId(userId);
  }

  @override
  Future<int> updateTask(Task task) async {
    await _initialize();
    return _implementation.updateTask(task);
  }

  @override
  Future<int> deleteTask(int taskId) async {
    await _initialize();
    return _implementation.deleteTask(taskId);
  }
}

// Implementación para web usando SharedPreferences
class WebStorageService implements StorageService {
  static const String _usersKey = 'users';
  static const String _tasksKey = 'tasks';
  static const String _userIdCounterKey = 'user_id_counter';
  static const String _taskIdCounterKey = 'task_id_counter';

  @override
  Future<int> insertUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Obtener usuarios existentes
      final usersJson = prefs.getString(_usersKey) ?? '[]';
      final List<dynamic> usersList = json.decode(usersJson);

      // Generar nuevo ID
      final currentId = prefs.getInt(_userIdCounterKey) ?? 0;
      final newId = currentId + 1;

      // Crear usuario con ID
      final userWithId = user.copyWith(id: newId);

      // Agregar a la lista
      usersList.add(userWithId.toMap());

      // Guardar
      await prefs.setString(_usersKey, json.encode(usersList));
      await prefs.setInt(_userIdCounterKey, newId);

      return newId;
    } catch (e) {
      print('Error insertando usuario en web: $e');
      rethrow;
    }
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey) ?? '[]';
      final List<dynamic> usersList = json.decode(usersJson);

      for (final userMap in usersList) {
        final user = User.fromMap(Map<String, dynamic>.from(userMap));
        if (user.email == email) {
          return user;
        }
      }

      return null;
    } catch (e) {
      print('Error obteniendo usuario en web: $e');
      return null;
    }
  }

  @override
  Future<int> insertTask(Task task) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Obtener tareas existentes
      final tasksJson = prefs.getString(_tasksKey) ?? '[]';
      final List<dynamic> tasksList = json.decode(tasksJson);

      // Generar nuevo ID
      final currentId = prefs.getInt(_taskIdCounterKey) ?? 0;
      final newId = currentId + 1;

      // Crear tarea con ID
      final taskWithId = task.copyWith(id: newId);

      // Agregar a la lista
      tasksList.add(taskWithId.toMap());

      // Guardar
      await prefs.setString(_tasksKey, json.encode(tasksList));
      await prefs.setInt(_taskIdCounterKey, newId);

      return newId;
    } catch (e) {
      print('Error insertando tarea en web: $e');
      rethrow;
    }
  }

  @override
  Future<List<Task>> getTasksByUserId(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_tasksKey) ?? '[]';
      final List<dynamic> tasksList = json.decode(tasksJson);

      final userTasks = <Task>[];
      for (final taskMap in tasksList) {
        final task = Task.fromMap(Map<String, dynamic>.from(taskMap));
        if (task.userId == userId) {
          userTasks.add(task);
        }
      }

      // Ordenar por fecha de creación (más recientes primero)
      userTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return userTasks;
    } catch (e) {
      print('Error obteniendo tareas en web: $e');
      return [];
    }
  }

  @override
  Future<int> updateTask(Task task) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_tasksKey) ?? '[]';
      final List<dynamic> tasksList = json.decode(tasksJson);

      // Encontrar y actualizar la tarea
      for (int i = 0; i < tasksList.length; i++) {
        final taskMap = Map<String, dynamic>.from(tasksList[i]);
        if (taskMap['id'] == task.id) {
          tasksList[i] = task.toMap();
          break;
        }
      }

      // Guardar
      await prefs.setString(_tasksKey, json.encode(tasksList));

      return 1; // Número de filas afectadas
    } catch (e) {
      print('Error actualizando tarea en web: $e');
      return 0;
    }
  }

  @override
  Future<int> deleteTask(int taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_tasksKey) ?? '[]';
      final List<dynamic> tasksList = json.decode(tasksJson);

      // Remover la tarea
      tasksList.removeWhere((taskMap) => taskMap['id'] == taskId);

      // Guardar
      await prefs.setString(_tasksKey, json.encode(tasksList));

      return 1; // Número de filas afectadas
    } catch (e) {
      print('Error eliminando tarea en web: $e');
      return 0;
    }
  }
}

// Implementación para móvil usando SQLite
class MobileStorageService implements StorageService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Future<int> insertUser(User user) async {
    return await _dbHelper.insertUser(user);
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    return await _dbHelper.getUserByEmail(email);
  }

  @override
  Future<int> insertTask(Task task) async {
    return await _dbHelper.insertTask(task);
  }

  @override
  Future<List<Task>> getTasksByUserId(int userId) async {
    return await _dbHelper.getTasksByUserId(userId);
  }

  @override
  Future<int> updateTask(Task task) async {
    return await _dbHelper.updateTask(task);
  }

  @override
  Future<int> deleteTask(int taskId) async {
    return await _dbHelper.deleteTask(taskId);
  }
}
