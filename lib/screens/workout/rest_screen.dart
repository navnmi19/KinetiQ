import 'dart:async';
import 'package:flutter/material.dart';
import '../../../models/exercise_model.dart';

class RestScreen extends StatefulWidget {
  final Exercise? nextExercise; // null shouldn't happen in practice here,
  // since the controller skips this screen after the final exercise.
  final void Function(int actualRestSeconds) onMoveToNextExercise;

  const RestScreen({
    super.key,
    required this.nextExercise,
    required this.onMoveToNextExercise,
  });

  @override
  State<RestScreen> createState() => _RestScreenState();
}

class _RestScreenState extends State<RestScreen> {
  static const int _minRestSeconds = 30;
  int _elapsedSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _isReady => _elapsedSeconds >= _minRestSeconds;

  String get _formattedTime {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark ? const Color(0xFF090909) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF14532D);
    final Color mutedColor =
        isDark ? Colors.white60 : const Color(0xFF14532D).withOpacity(0.6);
    final Color accent = isDark ? const Color(0xFFFF8A00) : const Color(0xFF22C55E);
    final Color trackColor = isDark ? Colors.white12 : const Color(0xFFE5F7EC);
    final Color disabledColor = isDark ? Colors.white24 : const Color(0xFFBFE6CC);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Icon(Icons.self_improvement, size: 40, color: accent),
              const SizedBox(height: 16),
              Text(
                'Rest',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor),
              ),
              const SizedBox(height: 28),
              Container(
                width: 200,
                height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: trackColor, width: 8),
                ),
                child: Text(
                  _formattedTime,
                  style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: textColor),
                ),
              ),
              const SizedBox(height: 24),
              if (widget.nextExercise != null) ...[
                Text('Next Up', style: TextStyle(fontSize: 12, color: mutedColor)),
                const SizedBox(height: 4),
                Text(
                  widget.nextExercise!.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor),
                ),
              ],
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isReady
                      ? () => widget.onMoveToNextExercise(_elapsedSeconds)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isReady ? accent : disabledColor,
                    foregroundColor: _isReady
                        ? (isDark ? Colors.black : Colors.white)
                        : mutedColor,
                    disabledBackgroundColor: disabledColor,
                    disabledForegroundColor: mutedColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text(
                    _isReady ? "I'm Ready" : 'Move to Next Exercise',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}