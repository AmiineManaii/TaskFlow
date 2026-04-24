import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/database_helper.dart';
import '../core/network/api_service.dart';
import 'project_controller.dart';

final syncControllerProvider = Provider((ref) => SyncController(
      DatabaseHelper.instance,
      ref.read(apiServiceProvider),
    ));

class SyncController {
  final DatabaseHelper _db;
  final ApiService _api;

  SyncController(this._db, this._api);

  Future<void> syncAll() async {
    // 1. Synchroniser les projets non synchronisés
    final unsyncedProjects = await _db.getUnsyncedProjects();
    for (final project in unsyncedProjects) {
      try {
        // Heuristique : si l'ID contient un tiret, c'est un UUID local (nouveau projet)
        if (project.id.contains('-')) {
          final remoteProject = await _api.createProject(project);
          if (remoteProject.id != project.id) {
            await _db.deleteProject(project.id);
            await _db.insertProject(remoteProject.copyWith(isSynced: true));

            final tasks = await _db.getTasksByProject(project.id);
            for (final task in tasks) {
              await _db.updateTask(task.copyWith(projectId: remoteProject.id));
            }
          } else {
            await _db.markProjectSynced(project.id);
          }
        } else {
          // Sinon c'est une mise à jour d'un projet existant
          await _api.updateProject(project);
          await _db.markProjectSynced(project.id);
        }
      } catch (_) {}
    }

    // 2. Synchroniser les tâches non synchronisées
    final unsyncedTasks = await _db.getUnsyncedTasks();
    for (final task in unsyncedTasks) {
      try {
        if (task.id.contains('-')) {
          // Création
          final remoteTask = await _api.createTask(task);
          if (remoteTask.id != task.id) {
            await _db.deleteTask(task.id);
            await _db.insertTask(remoteTask.copyWith(isSynced: true));
          } else {
            await _db.markTaskSynced(task.id);
          }
        } else {
          // Mise à jour
          await _api.updateTask(task);
          await _db.markTaskSynced(task.id);
        }
      } catch (_) {}
    }
  }
}
