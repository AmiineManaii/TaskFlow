import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/project_controller.dart';
import '../../controllers/sync_controller.dart';
import '../../controllers/task_controller.dart';
import '../../core/database/database_helper.dart';
import '../../models/project_model.dart';
import '../auth/login_screen.dart';
import '../projects/project_detail_screen.dart';
import '../projects/project_form_screen.dart';
import '../settings/settings_screen.dart';
import '../tasks/my_tasks_screen.dart';
import '../widgets/project_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.valueOrNull;
    final l10n = AppLocalizations.of(context)!;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _ProjectsTab(userId: user.id),
          MyTasksScreen(userId: user.id),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.folder_outlined),
            selectedIcon: const Icon(Icons.folder_rounded),
            label: l10n.projects,
          ),
          NavigationDestination(
            icon: const Icon(Icons.task_outlined),
            selectedIcon: const Icon(Icons.task_alt_rounded),
            label: l10n.myTasks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}

class _ProjectsTab extends ConsumerStatefulWidget {
  final String userId;
  const _ProjectsTab({required this.userId});

  @override
  ConsumerState<_ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends ConsumerState<_ProjectsTab> {
  // Cache des stats par projet
  final Map<String, (int, int)> _stats = {};

  Future<void> _loadStats(List<ProjectModel> projects) async {
    final db = DatabaseHelper.instance;
    for (final p in projects) {
      final total = await db.countTasks(p.id);
      final done = await db.countTasksByStatus(p.id, 'done');
      if (mounted) {
        setState(() => _stats[p.id] = (total, done));
      }
    }
  }

  void _openProjectForm({ProjectModel? project}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProjectFormScreen(
        userId: widget.userId,
        project: project,
      ),
    );
  }

  void _deleteProject(BuildContext ctx, String id) async {
    final l10n = AppLocalizations.of(ctx)!;
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteProject),
        content: Text(l10n.deleteProjectConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectsState = ref.watch(projectControllerProvider(widget.userId));
    final user = ref.watch(authControllerProvider).valueOrNull;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TaskFlow'),
            if (user != null)
              Text(
                '${l10n.hello}, ${user.name.split(' ').first} 👋',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: l10n.sync,
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.syncing)),
              );

              try {
                // 1. Synchroniser local -> distant
                await ref.read(syncControllerProvider).syncAll();

                // 2. Recharger distant -> local
                if (user != null) {
                  await ref
                      .read(projectControllerProvider(user.id).notifier)
                      .loadProjects();
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.syncSuccess),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l10n.error}: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: projectsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.error}: $e')),
        data: (projects) {
          if (projects.isEmpty) {
            return _EmptyProjects(onAdd: _openProjectForm);
          }

          // Charger les stats
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadStats(projects);
          });

          return RefreshIndicator(
            onRefresh: () async {
              ref
                  .read(projectControllerProvider(widget.userId).notifier)
                  .loadProjects();
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 100),
              itemCount: projects.length,
              itemBuilder: (ctx, i) {
                final p = projects[i];
                final stats = _stats[p.id];
                return ProjectCard(
                  project: p,
                  totalTasks: stats?.$1 ?? 0,
                  doneTasks: stats?.$2 ?? 0,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectDetailScreen(
                        project: p,
                        userId: widget.userId,
                      ),
                    ),
                  ).then((_) {
                    ref
                        .read(projectControllerProvider(widget.userId).notifier)
                        .loadProjects();
                  }),
                  onEdit: () => _openProjectForm(project: p),
                  onDelete: () => _deleteProject(ctx, p.id),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openProjectForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyProjects extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyProjects({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded,
              size: 72, color: theme.colorScheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(l10n.noProjects,
              style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.5))),
          const SizedBox(height: 8),
          Text(l10n.createFirstProject,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.4))),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(l10n.newProject),
          ),
        ],
      ),
    );
  }
}
