import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../core/constants/app_colors.dart';
import 'status_badge.dart';
import 'user_avatar.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final UserModel? assignee;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Function(TaskStatus)? onStatusChange;

  const TaskCard({
    super.key,
    required this.task,
    this.assignee,
    this.onTap,
    this.onDelete,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ligne 1 : titre + menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox rapide
                  GestureDetector(
                    onTap: () {
                      if (onStatusChange != null) {
                        onStatusChange!(task.status == TaskStatus.done
                            ? TaskStatus.todo
                            : TaskStatus.done);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(top: 1, right: 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.status == TaskStatus.done
                            ? AppColors.done
                            : Colors.transparent,
                        border: Border.all(
                          color: task.status == TaskStatus.done
                              ? AppColors.done
                              : (isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFFCBD5E1)),
                          width: 2,
                        ),
                      ),
                      child: task.status == TaskStatus.done
                          ? const Icon(Icons.check,
                              size: 13, color: Colors.white)
                          : null,
                    ),
                  ),

                  // Titre
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: task.status == TaskStatus.done
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.status == TaskStatus.done
                            ? (isDark
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8))
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Menu
                  if (onDelete != null)
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                            value: 'edit', child: Text('Modifier')),
                        PopupMenuItem(
                          value: 'status',
                          child: Text(_nextStatusLabel()),
                        ),
                        const PopupMenuItem(
                            value: 'delete',
                            child: Text('Supprimer',
                                style: TextStyle(color: Colors.red))),
                      ],
                      onSelected: (val) {
                        if (val == 'delete' && onDelete != null) onDelete!();
                        if (val == 'edit' && onTap != null) onTap!();
                        if (val == 'status' && onStatusChange != null) {
                          onStatusChange!(_nextStatus());
                        }
                      },
                    ),
                ],
              ),

              // Description
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Text(
                    task.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // Ligne 2 : badges + date + avatar
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Row(
                  children: [
                    StatusBadge(status: task.status, small: true),
                    const SizedBox(width: 6),
                    PriorityBadge(priority: task.priority, small: true),

                    const Spacer(),

                    // Date limite
                    if (task.dueDate != null) ...[
                      Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: task.isOverdue
                            ? AppColors.priorityHigh
                            : (isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        du.DateUtils.formatDueDate(task.dueDate!),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: task.isOverdue
                              ? AppColors.priorityHigh
                              : (isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B)),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Avatar assigné
                    if (assignee != null)
                      UserAvatar(user: assignee, size: 24),

                    // Indicateur non-synced
                    if (!task.isSynced) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.priorityMedium,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _nextStatusLabel() {
    switch (task.status) {
      case TaskStatus.todo:
        return 'Marquer en cours';
      case TaskStatus.inProgress:
        return 'Marquer terminé';
      case TaskStatus.done:
        return 'Remettre à faire';
    }
  }

  TaskStatus _nextStatus() {
    switch (task.status) {
      case TaskStatus.todo:
        return TaskStatus.inProgress;
      case TaskStatus.inProgress:
        return TaskStatus.done;
      case TaskStatus.done:
        return TaskStatus.todo;
    }
  }
}
