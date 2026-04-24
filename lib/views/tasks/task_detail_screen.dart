import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/models/project_model.dart';
import '../../controllers/task_controller.dart';
import '../../core/database/database_helper.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../widgets/status_badge.dart';
import '../widgets/user_avatar.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final TaskModel task;
  final String userId;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.userId,
  });

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  late TaskModel _task;
  UserModel? _assignee;
  UserModel? _creator;
  ProjectModel? _project;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper.instance;
    final assignee = _task.assigneeId != null
        ? await db.getUserById(_task.assigneeId!)
        : null;
    final creator = await db.getUserById(_task.creatorId);
    final project = await db.getProjectById(_task.projectId);
    if (mounted) {
      setState(() {
        _assignee = assignee;
        _creator = creator;
        _project = project;
      });
    }
  }

  void _editTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskFormScreen(
        projectId: _task.projectId,
        creatorId: widget.userId,
        task: _task,
      ),
    ).then((_) async {
      final updated = await DatabaseHelper.instance.getTaskById(_task.id);
      if (updated != null && mounted) {
        setState(() => _task = updated);
        _loadData();
      }
    });
  }

  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer la tâche'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette tâche ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(taskControllerProvider(_task.projectId).notifier)
          .deleteTask(_task.id);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _changeStatus(TaskStatus status) async {
    await ref
        .read(taskControllerProvider(_task.projectId).notifier)
        .updateStatus(_task.id, status);
    final updated = await DatabaseHelper.instance.getTaskById(_task.id);
    if (updated != null && mounted) setState(() => _task = updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isOwner = _project?.ownerId == widget.userId;
    final isCreator = _task.creatorId == widget.userId;
    final canManage = isOwner || isCreator;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la tâche'),
        actions: [
          if (canManage) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _editTask,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deleteTask,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Text(
              _task.title,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            // Badges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusBadge(status: _task.status),
                PriorityBadge(priority: _task.priority),
                if (_task.isOverdue)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF87171).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFF87171).withOpacity(0.3)),
                    ),
                    child: const Text(
                      '⚠ En retard',
                      style: TextStyle(
                          color: Color(0xFFF87171),
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Description
            if (_task.description.isNotEmpty) ...[
              _SectionTitle('Description'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  _task.description,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Changer statut
            _SectionTitle('Statut'),
            const SizedBox(height: 8),
            SegmentedButton<TaskStatus>(
              segments: const [
                ButtonSegment(value: TaskStatus.todo, label: Text('À faire')),
                ButtonSegment(
                    value: TaskStatus.inProgress, label: Text('En cours')),
                ButtonSegment(value: TaskStatus.done, label: Text('Terminé')),
              ],
              selected: {_task.status},
              onSelectionChanged: (s) => _changeStatus(s.first),
            ),

            const SizedBox(height: 24),

            // Infos
            _InfoCard(children: [
              _InfoRow(
                icon: Icons.person_outline,
                label: 'Créé par',
                value: _creator?.name ?? _task.creatorId,
                trailing: UserAvatar(user: _creator, size: 28),
              ),
              _InfoRow(
                icon: Icons.assignment_ind_outlined,
                label: 'Assigné à',
                value: _assignee?.name ?? 'Non assigné',
                trailing: _assignee != null
                    ? UserAvatar(user: _assignee, size: 28)
                    : null,
              ),
              if (_task.dueDate != null)
                _InfoRow(
                  icon: Icons.schedule_rounded,
                  label: 'Date limite',
                  value: du.DateUtils.formatDate(_task.dueDate!),
                  valueColor: _task.isOverdue ? const Color(0xFFF87171) : null,
                ),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Créé le',
                value: du.DateUtils.formatDate(_task.createdAt),
              ),
              _InfoRow(
                icon: Icons.sync_rounded,
                label: 'Synchronisé',
                value: _task.isSynced ? 'Oui ✓' : 'En attente...',
                valueColor: _task.isSynced
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF59E0B),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
      );
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: children
            .expand((w) => [
                  w,
                  if (w != children.last)
                    Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: isDark
                            ? const Color(0xFF475569)
                            : const Color(0xFFE2E8F0))
                ])
            .toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon,
              size: 18, color: theme.colorScheme.onSurface.withOpacity(0.4)),
          const SizedBox(width: 10),
          Text(label,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5))),
          const Spacer(),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: 8),
          ],
          Text(value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              )),
        ],
      ),
    );
  }
}
