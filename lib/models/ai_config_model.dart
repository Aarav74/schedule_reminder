enum AIProvider {
  gemini,
  openrouter,
}

class AIConfigModel {
  final AIProvider provider;
  final String apiKey;
  final String model;
  final double temperature;
  final int maxTokens;

  AIConfigModel({
    required this.provider,
    required this.apiKey,
    required this.model,
    this.temperature = 0.7,
    this.maxTokens = 1024,
  });

  AIConfigModel copyWith({
    AIProvider? provider,
    String? apiKey,
    String? model,
    double? temperature,
    int? maxTokens,
  }) {
    return AIConfigModel(
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.name,
      'apiKey': apiKey,
      'model': model,
      'temperature': temperature,
      'maxTokens': maxTokens,
    };
  }

  factory AIConfigModel.fromJson(Map<String, dynamic> json) {
    return AIConfigModel(
      provider: AIProvider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => AIProvider.gemini,
      ),
      apiKey: json['apiKey'] ?? '',
      model: json['model'] ?? '',
      temperature: json['temperature'] ?? 0.7,
      maxTokens: json['maxTokens'] ?? 1024,
    );
  }
}
