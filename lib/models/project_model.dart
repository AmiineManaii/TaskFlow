import 'package:flutter/material.dart';

class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String color;
  final String ownerId;
  final List<String> memberIds;
  final DateTime createdAt;
  final bool isSynced;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.ownerId,
    this.memberIds = const [],
    required this.createdAt,
    this.isSynced = false,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    List<String> members = [];
    if (map['memberIds'] != null) {
      final rawMembers = map['memberIds'].toString();
      if (rawMembers.isNotEmpty) {
        members = rawMembers.split(',').where((m) => m.isNotEmpty).toList();
      }
    }

    return ProjectModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      color: _cleanColor(map['color']),
      ownerId: map['ownerId']?.toString() ?? '',
      memberIds: members,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isSynced: map['isSynced'] == true || map['isSynced'] == 1,
    );
  }

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
        'memberIds': memberIds.join(','),
        'createdAt': createdAt.toIso8601String(),
        'isSynced': isSynced ? 1 : 0,
      };

  Map<String, dynamic> toApiMapForCreate() => {
        'name': name,
        'description': description,
        'color': color,
        'ownerId': ownerId,
        'memberIds': memberIds.join(','),
        'createdAt': createdAt.toIso8601String(),
      };

  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? ownerId,
    List<String>? memberIds,
    DateTime? createdAt,
    bool? isSynced,
  }) =>
      ProjectModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        color: color ?? this.color,
        ownerId: ownerId ?? this.ownerId,
        memberIds: memberIds ?? this.memberIds,
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
