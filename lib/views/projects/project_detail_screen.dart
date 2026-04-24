import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../controllers/task_controller.dart';
import '../../core/database/database_helper.dart';
import '../../controllers/project_controller.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../tasks/task_form_screen.dart';
import '../tasks/task_detail_screen.dart';
import '../widgets/task_card.dart';
import '../widgets/user_avatar.dart';
import 'project_form_screen.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final ProjectModel project;
  final String userId;

  const ProjectDetailScreen({
    super.key,
    required this.project,
    required this.userId,
  });

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TaskStatus? _filterStatus;
  final Map<String, UserModel?> _userCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<UserModel?> _getUser(String? id) async {
    if (id == null) return null;
    if (_userCache.containsKey(id)) return _userCache[id];
    final user = await DatabaseHelper.instance.getUserById(id);
    _userCache[id] = user;
    return user;
  }

  void _openTaskForm({TaskModel? task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskFormScreen(
        projectId: widget.project.id,
        creatorId: widget.userId,
        task: task,
      ),
    );
  }

  void _deleteTask(String id) async {
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
          .read(taskControllerProvider(widget.project.id).notifier)
          .deleteTask(id);
    }
  }

  List<TaskModel> _filtered(List<TaskModel> tasks, TaskStatus? status) {
    if (status == null) return tasks;
    return tasks.where((t) => t.status == status).toList();
  }

  void _openProjectForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProjectFormScreen(
        userId: widget.userId,
        project: widget.project,
      ),
    );
  }

  void _deleteProject(String id) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteProject),
        content: Text(l10n.deleteProjectConfirm),
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
          .read(projectControllerProvider(widget.userId).notifier)
          .deleteProject(id);
      if (mounted) Navigator.pop(context);
    }
  }

  void _showAddMemberDialog(ProjectModel project) async {
    final l10n = AppLocalizations.of(context)!;
    final allUsers = await DatabaseHelper.instance.getAllUsers();
    // Exclure ceux qui sont déjà membres
    final potentialMembers =
        allUsers.where((u) => !project.memberIds.contains(u.id)).toList();

    if (!mounted) return;

    if (potentialMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Tous les utilisateurs sont déjà membres")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Ajouter un membre"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: potentialMembers.length,
            itemBuilder: (ctx, i) {
              final user = potentialMembers[i];
              return ListTile(
                leading: UserAvatar(user: user, size: 32),
                title: Text(user.name),
                subtitle: Text(user.email),
                onTap: () async {
                  try {
                    await ref
                        .read(projectControllerProvider(widget.userId).notifier)
                        .addMember(project.id, user.id);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("${user.name} ajouté au projet")),
                      );
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Erreur: $e")),
                      );
                    }
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final projectsState = ref.watch(projectControllerProvider(widget.userId));

    // Récupérer le projet à jour depuis le state du controller
    final currentProject = projectsState.when(
      data: (projects) => projects.firstWhere(
        (p) => p.id == widget.project.id,
        orElse: () => widget.project,
      ),
      loading: () => widget.project,
      error: (_, __) => widget.project,
    );

    final color = currentProject.colorValue;
    final tasksState = ref.watch(taskControllerProvider(currentProject.id));
    final isOwner = currentProject.ownerId == widget.userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentProject.name),
        actions: [
          if (isOwner) ...[
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              tooltip: "Ajouter un membre",
              onPressed: () => _showAddMemberDialog(currentProject),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _openProjectForm,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteProject(currentProject.id),
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          onTap: (i) {
            setState(() {
              _filterStatus = switch (i) {
                1 => TaskStatus.todo,
                2 => TaskStatus.inProgress,
                3 => TaskStatus.done,
                _ => null,
              };
            });
          },
          tabs: [
            Tab(text: l10n.all),
            Tab(text: l10n.status_todo),
            Tab(text: l10n.status_inProgress),
            Tab(text: l10n.status_done),
          ],
        ),
      ),
      body: tasksState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.error}: $e')),
        data: (tasks) {
          final filtered = _filtered(tasks, _filterStatus);

          // Stats header
          final total = tasks.length;
          final done = tasks.where((t) => t.status == TaskStatus.done).length;
          final progress = total > 0 ? done / total : 0.0;

          return Column(
            children: [
              // Stats bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatChip(
                          label: l10n.total,
                          value: total.toString(),
                          color: color,
                        ),
                        _StatChip(
                          label: l10n.status_todo,
                          value: tasks
                              .where((t) => t.status == TaskStatus.todo)
                              .length
                              .toString(),
                          color: const Color(0xFF64748B),
                        ),
                        _StatChip(
                          label: l10n.status_inProgress,
                          value: tasks
                              .where((t) => t.status == TaskStatus.inProgress)
                              .length
                              .toString(),
                          color: const Color(0xFFF59E0B),
                        ),
                        _StatChip(
                          label: l10n.status_done,
                          value: done.toString(),
                          color: const Color(0xFF10B981),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: theme.dividerColor,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Liste tâches
              Expanded(
                child: filtered.isEmpty
                    ? _EmptyTasks(onAdd: _openTaskForm)
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref
                              .read(taskControllerProvider(currentProject.id)
                                  .notifier)
                              .loadTasks();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 100),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final task = filtered[i];
                            final isTaskCreator =
                                task.creatorId == widget.userId;
                            final canDeleteTask = isOwner || isTaskCreator;

                            return FutureBuilder<UserModel?>(
                              future: _getUser(task.assigneeId),
                              builder: (_, snap) => TaskCard(
                                task: task,
                                assignee: snap.data,
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
                                      .read(taskControllerProvider(
                                              currentProject.id)
                                          .notifier)
                                      .loadTasks();
                                }),
                                onDelete: canDeleteTask
                                    ? () => _deleteTask(task.id)
                                    : null,
                                onStatusChange: (status) {
                                  ref
                                      .read(taskControllerProvider(
                                              currentProject.id)
                                          .notifier)
                                      .updateStatus(task.id, status);
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openTaskForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _EmptyTasks extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyTasks({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 64, color: theme.colorScheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(l10n.noTasks,
              style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.5))),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(l10n.addTask),
          ),
        ],
      ),
    );
  }
}
