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

  void _handleMoveToNextSet() {
    final exercise = _currentExercise;
    setState(() {
      _caloriesBurned += _kCaloriesPerSet;

      if (_currentSet < exercise.sets) {
        _currentSet++;
      } else if (_isLastExercise) {
        _phase = _WorkoutPhase.complete;
      } else {
        _phase = _WorkoutPhase.rest;
      }
    });
  }

  void _handleMoveToNextExercise(int actualRestSeconds) {
    setState(() {
      _totalRestSeconds += actualRestSeconds;
      _exerciseIndex++;
      _currentSet = 1;
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
        final nextExercise = _exerciseIndex + 1 < _session.exercises.length
            ? _session.exercises[_exerciseIndex + 1]
            : null;
        return RestScreen(
          nextExercise: nextExercise,
          onMoveToNextExercise: _handleMoveToNextExercise,
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