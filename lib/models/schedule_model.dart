import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'task_model.dart';

part 'schedule_model.g.dart';

@HiveType(typeId: 1)
class ScheduleModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final List<TaskModel> tasks;

  @HiveField(3)
  final int totalTasks;

  @HiveField(4)
  final int completedTasks;

  @HiveField(5)
  final int pendingTasks;

  @HiveField(6)
  final int missedTasks;

  @HiveField(7)
  final double completionPercentage;

  @HiveField(8)
  final int totalDuration; // in minutes

  @HiveField(9)
  final int productiveHours; // in minutes

  @HiveField(10)
  final int breakHours; // in minutes

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  @HiveField(13)
  final bool isAIGenerated;

  @HiveField(14)
  final String? aiPrompt;

  @HiveField(15)
  final String? aiProvider;

  @HiveField(16)
  final Map<String, dynamic>? metadata;

  @HiveField(17)
  final List<String>? notes;

  @HiveField(18)
  final List<String>? tags;

  ScheduleModel({
    String? id,
    required this.date,
    this.tasks = const [],
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.pendingTasks = 0,
    this.missedTasks = 0,
    this.completionPercentage = 0.0,
    this.totalDuration = 0,
    this.productiveHours = 0,
    this.breakHours = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isAIGenerated = false,
    this.aiPrompt,
    this.aiProvider,
    this.metadata,
    this.notes,
    this.tags,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ============ COMPUTED PROPERTIES ============
  bool get isEmpty => tasks.isEmpty;
  
  bool get isNotEmpty => tasks.isNotEmpty;
  
  bool get isComplete => completionPercentage == 100.0;
  
  bool get hasProgress => completionPercentage > 0 && completionPercentage < 100;
  
  String get completionStatus {
    if (isComplete) return 'Complete';
    if (hasProgress) return 'In Progress';
    return 'Not Started';
  }

  Color get completionColor {
    if (isComplete) return Colors.green;
    if (hasProgress) return Colors.orange;
    return Colors.grey;
  }

  int get totalTasksCount => tasks.length;
  
  int get completedTasksCount => tasks.where((t) => t.status == TaskStatus.completed).length;
  
  int get pendingTasksCount => tasks.where((t) => t.status == TaskStatus.pending).length;
  
  int get missedTasksCount => tasks.where((t) => t.status == TaskStatus.missed).length;
  
  int get highPriorityTasks => tasks.where((t) => t.priority == Priority.high).length;
  
  int get mediumPriorityTasks => tasks.where((t) => t.priority == Priority.medium).length;
  
  int get lowPriorityTasks => tasks.where((t) => t.priority == Priority.low).length;

  Duration get totalDurationDuration => Duration(minutes: totalDuration);
  
  Duration get productiveDuration => Duration(minutes: productiveHours);
  
  Duration get breakDuration => Duration(minutes: breakHours);

  double get efficiencyScore {
    if (totalDuration == 0) return 0.0;
    return (productiveHours / totalDuration) * 100;
  }

  // ============ JSON SERIALIZATION ============
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'tasks': tasks.map((t) => t.toJson()).toList(),
    'totalTasks': totalTasks,
    'completedTasks': completedTasks,
    'pendingTasks': pendingTasks,
    'missedTasks': missedTasks,
    'completionPercentage': completionPercentage,
    'totalDuration': totalDuration,
    'productiveHours': productiveHours,
    'breakHours': breakHours,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isAIGenerated': isAIGenerated,
    'aiPrompt': aiPrompt,
    'aiProvider': aiProvider,
    'metadata': metadata,
    'notes': notes,
    'tags': tags,
  };

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => ScheduleModel(
    id: json['id'],
    date: DateTime.parse(json['date']),
    tasks: (json['tasks'] as List)
        .map((t) => TaskModel.fromJson(t))
        .toList(),
    totalTasks: json['totalTasks'] ?? 0,
    completedTasks: json['completedTasks'] ?? 0,
    pendingTasks: json['pendingTasks'] ?? 0,
    missedTasks: json['missedTasks'] ?? 0,
    completionPercentage: json['completionPercentage'] ?? 0.0,
    totalDuration: json['totalDuration'] ?? 0,
    productiveHours: json['productiveHours'] ?? 0,
    breakHours: json['breakHours'] ?? 0,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    isAIGenerated: json['isAIGenerated'] ?? false,
    aiPrompt: json['aiPrompt'],
    aiProvider: json['aiProvider'],
    metadata: json['metadata'],
    notes: json['notes'] != null ? List<String>.from(json['notes']) : null,
    tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
  );

  // ============ COPY WITH ============
  ScheduleModel copyWith({
    String? id,
    DateTime? date,
    List<TaskModel>? tasks,
    int? totalTasks,
    int? completedTasks,
    int? pendingTasks,
    int? missedTasks,
    double? completionPercentage,
    int? totalDuration,
    int? productiveHours,
    int? breakHours,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAIGenerated,
    String? aiPrompt,
    String? aiProvider,
    Map<String, dynamic>? metadata,
    List<String>? notes,
    List<String>? tags,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      date: date ?? this.date,
      tasks: tasks ?? this.tasks,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      pendingTasks: pendingTasks ?? this.pendingTasks,
      missedTasks: missedTasks ?? this.missedTasks,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      totalDuration: totalDuration ?? this.totalDuration,
      productiveHours: productiveHours ?? this.productiveHours,
      breakHours: breakHours ?? this.breakHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      aiPrompt: aiPrompt ?? this.aiPrompt,
      aiProvider: aiProvider ?? this.aiProvider,
      metadata: metadata ?? this.metadata,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
    );
  }

  // ============ HELPER METHODS ============
  ScheduleModel recalculateStats() {
    final tasksList = tasks;
    final completed = tasksList.where((t) => t.status == TaskStatus.completed).length;
    final pending = tasksList.where((t) => t.status == TaskStatus.pending).length;
    final missed = tasksList.where((t) => t.status == TaskStatus.missed).length;
    final total = tasksList.length;
    final percentage = total > 0 ? (completed / total) * 100 : 0.0;
    
    // Calculate durations
    int totalDur = 0;
    int productive = 0;
    int breaks = 0;
    
    for (final task in tasksList) {
      final duration = task.durationInMinutes;
      totalDur += duration;
      
      // Consider high and medium priority tasks as productive
      if (task.priority == Priority.high || task.priority == Priority.medium) {
        productive += duration;
      } else {
        breaks += duration;
      }
    }

    return copyWith(
      totalTasks: total,
      completedTasks: completed,
      pendingTasks: pending,
      missedTasks: missed,
      completionPercentage: percentage,
      totalDuration: totalDur,
      productiveHours: productive,
      breakHours: breaks,
      updatedAt: DateTime.now(),
    );
  }

  ScheduleModel addTask(TaskModel task) {
    final newTasks = List<TaskModel>.from(tasks)..add(task);
    return copyWith(tasks: newTasks).recalculateStats();
  }

  ScheduleModel removeTask(String taskId) {
    final newTasks = tasks.where((t) => t.id != taskId).toList();
    return copyWith(tasks: newTasks).recalculateStats();
  }

  ScheduleModel updateTask(TaskModel updatedTask) {
    final index = tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index == -1) return this;
    
    final newTasks = List<TaskModel>.from(tasks);
    newTasks[index] = updatedTask;
    return copyWith(tasks: newTasks).recalculateStats();
  }

  List<TaskModel> getTasksByPriority(Priority priority) {
    return tasks.where((t) => t.priority == priority).toList();
  }

  List<TaskModel> getTasksByCategory(TaskCategory category) {
    return tasks.where((t) => t.category == category).toList();
  }

  List<TaskModel> getTasksByStatus(TaskStatus status) {
    return tasks.where((t) => t.status == status).toList();
  }

  List<TaskModel> getTasksByDate(DateTime date) {
    return tasks.where((t) => 
      t.startTime.year == date.year &&
      t.startTime.month == date.month &&
      t.startTime.day == date.day
    ).toList();
  }

  // ============ EQUALITY & HASHCODE ============
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ScheduleModel(date: ${date.toLocal()}, tasks: ${tasks.length}, completion: ${completionPercentage.toStringAsFixed(1)}%)';
  }
}

