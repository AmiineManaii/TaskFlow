import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:taskflow/models/project_model.dart';
import 'package:taskflow/models/task_model.dart';
import 'package:taskflow/models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    _database ??= await _initDB('taskflow.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return openDatabase(
      path,
      onCreate: _createDB,
      version: 2,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Ajout de la colonne isSynced à la table projects
      await db.execute('ALTER TABLE projects ADD COLUMN isSynced INTEGER DEFAULT 0');
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        avatarUrl TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE projects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        color TEXT DEFAULT '#2563EB',
        ownerId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isSynced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        status TEXT DEFAULT 'todo',
        priority TEXT DEFAULT 'medium',
        projectId TEXT NOT NULL,
        creatorId TEXT NOT NULL,
        assigneeId TEXT,
        dueDate TEXT,
        createdAt TEXT NOT NULL,
        isSynced INTEGER DEFAULT 0,
        FOREIGN KEY (projectId) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');
  }

  // ─── USERS ───────────────────────────────────────────────

  Future<void> insertUser(UserModel user) async {
    final db = await database;

    // Vérifier si l'utilisateur existe déjà (par ID ou par Email)
    // pour ne pas écraser le mot de passe par du vide lors de la synchronisation
    UserModel? existing = await getUserById(user.id);
    if (existing == null) {
      existing = await getUserByEmail(user.email);
    }

    UserModel userToSave = user;
    if (existing != null &&
        user.password.isEmpty &&
        existing.password.isNotEmpty) {
      userToSave = user.copyWith(password: existing.password);
    }

    await db.insert('users', userToSave.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query('users',
        where: 'email = ?', whereArgs: [email], limit: 1);
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getUserById(String id) async {
    final db = await database;
    final maps =
        await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users');
    return maps.map((m) => UserModel.fromMap(m)).toList();
  }

  // ─── PROJECTS ────────────────────────────────────────────

  Future<void> insertProject(ProjectModel project) async {
    final db = await database;
    await db.insert('projects', project.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ProjectModel>> getProjects(String ownerId) async {
    final db = await database;
    final maps = await db.query('projects',
        where: 'ownerId = ?', whereArgs: [ownerId], orderBy: 'createdAt DESC');
    return maps.map((m) => ProjectModel.fromMap(m)).toList();
  }

  Future<List<ProjectModel>> getAllProjects() async {
    final db = await database;
    final maps = await db.query('projects', orderBy: 'createdAt DESC');
    return maps.map((m) => ProjectModel.fromMap(m)).toList();
  }

  Future<List<ProjectModel>> getUnsyncedProjects() async {
    final db = await database;
    final maps =
        await db.query('projects', where: 'isSynced = ?', whereArgs: [0]);
    return maps.map((m) => ProjectModel.fromMap(m)).toList();
  }

  Future<ProjectModel?> getProjectById(String id) async {
    final db = await database;
    final maps =
        await db.query('projects', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return ProjectModel.fromMap(maps.first);
  }

  Future<void> updateProject(ProjectModel project) async {
    final db = await database;
    await db.update('projects', project.toMap(),
        where: 'id = ?', whereArgs: [project.id]);
  }

  Future<void> deleteProject(String id) async {
    final db = await database;
    // Les tâches sont supprimées via ON DELETE CASCADE
    await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markProjectSynced(String id) async {
    final db = await database;
    await db.update(
      'projects',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── TASKS ───────────────────────────────────────────────

  Future<void> insertTask(TaskModel task) async {
    final db = await database;
    await db.insert('tasks', task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<TaskModel>> getTasksByProject(String projectId) async {
    final db = await database;
    final maps = await db.query('tasks',
        where: 'projectId = ?',
        whereArgs: [projectId],
        orderBy: 'createdAt DESC');
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<List<TaskModel>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'createdAt DESC');
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<List<TaskModel>> getTasksByAssignee(String userId) async {
    final db = await database;
    final maps = await db.query('tasks',
        where: 'assigneeId = ?',
        whereArgs: [userId],
        orderBy: 'createdAt DESC');
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<List<TaskModel>> getUnsyncedTasks() async {
    final db = await database;
    final maps = await db.query('tasks', where: 'isSynced = ?', whereArgs: [0]);
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<TaskModel?> getTaskById(String id) async {
    final db = await database;
    final maps =
        await db.query('tasks', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return TaskModel.fromMap(maps.first);
  }

  Future<void> updateTask(TaskModel task) async {
    final db = await database;
    await db
        .update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> markTaskSynced(String id) async {
    final db = await database;
    await db.update('tasks', {'isSynced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllUsers() async {
    final db = await database;
    await db.delete('users');
  }

  Future<void> clearAllProjects() async {
    final db = await database;
    await db.delete('projects');
  }

  Future<void> clearAllTasks() async {
    final db = await database;
    await db.delete('tasks');
  }

  Future<void> clearAllData() async {
    await clearAllTasks();
    await clearAllProjects();
    await clearAllUsers();
  }

  Future<int> countTasksByStatus(String projectId, String status) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM tasks WHERE projectId = ? AND status = ?',
        [projectId, status]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> countTasks(String projectId) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM tasks WHERE projectId = ?', [projectId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
