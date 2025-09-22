import 'package:flutter_test/flutter_test.dart';
import 'package:productividad_app/models/task.dart';
import 'package:productividad_app/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('User creation with password hashing', () {
      final user = User.create(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
      );

      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.passwordHash, isNotEmpty);
      expect(user.passwordHash, isNot('password123')); // Should be hashed
    });

    test('Password verification', () {
      final user = User.create(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
      );

      expect(user.verifyPassword('password123'), isTrue);
      expect(user.verifyPassword('wrongpassword'), isFalse);
    });

    test('User toMap and fromMap', () {
      final user = User.create(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
      );

      final map = user.toMap();
      final userFromMap = User.fromMap(map);

      expect(userFromMap.id, user.id);
      expect(userFromMap.name, user.name);
      expect(userFromMap.email, user.email);
      expect(userFromMap.passwordHash, user.passwordHash);
    });
  });

  group('Task Model Tests', () {
    test('Task creation', () {
      final task = Task.create(
        userId: 1,
        title: 'Test Task',
        description: 'Test Description',
        category: 'Work',
        priority: TaskPriority.high,
      );

      expect(task.title, 'Test Task');
      expect(task.description, 'Test Description');
      expect(task.category, 'Work');
      expect(task.priority, TaskPriority.high);
      expect(task.status, TaskStatus.pending);
    });

    test('Task status toggle', () {
      final task = Task.create(
        userId: 1,
        title: 'Test Task',
        category: 'Work',
      );

      expect(task.status, TaskStatus.pending);

      final completedTask = task.markAsCompleted();
      expect(completedTask.status, TaskStatus.completed);
      expect(completedTask.completedAt, isNotNull);

      final pendingTask = completedTask.markAsPending();
      expect(pendingTask.status, TaskStatus.pending);
      expect(pendingTask.completedAt, isNull);
    });

    test('Task due date checks', () {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      final yesterday = today.subtract(const Duration(days: 1));

      final taskDueToday = Task.create(
        userId: 1,
        title: 'Due Today',
        category: 'Work',
        dueDate: DateTime(today.year, today.month, today.day, 23, 59),
      );

      final taskOverdue = Task.create(
        userId: 1,
        title: 'Overdue',
        category: 'Work',
        dueDate: yesterday,
      );

      final taskFuture = Task.create(
        userId: 1,
        title: 'Future',
        category: 'Work',
        dueDate: tomorrow,
      );

      expect(taskDueToday.isDueToday, isTrue);
      expect(taskOverdue.isOverdue, isTrue);
      expect(taskFuture.isOverdue, isFalse);
      expect(taskFuture.isDueToday, isFalse);
    });

    test('Task toMap and fromMap', () {
      final task = Task.create(
        id: 1,
        userId: 1,
        title: 'Test Task',
        description: 'Test Description',
        category: 'Work',
        priority: TaskPriority.high,
        dueDate: DateTime.now(),
      );

      final map = task.toMap();
      final taskFromMap = Task.fromMap(map);

      expect(taskFromMap.id, task.id);
      expect(taskFromMap.userId, task.userId);
      expect(taskFromMap.title, task.title);
      expect(taskFromMap.description, task.description);
      expect(taskFromMap.category, task.category);
      expect(taskFromMap.priority, task.priority);
      expect(taskFromMap.status, task.status);
    });
  });
}