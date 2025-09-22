import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../models/task.dart';
import '../../services/haptic_service.dart';

class AnimatedTaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int index;

  const AnimatedTaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggle,
    this.onEdit,
    this.onDelete,
    required this.index,
  });

  @override
  State<AnimatedTaskCard> createState() => _AnimatedTaskCardState();
}

class _AnimatedTaskCardState extends State<AnimatedTaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Iniciar animación con delay basado en el índice
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildTaskCard(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getPriorityColor().withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // Checkbox animado
                _buildAnimatedCheckbox(),
                const SizedBox(width: 12),
                
                // Contenido de la tarea
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: widget.task.status == TaskStatus.completed
                              ? TextDecoration.lineThrough
                              : null,
                          color: widget.task.status == TaskStatus.completed
                              ? Colors.grey
                              : null,
                        ),
                        child: Text(widget.task.title),
                      ),
                      
                      // Descripción
                      if (widget.task.description != null && 
                          widget.task.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.task.description!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      const SizedBox(height: 8),
                      
                      // Chips de información
                      _buildInfoChips(),
                    ],
                  ),
                ),
                
                // Menú de acciones
                _buildActionMenu(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCheckbox() {
    return GestureDetector(
      onTap: () {
        HapticService.taskCompleted();
        widget.onToggle?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.task.status == TaskStatus.completed
              ? Colors.green
              : Colors.transparent,
          border: Border.all(
            color: widget.task.status == TaskStatus.completed
                ? Colors.green
                : Colors.grey,
            width: 2,
          ),
        ),
        child: widget.task.status == TaskStatus.completed
            ? const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  Widget _buildInfoChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        // Chip de categoría
        _buildChip(
          label: widget.task.category,
          color: Colors.blue,
          icon: Icons.label,
        ),
        
        // Chip de prioridad
        _buildChip(
          label: _getPriorityLabel(),
          color: _getPriorityColor(),
          icon: _getPriorityIcon(),
        ),
        
        // Chip de fecha si existe
        if (widget.task.dueDate != null)
          _buildChip(
            label: _formatDate(widget.task.dueDate!),
            color: widget.task.isOverdue ? Colors.red : Colors.orange,
            icon: Icons.schedule,
          ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            widget.onEdit?.call();
            break;
          case 'delete':
            widget.onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Editar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 18),
              SizedBox(width: 8),
              Text('Eliminar', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withOpacity(0.1),
        ),
        child: const Icon(Icons.more_vert, size: 18),
      ),
    );
  }

  Color _getPriorityColor() {
    return AppTheme.getPriorityColor(widget.task.priority.value);
  }

  IconData _getPriorityIcon() {
    return AppTheme.getPriorityIcon(widget.task.priority.value);
  }

  String _getPriorityLabel() {
    switch (widget.task.priority) {
      case TaskPriority.low:
        return 'Baja';
      case TaskPriority.medium:
        return 'Media';
      case TaskPriority.high:
        return 'Alta';
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
}