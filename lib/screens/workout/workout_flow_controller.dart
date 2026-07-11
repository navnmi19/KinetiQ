import 'package:flutter/material.dart';
import '../../models/exercise_model.dart';
import 'workout_overview_screen.dart';
import 'exercise_screen.dart';
import 'rest_screen.dart';
import 'workout_complete_screen.dart';

enum _WorkoutPhase { overview, exercise, rest, complete }

/// Placeholder calorie estimate per completed set.
/// Swap for a real formula (based on weight/reps/user profile) later.
const int _kCaloriesPerSet = 8;

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
  }

  void _handleRestFinished(int actualRestSeconds) {
    setState(() {
      _totalRestSeconds += actualRestSeconds;
      _exerciseIndex = _pendingExerciseIndex;
      _currentSet = _pendingSet;
      _phase = _WorkoutPhase.exercise;
    });
  }

  void _handleBackToDashboard() {
    if (widget.onWorkoutFinished != null) {
      widget.onWorkoutFinished!();
    } else {
      Navigator.of(context).maybePop();
    }
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