import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import '../services/ai_services/ai_service_factory.dart';

class AIProvider with ChangeNotifier {
  String _provider = 'gemini';
  String _apiKey = '';
  bool _isLoading = false;
  String? _error;
  List<TaskModel> _generatedTasks = [];
  bool? _isTestSuccess;

  // Getters
  String get provider => _provider;
  String get apiKey => _apiKey;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TaskModel> get generatedTasks => _generatedTasks;
  bool? get isTestSuccess => _isTestSuccess;

  AIProvider() {
    loadConfig();
  }

  // Load config from SharedPreferences
  Future<void> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _provider = prefs.getString('ai_provider') ?? 'gemini';
      _apiKey = prefs.getString('ai_api_key') ?? '';
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load configuration: $e';
      notifyListeners();
    }
  }

  // Save config to SharedPreferences
  Future<bool> saveConfig(String provider, String apiKey) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ai_provider', provider);
      await prefs.setString('ai_api_key', apiKey);
      _provider = provider;
      _apiKey = apiKey;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to save configuration: $e';
      notifyListeners();
      return false;
    }
  }

  // Test API key connection without saving
  Future<bool> testConnection(String testProvider, String testApiKey) async {
    _isLoading = true;
    _error = null;
    _isTestSuccess = null;
    notifyListeners();

    try {
      final service = AIServiceFactory.getService(testProvider);
      final success = await service.validateApiKey(testApiKey);
      _isTestSuccess = success;
      if (!success) {
        _error = 'API key validation failed. Please verify and try again.';
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _isTestSuccess = false;
      _error = 'Error testing connection: $e';
      notifyListeners();
      return false;
    }
  }

  // Generate schedule using current provider and key
  Future<bool> generateScheduleFromPrompt(String prompt, List<TaskModel> existingTasks) async {
    if (_apiKey.isEmpty) {
      _error = 'Please configure your API key first.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final service = AIServiceFactory.getService(_provider);
      service.setApiKey(_apiKey);
      final response = await service.generateSchedule(
        prompt: prompt,
        existingTasks: existingTasks,
      );

      if (response.success && response.tasks != null) {
        _generatedTasks = response.tasks!;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _error = response.error ?? 'Failed to generate schedule';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to generate schedule: $e';
      notifyListeners();
      return false;
    }
  }

  // Toggle alarm for an item in generated tasks
  void toggleAlarm(int index) {
    if (index >= 0 && index < _generatedTasks.length) {
      final item = _generatedTasks[index];
      _generatedTasks[index] = item.copyWith(hasAlarm: !item.hasAlarm);
      notifyListeners();
    }
  }

  // Remove an item from the generated tasks preview
  void removeGeneratedTaskItem(int index) {
    if (index >= 0 && index < _generatedTasks.length) {
      _generatedTasks.removeAt(index);
      notifyListeners();
    }
  }

  // Clear preview list
  void clearGeneratedTasks() {
    _generatedTasks = [];
    _error = null;
    notifyListeners();
  }

  // Clear connection test status
  void clearTestStatus() {
    _isTestSuccess = null;
    _error = null;
    notifyListeners();
  }
}
