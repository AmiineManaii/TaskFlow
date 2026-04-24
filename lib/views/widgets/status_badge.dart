import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final TaskStatus status;
  final bool small;

  const StatusBadge({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = _statusInfo();
    final fontSize = small ? 10.0 : 12.0;
    final padding = small
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, Color) _statusInfo() {
    switch (status) {
      case TaskStatus.todo:
        return ('À faire', AppColors.todo, AppColors.todo.withOpacity(0.1));
      case TaskStatus.inProgress:
        return ('En cours', AppColors.inProgress,
            AppColors.inProgress.withOpacity(0.12));
      case TaskStatus.done:
        return ('Terminé', AppColors.done, AppColors.done.withOpacity(0.1));
    }
  }
}

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool small;

  const PriorityBadge({super.key, required this.priority, this.small = false});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _priorityInfo();
    final fontSize = small ? 10.0 : 11.0;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 6 : 8, vertical: small ? 2 : 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (String, Color) _priorityInfo() {
    switch (priority) {
      case TaskPriority.low:
        return ('Faible', AppColors.priorityLow);
      case TaskPriority.medium:
        return ('Moyenne', AppColors.priorityMedium);
      case TaskPriority.high:
        return ('Haute', AppColors.priorityHigh);
    }
  }
}
