import 'package:flutter/foundation.dart';
import '../models/exercise_model.dart';

/// Snapshot of an in-progress workout, kept alive across navigation so the
/// dashboard's Resume actions have something real to resume into even after
/// [WorkoutFlowController]'s own State object has been popped/destroyed.
class ActiveWorkoutSnapshot {
  final WorkoutSession session;
  final int exerciseIndex;
  final int currentSet;
  final DateTime startTime;
  final int caloriesBurned;
  final int totalRestSeconds;

  const ActiveWorkoutSnapshot({
    required this.session,
    required this.exerciseIndex,
    required this.currentSet,
    required this.startTime,
    this.caloriesBurned = 0,
    this.totalRestSeconds = 0,
  });

  ActiveWorkoutSnapshot copyWith({
    WorkoutSession? session,
    int? exerciseIndex,
    int? currentSet,
    int? caloriesBurned,
    int? totalRestSeconds,
  }) {
    return ActiveWorkoutSnapshot(
      session: session ?? this.session,
      exerciseIndex: exerciseIndex ?? this.exerciseIndex,
      currentSet: currentSet ?? this.currentSet,
      startTime: startTime,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      totalRestSeconds: totalRestSeconds ?? this.totalRestSeconds,
    );
  }
}

/// Cross-screen "is a workout currently in progress" state, following the
/// same static-singleton `ValueNotifier` pattern as `ThemeController`
/// (see lib/themes/theme_controller.dart) — plain state, no package.
class ActiveWorkoutController {
  ActiveWorkoutController._();

  static final ValueNotifier<ActiveWorkoutSnapshot?> snapshot =
      ValueNotifier<ActiveWorkoutSnapshot?>(null);

  static void start(WorkoutSession session) {
    snapshot.value = ActiveWorkoutSnapshot(
      session: session,
      exerciseIndex: 0,
      currentSet: 1,
      startTime: DateTime.now(),
    );
  }

  static void update(ActiveWorkoutSnapshot next) {
    snapshot.value = next;
  }

  static void clear() {
    snapshot.value = null;
  }
}
