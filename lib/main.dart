import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_dimensions.dart';
import 'core/constants/app_theme.dart';
import 'core/utils/date_time_utils.dart';
import 'models/task_model.dart';
import 'providers/ai_provider.dart';
import 'providers/schedule_provider.dart';
import 'screens/ai_screen/ai_schedule_screen.dart';
import 'screens/ai_screen/ai_config_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AIProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schedule AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final todaySchedule = scheduleProvider.getOrCreateScheduleForDate(DateTime.now());
    final tasks = todaySchedule.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AIConfigScreen()),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.lg),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    const Text(
                      'No Tasks Planned Today',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    const Text(
                      'Tap "Generate with AI" below to instantly convert your day\'s description into a beautiful, structured routine.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xl),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        gradient: AppColors.primaryGradient,
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const AIScheduleScreen()),
                          );
                        },
                        icon: const Icon(Icons.psychology),
                        label: const Text('Generate with AI'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.md),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final isCompleted = task.status == TaskStatus.completed;
                final timeRange = '${DateTimeUtils.formatTime12h(task.startTime)} - ${DateTimeUtils.formatTime12h(task.endTime)}';

                return Dismissible(
                  key: Key(task.id),
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
                  onDismissed: (_) {
                    scheduleProvider.removeTaskFromDate(DateTime.now(), task.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Deleted "${task.title}"')),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: AppDimensions.sm),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.md,
                        vertical: AppDimensions.sm,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(AppDimensions.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCompleted ? Icons.check_circle : Icons.schedule,
                          color: isCompleted ? AppColors.secondary : AppColors.primary,
                        ),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task.description.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              task.description,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                          const SizedBox(height: AppDimensions.xs),
                          Text(
                            'Time: $timeRange',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              task.hasAlarm ? Icons.alarm_on : Icons.alarm_off,
                              color: task.hasAlarm ? AppColors.secondary : AppColors.textMuted,
                            ),
                            onPressed: () {
                              scheduleProvider.toggleTaskAlarm(DateTime.now(), task.id);
                            },
                          ),
                          Checkbox(
                            value: isCompleted,
                            activeColor: AppColors.secondary,
                            checkColor: AppColors.background,
                            onChanged: (_) {
                              scheduleProvider.toggleTaskComplete(DateTime.now(), task.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: tasks.isEmpty
          ? null
          : Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AIScheduleScreen()),
                  );
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(Icons.psychology, color: AppColors.textPrimary),
              ),
            ),
    );
  }
}
