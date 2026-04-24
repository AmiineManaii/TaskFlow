import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../controllers/sync_controller.dart';
import '../../controllers/project_controller.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/language_controller.dart';
import '../../core/database/database_helper.dart';
import '../../views/auth/login_screen.dart';
import '../../models/user_model.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';
import '../widgets/user_avatar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = ref.watch(themeControllerProvider) == ThemeMode.dark;
    final locale = ref.watch(languageControllerProvider);
    final user = ref.watch(authControllerProvider).valueOrNull;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          // Profil utilisateur
          if (user != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  UserAvatar(user: user, size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        Text(user.email,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          _SectionHeader(l10n.appearance),

          // Mode sombre
          SwitchListTile(
            secondary: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            ),
            title: Text(l10n.darkMode),
            subtitle: Text(isDark ? l10n.enabled : l10n.disabled),
            value: isDark,
            onChanged: (_) {
              ref.read(themeControllerProvider.notifier).toggleTheme();
            },
          ),

          const Divider(indent: 16, endIndent: 16),

          _SectionHeader(l10n.language),

          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: const Text('Français'),
            trailing: locale.languageCode == 'fr'
                ? const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF2563EB))
                : null,
            onTap: () {
              ref
                  .read(languageControllerProvider.notifier)
                  .setLocale(const Locale('fr'));
            },
          ),

          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: const Text('English'),
            trailing: locale.languageCode == 'en'
                ? const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF2563EB))
                : null,
            onTap: () {
              ref
                  .read(languageControllerProvider.notifier)
                  .setLocale(const Locale('en'));
            },
          ),

          const Divider(indent: 16, endIndent: 16),

          _SectionHeader(l10n.data),

          // Sync
          ListTile(
            leading: const Icon(Icons.sync_rounded),
            title: Text(l10n.syncWithServer),
            subtitle: Text(l10n.syncSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () async {
              _showSyncDialog(context, ref);
            },
          ),

          // Stats BDD
          ListTile(
            leading: const Icon(Icons.storage_rounded),
            title: Text(l10n.localData),
            subtitle: FutureBuilder<List<int>>(
              future: Future.wait([
                DatabaseHelper.instance.getAllUsers().then((l) => l.length),
                DatabaseHelper.instance.getAllProjects().then((l) => l.length),
                DatabaseHelper.instance.getAllTasks().then((l) => l.length),
              ]),
              builder: (_, snap) {
                if (!snap.hasData) return Text(l10n.loading);
                final counts = snap.data!;
                return Text(
                    '${counts[0]} users, ${counts[1]} projects, ${counts[2]} tasks');
              },
            ),
            trailing: const Icon(Icons.manage_search_rounded),
            onTap: () => _showDataExplorer(context),
          ),

          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            title: Text(l10n.clearLocalData,
                style: const TextStyle(color: Colors.red)),
            subtitle: Text(l10n.clearLocalDataSubtitle),
            onTap: () => _showClearDataDialog(context, ref),
          ),

          const Divider(indent: 16, endIndent: 16),

          _SectionHeader(l10n.account),

          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(l10n.logout),
                  content: Text(l10n.logoutConfirm),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.cancel)),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(l10n.logout),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                }
              }
            },
          ),

          const SizedBox(height: 40),

          // Version
          Center(
            child: Text(
              'TaskFlow v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showSyncDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.read(authControllerProvider).valueOrNull;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.syncInProgress),
          ],
        ),
      ),
    );

    try {
      // 1. Synchroniser les données locales vers le serveur
      await ref.read(syncControllerProvider).syncAll();

      // 2. Recharger les données depuis le serveur
      if (user != null) {
        await ref
            .read(projectControllerProvider(user.id).notifier)
            .loadProjects();
      }

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.syncSuccess),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.clearLocalData),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.clearLocalDataConfirm),
            const SizedBox(height: 16),
            _ClearOption(
              icon: Icons.person_outline,
              label: l10n.users,
              onTap: () => Navigator.pop(context, 'users'),
            ),
            _ClearOption(
              icon: Icons.folder_outlined,
              label: l10n.projects,
              onTap: () => Navigator.pop(context, 'projects'),
            ),
            _ClearOption(
              icon: Icons.task_outlined,
              label: l10n.tasks,
              onTap: () => Navigator.pop(context, 'tasks'),
            ),
            const Divider(),
            _ClearOption(
              icon: Icons.delete_forever,
              label: l10n.clearAll,
              color: Colors.red,
              onTap: () => Navigator.pop(context, 'all'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );

    if (result == null || !context.mounted) return;

    final db = DatabaseHelper.instance;
    switch (result) {
      case 'users':
        await db.clearAllUsers();
        break;
      case 'projects':
        await db.clearAllProjects();
        break;
      case 'tasks':
        await db.clearAllTasks();
        break;
      case 'all':
        await db.clearAllData();
        break;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.clearLocalDataSuccess),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  void _showDataExplorer(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(2))),
                TabBar(
                  tabs: [
                    Tab(text: l10n.users),
                    Tab(text: l10n.projects),
                    Tab(text: l10n.tasks),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _DataList<UserModel>(
                        future: DatabaseHelper.instance.getAllUsers(),
                        itemBuilder: (u) => ListTile(
                          title: Text(u.name),
                          subtitle: Text(u.email),
                          leading: UserAvatar(user: u, size: 40),
                        ),
                      ),
                      _DataList<ProjectModel>(
                        future: DatabaseHelper.instance.getAllProjects(),
                        itemBuilder: (p) => ListTile(
                          title: Text(p.name),
                          subtitle: Text(p.id),
                          leading: CircleAvatar(
                              backgroundColor: p.colorValue, radius: 8),
                        ),
                      ),
                      _DataList<TaskModel>(
                        future: DatabaseHelper.instance.getAllTasks(),
                        itemBuilder: (t) => ListTile(
                          title: Text(t.title),
                          subtitle: Text('Project: ${t.projectId}'),
                          trailing: Icon(
                            t.isSynced ? Icons.cloud_done : Icons.cloud_off,
                            color: t.isSynced ? Colors.green : Colors.orange,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DataList<T> extends StatelessWidget {
  final Future<List<T>> future;
  final Widget Function(T) itemBuilder;

  const _DataList({required this.future, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final items = snap.data!;
        if (items.isEmpty) return const Center(child: Text('Empty table'));
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) => itemBuilder(items[i]),
        );
      },
    );
  }
}

class _ClearOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ClearOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
