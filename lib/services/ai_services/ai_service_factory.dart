import 'ai_service_interface.dart';
import 'gemini_service.dart';
import 'openrouter_service.dart';

class AIServiceFactory {
  static AIServiceInterface getService(String provider) {
    switch (provider.toLowerCase()) {
      case 'gemini':
        return GeminiService();
      case 'openrouter':
        return OpenRouterService();
      default:
        throw Exception('Unsupported AI provider: $provider');
    }
  }
}
