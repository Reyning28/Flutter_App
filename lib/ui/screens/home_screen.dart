import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/task.dart';
import '../../providers/auth_providers.dart';
import '../../providers/task_providers.dart';
import '../../services/task_reminder_service.dart';
import '../widgets/animated_task_card.dart';
import '../widgets/animated_stats_card.dart';
import '../utils/page_transitions.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'task_edit_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  final TaskReminderService _reminderService = TaskReminderService();

  @override
  void initState() {
    super.initState();
    // Cargar tareas cuando se inicia la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(tasksProvider.notifier).loadTasks(user.id!);
        // Iniciar servicio de recordatorios
        _reminderService.startReminderService(user.id!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _reminderService.stopReminderService();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final tasksAsync = ref.watch(tasksProvider);
    final currentFilter = ref.watch(taskFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Buscar tareas...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {}); // Trigger rebuild to filter tasks
                },
              )
            : Text('Hola, ${user?.name ?? 'Usuario'}'),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.of(context).push(
                  CustomPageTransitions.slideFromRight(const SettingsScreen()),
                );
              } else if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Configuraciones'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Estadísticas animadas
          tasksAsync.when(
            data: (tasks) => AnimatedStatsCard(tasks: tasks),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          // Filtros de tareas
          _buildFilterChips(),

          // Lista de tareas
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                var filteredTasks = _getFilteredTasks(tasks, currentFilter);
                
                // Aplicar búsqueda si hay texto
                if (_searchController.text.isNotEmpty) {
                  filteredTasks = _searchTasks(filteredTasks, _searchController.text);
                }

                if (filteredTasks.isEmpty) {
                  return _buildEmptyState(
                    isSearching: _searchController.text.isNotEmpty,
                    searchQuery: _searchController.text,
                    currentFilter: currentFilter,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return AnimatedTaskCard(
                      task: task,
                      index: index,
                      onToggle: () {
                        ref.read(tasksProvider.notifier).toggleTaskStatus(task.id!);
                      },
                      onEdit: () {
                        Navigator.of(context).push(
                          CustomPageTransitions.slideFromBottom(TaskEditScreen(task: task)),
                        );
                      },
                      onDelete: () => _showDeleteDialog(task),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (user != null) {
                          ref.read(tasksProvider.notifier).loadTasks(user.id!);
                        }
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            CustomPageTransitions.scaleIn(const TaskEditScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Tarea'),
      ),
    );
  }

  Widget _buildFilterChips() {
    final currentFilter = ref.watch(taskFilterProvider);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: TaskFilter.values.map((filter) {
          final isSelected = currentFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getFilterLabel(filter)),
              selected: isSelected,
              onSelected: (selected) {
                ref.read(taskFilterProvider.notifier).setFilter(filter);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.status == TaskStatus.completed,
          onChanged: (value) {
            ref.read(tasksProvider.notifier).toggleTaskStatus(task.id!);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.status == TaskStatus.completed
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.isNotEmpty)
              Text(task.description!),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(task.category),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Icon(
                  AppTheme.getPriorityIcon(task.priority.value),
                  color: AppTheme.getPriorityColor(task.priority.value),
                  size: 16,
                ),
                if (task.dueDate != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: task.isOverdue ? Colors.red : Colors.grey,
                  ),
                  Text(
                    _formatDate(task.dueDate!),
                    style: TextStyle(
                      color: task.isOverdue ? Colors.red : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TaskEditScreen(task: task),
                ),
              );
            } else if (value == 'delete') {
              _showDeleteDialog(task);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    bool isSearching = false,
    String searchQuery = '',
    TaskFilter? currentFilter,
  }) {
    String title;
    String subtitle;
    IconData icon;
    
    if (isSearching) {
      title = 'Sin resultados';
      subtitle = 'No se encontraron tareas para "$searchQuery"';
      icon = Icons.search_off;
    } else if (currentFilter != null && currentFilter != TaskFilter.all) {
      title = 'Sin tareas ${_getFilterLabel(currentFilter).toLowerCase()}';
      subtitle = 'No tienes tareas en esta categoría';
      icon = Icons.filter_list_off;
    } else {
      title = 'No hay tareas';
      subtitle = 'Toca el botón + para crear tu primera tarea';
      icon = Icons.task_alt;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (!isSearching) ...[
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  CustomPageTransitions.scaleIn(const TaskEditScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear Tarea'),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Limpiar Búsqueda'),
            ),
          ],
        ],
      ),
    );
  }

  List<Task> _getFilteredTasks(List<Task> tasks, TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return tasks;
      case TaskFilter.pending:
        return tasks
            .where((task) => task.status == TaskStatus.pending)
            .toList();
      case TaskFilter.completed:
        return tasks
            .where((task) => task.status == TaskStatus.completed)
            .toList();
      case TaskFilter.overdue:
        return tasks.where((task) => task.isOverdue).toList();
      case TaskFilter.today:
        return tasks.where((task) => task.isDueToday).toList();
    }
  }

  String _getFilterLabel(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'Todas';
      case TaskFilter.pending:
        return 'Pendientes';
      case TaskFilter.completed:
        return 'Completadas';
      case TaskFilter.overdue:
        return 'Vencidas';
      case TaskFilter.today:
        return 'Hoy';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Hoy';
    } else if (difference == 1) {
      return 'Mañana';
    } else if (difference == -1) {
      return 'Ayer';
    } else if (difference > 0) {
      return 'En $difference días';
    } else {
      return 'Hace ${-difference} días';
    }
  }

  void _showDeleteDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tarea'),
        content: Text('¿Estás seguro de que quieres eliminar "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(tasksProvider.notifier).deleteTask(task.id!);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(AsyncValue<List<Task>> tasksAsync) {
    return tasksAsync.when(
      data: (tasks) {
        final totalTasks = tasks.length;
        final completedTasks = tasks.where((task) => task.status == TaskStatus.completed).length;
        final pendingTasks = tasks.where((task) => task.status == TaskStatus.pending).length;
        final overdueTasks = tasks.where((task) => task.isOverdue).length;
        
        return Container(
          margin: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Total', totalTasks.toString(), Icons.task_alt, Colors.blue),
                  _buildStatItem('Pendientes', pendingTasks.toString(), Icons.pending, Colors.orange),
                  _buildStatItem('Completadas', completedTasks.toString(), Icons.check_circle, Colors.green),
                  if (overdueTasks > 0)
                    _buildStatItem('Vencidas', overdueTasks.toString(), Icons.warning, Colors.red),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  List<Task> _searchTasks(List<Task> tasks, String query) {
    final lowercaseQuery = query.toLowerCase();
    return tasks.where((task) {
      return task.title.toLowerCase().contains(lowercaseQuery) ||
             (task.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             task.category.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<void> _handleLogout() async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();
    
    ref.read(currentUserProvider.notifier).clearUser();
    ref.read(authStateProvider.notifier).setAuthenticated(false);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }
}
