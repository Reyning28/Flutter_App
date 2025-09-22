import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/storage/storage_service.dart';
import '../models/user.dart';

// Provider para el usuario actual
final currentUserProvider = NotifierProvider<CurrentUserNotifier, User?>(
  CurrentUserNotifier.new,
);

// Provider para el estado de autenticación
final authStateProvider = NotifierProvider<AuthStateNotifier, bool>(
  AuthStateNotifier.new,
);

// Provider para el servicio de autenticación
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class CurrentUserNotifier extends Notifier<User?> {
  @override
  User? build() => null;

  void setUser(User? user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }
}

class AuthStateNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setAuthenticated(bool isAuth) {
    state = isAuth;
  }
}

class AuthService {
  final StorageService _storage = StorageServiceImpl();
  
  // Guardar sesión del usuario
  Future<void> _saveUserSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', json.encode(user.toMap()));
    await prefs.setBool('is_logged_in', true);
  }
  
  // Cargar sesión del usuario
  Future<User?> loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      if (!isLoggedIn) return null;
      
      final userJson = prefs.getString('current_user');
      if (userJson == null) return null;
      
      final userMap = json.decode(userJson);
      return User.fromMap(Map<String, dynamic>.from(userMap));
    } catch (e) {
      print('Error cargando sesión: $e');
      return null;
    }
  }
  
  // Limpiar sesión
  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    await prefs.setBool('is_logged_in', false);
  }

  // Registrar usuario
  Future<User?> register(String name, String email, String password) async {
    try {
      print('Iniciando registro para: $email'); // Debug

      // Verificar si el usuario ya existe
      final existingUser = await _storage.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('El usuario ya existe');
      }

      print('Usuario no existe, creando nuevo usuario'); // Debug

      // Crear nuevo usuario
      final user = User.create(name: name, email: email, password: password);

      print('Usuario creado, insertando en storage'); // Debug

      // Insertar en el almacenamiento
      final id = await _storage.insertUser(user);

      print('Usuario insertado con ID: $id'); // Debug

      final newUser = user.copyWith(id: id);
      await _saveUserSession(newUser); // Guardar sesión
      return newUser;
    } catch (e) {
      print('Error en registro: $e'); // Debug
      throw Exception('Error al registrar usuario: $e');
    }
  }

  // Iniciar sesión
  Future<User?> login(String email, String password) async {
    try {
      print('Iniciando login para: $email'); // Debug

      final user = await _storage.getUserByEmail(email);
      if (user == null) {
        throw Exception('Usuario no encontrado');
      }

      if (!user.verifyPassword(password)) {
        throw Exception('Contraseña incorrecta');
      }

      print('Login exitoso para: $email'); // Debug
      await _saveUserSession(user); // Guardar sesión
      return user;
    } catch (e) {
      print('Error en login: $e'); // Debug
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await clearUserSession();
  }
}
