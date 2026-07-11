import 'package:flutter/material.dart';
import '../../../models/exercise_model.dart';
import '../../../widgets/exercise_help_sheet.dart';
import 'package:gym_app/themes/theme_controller.dart';

class ExerciseScreen extends StatelessWidget {
  final String workoutName;
  final Exercise exercise;
  final int exerciseIndex; // 0-based
  final int totalExercises;
  final int currentSet; // 1-based
  final VoidCallback onMoveToNextSet;
  final VoidCallback? onWatchVideo;

  const ExerciseScreen({
    super.key,
    required this.workoutName,
    required this.exercise,
    required this.exerciseIndex,
    required this.totalExercises,
    required this.currentSet,
    required this.onMoveToNextSet,
    this.onWatchVideo,
  });

  bool get _isLastSet => currentSet >= exercise.sets;

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
            child: Column(
              children: [
                _buildHeader(context, textColor),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          exercise.name,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Exercise ${exerciseIndex + 1} of $totalExercises',
                          style: TextStyle(fontSize: 13, color: mutedColor),
                        ),
                        const SizedBox(height: 24),
                        _buildSetRepRow(cardColor, textColor, mutedColor, borderColor, isDark),
                        const SizedBox(height: 20),
                        _buildBlankMannequinSpace(borderColor),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                _buildMoveToNextSetButton(accent, isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              workoutName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor),
            ),
          ),
          IconButton(
            icon: Icon(Icons.info_outline, size: 24, color: textColor),
            onPressed: () => ExerciseHelpSheet.show(
              context,
              exercise,
              onWatchVideo: onWatchVideo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRepRow(
    Color cardColor,
    Color textColor,
    Color mutedColor,
    Color borderColor,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            label: 'Set',
            value: '$currentSet / ${exercise.sets}',
            cardColor: cardColor,
            textColor: textColor,
            mutedColor: mutedColor,
            borderColor: borderColor,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _InfoCard(
            label: 'Reps (Target)',
            value: '${exercise.reps}',
            cardColor: cardColor,
            textColor: textColor,
            mutedColor: mutedColor,
            borderColor: borderColor,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  /// Deliberately empty — mannequin/illustration goes here later.
  /// No icon, no text, just the reserved space.
  Widget _buildBlankMannequinSpace(Color borderColor) {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
      ),
    );
  }

  Widget _buildMoveToNextSetButton(Color accent, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onMoveToNextSet,
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: isDark ? Colors.black : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          child: Text(
            _isLastSet ? 'Finish Exercise' : 'Move to Next Set',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color cardColor;
  final Color textColor;
  final Color mutedColor;
  final Color borderColor;
  final bool isDark;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.cardColor,
    required this.textColor,
    required this.mutedColor,
    required this.borderColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: mutedColor, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textColor),
          ),
        ],
      ),
    );
  }
}