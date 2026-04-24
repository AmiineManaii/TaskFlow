import 'package:flutter/material.dart';

class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String color;
  final String ownerId;
  final DateTime createdAt;
  final bool isSynced;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.ownerId,
    required this.createdAt,
    this.isSynced = false,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) => ProjectModel(
        id: map['id']?.toString() ?? '',
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        color: _cleanColor(map['color']),
        ownerId: map['ownerId']?.toString() ?? '',
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        isSynced: map['isSynced'] == true || map['isSynced'] == 1,
      );

  static String _cleanColor(dynamic color) {
    if (color == null) return '#2563EB';
    String c = color.toString().trim();
    if (!c.startsWith('#')) c = '#$c';
    final hex = c.replaceAll('#', '');
    if (hex.length != 6 || !RegExp(r'^[0-9A-Fa-f]+$').hasMatch(hex)) {
      return '#2563EB';
    }
    return c;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'color': color,
        'ownerId': ownerId,
        'createdAt': createdAt.toIso8601String(),
        'isSynced': isSynced ? 1 : 0,
      };

  Map<String, dynamic> toApiMapForCreate() => {
        'name': name,
        'description': description,
        'color': color,
        'ownerId': ownerId,
        'createdAt': createdAt.toIso8601String(),
      };

  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? ownerId,
    DateTime? createdAt,
    bool? isSynced,
  }) =>
      ProjectModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        color: color ?? this.color,
        ownerId: ownerId ?? this.ownerId,
        createdAt: createdAt ?? this.createdAt,
        isSynced: isSynced ?? this.isSynced,
      );

  Color get colorValue {
    try {
      final hex = color.replaceAll('#', '').trim();
      if (hex.length != 6) return const Color(0xFF2563EB);
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF2563EB);
    }
  }
}
