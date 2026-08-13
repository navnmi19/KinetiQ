# KINETIQ

### Personalized Fitness & Workout Application

KINETIQ is a cross-platform fitness application built with **Flutter and Dart**, designed to provide a personalized and engaging fitness experience through workout planning, progress tracking, nutrition, and social fitness features.

The project began as a **UI/UX-focused fitness application** and is being developed into a more complete mobile product with an emphasis on personalization, modular architecture, and a consistent user experience.

---

## Features

### Personalized Onboarding

KINETIQ collects key user information during onboarding to create a personalized experience throughout the application.

- Name and age
- Height and weight
- Fitness goals
- Target body parts
- Training preferences
- Time commitment
- Injury considerations

User information collected during onboarding is designed to flow into the rest of the application.

### Dashboard

The dashboard acts as the central hub of KINETIQ and provides access to the user's main fitness experiences.

- Personalized workout information
- Daily fitness information
- Progress overview
- Nutrition
- Social features
- Workout navigation

### Workout System

KINETIQ provides both recommended and customizable workout experiences.

The custom workout builder allows users to:

- Select exercises
- Add exercises to a workout
- Modify sets and repetitions
- Remove exercises
- Reorder exercises
- View exercise information
- Track workout completion

The workout system uses reusable exercise and workout models to separate workout data from individual UI screens.

### Progress Tracking

The Progress module is designed to give users a visual representation of their training development.

- Workout consistency
- Training history
- Progress metrics
- Workout completion
- Personal milestones

### Nutrition

KINETIQ includes a dedicated nutrition experience for tracking and understanding food intake.

The nutrition module is currently being expanded as part of the application's ongoing development.

### Social Fitness

KINETIQ includes a social layer designed around:

- Friends
- Activity
- Workout sharing
- Fitness engagement
- Community interaction

The social system is currently under development.

---

## Design System

KINETIQ follows a centralized visual design system across the application.

### Dark Mode

- Dark background
- Orange accent
- High-contrast typography
- Minimal flat UI
- Consistent cards and controls

### Light Mode

- Light background
- Green accent
- Clean minimal interface

The application uses a centralized theme architecture to maintain visual consistency across screens.

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Application programming language |
| Git | Version control |
| GitHub | Source control |
| VS Code | Development environment |

---

## Architecture

KINETIQ is organized into modular screens, models, services, themes, and reusable UI components.

```text
lib/
│
├── models/
├── services/
├── screens/
│   ├── home/
│   ├── workout/
│   ├── progress/
│   ├── nutrition/
│   └── social/
│
├── widgets/
├── themes/
└── main.dart

