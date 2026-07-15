import 'package:flutter/material.dart';
import '../../../models/exercise_model.dart';
import '../../../widgets/exercise_help_sheet.dart';
import 'package:gym_app/themes/theme_controller.dart';

class WorkoutOverviewScreen extends StatefulWidget {
  final WorkoutSession session;
  final void Function(WorkoutSession reorderedSession) onStartWorkout;

  const WorkoutOverviewScreen({
    super.key,
    required this.session,
    required this.onStartWorkout,
  });

  @override
  State<WorkoutOverviewScreen> createState() => _WorkoutOverviewScreenState();
}

class _WorkoutOverviewScreenState extends State<WorkoutOverviewScreen> {
  late List<Exercise> _exercises;

  @override
  void initState() {
    super.initState();
    _exercises = List.of(widget.session.exercises);
  }

  Duration get _estimatedDuration =>
      widget.session.copyWith(exercises: _exercises).estimatedDuration;

  Set<String> get _muscleGroups =>
      widget.session.copyWith(exercises: _exercises).muscleGroups;

  void _handleReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _exercises.removeAt(oldIndex);
      _exercises.insert(newIndex, item);
    });
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
            isDark ? Colors.white60 : const Color(0xFF14532D).withValues(alpha: 0.6);
        final Color accent = isDark ? const Color(0xFFFF8A00) : const Color(0xFF22C55E);

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, textColor),
                _buildMetaRow(textColor, mutedColor, accent),
                const SizedBox(height: 8),
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: _exercises.length,
                    onReorder: _handleReorder,
                    itemBuilder: (context, index) {
                      final exercise = _exercises[index];
                      return _ExerciseRow(
                        key: ValueKey(exercise.id),
                        exercise: exercise,
                        index: index,
                        cardColor: cardColor,
                        textColor: textColor,
                        mutedColor: mutedColor,
                        accent: accent,
                        isDark: isDark,
                        onTap: () => ExerciseHelpSheet.show(context, exercise),
                      );
                    },
                  ),
                ),
                _buildStartButton(context, accent, isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 20, color: textColor),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(
              widget.session.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildMetaRow(Color textColor, Color mutedColor, Color accent) {
    final minutes = _estimatedDuration.inMinutes;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, size: 18, color: mutedColor),
          const SizedBox(width: 6),
          Text(
            '~$minutes min',
            style: TextStyle(fontSize: 14, color: mutedColor, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _muscleGroups
                  .map((group) => _MuscleTag(label: group, accent: accent))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, Color accent, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => widget.onStartWorkout(
            widget.session.copyWith(exercises: _exercises),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: isDark ? Colors.black : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            'Start Workout',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _MuscleTag extends StatelessWidget {
  final String label;
  final Color accent;

  const _MuscleTag({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accent),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final Exercise exercise;
  final int index;
  final Color cardColor;
  final Color textColor;
  final Color mutedColor;
  final Color accent;
  final bool isDark;
  final VoidCallback onTap;

  const _ExerciseRow({
    super.key,
    required this.exercise,
    required this.index,
    required this.cardColor,
    required this.textColor,
    required this.mutedColor,
    required this.accent,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.fitness_center, color: accent, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${exercise.sets} × ${exercise.reps}',
                        style: TextStyle(fontSize: 13, color: mutedColor),
                      ),
                    ],
                  ),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.drag_handle, color: mutedColor, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}