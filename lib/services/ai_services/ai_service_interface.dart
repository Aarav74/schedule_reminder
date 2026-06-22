import '../../models/task_model.dart';
import '../../models/ai_config_model.dart';

abstract class AIServiceInterface {
  Future<AIScheduleResponse> generateSchedule({
    required String prompt,
    required List<TaskModel> existingTasks,
    Map<String, dynamic>? preferences,
  });

  Future<AIResponseModel> generateResponse({
    required String prompt,
    Map<String, dynamic>? parameters,
  });

  Future<List<TaskModel>> parseScheduleResponse(String response);

  String getServiceName();

  AIProvider getProvider();

  Future<bool> validateApiKey(String apiKey);

  bool isConfigured();

  void setApiKey(String apiKey);

  List<String> getAvailableModels();

  String getCurrentModel();

  void setModel(String model);

  RateLimit getRateLimit();

  ServiceCost getServiceCost();

  void resetService();

  Future<ServiceStatus> getServiceStatus();
}

class AIScheduleResponse {
  final bool success;
  final List<TaskModel>? tasks;
  final String? rawResponse;
  final double? processingTime;
  final String? error;
  final Map<String, dynamic>? metadata;

  AIScheduleResponse({
    required this.success,
    this.tasks,
    this.rawResponse,
    this.processingTime,
    this.error,
    this.metadata,
  });
}

class AIResponseModel {
  final String prompt;
  final String response;
  final AIProvider provider;
  final double responseTime;
  final bool success;
  final int tokensUsed;
  final Map<String, dynamic>? metadata;

  AIResponseModel({
    required this.prompt,
    required this.response,
    required this.provider,
    required this.responseTime,
    required this.success,
    required this.tokensUsed,
    this.metadata,
  });
}

class AIServiceException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  AIServiceException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AIServiceException: $message (Code: $code)';
}

class AIServiceErrorCodes {
  static const String invalidResponse = 'invalidResponse';
  static const String invalidApiKey = 'invalidApiKey';
  static const String unknownError = 'unknownError';
  static const String parsingError = 'parsingError';
  static const String timeoutError = 'timeoutError';
  static const String networkError = 'networkError';
}

class RateLimit {
  final int maxRequests;
  final int currentRequests;
  final int resetTimeSeconds;
  final DateTime? resetTime;

  RateLimit({
    required this.maxRequests,
    required this.currentRequests,
    required this.resetTimeSeconds,
    this.resetTime,
  });
}

class ServiceCost {
  final double costPerToken;
  final double costPerRequest;
  final double totalCost;
  final String currency;
  final int totalTokens;
  final int totalRequests;

  ServiceCost({
    required this.costPerToken,
    required this.costPerRequest,
    required this.totalCost,
    required this.currency,
    required this.totalTokens,
    required this.totalRequests,
  });
}

class ServiceStatus {
  final bool isAvailable;
  final bool isConfigured;
  final bool isRateLimited;
  final int remainingRequests;
  final DateTime? resetTime;
  final String statusMessage;
  final Map<String, dynamic>? details;

  ServiceStatus({
    required this.isAvailable,
    required this.isConfigured,
    required this.isRateLimited,
    required this.remainingRequests,
    this.resetTime,
    required this.statusMessage,
    this.details,
  });
}
