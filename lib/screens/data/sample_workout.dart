import 'package:gym_app/models/exercise_model.dart';

/// Basic 3-exercise session for testing the workout flow.
/// Instructions, common mistakes, and video links are intentionally
/// left empty — content comes later.
final WorkoutSession sampleWorkoutSession = WorkoutSession(
  id: 'sample_1',
  name: 'Full Body Basics',
  exercises: [
    Exercise(
      id: 'ex_pushup',
      name: 'Push-up',
      sets: 3,
      reps: 12,
      weight: 0,
      muscleGroup: 'Chest',
      description: '',
      instructions: const [],
      commonMistakes: const [],
      youtubeUrl: '',
    ),
    Exercise(
      id: 'ex_squat',
      name: 'Bodyweight Squat',
      sets: 3,
      reps: 15,
      weight: 0,
      muscleGroup: 'Legs',
      description: '',
      instructions: const [],
      commonMistakes: const [],
      youtubeUrl: '',
    ),
    Exercise(
      id: 'ex_curl',
      name: 'Bicep Curl',
      sets: 3,
      reps: 10,
      weight: 8,
      muscleGroup: 'Biceps',
      description: '',
      instructions: const [],
      commonMistakes: const [],
      youtubeUrl: '',
    ),
  ],
);