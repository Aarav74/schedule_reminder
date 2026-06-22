import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/ai_provider.dart';
import 'widgets/api_key_input.dart';
import 'widgets/provider_selector.dart';

class AIConfigScreen extends StatefulWidget {
  const AIConfigScreen({super.key});

  @override
  State<AIConfigScreen> createState() => _AIConfigScreenState();
}

class _AIConfigScreenState extends State<AIConfigScreen> {
  late TextEditingController _apiKeyController;
  String _selectedProvider = 'gemini';

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    
    // Load existing config into fields
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final aiProvider = Provider.of<AIProvider>(context, listen: false);
      setState(() {
        _selectedProvider = aiProvider.provider;
        _apiKeyController.text = aiProvider.apiKey;
      });
      aiProvider.clearTestStatus();
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    if (_apiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.apiKeyRequired)),
      );
      return;
    }

    final success = await aiProvider.testConnection(
      _selectedProvider,
      _apiKeyController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? AppStrings.connectionSuccess : AppStrings.connectionFailed,
          ),
          backgroundColor: success ? AppColors.secondary : AppColors.error,
        ),
      );
    }
  }

  Future<void> _saveConfig() async {
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    if (_apiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.apiKeyRequired)),
      );
      return;
    }

    final success = await aiProvider.saveConfig(
      _selectedProvider,
      _apiKeyController.text.trim(),
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.configSavedSuccess),
          backgroundColor: AppColors.secondary,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = Provider.of<AIProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.aiConfigTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary, size: 28),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Text(
                        'Configure your AI provider and API keys below. Your keys are stored locally on your device.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Provider Selector
            ProviderSelector(
              selectedProvider: _selectedProvider,
              onProviderChanged: (provider) {
                setState(() {
                  _selectedProvider = provider;
                });
                aiProvider.clearTestStatus();
              },
            ),
            const SizedBox(height: AppDimensions.lg),

            // API Key Input
            ApiKeyInput(
              controller: _apiKeyController,
              provider: _selectedProvider,
              errorText: aiProvider.error,
            ),
            const SizedBox(height: AppDimensions.xl),

            // Connection status feedback
            if (aiProvider.isTestSuccess != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: aiProvider.isTestSuccess!
                      ? AppColors.secondary.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(
                    color: aiProvider.isTestSuccess! ? AppColors.secondary : AppColors.error,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      aiProvider.isTestSuccess! ? Icons.check_circle_outline : Icons.error_outline,
                      color: aiProvider.isTestSuccess! ? AppColors.secondary : AppColors.error,
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Text(
                        aiProvider.isTestSuccess!
                            ? AppStrings.connectionSuccess
                            : (aiProvider.error ?? AppStrings.connectionFailed),
                        style: TextStyle(
                          color: aiProvider.isTestSuccess! ? AppColors.secondary : AppColors.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
            ],

            // Action Buttons
            if (aiProvider.isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            else ...[
              OutlinedButton.icon(
                onPressed: _testConnection,
                icon: const Icon(Icons.cable),
                label: const Text(AppStrings.testConnection),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  gradient: AppColors.primaryGradient,
                ),
                child: ElevatedButton.icon(
                  onPressed: _saveConfig,
                  icon: const Icon(Icons.check),
                  label: const Text(AppStrings.saveConfig),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
