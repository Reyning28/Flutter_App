import 'package:crypto/crypto.dart';
import 'dart:convert';

class User {
  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
    this.updatedAt,
  });

  // Constructor para crear usuario con contraseña en texto plano
  User.create({
    this.id,
    required this.name,
    required this.email,
    required String password,
    DateTime? createdAt,
    this.updatedAt,
  }) : passwordHash = _hashPassword(password),
       createdAt = createdAt ?? DateTime.now();

  // Método para hashear contraseña
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Método para verificar contraseña
  bool verifyPassword(String password) {
    return passwordHash == _hashPassword(password);
  }

  // Convertir a Map para la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Crear desde Map de la base de datos
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      passwordHash: map['password_hash'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : null,
    );
  }

  // Método copyWith para actualizaciones
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? passwordHash,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.passwordHash == passwordHash;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        passwordHash.hashCode;
  }
}