enum TaskStatus { todo, inProgress, done }

enum TaskPriority { low, medium, high }

extension TaskStatusExt on TaskStatus {
  String get value {
    switch (this) {
      case TaskStatus.todo:
        return 'todo';
      case TaskStatus.inProgress:
        return 'inProgress';
      case TaskStatus.done:
        return 'done';
    }
  }

  static TaskStatus fromString(String s) {
    switch (s) {
      case 'inProgress':
        return TaskStatus.inProgress;
      case 'done':
        return TaskStatus.done;
      default:
        return TaskStatus.todo;
    }
  }
}

extension TaskPriorityExt on TaskPriority {
  String get value {
    switch (this) {
      case TaskPriority.low:
        return 'low';
      case TaskPriority.medium:
        return 'medium';
      case TaskPriority.high:
        return 'high';
    }
  }

  static TaskPriority fromString(String s) {
    switch (s) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String projectId;
  final String creatorId;
  final String? assigneeId;
  final DateTime? dueDate;
  final DateTime createdAt;
  final bool isSynced;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.projectId,
    required this.creatorId,
    this.assigneeId,
    this.dueDate,
    required this.createdAt,
    this.isSynced = false,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) => TaskModel(
        id: map['id']?.toString() ?? '',
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        status:
            TaskStatusExt.fromString(map['status']?.toString() ?? 'todo'),
        priority:
            TaskPriorityExt.fromString(map['priority']?.toString() ?? 'medium'),
        projectId: map['projectId']?.toString() ?? '',
        creatorId: map['creatorId']?.toString() ?? '',
        assigneeId: map['assigneeId']?.toString(),
        dueDate: map['dueDate'] != null && map['dueDate'].toString().isNotEmpty
            ? DateTime.tryParse(map['dueDate'].toString())
            : null,
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        isSynced: (map['isSynced'] == 1 || map['isSynced'] == true),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status.value,
        'priority': priority.value,
        'projectId': projectId,
        'creatorId': creatorId,
        'assigneeId': assigneeId,
        'dueDate': dueDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'isSynced': isSynced ? 1 : 0,
      };

  Map<String, dynamic> toApiMap() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status.value,
        'priority': priority.value,
        'projectId': projectId,
        'creatorId': creatorId,
        'assigneeId': assigneeId,
        'dueDate': dueDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  Map<String, dynamic> toApiMapForCreate() => {
        'title': title,
        'description': description,
        'status': status.value,
        'priority': priority.value,
        'projectId': projectId,
        'creatorId': creatorId,
        'assigneeId': assigneeId,
        'dueDate': dueDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? projectId,
    String? creatorId,
    String? assigneeId,
    DateTime? dueDate,
    DateTime? createdAt,
    bool? isSynced,
    bool clearAssignee = false,
    bool clearDueDate = false,
  }) =>
      TaskModel(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        projectId: projectId ?? this.projectId,
        creatorId: creatorId ?? this.creatorId,
        assigneeId: clearAssignee ? null : (assigneeId ?? this.assigneeId),
        dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
        createdAt: createdAt ?? this.createdAt,
        isSynced: isSynced ?? this.isSynced,
      );

  bool get isOverdue =>
      dueDate != null &&
      dueDate!.isBefore(DateTime.now()) &&
      status != TaskStatus.done;
}
