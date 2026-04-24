class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.avatarUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id']?.toString() ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        password: map['password'] ?? '',
        avatarUrl: map['avatarUrl'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'avatarUrl': avatarUrl,
      };

  // toMap pour l'API (inclut le mot de passe pour le mock login)
  Map<String, dynamic> toApiMap() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'avatarUrl': avatarUrl,
      };

  Map<String, dynamic> toApiMapForCreate() => {
        'name': name,
        'email': email,
        'password': password,
        'avatarUrl': avatarUrl,
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? avatarUrl,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        password: password ?? this.password,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }
}
