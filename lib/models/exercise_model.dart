/// A single exercise, as defined by the real workout-flow screens
/// (ExerciseScreen, WorkoutOverviewScreen, WorkoutFlowController,
/// sample_workout.dart). This is the ORIGINAL shape — restored after
/// an earlier rewrite incorrectly replaced it with a Dashboard-only
/// version (setsReps string + isCompleted). That was wrong; this is
/// the real one.
class Exercise {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final double weight;
  final String muscleGroup;
  final String description;
  final List<String> instructions;
  final List<String> commonMistakes;
  final String youtubeUrl;

  const Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.muscleGroup,
    required this.description,
    required this.instructions,
    required this.commonMistakes,
    required this.youtubeUrl,
  });

  Exercise copyWith({
    String? id,
    String? name,
    int? sets,
    int? reps,
    double? weight,
    String? muscleGroup,
    String? description,
    List<String>? instructions,
    List<String>? commonMistakes,
    String? youtubeUrl,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      commonMistakes: commonMistakes ?? this.commonMistakes,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
    );
  }
}

/// A full workout session — an ordered list of exercises plus
/// identity. Reconstructed from usage in WorkoutOverviewScreen and
/// WorkoutFlowController, which both reference `WorkoutSession` but
/// whose original definition I don't have. I do NOT have the real
/// `estimatedDuration` formula — the one below is a placeholder
/// (40s work + 60s rest per set) so the app compiles and shows a
/// plausible number. If you have the actual original file (git
/// history, local history, or another editor tab), paste it and
/// I'll replace this with the real formula instead of a guess.
class WorkoutSession {
  final String id;
  final String name;
  final List<Exercise> exercises;

  const WorkoutSession({
    required this.id,
    required this.name,
    required this.exercises,
  });

  WorkoutSession copyWith({
    String? id,
    String? name,
    List<Exercise>? exercises,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
    );
  }

  /// PLACEHOLDER FORMULA — see class doc comment above.
  Duration get estimatedDuration {
    const workSecondsPerSet = 40;
    const restSecondsPerSet = 60;
    final totalSeconds = exercises.fold<int>(
      0,
      (sum, e) => sum + e.sets * (workSecondsPerSet + restSecondsPerSet),
    );
    return Duration(seconds: totalSeconds);
  }

  Set<String> get muscleGroups =>
      exercises.map((e) => e.muscleGroup).where((g) => g.isNotEmpty).toSet();
}