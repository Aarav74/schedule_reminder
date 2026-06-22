import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/ai_provider.dart';
import '../../providers/schedule_provider.dart';
import 'ai_config_screen.dart';
import 'widgets/generated_schedule_preview.dart';

class AIScheduleScreen extends StatefulWidget {
  const AIScheduleScreen({super.key});

  @override
  State<AIScheduleScreen> createState() => _AIScheduleScreenState();
}

class _AIScheduleScreenState extends State<AIScheduleScreen> {
  final TextEditingController _promptController = TextEditingController();

  final List<Map<String, String>> _templates = [
    {
      'label': 'Study Day',
      'text': 'Math exam preparation from 9 AM to 12 PM. Lunch break at 12 PM. Physics study session from 2 PM to 4 PM. Gym workout at 6 PM for 1.5 hours.',
    },
    {
      'label': 'Productive Workday',
      'text': 'Review emails at 8:30 AM for 30 mins. Team standup meeting at 9:30 AM. Deep work on coding from 10 AM to 1 PM. Lunch and walk at 1 PM. Client call at 3:30 PM.',
    },
    {
      'label': 'Morning Routine',
      'text': 'Wake up, hydrate, and stretch at 6:00 AM. Meditation for 15 minutes at 6:20 AM. Read a book for 30 minutes at 6:40 AM. Healthy breakfast at 7:20 AM.',
    },
    {
      'label': 'Weekend Chores',
      'text': 'Grocery shopping at 10 AM for 1 hour. Clean the house and laundry from 1 PM to 3 PM. Cook dinner at 6 PM.',
    },
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
    
    // Check if key is configured
    if (aiProvider.apiKey.isEmpty) {
      _showSetupApiKeyDialog();
      return;
    }

    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.promptRequired)),
      );
      return;
    }

    final todaySchedule = scheduleProvider.getOrCreateScheduleForDate(DateTime.now());
    final existingTasks = todaySchedule.tasks;

    final success = await aiProvider.generateScheduleFromPrompt(
      _promptController.text.trim(),
      existingTasks,
    );

    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(aiProvider.error ?? AppStrings.genericError),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSetupApiKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Key Required'),
        content: const Text(
          'To generate schedules using AI, you must configure your Gemini or OpenRouter API key first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AIConfigScreen()),
              );
            },
            child: const Text('Configure'),
          ),
        ],
      ),
    );
  }

  void _saveSchedules() {
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
    
    final items = aiProvider.generatedTasks;
    if (items.isEmpty) return;

    // Add generated tasks to today's schedule list
    scheduleProvider.addTasksToDate(DateTime.now(), items);
    
    // Clear preview
    aiProvider.clearGeneratedTasks();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.saveSchedulesSuccess),
        backgroundColor: AppColors.secondary,
      ),
    );
    
    // Navigate back
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = Provider.of<AIProvider>(context);
    final hasPreview = aiProvider.generatedTasks.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.aiScheduleTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AIConfigScreen()),
              );
            },
            tooltip: 'Configure AI Keys',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prompt Label
              const Text(
                AppStrings.promptLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              
              // Text Area Input
              TextField(
                controller: _promptController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: AppStrings.promptHint,
                ),
              ),
              const SizedBox(height: AppDimensions.md),

              // Templates / Quick Prompt Chips
              const Text(
                'Quick Templates:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              Wrap(
                spacing: AppDimensions.sm,
                runSpacing: AppDimensions.sm,
                children: _templates.map((template) {
                  return ActionChip(
                    label: Text(template['label']!),
                    labelStyle: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.border),
                    onPressed: () {
                      setState(() {
                        _promptController.text = template['text']!;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimensions.lg),

              // Generate Button / Loading state
              if (aiProvider.isLoading)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: AppDimensions.md),
                      Text(
                        AppStrings.generatingStatus,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _generate,
                    icon: const Icon(Icons.psychology),
                    label: const Text(AppStrings.generateBtn),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
                    ),
                  ),
                ),
              
              const SizedBox(height: AppDimensions.xl),

              // Generated Preview Widget
              if (hasPreview) ...[
                GeneratedSchedulePreview(
                  onSaveAll: _saveSchedules,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
