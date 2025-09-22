import '../core/constants.dart';

enum TaskStatus {
  pending(AppConstants.taskStatusPending),
  completed(AppConstants.taskStatusCompleted);

  const TaskStatus(this.value);
  final String value;

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TaskStatus.pending,
    );
  }
}

enum TaskPriority {
  low(AppConstants.priorityLow),
  medium(AppConstants.priorityMedium),
  high(AppConstants.priorityHigh);

  const TaskPriority(this.value);
  final String value;

  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => TaskPriority.medium,
    );
  }
}

class Task {
  final int? id;
  final int userId;
  final String title;
  final String? description;
  final String category;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final DateTime? reminderDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  Task({
    this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.category,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.dueDate,
    this.reminderDate,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  // Constructor para crear nueva tarea
  Task.create({
    this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.category,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.reminderDate,
    DateTime? createdAt,
  }) : status = TaskStatus.pending,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = null,
       completedAt = null;

  // Método para marcar como completada
  Task markAsCompleted() {
    return copyWith(
      status: TaskStatus.completed,
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Método para marcar como pendiente
  Task markAsPending() {
    return copyWith(
      status: TaskStatus.pending,
      completedAt: null,
      updatedAt: DateTime.now(),
    );
  }

  // Verificar si la tarea está vencida
  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  // Verificar si la tarea vence hoy
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final due = dueDate!;
    return now.year == due.year && 
           now.month == due.month && 
           now.day == due.day;
  }

  // Convertir a Map para la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority.value,
      'status': status.value,
      'due_date': dueDate?.toIso8601String(),
      'reminder_date': reminderDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  // Crear desde Map de la base de datos
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id']?.toInt(),
      userId: map['user_id']?.toInt() ?? 0,
      title: map['title'] ?? '',
      description: map['description'],
      category: map['category'] ?? '',
      priority: TaskPriority.fromString(map['priority'] ?? AppConstants.priorityMedium),
      status: TaskStatus.fromString(map['status'] ?? AppConstants.taskStatusPending),
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      reminderDate: map['reminder_date'] != null ? DateTime.parse(map['reminder_date']) : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at']) : null,
    );
  }

  // Método copyWith para actualizaciones
  Task copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? category,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    DateTime? reminderDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      reminderDate: reminderDate ?? this.reminderDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: ${status.value}, priority: ${priority.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        title.hashCode ^
        status.hashCode;
  }
}