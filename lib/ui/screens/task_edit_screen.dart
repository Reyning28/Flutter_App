import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/task.dart';
import '../../providers/auth_providers.dart';
import '../../providers/task_providers.dart';
import '../../core/constants.dart';

class TaskEditScreen extends ConsumerStatefulWidget {
  final Task? task;
  
  const TaskEditScreen({super.key, this.task});

  @override
  ConsumerState<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends ConsumerState<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = AppConstants.defaultCategories.first;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;
  DateTime? _selectedReminderDate;
  bool _isLoading = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadTaskData();
    }
  }

  void _loadTaskData() {
    final task = widget.task!;
    _titleController.text = task.title;
    _descriptionController.text = task.description ?? '';
    _selectedCategory = task.category;
    _selectedPriority = task.priority;
    _selectedDueDate = task.dueDate;
    _selectedReminderDate = task.reminderDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Tarea' : 'Nueva Tarea'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                hintText: 'Ingresa el título de la tarea',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El título es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Descripción
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Descripción opcional de la tarea',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Categoría
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoría',
              ),
              items: AppConstants.defaultCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Prioridad
            DropdownButtonFormField<TaskPriority>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Prioridad',
              ),
              items: TaskPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Icon(
                        _getPriorityIcon(priority),
                        color: _getPriorityColor(priority),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(_getPriorityLabel(priority)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPriority = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Fecha de vencimiento
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Fecha de vencimiento'),
                subtitle: Text(
                  _selectedDueDate != null
                      ? _formatDate(_selectedDueDate!)
                      : 'Sin fecha límite',
                ),
                trailing: _selectedDueDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedDueDate = null;
                            _selectedReminderDate = null; // Clear reminder too
                          });
                        },
                      )
                    : null,
                onTap: _selectDueDate,
              ),
            ),
            const SizedBox(height: 8),

            // Recordatorio
            if (_selectedDueDate != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Recordatorio'),
                  subtitle: Text(
                    _selectedReminderDate != null
                        ? _formatDateTime(_selectedReminderDate!)
                        : 'Sin recordatorio',
                  ),
                  trailing: _selectedReminderDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _selectedReminderDate = null;
                            });
                          },
                        )
                      : null,
                  onTap: _selectReminderDate,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDueDate = date;
        // Clear reminder if it's after the due date
        if (_selectedReminderDate != null && _selectedReminderDate!.isAfter(date)) {
          _selectedReminderDate = null;
        }
      });
    }
  }

  Future<void> _selectReminderDate() async {
    if (_selectedDueDate == null) return;

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedReminderDate?.isBefore(_selectedDueDate!) == true
          ? _selectedReminderDate!
          : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: _selectedDueDate!,
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: _selectedReminderDate != null
            ? TimeOfDay.fromDateTime(_selectedReminderDate!)
            : const TimeOfDay(hour: 9, minute: 0),
      );

      if (time != null) {
        setState(() {
          _selectedReminderDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isEditing) {
        // Actualizar tarea existente
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          category: _selectedCategory,
          priority: _selectedPriority,
          dueDate: _selectedDueDate,
          reminderDate: _selectedReminderDate,
          updatedAt: DateTime.now(),
        );

        await ref.read(tasksProvider.notifier).updateTask(updatedTask);
      } else {
        // Crear nueva tarea
        final newTask = Task.create(
          userId: user.id!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          category: _selectedCategory,
          priority: _selectedPriority,
          dueDate: _selectedDueDate,
          reminderDate: _selectedReminderDate,
        );

        await ref.read(tasksProvider.notifier).addTask(newTask);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Tarea actualizada' : 'Tarea creada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Baja';
      case TaskPriority.medium:
        return 'Media';
      case TaskPriority.high:
        return 'Alta';
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.keyboard_arrow_down;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.priority_high;
    }
  }
}