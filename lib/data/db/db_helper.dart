import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../../core/constants.dart';
import '../../models/task.dart';
import '../../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      print('Inicializando base de datos...'); // Debug
      
      // Inicializar para web si es necesario
      if (kIsWeb) {
        print('Configurando para web'); // Debug
        databaseFactory = databaseFactoryFfiWeb;
      }
      
      final databasePath = await getDatabasesPath();
      final path = join(databasePath, AppConstants.databaseName);
      
      print('Ruta de BD: $path'); // Debug

      final db = await openDatabase(
        path,
        version: AppConstants.databaseVersion,
        onCreate: _onCreate,
      );
      
      print('Base de datos inicializada correctamente'); // Debug
      return db;
    } catch (e) {
      print('Error inicializando BD: $e'); // Debug
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      print('Creando tablas de BD...'); // Debug
      
      // Crear tabla de usuarios
      await db.execute('''
        CREATE TABLE ${AppConstants.usersTable} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT UNIQUE NOT NULL,
          password_hash TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT
        )
      ''');
      
      print('Tabla de usuarios creada'); // Debug

      // Crear tabla de tareas
      await db.execute('''
        CREATE TABLE ${AppConstants.tasksTable} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT,
          category TEXT NOT NULL,
          priority TEXT NOT NULL DEFAULT '${AppConstants.priorityMedium}',
          status TEXT NOT NULL DEFAULT '${AppConstants.taskStatusPending}',
          due_date TEXT,
          reminder_date TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          completed_at TEXT,
          FOREIGN KEY (user_id) REFERENCES ${AppConstants.usersTable} (id)
        )
      ''');
      
      print('Tabla de tareas creada'); // Debug
      print('Todas las tablas creadas exitosamente'); // Debug
    } catch (e) {
      print('Error creando tablas: $e'); // Debug
      rethrow;
    }
  }

  // Métodos para usuarios
  Future<int> insertUser(User user) async {
    try {
      print('Insertando usuario: ${user.email}'); // Debug
      final db = await database;
      final userMap = user.toMap();
      print('Datos del usuario: $userMap'); // Debug
      
      final id = await db.insert(AppConstants.usersTable, userMap);
      print('Usuario insertado con ID: $id'); // Debug
      return id;
    } catch (e) {
      print('Error insertando usuario: $e'); // Debug
      rethrow;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.usersTable,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Métodos para tareas
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert(AppConstants.tasksTable, task.toMap());
  }

  Future<List<Task>> getTasksByUserId(int userId) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tasksTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      AppConstants.tasksTable,
      task.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int taskId) async {
    final db = await database;
    return await db.delete(
      AppConstants.tasksTable,
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }
}