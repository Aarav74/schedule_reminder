import 'dart:convert';
import 'package:dio/dio.dart';
import '../../models/task_model.dart';
import '../../models/ai_config_model.dart';
import '../../core/utils/date_time_utils.dart';
import 'ai_service_interface.dart';

class GeminiService implements AIServiceInterface {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String _defaultModel = 'gemini-pro';
  static const int _defaultMaxTokens = 1024;
  static const double _defaultTemperature = 0.7;

  String? _apiKey;
  String _model = _defaultModel;
  int _maxTokens = _defaultMaxTokens;
  double _temperature = _defaultTemperature;
  int _totalCalls = 0;
  int _successfulCalls = 0;
  double _totalResponseTime = 0.0;
  int _rateLimitRemaining = 60;
  DateTime? _rateLimitReset;

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  @override
  Future<AIScheduleResponse> generateSchedule({
    required String prompt,
    required List<TaskModel> existingTasks,
    Map<String, dynamic>? preferences,
  }) async {
    if (!isConfigured()) {
      return AIScheduleResponse(
        success: false,
        error: 'Gemini API key not configured',
      );
    }

    final startTime = DateTime.now();

    try {
      final requestBody = _buildScheduleRequest(prompt, existingTasks, preferences);
      final response = await _makeRequest(requestBody);

      if (response.statusCode == 200) {
        final responseData = response.data;
        final generatedText = _extractTextFromResponse(responseData);

        if (generatedText.isEmpty) {
          throw AIServiceException(
            message: 'Empty response from Gemini API',
            code: AIServiceErrorCodes.invalidResponse,
          );
        }

        final tasks = await parseScheduleResponse(generatedText);

        final endTime = DateTime.now();
        final processingTime = endTime.difference(startTime).inMilliseconds / 1000.0;

        _updateStats(true, processingTime);

        return AIScheduleResponse(
          success: true,
          tasks: tasks,
          rawResponse: generatedText,
          processingTime: processingTime,
          metadata: {
            'model': _model,
            'tokensUsed': responseData['usageMetadata']?['totalTokenCount'] ?? 0,
            'provider': 'gemini',
          },
        );
      } else {
        final errorData = response.data;
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        throw AIServiceException(
          message: errorMessage,
          code: errorData['error']?['code']?.toString(),
          details: errorData,
        );
      }
    } catch (e) {
      _updateStats(false, 0);
      
      if (e is AIServiceException) throw e;
      
      throw AIServiceException(
        message: 'Failed to generate schedule: ${e.toString()}',
        code: AIServiceErrorCodes.unknownError,
        details: {'error': e.toString()},
      );
    }
  }

  @override
  Future<AIResponseModel> generateResponse({
    required String prompt,
    Map<String, dynamic>? parameters,
  }) async {
    if (!isConfigured()) {
      throw AIServiceException(
        message: 'Gemini API key not configured',
        code: AIServiceErrorCodes.invalidApiKey,
      );
    }

    final startTime = DateTime.now();

    try {
      final requestBody = _buildTextRequest(prompt, parameters);
      final response = await _makeRequest(requestBody);

      if (response.statusCode == 200) {
        final responseData = response.data;
        final generatedText = _extractTextFromResponse(responseData);

        final endTime = DateTime.now();
        final responseTime = endTime.difference(startTime).inMilliseconds / 1000.0;
        _updateStats(true, responseTime);

        return AIResponseModel(
          prompt: prompt,
          response: generatedText,
          provider: AIProvider.gemini,
          responseTime: responseTime,
          success: true,
          tokensUsed: responseData['usageMetadata']?['totalTokenCount'] ?? 0,
          metadata: {
            'model': _model,
            'temperature': _temperature,
          },
        );
      } else {
        final errorData = response.data;
        throw AIServiceException(
          message: errorData['error']?['message'] ?? 'Request failed',
          code: errorData['error']?['code']?.toString(),
          details: errorData,
        );
      }
    } catch (e) {
      _updateStats(false, 0);
      
      if (e is AIServiceException) throw e;
      
      throw AIServiceException(
        message: 'Failed to generate response: ${e.toString()}',
        code: AIServiceErrorCodes.unknownError,
        details: {'error': e.toString()},
      );
    }
  }

  @override
  Future<List<TaskModel>> parseScheduleResponse(String response) async {
    try {
      // Extract JSON from response
      final jsonStr = _extractJsonFromText(response);
      
      if (jsonStr.isEmpty) {
        throw AIServiceException(
          message: 'No valid JSON found in response',
          code: AIServiceErrorCodes.parsingError,
        );
      }

      final data = json.decode(jsonStr);
      
      if (data is Map<String, dynamic> && data.containsKey('tasks')) {
        final tasks = data['tasks'] as List;
        return tasks.map((taskJson) => _parseTaskFromJson(taskJson)).toList();
      } else if (data is List) {
        return data.map((taskJson) => _parseTaskFromJson(taskJson)).toList();
      } else {
        throw AIServiceException(
          message: 'Invalid response format: Expected list of tasks',
          code: AIServiceErrorCodes.parsingError,
        );
      }
    } catch (e) {
      if (e is AIServiceException) throw e;
      
      throw AIServiceException(
        message: 'Failed to parse schedule response: ${e.toString()}',
        code: AIServiceErrorCodes.parsingError,
        details: {'response': response},
      );
    }
  }

