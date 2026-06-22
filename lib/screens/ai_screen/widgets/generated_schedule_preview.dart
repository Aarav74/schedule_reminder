import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../providers/ai_provider.dart';

class GeneratedSchedulePreview extends StatelessWidget {
  final VoidCallback onSaveAll;

  const GeneratedSchedulePreview({
    super.key,
    required this.onSaveAll,
  });

  @override
  Widget build(BuildContext context) {
    final aiProvider = Provider.of<AIProvider>(context);
    final items = aiProvider.generatedTasks;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.checklist, color: AppColors.primary),
            SizedBox(width: AppDimensions.sm),
            Text(
              AppStrings.previewTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.xs),
        const Text(
          AppStrings.previewSubtitle,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.sm),
          itemBuilder: (context, index) {
            final item = items[index];
            final timeRangeStr = '${DateTimeUtils.formatTime24h(item.startTime)} - ${DateTimeUtils.formatTime24h(item.endTime)}';
            
            return Dismissible(
              key: Key(item.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: AppDimensions.lg),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: const Icon(Icons.delete, color: AppColors.textPrimary),
              ),
              onDismissed: (direction) {
                aiProvider.removeGeneratedTaskItem(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed "${item.title}"'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Row(
                    children: [
                      // Time badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm,
                          vertical: AppDimensions.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Text(
                          timeRangeStr,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.md),
                      // Text info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (item.description.isNotEmpty) ...[
                              const SizedBox(height: AppDimensions.xs),
                              Text(
                                item.description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      // Alarm toggle
                      IconButton(
                        icon: Icon(
                          item.hasAlarm ? Icons.alarm_on : Icons.alarm_off,
                          color: item.hasAlarm ? AppColors.secondary : AppColors.textMuted,
                        ),
                        onPressed: () {
                          aiProvider.toggleAlarm(index);
                        },
                        tooltip: item.hasAlarm ? 'Alarm enabled' : 'Alarm disabled',
                      ),
                      // Delete button
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () {
                          aiProvider.removeGeneratedTaskItem(index);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppDimensions.lg),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: ElevatedButton(
            onPressed: onSaveAll,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save),
                SizedBox(width: AppDimensions.sm),
                Text(AppStrings.saveAllSchedules),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
