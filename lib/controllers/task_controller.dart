import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../core/network/api_service.dart';
import '../core/utils/notification_service.dart';
import '../models/task_model.dart';
import 'project_controller.dart';

final taskControllerProvider = StateNotifierProvider.family<TaskController,
    AsyncValue<List<TaskModel>>, String>(
  (ref, projectId) => TaskController(
    DatabaseHelper.instance,
    ref.read(apiServiceProvider),
    projectId,
  ),
);

// Provider pour les tâches assignées à un utilisateur
final assignedTasksProvider = StateNotifierProvider.family<
    AssignedTasksController, AsyncValue<List<TaskModel>>, String>(
  (ref, userId) => AssignedTasksController(
    DatabaseHelper.instance,
    ref.read(apiServiceProvider),
    userId,
  ),
);

class TaskController extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final DatabaseHelper _db;
  final ApiService _api;
  final String _projectId;

  TaskController(this._db, this._api, this._projectId)
      : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      state = const AsyncValue.loading();

      // 1. Charger depuis MockAPI
      List<TaskModel> remoteTasks = [];
      try {
        remoteTasks = await _api.fetchTasks();
        final projectTasks =
            remoteTasks.where((t) => t.projectId == _projectId).toList();

        for (final t in projectTasks) {
          // On s'assure que isSynced est à true pour les données venant de l'API
          await _db.insertTask(t.copyWith(isSynced: true));
        }
      } catch (_) {}

      // 2. Charger depuis SQLite (contient toutes les tâches locales + distantes)
      final localTasks = await _db.getTasksByProject(_projectId);

      // 3. Fusionner: on privilégie les données distantes (isSynced: true)
      // pour les tâches qui existent déjà, mais on garde les tâches locales non sync.
      final mergedTasks = <String, TaskModel>{};

      // D'abord on remplit avec le local
      for (final t in localTasks) {
        mergedTasks[t.id] = t;
      }

      // Ensuite on écrase avec le distant (qui a isSynced: true)
      for (final t in remoteTasks.where((t) => t.projectId == _projectId)) {
        mergedTasks[t.id] = t.copyWith(isSynced: true);
      }

      final allTasks = mergedTasks.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = AsyncValue.data(allTasks);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<TaskModel> addTask({
    required String title,
    required String description,
    required TaskPriority priority,
    required String creatorId,
    String? assigneeId,
    DateTime? dueDate,
  }) async {
    final task = TaskModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      status: TaskStatus.todo,
      priority: priority,
      projectId: _projectId,
      creatorId: creatorId,
      assigneeId: assigneeId,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      isSynced: false,
    );

    await _db.insertTask(task);

    // Notification si assignée
    if (assigneeId != null) {
      await NotificationService.showInstant(
        id: task.id.hashCode,
        title: 'Nouvelle tâche assignée',
        body: title,
      );
    }

    // Programmer rappel si date limite
    if (dueDate != null) {
      await NotificationService.scheduleTaskReminder(
        id: task.id.hashCode + 1,
        taskTitle: title,
        dueDate: dueDate,
      );
    }

    await _syncTaskCreate(task);
    await loadTasks();
    return task;
  }

  Future<void> updateTask(TaskModel task) async {
    final updated = task.copyWith(isSynced: false);
    await _db.updateTask(updated);
    await _syncTaskUpdate(updated);
    await loadTasks();
  }

  Future<void> updateStatus(String taskId, TaskStatus status) async {
    final task = await _db.getTaskById(taskId);
    if (task == null) return;
    final updated = task.copyWith(status: status, isSynced: false);
    await _db.updateTask(updated);
    await _syncTaskUpdate(updated);
    await loadTasks();
  }

  Future<void> deleteTask(String taskId) async {
    await NotificationService.cancelNotification(taskId.hashCode + 1);
    await _db.deleteTask(taskId);
    _syncTaskDelete(taskId);
    await loadTasks();
  }

  Future<void> _syncTaskCreate(TaskModel task) async {
    try {
      final remoteTask = await _api.createTask(task);
      // Si MockAPI a généré un ID différent, on met à jour localement
      if (remoteTask.id != task.id) {
        await _db.deleteTask(task.id);
        await _db.insertTask(remoteTask.copyWith(isSynced: true));
      } else {
        await _db.markTaskSynced(task.id);
      }
    } catch (_) {
      // isSynced reste false → sync différée
    }
  }

  Future<void> _syncTaskUpdate(TaskModel task) async {
    try {
      await _api.updateTask(task);
      await _db.markTaskSynced(task.id);
    } catch (_) {}
  }

  void _syncTaskDelete(String id) async {
    try {
      await _api.deleteTask(id);
    } catch (_) {}
  }

  Future<int> syncPendingTasks() async {
    final unsynced = await _db.getUnsyncedTasks();
    int count = 0;
    for (final task in unsynced) {
      try {
        final remoteTask = await _api.createTask(task);
        if (remoteTask.id != task.id) {
          await _db.deleteTask(task.id);
          await _db.insertTask(remoteTask.copyWith(isSynced: true));
        } else {
          await _db.markTaskSynced(task.id);
        }
        count++;
      } catch (_) {}
    }
    return count;
  }
}

class AssignedTasksController
    extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final DatabaseHelper _db;
  final ApiService _api;
  final String _userId;

  AssignedTasksController(this._db, this._api, this._userId)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      // 1. Synchroniser avec MockAPI d'abord pour avoir les dernières assignations
      try {
        final remoteTasks = await _api.fetchTasks();
        for (final t in remoteTasks) {
          await _db.insertTask(t.copyWith(isSynced: true));
        }
      } catch (_) {
        // En cas d'erreur réseau, on continue avec les données locales
      }

      // 2. Charger les tâches assignées depuis SQLite
      final tasks = await _db.getTasksByAssignee(_userId);
      state = AsyncValue.data(tasks);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}
