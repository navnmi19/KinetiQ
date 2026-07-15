import 'package:flutter/material.dart';
import '../models/exercise_model.dart';

/// MVP help sheet opened from the (i) icon on the Exercise Screen.
/// Two sections only: Instructions + Video link, and Common Mistakes.
/// Content is intentionally left empty for now — exercise.instructions,
/// exercise.commonMistakes, and exercise.youtubeUrl are unfilled in the
/// sample data, and this sheet just shows a placeholder state until
/// that content is written.
class ExerciseHelpSheet extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onWatchVideo;

  const ExerciseHelpSheet({super.key, required this.exercise, this.onWatchVideo});

  static Future<void> show(
    BuildContext context,
    Exercise exercise, {
    VoidCallback? onWatchVideo,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExerciseHelpSheet(exercise: exercise, onWatchVideo: onWatchVideo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color sheetColor = isDark ? const Color(0xFF141414) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF14532D);
    final Color mutedColor =
        isDark ? Colors.white70 : const Color(0xFF14532D).withValues(alpha: 0.65);
    final Color accent = isDark ? const Color(0xFFFF8A00) : const Color(0xFF22C55E);

    final bool hasInstructions = exercise.instructions.isNotEmpty;
    final bool hasMistakes = exercise.commonMistakes.isNotEmpty;
    final bool hasVideo = exercise.youtubeUrl.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: sheetColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: mutedColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                exercise.name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textColor),
              ),
              const SizedBox(height: 24),

              // Section 1: Instructions + Video
              _SectionHeader(title: 'Instructions', textColor: textColor),
              const SizedBox(height: 10),
              Text(
                hasInstructions
                    ? exercise.instructions.join('\n')
                    : 'Instructions coming soon.',
                style: TextStyle(fontSize: 14, height: 1.5, color: mutedColor),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: hasVideo ? onWatchVideo : null,
                  icon: Icon(Icons.play_circle_outline,
                      color: hasVideo ? accent : mutedColor.withValues(alpha: 0.5)),
                  label: Text(
                    hasVideo ? 'Watch on YouTube' : 'Video coming soon',
                    style: TextStyle(
                      color: hasVideo ? accent : mutedColor.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: (hasVideo ? accent : mutedColor).withValues(alpha: 0.35),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Section 2: Common Mistakes
              _SectionHeader(title: 'Common Mistakes', textColor: textColor),
              const SizedBox(height: 10),
              Text(
                hasMistakes
                    ? exercise.commonMistakes.join('\n')
                    : 'Common mistakes coming soon.',
                style: TextStyle(fontSize: 14, height: 1.5, color: mutedColor),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color textColor;

  const _SectionHeader({required this.title, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor),
    );
  }
}