import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

class ApiKeyInput extends StatefulWidget {
  final TextEditingController controller;
  final String provider;
  final String? errorText;

  const ApiKeyInput({
    super.key,
    required this.controller,
    required this.provider,
    this.errorText,
  });

  @override
  State<ApiKeyInput> createState() => _ApiKeyInputState();
}

class _ApiKeyInputState extends State<ApiKeyInput> {
  bool _obscureText = true;

  String get _keyLink {
    if (widget.provider.toLowerCase() == 'gemini') {
      return 'https://aistudio.google.com/app/apikey';
    } else {
      return 'https://openrouter.ai/keys';
    }
  }

  Future<void> _launchUrl() async {
    final url = Uri.parse(_keyLink);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppStrings.apiKeyLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: _launchUrl,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Get ${widget.provider.toUpperCase()} Key',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'monospace',
            letterSpacing: 1.5,
          ),
          decoration: InputDecoration(
            hintText: AppStrings.apiKeyHint,
            errorText: widget.errorText,
            prefixIcon: const Icon(Icons.key, color: AppColors.textSecondary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Simple helper to avoid importing package url_launcher directly if not available or failed
// But since the project compiles with standard flutter web plugins etc, url_launcher or similar might not be in pubspec.yaml unless we add it.
// Wait! Is url_launcher in pubspec.yaml? Let's check!
// Ah, url_launcher is NOT in pubspec.yaml.
// If it is not in pubspec.yaml, we will get a compilation error!
// We should either add url_launcher to pubspec.yaml or use a fallback.
// Adding url_launcher to pubspec.yaml is very easy and makes the app very premium!
// Let's modify pubspec.yaml to add `url_launcher: ^6.2.0` and run `flutter pub get`.
