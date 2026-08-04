# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

This is a Flutter/Dart app (SDK `^3.12.2`, no state-management package — see Architecture).

- Install dependencies: `flutter pub get`
- Run the app: `flutter run` (pick a device, e.g. `-d windows`, `-d chrome`)
- Static analysis / lint: `flutter analyze`
- Run all tests: `flutter test`
- Run a single test file: `flutter test test/widget_test.dart`
- Format code: `dart format lib`

Lints come from `package:flutter_lints/flutter.yaml` via `analysis_options.yaml`; no custom rules are currently added/disabled.

## Architecture

**Navigation**: No named routes / router package. Screens are pushed imperatively with
`Navigator.push(context, MaterialPageRoute(builder: (_) => SomeScreen()))`. `main.dart` sets
`home: const SplashScreen()` and that's the only route configured on `MaterialApp`.

**State management**: Plain `StatefulWidget` + `setState`. No Provider/Riverpod/Bloc/GetX. Global
app-wide state that needs to be read from unrelated widget trees (currently just the dark/light
theme) is done via a static `ValueNotifier` singleton — see `lib/themes/theme_controller.dart`
(`ThemeController.mode`, toggled with `ThemeController.toggle()`, listened to with
`ThemeController.mode.addListener(...)` in `initState`/removed in `dispose`). Follow this same
pattern for any new cross-screen state rather than introducing a state package.

**Screen flow** (each screen pushes the next by importing it directly):
```
SplashScreen (lib/screens/splash)
  -> BasicInfoScreen -> BodyMetricsScreen -> FitnessGoalScreen -> TargetBodyPartsScreen
  -> CapabilityAssessmentScreen -> TimeCommitmentScreen -> TrainingSetupScreen
  -> ProgramGenerationScreen -> DashboardScreen   (lib/screens/onboarding/*, then home)
```
From `DashboardScreen` (lib/screens/home/dashboard_screen.dart), the bottom nav bar pushes
`NutritionScreen`, `ProgressScreen`, and `FriendsScreen` as separate routes (only "Home" is a
real in-place tab; the other three nav items navigate away). Starting a workout pushes
`WorkoutFlowController` (lib/screens/workout/workout_flow_controller.dart), which is itself a
small internal state machine (`_WorkoutPhase`: overview -> exercise -> rest -> complete) that
swaps its build output rather than pushing new routes — it drives `WorkoutOverviewScreen`,
`ExerciseScreen`, `RestScreen`, `WorkoutCompleteScreen` in place.

**Data is currently all in-file placeholders.** There is no backend/API/persistence layer yet.
Dashboard stats, calendar days, graph series, friends lists, nutrition data, etc. are hardcoded
`const` lists/maps directly inside the screen widgets (clearly marked with `// TODO` or
"placeholder" comments where relevant). When wiring up real data, look for these in-widget
constants rather than assuming a service/repository layer exists.

**Naming collision to watch for**: there are two unrelated `WorkoutSession` classes:
- `lib/models/exercise_model.dart` — the real domain model (`id`, `name`, `List<Exercise>`),
  used by `WorkoutFlowController` and the workout screens.
- `lib/screens/home/dashboard_screen.dart` — a dashboard-only display model (`title`, `tags`,
  `duration`, `statusLabel`, `List<WorkoutExercise>`) used for the calendar/history card.

They are not interchangeable; check which file you're in / which import is present before using
the type.

**Theming**: `lib/themes/gymin_theme.dart` and `theme_toggle_button.dart` exist, but in practice
most screens (e.g. `DashboardScreen`) don't consume a `ThemeData` — they read
`ThemeController.mode.value == ThemeMode.dark` directly and branch colors manually via a set of
private `Color get _xxx` getters (`_bgTop`, `_accent`, `_textPrimary`, etc.) redefined per screen.
Follow this same per-screen light/dark color-getter pattern when adding UI rather than trying to
centralize into `ThemeData`.

**Directory layout**: `lib/screens/<feature>/` (onboarding, home, workout, social, nutrition,
progress, splash), `lib/models/`, `lib/themes/`, `lib/widgets/` (shared widgets used across
features, e.g. `background_decoration.dart`).

**Assets**: registered in `pubspec.yaml` under `flutter.assets` as whole-directory globs
(`assets/animations/`, `assets/images/bodyparts/`, `assets/illustrations/`) — new files dropped
into those existing directories are picked up automatically; a new top-level asset directory
needs a new entry in `pubspec.yaml`.
