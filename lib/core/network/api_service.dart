import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../../models/user_model.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ─── USERS ────────────────────────────────────────────────

  Future<List<UserModel>> fetchUsers() async {
    final res = await _client
        .get(Uri.parse('${ApiConstants.baseUrl1}${ApiConstants.usersEndpoint}'))
        .timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => UserModel.fromMap(e)).toList();
    }
    throw Exception('Fetch users failed: ${res.statusCode}');
  }

  Future<UserModel> createUser(UserModel user) async {
    final res = await _client
        .post(
          Uri.parse(
              '${ApiConstants.baseUrl1}${ApiConstants.usersEndpoint}'),
          headers: _headers,
          body: json.encode(user.toApiMapForCreate()),
        )
        .timeout(const Duration(seconds: 10));
    return UserModel.fromMap(json.decode(res.body));
  }

  // ─── PROJECTS ─────────────────────────────────────────────

  Future<List<ProjectModel>> fetchProjects() async {
    final res = await _client
        .get(Uri.parse(
            '${ApiConstants.baseUrl1}${ApiConstants.projectsEndpoint}'))
        .timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => ProjectModel.fromMap(e)).toList();
    }
    throw Exception('Fetch projects failed: ${res.statusCode}');
  }

  Future<ProjectModel> createProject(ProjectModel project) async {
    final res = await _client
        .post(
          Uri.parse(
              '${ApiConstants.baseUrl1}${ApiConstants.projectsEndpoint}'),
          headers: _headers,
          body: json.encode(project.toApiMapForCreate()),
        )
        .timeout(const Duration(seconds: 10));
    return ProjectModel.fromMap(json.decode(res.body));
  }

  Future<void> updateProject(ProjectModel project) async {
    await _client
        .put(
          Uri.parse(
              '${ApiConstants.baseUrl1}${ApiConstants.projectsEndpoint}/${project.id}'),
          headers: _headers,
          body: json.encode(project.toMap()),
        )
        .timeout(const Duration(seconds: 10));
  }

  Future<void> deleteProject(String id) async {
    await _client
        .delete(Uri.parse(
            '${ApiConstants.baseUrl1}${ApiConstants.projectsEndpoint}/$id'))
        .timeout(const Duration(seconds: 10));
  }

  // ─── TASKS ────────────────────────────────────────────────

  Future<List<TaskModel>> fetchTasks() async {
    final res = await _client
        .get(Uri.parse(
            '${ApiConstants.baseUrl2}${ApiConstants.tasksEndpoint}'))
        .timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => TaskModel.fromMap(e)).toList();
    }
    throw Exception('Fetch tasks failed: ${res.statusCode}');
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final res = await _client
        .post(
          Uri.parse(
              '${ApiConstants.baseUrl2}${ApiConstants.tasksEndpoint}'),
          headers: _headers,
          body: json.encode(task.toApiMapForCreate()),
        )
        .timeout(const Duration(seconds: 10));
    return TaskModel.fromMap(json.decode(res.body));
  }

  Future<void> updateTask(TaskModel task) async {
    await _client
        .put(
          Uri.parse(
              '${ApiConstants.baseUrl2}${ApiConstants.tasksEndpoint}/${task.id}'),
          headers: _headers,
          body: json.encode(task.toApiMap()),
        )
        .timeout(const Duration(seconds: 10));
  }

  Future<void> deleteTask(String id) async {
    await _client
        .delete(Uri.parse(
            '${ApiConstants.baseUrl2}${ApiConstants.tasksEndpoint}/$id'))
        .timeout(const Duration(seconds: 10));
  }
}