  @override
  String getServiceName() => 'Google Gemini AI';

  @override
  AIProvider getProvider() => AIProvider.gemini;

  @override
  Future<bool> validateApiKey(String apiKey) async {
    if (apiKey.isEmpty) return false;
    
    try {
      // Make a minimal request to validate API key
      final response = await _dio.post(
        '$_baseUrl/models',
        queryParameters: {'key': apiKey},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  bool isConfigured() {
    return _apiKey != null && _apiKey!.isNotEmpty;
  }

  @override
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  @override
  List<String> getAvailableModels() {
    return ['gemini-pro', 'gemini-ultra', 'gemini-pro-vision'];
  }

  @override
  String getCurrentModel() => _model;

  @override
  void setModel(String model) {
    if (getAvailableModels().contains(model)) {
      _model = model;
    }
  }

  @override
  RateLimit getRateLimit() {
    return RateLimit(
      maxRequests: 60,
      currentRequests: 60 - _rateLimitRemaining,
      resetTimeSeconds: _rateLimitReset != null
          ? _rateLimitReset!.difference(DateTime.now()).inSeconds
          : 3600,
      resetTime: _rateLimitReset,
    );
  }

  @override
  ServiceCost getServiceCost() {
    // Gemini pricing (approximately)
    final costPerToken = 0.0001; // $0.0001 per 1K tokens
    final totalTokens = _totalCalls * 1000; // Approximate
    return ServiceCost(
      costPerToken: costPerToken,
      costPerRequest: 0.001, // $0.001 per request
      totalCost: totalTokens * costPerToken / 1000,
      currency: 'USD',
      totalTokens: totalTokens,
      totalRequests: _totalCalls,
    );
  }

  @override
  void resetService() {
    _totalCalls = 0;
    _successfulCalls = 0;
    _totalResponseTime = 0.0;
    _rateLimitRemaining = 60;
    _rateLimitReset = null;
  }

  @override
  Future<ServiceStatus> getServiceStatus() async {
    return ServiceStatus(
      isAvailable: true,
      isConfigured: isConfigured(),
      isRateLimited: _rateLimitRemaining <= 0,
      remainingRequests: _rateLimitRemaining,
      resetTime: _rateLimitReset,
      statusMessage: _getStatusMessage(),
      details: {
        'model': _model,
        'totalCalls': _totalCalls,
        'successRate': _successfulCalls > 0 && _totalCalls > 0
            ? (_successfulCalls / _totalCalls * 100).round()
            : 100,
        'averageResponseTime': _totalCalls > 0
            ? (_totalResponseTime / _totalCalls).toStringAsFixed(2)
            : '0.00',
      },
    );
  }

  // ============ PRIVATE METHODS ============

  Map<String, dynamic> _buildScheduleRequest(
    String prompt,
    List<TaskModel> existingTasks,
    Map<String, dynamic>? preferences,
  ) {
    final promptText = _buildPrompt(prompt, existingTasks, preferences);
    return {
      'contents': [
        {
          'parts': [
            {
              'text': promptText,
            }
          ],
        }
      ],
      'generationConfig': {
        'temperature': _temperature,
        'maxOutputTokens': _maxTokens,
        'topP': 0.95,
        'topK': 40,
      },
    };
  }

  Map<String, dynamic> _buildTextRequest(
    String prompt,
    Map<String, dynamic>? parameters,
  ) {
    return {
      'contents': [
        {
          'parts': [
            {
              'text': prompt,
            }
          ],
        }
      ],
      'generationConfig': {
        'temperature': parameters?['temperature'] ?? _temperature,
        'maxOutputTokens': parameters?['maxTokens'] ?? _maxTokens,
        'topP': parameters?['topP'] ?? 0.95,
        'topK': parameters?['topK'] ?? 40,
      },
    };
  }

  String _buildPrompt(
    String prompt,
    List<TaskModel> existingTasks,
    Map<String, dynamic>? preferences,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('You are an AI schedule assistant. Create a daily schedule based on the following:');
    buffer.writeln();
    buffer.writeln('User Request: $prompt');
    buffer.writeln();

    if (existingTasks.isNotEmpty) {
      buffer.writeln('Existing Tasks:');
      for (final task in existingTasks) {
        buffer.writeln(
          '- ${task.title} (${DateTimeUtils.formatTime12h(task.startTime)} - ${DateTimeUtils.formatTime12h(task.endTime)}) '
          '[${task.priority.displayName} priority] [${task.category.displayName}]'
        );
      }
      buffer.writeln();
    }

    if (preferences != null && preferences.isNotEmpty) {
      buffer.writeln('User Preferences:');
      preferences.forEach((key, value) {
        buffer.writeln('- $key: $value');
      });
      buffer.writeln();
    }

    buffer.writeln('Please generate a schedule in JSON format with the following structure:');
    buffer.writeln('{');
    buffer.writeln('  "tasks": [');
    buffer.writeln('    {');
    buffer.writeln('      "title": "Task name",');
    buffer.writeln('      "description": "Task description",');
    buffer.writeln('      "startTime": "HH:MM",');
    buffer.writeln('      "endTime": "HH:MM",');
    buffer.writeln('      "priority": "low|medium|high",');
    buffer.writeln('      "category": "work|study|personal|health|exercise|social|entertainment|other"');
    buffer.writeln('    }');
    buffer.writeln('  ]');
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln('Important rules:');
    buffer.writeln('1. Times must be in 24-hour format (HH:MM)');
    buffer.writeln('2. Prioritize high priority tasks');
    buffer.writeln('3. Include appropriate break times');
    buffer.writeln('4. Consider task duration and dependencies');
    buffer.writeln('5. Only return the JSON, no additional text');

    return buffer.toString();
  }

  Future<Response<dynamic>> _makeRequest(Map<String, dynamic> body) async {
    final url = '$_baseUrl/models/$_model:generateContent?key=$_apiKey';
    
    try {
      final response = await _dio.post(
        url,
        data: body,
      );
      return response;
    } on DioException catch (e) {
      if (e.response != null) {
        throw AIServiceException(
          message: 'API request failed with status: ${e.response?.statusCode}',
          code: e.response?.statusCode?.toString(),
          details: e.response?.data,
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw AIServiceException(
          message: 'Connection timeout',
          code: AIServiceErrorCodes.timeoutError,
        );
      } else {
        throw AIServiceException(
          message: 'Network error: ${e.message}',
          code: AIServiceErrorCodes.networkError,
        );
      }
    } catch (e) {
      throw AIServiceException(
        message: 'Unexpected error: ${e.toString()}',
        code: AIServiceErrorCodes.unknownError,
      );
    }
  }

  String _extractTextFromResponse(Map<String, dynamic> response) {
    try {
      final candidates = response['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        return '';
      }

      final content = candidates.first['content'] as Map<String, dynamic>?;
      if (content == null) return '';

      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) return '';

      return parts.first['text'] as String? ?? '';
    } catch (e) {
      return '';
    }
  }

  String _extractJsonFromText(String text) {
    // Try to find JSON between ```json and ``` markers
    final jsonRegex = RegExp(r'```json\s*([\s\S]*?)\s*```', caseSensitive: false);
    final match = jsonRegex.firstMatch(text);
    if (match != null) {
      return match.group(1) ?? '';
    }

    // Try to find JSON between { and } with balanced braces
    final start = text.indexOf('{');
    if (start == -1) return '';
    
    var braceCount = 0;
    var end = start;
    for (var i = start; i < text.length; i++) {
      if (text[i] == '{') braceCount++;
      if (text[i] == '}') braceCount--;
      if (braceCount == 0) {
        end = i + 1;
        break;
      }
    }
    
    if (braceCount != 0) return '';
    return text.substring(start, end);
  }

  TaskModel _parseTaskFromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final startTime = _parseTime(json['startTime'] as String?);
    final endTime = _parseTime(json['endTime'] as String?);

    return TaskModel(
      title: json['title'] as String? ?? 'Untitled Task',
      description: json['description'] as String? ?? '',
      startTime: startTime ?? DateTime(now.year, now.month, now.day, 9, 0),
      endTime: endTime ?? DateTime(now.year, now.month, now.day, 10, 0),
      priority: _parsePriority(json['priority'] as String?),
      category: _parseCategory(json['category'] as String?),
      isAIGenerated: true,
      status: TaskStatus.pending,
      hasAlarm: true,
    );
  }

  DateTime? _parseTime(String? timeStr) {
    if (timeStr == null) return null;
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, hour, minute);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Priority _parsePriority(String? priority) {
    if (priority == null) return Priority.medium;
    switch (priority.toLowerCase()) {
      case 'low':
        return Priority.low;
      case 'high':
        return Priority.high;
      default:
        return Priority.medium;
    }
  }

  TaskCategory _parseCategory(String? category) {
    if (category == null) return TaskCategory.other;
    return TaskCategoryExtension.fromString(category);
  }

  void _updateStats(bool success, double responseTime) {
    _totalCalls++;
    if (success) {
      _successfulCalls++;
      _totalResponseTime += responseTime;
    }
    
    // Update rate limit
    _rateLimitRemaining--;
    if (_rateLimitRemaining <= 0) {
      _rateLimitReset = DateTime.now().add(const Duration(hours: 1));
    }
  }

  String _getStatusMessage() {
    if (!isConfigured()) return 'Not configured';
    if (_rateLimitRemaining <= 0) return 'Rate limited';
    if (_totalCalls == 0) return 'Ready';
    return 'Active';
  }
}