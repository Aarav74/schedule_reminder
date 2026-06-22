import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule_model.dart';
import '../models/task_model.dart';
import '../core/utils/date_time_utils.dart';

class ScheduleProvider with ChangeNotifier {
  List<ScheduleModel> _schedules = [];

  List<ScheduleModel> get schedules => _schedules;

  ScheduleProvider() {
    loadSchedules();
  }

  // Load schedules from SharedPreferences
  Future<void> loadSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedulesString = prefs.getString('user_schedules_v2') ?? '[]';
      final List<dynamic> jsonList = jsonDecode(schedulesString);
      
      _schedules = jsonList.map((jsonItem) => ScheduleModel.fromJson(jsonItem)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading schedules: $e');
    }
  }

  // Save schedules to SharedPreferences
  Future<void> saveSchedulesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _schedules.map((item) => item.toJson()).toList();
      await prefs.setString('user_schedules_v2', jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving schedules: $e');
    }
  }

  // Get or create daily schedule for a date
  ScheduleModel getOrCreateScheduleForDate(DateTime date) {
    final index = _schedules.indexWhere((s) => DateTimeUtils.isSameDay(s.date, date));
    if (index != -1) {
      return _schedules[index];
    }
    
    // Create new daily schedule
    final newSchedule = ScheduleModel(
      date: DateTime(date.year, date.month, date.day),
      tasks: [],
    );
    _schedules.add(newSchedule);
    saveSchedulesToStorage();
    return newSchedule;
  }

  // Add tasks to a specific date
  void addTasksToDate(DateTime date, List<TaskModel> newTasks) {
    final schedule = getOrCreateScheduleForDate(date);
    var updatedSchedule = schedule;
    for (final task in newTasks) {
      updatedSchedule = updatedSchedule.addTask(task);
    }
    
    // Update list
    final index = _schedules.indexWhere((s) => DateTimeUtils.isSameDay(s.date, date));
    if (index != -1) {
      _schedules[index] = updatedSchedule;
      saveSchedulesToStorage();
      notifyListeners();
    }
  }

  // Remove task from a specific date
  void removeTaskFromDate(DateTime date, String taskId) {
    final index = _schedules.indexWhere((s) => DateTimeUtils.isSameDay(s.date, date));
    if (index != -1) {
      _schedules[index] = _schedules[index].removeTask(taskId);
      saveSchedulesToStorage();
      notifyListeners();
    }
  }

  // Toggle completion of a task
  void toggleTaskComplete(DateTime date, String taskId) {
    final index = _schedules.indexWhere((s) => DateTimeUtils.isSameDay(s.date, date));
    if (index != -1) {
      final schedule = _schedules[index];
      final taskIndex = schedule.tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex != -1) {
        final task = schedule.tasks[taskIndex];
        final updatedTask = task.copyWith(
          status: task.status == TaskStatus.completed ? TaskStatus.pending : TaskStatus.completed,
        );
        _schedules[index] = schedule.updateTask(updatedTask);
        saveSchedulesToStorage();
        notifyListeners();
      }
    }
  }

  // Toggle alarm of a task
  void toggleTaskAlarm(DateTime date, String taskId) {
    final index = _schedules.indexWhere((s) => DateTimeUtils.isSameDay(s.date, date));
    if (index != -1) {
      final schedule = _schedules[index];
      final taskIndex = schedule.tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex != -1) {
        final task = schedule.tasks[taskIndex];
        final updatedTask = task.copyWith(hasAlarm: !task.hasAlarm);
        _schedules[index] = schedule.updateTask(updatedTask);
        saveSchedulesToStorage();
        notifyListeners();
      }
    }
  }

  // Clear all schedules
  void clearAllSchedules() {
    _schedules.clear();
    saveSchedulesToStorage();
    notifyListeners();
  }
}
