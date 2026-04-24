import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../core/network/api_service.dart';
import '../models/project_model.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final projectControllerProvider = StateNotifierProvider.family<
    ProjectController, AsyncValue<List<ProjectModel>>, String>(
  (ref, ownerId) => ProjectController(
    DatabaseHelper.instance,
    ref.read(apiServiceProvider),
    ownerId,
  ),
);

class ProjectController extends StateNotifier<AsyncValue<List<ProjectModel>>> {
  final DatabaseHelper _db;
  final ApiService _api;
  final String _ownerId;

  ProjectController(this._db, this._api, this._ownerId)
      : super(const AsyncValue.loading()) {
    loadProjects();
  }

  Future<void> loadProjects() async {
    state = const AsyncValue.loading();
    try {
      // 1. Charger SQLite (tous les projets stockés localement)
      final localProjects = await _db.getAllProjects();
      if (localProjects.isNotEmpty) {
        state = AsyncValue.data(localProjects);
      }

      // 2. Tenter de récupérer TOUS les projets de MockAPI pour la collaboration
      try {
        final remoteProjects = await _api.fetchProjects();

        // Mettre à jour SQLite avec tous les projets distants
        for (final p in remoteProjects) {
          await _db.insertProject(p);
        }

        final updatedProjects = await _db.getAllProjects();
        state = AsyncValue.data(updatedProjects);
      } catch (e) {
        // En cas d'erreur API, on garde les données locales si elles existent
        if (localProjects.isEmpty) {
          state = const AsyncValue.data([]);
        } else {
          state = AsyncValue.data(localProjects);
        }
      }
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<ProjectModel> addProject({
    required String name,
    required String description,
    required String color,
  }) async {
    final project = ProjectModel(
      id: const Uuid().v4(),
      name: name,
      description: description,
      color: color,
      ownerId: _ownerId,
      createdAt: DateTime.now(),
    );
    await _db.insertProject(project);
    _syncProjectCreate(project);
    await loadProjects();
    return project;
  }

  Future<void> updateProject(ProjectModel project) async {
    await _db.updateProject(project);
    _syncProjectUpdate(project);
    await loadProjects();
  }

  Future<void> deleteProject(String id) async {
    await _db.deleteProject(id);
    _syncProjectDelete(id);
    await loadProjects();
  }

  void _syncProjectCreate(ProjectModel project) async {
    try {
      final remoteProject = await _api.createProject(project);
      if (remoteProject.id != project.id) {
        await _db.deleteProject(project.id);
        await _db.insertProject(remoteProject);
      } else {
        await _db.markProjectSynced(project.id);
      }
    } catch (_) {}
  }

  void _syncProjectUpdate(ProjectModel project) async {
    try {
      await _api.updateProject(project);
    } catch (_) {}
  }

  void _syncProjectDelete(String id) async {
    try {
      await _api.deleteProject(id);
    } catch (_) {}
  }
}