// ============ SCHEDULE SUMMARY ============
class ScheduleSummary {
  final DateTime date;
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int missedTasks;
  final double completionPercentage;
  final int totalDuration;
  final int productiveHours;
  final int breakHours;
  final double efficiencyScore;

  ScheduleSummary({
    required this.date,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.missedTasks,
    required this.completionPercentage,
    required this.totalDuration,
    required this.productiveHours,
    required this.breakHours,
    required this.efficiencyScore,
  });

  factory ScheduleSummary.fromScheduleModel(ScheduleModel schedule) {
    return ScheduleSummary(
      date: schedule.date,
      totalTasks: schedule.totalTasks,
      completedTasks: schedule.completedTasks,
      pendingTasks: schedule.pendingTasks,
      missedTasks: schedule.missedTasks,
      completionPercentage: schedule.completionPercentage,
      totalDuration: schedule.totalDuration,
      productiveHours: schedule.productiveHours,
      breakHours: schedule.breakHours,
      efficiencyScore: schedule.efficiencyScore,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'totalTasks': totalTasks,
    'completedTasks': completedTasks,
    'pendingTasks': pendingTasks,
    'missedTasks': missedTasks,
    'completionPercentage': completionPercentage,
    'totalDuration': totalDuration,
    'productiveHours': productiveHours,
    'breakHours': breakHours,
    'efficiencyScore': efficiencyScore,
  };
}