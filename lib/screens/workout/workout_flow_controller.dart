import 'package:flutter/material.dart';
import '../../models/exercise_model.dart';
import '../../models/workout_card_model.dart';
import '../../models/workout_state.dart';
import '../../services/workout_service.dart';
import 'workout_overview_screen.dart';
import 'exercise_screen.dart';
import 'rest_screen.dart';
import 'workout_complete_screen.dart';

enum _WorkoutPhase { overview, exercise, rest, complete }

/// Placeholder calorie estimate per completed set.
/// Swap for a real formula (based on weight/reps/user profile) later.
const int _kCaloriesPerSet = 8;

/// The single source of truth for a live workout: current exercise,
/// sets, rest timer, completion, and navigation between the four
/// workout-flow screens. WorkoutService does NOT duplicate any of
/// this — it only receives a snapshot (via [_syncService]) after
/// every state change here, so the Dashboard can display progress
/// without owning any of the logic that produces it.
class WorkoutFlowController extends StatefulWidget {
  final WorkoutSession initialSession;
  final VoidCallback? onWorkoutFinished;

  const WorkoutFlowController({
    super.key,
    required this.initialSession,
    this.onWorkoutFinished,
  });

  @override
  State<WorkoutFlowController> createState() => _WorkoutFlowControllerState();
}

class _WorkoutFlowControllerState extends State<WorkoutFlowController> {
  _WorkoutPhase _phase = _WorkoutPhase.overview;

  late WorkoutSession _session;
  int _exerciseIndex = 0;
  int _currentSet = 1;

  // What happens once the current rest period ends — computed the moment
  // "Move to Next Set" is pressed, then applied when rest finishes.
  int _pendingExerciseIndex = 0;
  int _pendingSet = 1;
  bool _pendingIsNewExercise = false;

  DateTime? _workoutStartTime;
  int _totalRestSeconds = 0;
  int _caloriesBurned = 0;

  @override
  void initState() {
    super.initState();
    _session = widget.initialSession;
    _syncService(); // report the notStarted overview state immediately
  }

  Exercise get _currentExercise => _session.exercises[_exerciseIndex];

  bool get _isLastExercise => _exerciseIndex == _session.exercises.length - 1;

  void _handleStartWorkout(WorkoutSession reorderedSession) {
    setState(() {
      _session = reorderedSession;
      _exerciseIndex = 0;
      _currentSet = 1;
      _workoutStartTime = DateTime.now();
      _phase = _WorkoutPhase.exercise;
    });
    _syncService();
  }

  /// Fires when "Move to Next Set" / "Finish Exercise" is pressed.
  /// Every set is followed by rest, except the very last set of the
  /// very last exercise — that goes straight to the Complete screen.
  void _handleMoveToNextSet() {
    final exercise = _currentExercise;
    setState(() {
      _caloriesBurned += _kCaloriesPerSet;

      if (_currentSet < exercise.sets) {
        // More sets left on this exercise — rest, then next set.
        _pendingExerciseIndex = _exerciseIndex;
        _pendingSet = _currentSet + 1;
        _pendingIsNewExercise = false;
        _phase = _WorkoutPhase.rest;
      } else if (_isLastExercise) {
        // Last set of the last exercise — workout's done, no rest needed.
        _phase = _WorkoutPhase.complete;
      } else {
        // Last set of this exercise, but more exercises remain —
        // rest, then move to the next exercise.
        _pendingExerciseIndex = _exerciseIndex + 1;
        _pendingSet = 1;
        _pendingIsNewExercise = true;
        _phase = _WorkoutPhase.rest;
      }
    });
    _syncService();
  }

  void _handleRestFinished(int actualRestSeconds) {
    setState(() {
      _totalRestSeconds += actualRestSeconds;
      _exerciseIndex = _pendingExerciseIndex;
      _currentSet = _pendingSet;
      _phase = _WorkoutPhase.exercise;
    });
    _syncService();
  }

  void _handleBackToDashboard() {
    if (widget.onWorkoutFinished != null) {
      widget.onWorkoutFinished!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  /// Reports the current state to WorkoutService. Called after every
  /// transition above. Purely a data-reshaping step — see
  /// WorkoutCardModel.fromSession — it makes no decisions of its own,
  /// just reflects whatever this controller's fields already say.
  void _syncService() {
    final state = switch (_phase) {
      _WorkoutPhase.overview => WorkoutState.notStarted,
      _WorkoutPhase.exercise => WorkoutState.inProgress,
      _WorkoutPhase.rest => WorkoutState.inProgress,
      _WorkoutPhase.complete => WorkoutState.completed,
    };

    // An exercise counts as "completed" for Dashboard purposes once
    // its index has been passed. While mid-workout, that's
    // _exerciseIndex; once the whole workout is done, every exercise
    // is complete regardless of which one was last active.
    final completedExercises = _phase == _WorkoutPhase.complete
        ? _session.exercises.length
        : _exerciseIndex;

    final snapshot = WorkoutCardModel.fromSession(
      session: _session,
      currentExerciseIndex: _exerciseIndex,
      completedExercises: completedExercises,
      state: state,
    );

    WorkoutService.instance.syncFromFlow(
      snapshot,
      startTime: state == WorkoutState.inProgress ? _workoutStartTime : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _WorkoutPhase.overview:
        return WorkoutOverviewScreen(
          session: _session,
          onStartWorkout: _handleStartWorkout,
        );

      case _WorkoutPhase.exercise:
        return ExerciseScreen(
          workoutName: _session.name,
          exercise: _currentExercise,
          exerciseIndex: _exerciseIndex,
          totalExercises: _session.exercises.length,
          currentSet: _currentSet,
          onMoveToNextSet: _handleMoveToNextSet,
        );

      case _WorkoutPhase.rest:
        final upNextExercise = _session.exercises[_pendingExerciseIndex];
        return RestScreen(
          isNewExercise: _pendingIsNewExercise,
          upNextExerciseName: upNextExercise.name,
          upNextSetLabel: 'Set $_pendingSet of ${upNextExercise.sets}',
          onContinue: _handleRestFinished,
        );

      case _WorkoutPhase.complete:
        final duration = _workoutStartTime != null
            ? DateTime.now().difference(_workoutStartTime!)
            : Duration.zero;
        return WorkoutCompleteScreen(
          workoutName: _session.name,
          totalDuration: duration,
          caloriesBurned: _caloriesBurned,
          totalRestSeconds: _totalRestSeconds,
          exerciseCount: _session.exercises.length,
          muscleGroups: _session.muscleGroups,
          onBackToDashboard: _handleBackToDashboard,
        );
    }
  }
}