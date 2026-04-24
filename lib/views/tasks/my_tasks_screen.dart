import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';

class MyTasksScreen extends ConsumerStatefulWidget {
  final String userId;
  const MyTasksScreen({super.key, required this.userId});

  @override
  ConsumerState<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends ConsumerState<MyTasksScreen> {
  TaskStatus? _filter;

  @override
  void initState() {
    super.initState();
    // Charger les données dès l'ouverture de l'écran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(assignedTasksProvider(widget.userId).notifier).load();
    });
  }

  void _deleteTask(TaskModel task) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteTask),
        content: Text(l10n.deleteTaskConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(taskControllerProvider(task.projectId).notifier)
          .deleteTask(task.id);
      ref.read(assignedTasksProvider(widget.userId).notifier).load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final tasksState = ref.watch(assignedTasksProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myTasks),
        actions: [
          PopupMenuButton<TaskStatus?>(
            icon: const Icon(Icons.filter_list_rounded),
            initialValue: _filter,
            itemBuilder: (_) => [
              PopupMenuItem(value: null, child: Text(l10n.all)),
              PopupMenuItem(
                  value: TaskStatus.todo, child: Text(l10n.status_todo)),
              PopupMenuItem(
                  value: TaskStatus.inProgress,
                  child: Text(l10n.status_inProgress)),
              PopupMenuItem(
                  value: TaskStatus.done, child: Text(l10n.status_done)),
            ],
            onSelected: (v) => setState(() => _filter = v),
          ),
        ],
      ),
      body: tasksState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.error}: $e')),
        data: (tasks) {
          final filtered = _filter == null
              ? tasks
              : tasks.where((t) => t.status == _filter).toList();

          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(assignedTasksProvider(widget.userId).notifier)
                  .load();
            },
            child: filtered.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment_outlined,
                                  size: 64,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.2)),
                              const SizedBox(height: 16),
                              Text(
                                tasks.isEmpty ? l10n.noTasks : l10n.filter,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      // Mini stats
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Row(
                          children: [
                            _MiniStat(
                                label: l10n.total,
                                value: tasks.length,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            _MiniStat(
                                label: l10n.status_done,
                                value: tasks
                                    .where((t) => t.status == TaskStatus.done)
                                    .length,
                                color: const Color(0xFF10B981)),
                            const SizedBox(width: 12),
                            _MiniStat(
                                label: l10n.overdue,
                                value: tasks.where((t) => t.isOverdue).length,
                                color: const Color(0xFFF87171)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final task = filtered[i];
                            final isCreator = task.creatorId == widget.userId;

                            return TaskCard(
                              task: task,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TaskDetailScreen(
                                    task: task,
                                    userId: widget.userId,
                                  ),
                                ),
                              ).then((_) {
                                ref
                                    .read(assignedTasksProvider(widget.userId)
                                        .notifier)
                                    .load();
                              }),
                              onDelete:
                                  isCreator ? () => _deleteTask(task) : null,
                              onStatusChange: (status) async {
                                await ref
                                    .read(taskControllerProvider(task.projectId)
                                        .notifier)
                                    .updateStatus(task.id, status);
                                ref
                                    .read(assignedTasksProvider(widget.userId)
                                        .notifier)
                                    .load();
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value.toString(),
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
