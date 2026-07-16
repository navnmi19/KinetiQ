import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:gym_app/models/exercise_model.dart';
import 'package:gym_app/models/workout_card_model.dart';
import 'package:gym_app/models/workout_state.dart';

/// A read-only mirror of the workout WorkoutFlowController is
/// currently running — nothing more.
///
/// IMPORTANT: WorkoutService owns NO workout logic. It never decides
/// when a set finishes, when an exercise advances, or when a workout
/// completes — WorkoutFlowController decides all of that and then
/// calls [syncFromFlow] to report the result. This class exists only
/// so the Dashboard (and any other screen) can read "what's my
/// workout doing right now" via ListenableBuilder, without every
/// screen needing a reference to the actual WorkoutFlowController
/// instance.
///
/// There is deliberately no `startWorkout()`, `completeExercise()`,
/// etc. here — those verbs belong to WorkoutFlowController. Calling
/// this a second workout engine would be exactly the duplication this
/// design is meant to avoid.
class WorkoutService extends ChangeNotifier {
  WorkoutService._internal();

  static final WorkoutService instance = WorkoutService._internal();

  /// Before WorkoutFlowController has synced anything (e.g. the
  /// Dashboard is shown before the user ever opens a workout), this
  /// starts empty/idle rather than crashing on a null read. Still
  /// dummy data only — no backend involved.
  WorkoutCardModel _workout = const WorkoutCardModel(
    workoutId: '',
    workoutName: '',
    subtitle: '',
    estimatedDuration: Duration.zero,
    totalExercises: 0,
    completedExercises: 0,
    currentExerciseIndex: 0,
    currentExerciseName: '',
    state: WorkoutState.notStarted,
    exercises: <Exercise>[],
  );

  DateTime? _startTime;
  Timer? _ticker;

  /// Time elapsed since the mirrored workout started, ticking once a
  /// second while [workout].state is inProgress. Purely a display
  /// convenience — WorkoutFlowController is still the one that knows
  /// the real start time; this just re-derives a live-updating value
  /// from it for the Dashboard's ticking label.
  Duration elapsed = Duration.zero;

  /// The most recent snapshot reported by WorkoutFlowController.
  /// Read-only — there is no method on this class that mutates it
  /// directly; it only ever changes via [syncFromFlow].
  WorkoutCardModel get workout => _workout;

  /// Called by WorkoutFlowController after every state-changing
  /// action it makes (starting, finishing a set/exercise, completing
  /// the workout, resetting, switching days — whatever it does
  /// internally). WorkoutService does not interpret or validate this;
  /// it stores it and notifies listeners.
  ///
  /// [startTime] should be passed whenever [snapshot.state] is
  /// inProgress, so this service can keep [elapsed] ticking for the
  /// Dashboard without WorkoutFlowController needing to push a tick
  /// every second itself. Pass null when the workout isn't running.
  void syncFromFlow(WorkoutCardModel snapshot, {DateTime? startTime}) {
    _workout = snapshot;

    if (snapshot.state == WorkoutState.inProgress && startTime != null) {
      if (_startTime != startTime) {
        _startTime = startTime;
        elapsed = DateTime.now().difference(startTime);
        _startTicker();
      }
    } else {
      _startTime = null;
      _stopTicker();
      if (snapshot.state != WorkoutState.inProgress) {
        elapsed = Duration.zero;
      }
    }

    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Internals — presentation-only ticking, not business logic.
  // ---------------------------------------------------------------------

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startTime == null) return;
      elapsed = DateTime.now().difference(_startTime!);
      notifyListeners();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}