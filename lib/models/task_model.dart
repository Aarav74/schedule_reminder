enum TaskStatus {
  pending,
  completed,
  missed,
}

enum Priority {
  low,
  medium,
  high,
}

extension PriorityExtension on Priority {
  String get displayName {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }
}

enum TaskCategory {
  work,
  study,
  personal,
  health,
  exercise,
  social,
  entertainment,
  other,
}

extension TaskCategoryExtension on TaskCategory {
  String get displayName {
    switch (this) {
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.study:
        return 'Study';
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.health:
        return 'Health';
      case TaskCategory.exercise:
        return 'Exercise';
      case TaskCategory.social:
        return 'Social';
      case TaskCategory.entertainment:
        return 'Entertainment';
      case TaskCategory.other:
        return 'Other';
    }
  }

  static TaskCategory fromString(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return TaskCategory.work;
      case 'study':
        return TaskCategory.study;
      case 'personal':
        return TaskCategory.personal;
      case 'health':
        return TaskCategory.health;
      case 'exercise':
        return TaskCategory.exercise;
      case 'social':
        return TaskCategory.social;
      case 'entertainment':
        return TaskCategory.entertainment;
      default:
        return TaskCategory.other;
    }
  }
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final Priority priority;
  final TaskCategory category;
  final bool isAIGenerated;
  final TaskStatus status;
  final bool hasAlarm;

  TaskModel({
    String? id,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    this.priority = Priority.medium,
    this.category = TaskCategory.other,
    this.isAIGenerated = false,
    this.status = TaskStatus.pending,
    this.hasAlarm = false,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  int get durationInMinutes => endTime.difference(startTime).inMinutes;

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    Priority? priority,
    TaskCategory? category,
    bool? isAIGenerated,
    TaskStatus? status,
    bool? hasAlarm,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      status: status ?? this.status,
      hasAlarm: hasAlarm ?? this.hasAlarm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'priority': priority.name,
      'category': category.name,
      'isAIGenerated': isAIGenerated,
      'status': status.name,
      'hasAlarm': hasAlarm,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      priority: Priority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => Priority.medium,
      ),
      category: TaskCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TaskCategory.other,
      ),
      isAIGenerated: json['isAIGenerated'] ?? false,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      hasAlarm: json['hasAlarm'] ?? false,
    );
  }
}