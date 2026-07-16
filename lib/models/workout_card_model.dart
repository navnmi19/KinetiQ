import 'exercise_model.dart'; // Exercise + WorkoutSession
import 'workout_state.dart';

/// Everything the Dashboard's "Today's Workout" card needs to render,
/// for any of its three states (see WorkoutState).
///
/// Frontend-only for now — WorkoutService builds instances of this from
/// dummy data. Fields like [completedExercises], [currentExerciseIndex],
/// and [currentExerciseName] are stored directly rather than derived,
/// so this model maps 1:1 onto a future Firestore document (a document
/// read shouldn't require recomputing state client-side).
///
/// Immutable — mutate via [copyWith], never by reassigning fields
/// directly. This keeps the model safe to pass around and compare, and
/// matches how a Firestore-backed model will need to behave later.
class WorkoutCardModel {
  /// Stable identifier for this workout (e.g. Firestore document id).
  final String workoutId;

  /// Display name, e.g. "Push Day".
  final String workoutName;

  /// Secondary line, e.g. "Chest • Shoulders • Triceps".
  final String subtitle;

  /// Planned length of the workout, e.g. 58 minutes.
  final Duration estimatedDuration;

  /// Total number of exercises in this workout.
  final int totalExercises;

  /// Number of exercises finished so far.
  final int completedExercises;

  /// Index into [exercises] of the exercise currently in progress.
  final int currentExerciseIndex;

  /// Denormalized name of the current exercise, so UI can render it
  /// without looking it up in [exercises] first.
  final String currentExerciseName;

  /// Where this workout is in its lifecycle. See WorkoutState.
  final WorkoutState state;

  /// The full ordered list of exercises in this workout.
  final List<Exercise> exercises;

  const WorkoutCardModel({
    required this.workoutId,
    required this.workoutName,
    required this.subtitle,
    required this.estimatedDuration,
    required this.totalExercises,
    required this.completedExercises,
    required this.currentExerciseIndex,
    required this.currentExerciseName,
    required this.state,
    required this.exercises,
  });

  /// Builds a Dashboard-ready snapshot from the real WorkoutSession
  /// plus whatever progress numbers WorkoutFlowController currently
  /// has. This is pure reshaping — no decisions about *when* progress
  /// changes, which stays entirely WorkoutFlowController's job. It
  /// exists so that mapping logic isn't duplicated in both
  /// WorkoutFlowController and WorkoutService.
  factory WorkoutCardModel.fromSession({
    required WorkoutSession session,
    int currentExerciseIndex = 0,
    int completedExercises = 0,
    WorkoutState state = WorkoutState.notStarted,
  }) {
    final exercises = session.exercises;
    final safeIndex = exercises.isEmpty
        ? 0
        : currentExerciseIndex.clamp(0, exercises.length - 1);

    return WorkoutCardModel(
      workoutId: session.id,
      workoutName: session.name,
      subtitle: session.muscleGroups.join(' • '),
      estimatedDuration: session.estimatedDuration,
      totalExercises: exercises.length,
      completedExercises: completedExercises,
      currentExerciseIndex: safeIndex,
      currentExerciseName: exercises.isEmpty ? '' : exercises[safeIndex].name,
      state: state,
      exercises: exercises,
    );
  }

  WorkoutCardModel copyWith({
    String? workoutId,
    String? workoutName,
    String? subtitle,
    Duration? estimatedDuration,
    int? totalExercises,
    int? completedExercises,
    int? currentExerciseIndex,
    String? currentExerciseName,
    WorkoutState? state,
    List<Exercise>? exercises,
  }) {
    return WorkoutCardModel(
      workoutId: workoutId ?? this.workoutId,
      workoutName: workoutName ?? this.workoutName,
      subtitle: subtitle ?? this.subtitle,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      totalExercises: totalExercises ?? this.totalExercises,
      completedExercises: completedExercises ?? this.completedExercises,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      currentExerciseName: currentExerciseName ?? this.currentExerciseName,
      state: state ?? this.state,
      exercises: exercises ?? this.exercises,
    );
  }

  // ---------------------------------------------------------------------
  // Getters — read-only conveniences for UI. No business logic lives
  // here beyond simple arithmetic on the model's own fields.
  // ---------------------------------------------------------------------

  /// Completion progress as a 0.0–1.0 fraction, safe against
  /// divide-by-zero for an empty workout. (Named `progress` — this is
  /// what the Dashboard reads; there is no separate
  /// `progressPercentage` getter, to avoid two getters doing the same
  /// arithmetic.)
  double get progress =>
      totalExercises == 0 ? 0 : completedExercises / totalExercises;

  /// 1-based position for "Exercise 3 of 7" copy. Derived from
  /// [completedExercises] rather than [currentExerciseIndex] so it
  /// stays correct even once a workout is [isCompleted] (index stops
  /// advancing past the last exercise, but the count shouldn't).
  int get currentExerciseNumber =>
      (completedExercises + 1).clamp(1, totalExercises == 0 ? 1 : totalExercises);

  /// True once every exercise is done.
  bool get isCompleted => state == WorkoutState.completed;

  /// How many exercises are left to do.
  int get remainingExercises =>
      (totalExercises - completedExercises).clamp(0, totalExercises);

  /// The exercise at [currentExerciseIndex], or null if the index is
  /// out of range (e.g. before a workout has started).
  Exercise? get currentExercise {
    if (currentExerciseIndex < 0 || currentExerciseIndex >= exercises.length) {
      return null;
    }
    return exercises[currentExerciseIndex];
  }
}