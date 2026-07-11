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

class WorkoutSession {
  final String id;
  final String name;
  final List<Exercise> exercises;

  const WorkoutSession({
    required this.id,
    required this.name,
    required this.exercises,
  });

  /// Placeholder duration estimate: sum of (sets * (avg set time + rest)).
  /// avgSetSeconds and restSeconds are static MVP constants — swap for
  /// live/historical averages later without touching the UI layer.
  static const int avgSetSeconds = 40;
  static const int restSeconds = 45;

  Duration get estimatedDuration {
    final totalSeconds = exercises.fold<int>(
      0,
      (sum, exercise) =>
          sum + exercise.sets * (avgSetSeconds + restSeconds),
    );
    return Duration(seconds: totalSeconds);
  }

  Set<String> get muscleGroups =>
      exercises.map((e) => e.muscleGroup).toSet();

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
}