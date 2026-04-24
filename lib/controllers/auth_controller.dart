import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/database/database_helper.dart';
import '../core/network/api_service.dart';
import '../models/user_model.dart';
import 'package:uuid/uuid.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserModel?>>(
  (ref) => AuthController(
    DatabaseHelper.instance,
    ref.read(apiServiceProvider),
  ),
);

class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  final DatabaseHelper _db;
  final ApiService _api;
  static const _prefKey = 'logged_user_id';

  AuthController(this._db, this._api) : super(const AsyncValue.loading()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString(_prefKey);
      if (savedId != null) {
        final user = await _db.getUserById(savedId);
        state = AsyncValue.data(user);
        // Sync tous les utilisateurs pour la collaboration
        _syncAllUsers();
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> _syncAllUsers() async {
    try {
      final remoteUsers = await _api.fetchUsers();
      for (final u in remoteUsers) {
        await _db.insertUser(u);
      }
    } catch (e) {
      // Échec silencieux de la sync des utilisateurs
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final emailClean = email.trim().toLowerCase();

      // 1. Chercher localement d'abord
      var user = await _db.getUserByEmail(emailClean);

      // 2. Si non trouvé localement, chercher sur MockAPI (cas d'un nouvel appareil)
      if (user == null) {
        await _syncAllUsers();
        user = await _db.getUserByEmail(emailClean);
      }

      if (user == null || user.password != password) {
        return 'Email ou mot de passe incorrect';
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, user.id);
      state = AsyncValue.data(user);

      return null;
    } catch (e) {
      return 'Erreur: $e';
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final existing = await _db.getUserByEmail(email.trim().toLowerCase());
      if (existing != null) return 'Cet email est déjà utilisé';

      final user = UserModel(
        id: const Uuid().v4(),
        name: name.trim(),
        email: email.trim().toLowerCase(),
        password: password,
      );
      await _db.insertUser(user);

      // Sauvegarde sur MockAPI
      try {
        final remoteUser = await _api.createUser(user);
        // Si l'API a généré un ID différent (ex: MockAPI), on met à jour localement
        if (remoteUser.id != user.id) {
          // On peut choisir de garder l'ID distant pour la cohérence
          final updatedUser = user.copyWith(id: remoteUser.id);
          await _db.insertUser(updatedUser);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_prefKey, remoteUser.id);
          state = AsyncValue.data(updatedUser);
          return null;
        }
      } catch (e) {
        // Optionnel: loguer l'erreur ou gérer la sync plus tard
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, user.id);
      state = AsyncValue.data(user);
      return null;
    } catch (e) {
      return 'Erreur: $e';
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    state = const AsyncValue.data(null);
  }

  UserModel? get currentUser => state.valueOrNull;
}
