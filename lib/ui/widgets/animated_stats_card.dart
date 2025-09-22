import 'package:flutter/material.dart';
import '../../models/task.dart';

class AnimatedStatsCard extends StatefulWidget {
  final List<Task> tasks;

  const AnimatedStatsCard({
    super.key,
    required this.tasks,
  });

  @override
  State<AnimatedStatsCard> createState() => _AnimatedStatsCardState();
}

class _AnimatedStatsCardState extends State<AnimatedStatsCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<AnimationController> _itemControllers;
  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _itemControllers = List.generate(
      4,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 100)),
        vsync: this,
      ),
    );

    _itemAnimations = _itemControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
    }).toList();

    _startAnimations();
  }

  void _startAnimations() {
    _controller.forward();
    for (int i = 0; i < _itemControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _itemControllers[i].forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(AnimatedStatsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tasks.length != widget.tasks.length) {
      _restartAnimations();
    }
  }

  void _restartAnimations() {
    for (final controller in _itemControllers) {
      controller.reset();
    }
    _startAnimations();
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                'Resumen de Tareas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Estadísticas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAnimatedStatItem(
                    'Total',
                    stats['total']!,
                    Icons.task_alt,
                    Colors.blue,
                    0,
                  ),
                  _buildAnimatedStatItem(
                    'Pendientes',
                    stats['pending']!,
                    Icons.pending,
                    Colors.orange,
                    1,
                  ),
                  _buildAnimatedStatItem(
                    'Completadas',
                    stats['completed']!,
                    Icons.check_circle,
                    Colors.green,
                    2,
                  ),
                  if (stats['overdue']! > 0)
                    _buildAnimatedStatItem(
                      'Vencidas',
                      stats['overdue']!,
                      Icons.warning,
                      Colors.red,
                      3,
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Barra de progreso
              _buildProgressBar(stats),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedStatItem(
    String label,
    int value,
    IconData icon,
    Color color,
    int index,
  ) {
    if (index >= _itemAnimations.length) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _itemAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _itemAnimations[index].value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.3), width: 2),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: value),
                duration: Duration(milliseconds: 800 + (index * 100)),
                curve: Curves.easeOutCubic,
                builder: (context, animatedValue, child) {
                  return Text(
                    animatedValue.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  );
                },
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(Map<String, int> stats) {
    final total = stats['total']!;
    final completed = stats['completed']!;
    final progress = total > 0 ? completed / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progreso General',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: progress),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOutCubic,
          builder: (context, animatedProgress, child) {
            return LinearProgressIndicator(
              value: animatedProgress,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              minHeight: 8,
            );
          },
        ),
      ],
    );
  }

  Map<String, int> _calculateStats() {
    final total = widget.tasks.length;
    final completed = widget.tasks.where((task) => task.status == TaskStatus.completed).length;
    final pending = widget.tasks.where((task) => task.status == TaskStatus.pending).length;
    final overdue = widget.tasks.where((task) => task.isOverdue).length;

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'overdue': overdue,
    };
  }
}