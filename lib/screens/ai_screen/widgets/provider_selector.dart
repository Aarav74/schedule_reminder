import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class ProviderSelector extends StatelessWidget {
  final String selectedProvider;
  final ValueChanged<String> onProviderChanged;

  const ProviderSelector({
    super.key,
    required this.selectedProvider,
    required this.onProviderChanged,
  });

  Widget _buildChip(BuildContext context, String providerName, String label, IconData icon) {
    final isSelected = selectedProvider.toLowerCase() == providerName.toLowerCase();
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onProviderChanged(providerName),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                size: AppDimensions.iconMd,
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select AI Provider',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Row(
          children: [
            _buildChip(
              context,
              'gemini',
              'Google Gemini',
              Icons.bolt, // Lightning / bolt icon for Gemini
            ),
            const SizedBox(width: AppDimensions.md),
            _buildChip(
              context,
              'openrouter',
              'OpenRouter AI',
              Icons.hub, // Network/hub icon for OpenRouter router
            ),
          ],
        ),
      ],
    );
  }
}
