/// The lifecycle of today's workout.
///
/// This is the single source of truth for "what is the user's workout
/// doing right now" — read by the Dashboard, Workout Overview, Exercise
/// Screen, Rest Screen, and Workout Complete Screen. Nothing else about
/// a workout (which exercise, elapsed time, etc.) belongs in this enum —
/// see WorkoutCardModel for that.
///
/// Kept intentionally small for the MVP. Future states like `paused`,
/// `cancelled`, or `skipped` can be added as additional cases without
/// touching this file's structure — every consumer should already be
/// switching exhaustively on this enum, so Dart's compiler will flag
/// every call site that needs updating when a new case is added.
enum WorkoutState {
  /// No workout activity yet today. The Dashboard shows the
  /// "Today's Workout" prompt with a Start button in this state.
  notStarted,

  /// The user has started today's workout and is actively working
  /// through it. The Dashboard shows "Continue Workout" with progress
  /// and elapsed time in this state.
  inProgress,

  /// Every exercise in today's workout has been finished. The
  /// Dashboard shows the "Workout Complete" summary card in this state.
  completed,
}