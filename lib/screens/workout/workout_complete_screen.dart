import 'package:flutter/material.dart';
import '../../../themes/theme_controller.dart';

class WorkoutCompleteScreen extends StatelessWidget {
  final String workoutName;
  final Duration totalDuration;
  final int caloriesBurned;
  final int totalRestSeconds;
  final int exerciseCount;
  final Set<String> muscleGroups;
  final VoidCallback onBackToDashboard;

  const WorkoutCompleteScreen({
    super.key,
    required this.workoutName,
    required this.totalDuration,
    required this.caloriesBurned,
    required this.totalRestSeconds,
    required this.exerciseCount,
    required this.muscleGroups,
    required this.onBackToDashboard,
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  String _formatRest(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}m ${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        final Color bgColor = isDark ? const Color(0xFF090909) : Colors.white;
        final Color cardColor = isDark ? const Color(0xFF141414) : Colors.white;
        final Color textColor = isDark ? Colors.white : const Color(0xFF14532D);
        final Color mutedColor =
            isDark ? Colors.white60 : const Color(0xFF14532D).withOpacity(0.6);
        final Color accent = isDark ? const Color(0xFFFF8A00) : const Color(0xFF22C55E);
        final Color borderColor = isDark ? Colors.white12 : const Color(0xFFE5F7EC);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Container(
                width: 84,
                height: 84,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: accent.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(Icons.check, color: accent, size: 44),
              ),
              const SizedBox(height: 20),
              Text(
                'Workout Complete!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textColor),
              ),
              const SizedBox(height: 6),
              Text(
                workoutName,
                style: TextStyle(fontSize: 15, color: mutedColor, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 28),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.5,
                children: [
                  _StatCard(
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: _formatDuration(totalDuration),
                    cardColor: cardColor,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    borderColor: borderColor,
                    accent: accent,
                  ),
                  _StatCard(
                    icon: Icons.fitness_center,
                    label: 'Exercises',
                    value: '$exerciseCount',
                    cardColor: cardColor,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    borderColor: borderColor,
                    accent: accent,
                  ),
                  _StatCard(
                    icon: Icons.local_fire_department_outlined,
                    label: 'Calories Burned',
                    value: '$caloriesBurned kcal',
                    cardColor: cardColor,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    borderColor: borderColor,
                    accent: accent,
                  ),
                  _StatCard(
                    icon: Icons.self_improvement,
                    label: 'Rest Time',
                    value: _formatRest(totalRestSeconds),
                    cardColor: cardColor,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    borderColor: borderColor,
                    accent: accent,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Muscles Targeted',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textColor),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: muscleGroups
                      .map((group) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              group,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accent),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onBackToDashboard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text(
                    'Back to Dashboard',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color cardColor;
  final Color textColor;
  final Color mutedColor;
  final Color borderColor;
  final Color accent;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.cardColor,
    required this.textColor,
    required this.mutedColor,
    required this.borderColor,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 20),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: mutedColor)),
        ],
      ),
    );
  }
}