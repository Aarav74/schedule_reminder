class AppStrings {
  static const String appName = 'Schedule AI';
  
  // AI Config Screen Strings
  static const String aiConfigTitle = 'AI Configuration';
  static const String providerLabel = 'AI Provider';
  static const String apiKeyLabel = 'API Key';
  static const String apiKeyHint = 'Enter your API key';
  static const String saveConfig = 'Save Configuration';
  static const String configSavedSuccess = 'AI configuration saved successfully!';
  static const String apiKeyRequired = 'API Key is required';
  static const String testConnection = 'Test Connection';
  static const String testingConnection = 'Testing connection...';
  static const String connectionSuccess = 'Connection successful! Model response validated.';
  static const String connectionFailed = 'Connection failed. Please check your key.';
  
  // AI Schedule Screen Strings
  static const String aiScheduleTitle = 'AI Schedule Generator';
  static const String promptLabel = 'What do you want to plan today?';
  static const String promptHint = 'e.g., "Math study session from 9 AM to 11 AM, lunch at noon, gym workout at 5 PM for 1.5 hours."';
  static const String generateBtn = 'Generate Schedule';
  static const String generatingStatus = 'Analyzing and generating schedules...';
  static const String promptRequired = 'Please enter a description of your day.';
  
  // Preview Screen Strings
  static const String previewTitle = 'Generated Preview';
  static const String previewSubtitle = 'Verify and modify the items before saving';
  static const String saveAllSchedules = 'Add to My Schedule';
  static const String saveSchedulesSuccess = 'Schedules added successfully!';
  
  // General Errors
  static const String genericError = 'Something went wrong. Please try again.';
  static const String missingApiKeyError = 'API key is missing. Please configure it first.';
}
