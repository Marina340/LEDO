# LEDO App

Beautiful, consistent Flutter app for onboarding, personality quiz missions, and progress tracking with Firebase Auth.

## Overview

This app guides a user through a one-time onboarding experience, signs in with Firebase Authentication, and lets the user complete quiz missions. Progress is saved locally so the user can resume where they left off. The Home page provides an elegant entry point to resume or start fresh, and users can log out at any time.

## Getting Started

- Flutter SDK 3.x
- Firebase project configured (see `lib/firebase_options.dart`)

Install dependencies and run:

```bash
flutter pub get
flutter run
```

## App Architecture

- UI layer in `lib/pages/` and `lib/ui/widgets/`
- Domain models in `lib/models/`
- Content repository (mock) in `lib/repositories/`
- Local preferences in `lib/services/preferences_service.dart`
- Auth wrapper in `lib/services/auth_service.dart`
- In-memory/game session in `lib/state/game_state.dart`
- Theming in `lib/theme/`

## Key Flows

- Authentication gate: `lib/pages/auth_gate.dart`
  - Listens to Firebase Auth state.
  - Routes logged-out users to `LoginPage`.
  - Routes first-time logged-in users to `OnboardingPage` (checks `PreferencesService.onboarded`).
  - Otherwise routes to `HomePage`.

- Onboarding: `lib/pages/onboarding_page.dart`
  - Conversational UI with nickname capture.
  - Persists `onboarded=true` and `username` in `PreferencesService` when finishing.
  - Transitions into `QuizPage`.

- Home: `lib/pages/home_page.dart`
  - Greets the user by nickname or email.
  - If there is saved progress, shows “Resume where I left off” with icon.
  - Otherwise shows a “Start” action (onboards first if needed).
  - Provides a logout action in the AppBar.

- Quiz: `lib/pages/quiz_page.dart`
  - Loads missions from `MockContentRepository`.
  - Displays dialogue and questions.
  - Ensures all answer options have equal width for clean alignment.
  - Saves answer selection and progress (index/score) into `GameState` which also syncs last progress to preferences.
  - Supports a short delay before options appear and transitions between questions.

## Important Files

- `lib/main.dart`
  - Initializes Firebase and `PreferencesService`, hydrates `GameState` from saved progress.
  - Sets up `MaterialApp` with global theme.

- `lib/pages/auth_gate.dart`
  - Auth stream -> routes to `LoginPage`, `OnboardingPage`, or `HomePage`.

- `lib/pages/login_page.dart`
  - Simple email/password login using `AuthService`.
  - Minimal header via `GameHeader` (avatar hidden on login).

- `lib/pages/home_page.dart`
  - Polished UI with gradient background, welcome header, and icon buttons.
  - Resume/start actions based on saved progress and onboarding status.
  - Logout in AppBar.

- `lib/pages/onboarding_page.dart`
  - Chat-like bubbles (`ChatBubble`) and nickname field.
  - Saves `username` and `onboarded` to `PreferencesService` before entering the quiz.

- `lib/pages/quiz_page.dart`
  - Uses `GameHeader` at the top and shows progress bar and coin score.
  - Options use `OptionTile` and are stretched to full width for consistent layout.
  - Persists progress/answers via `GameState`, which mirrors last progress to preferences.

- `lib/repositories/content_repository.dart`
  - `ContentRepository` abstract + `MockContentRepository` implementation.
  - Missions (`fetchMission1/2/3`) with `DialogueLine` and `Question` entries.
  - For early MCQ questions, each option now explicitly sets `isCorrect` where appropriate.

- `lib/state/game_state.dart`
  - Keeps in-memory coins, completed missions, current progress, and selected answers.
  - Persists last mission progress to `PreferencesService` and hydrates on app start.

- `lib/services/preferences_service.dart`
  - Thin wrapper over `shared_preferences` for:
    - Onboarding completion
    - Username
    - Last mission progress (missionId, contentIndex, score)

- `lib/services/auth_service.dart`
  - Wraps `FirebaseAuth` for `signIn`, `signOut`, and `authStateChanges` stream.

- `lib/ui/widgets/option_tile.dart`
  - Styled answer option tile supporting states: selected, correct, incorrect.

- `lib/ui/widgets/primary_button.dart`
  - Uniform CTA button used across screens.

- `lib/ui/widgets/chat_bubble.dart`
  - Bubble for onboarding chat UI.

- `lib/ui/widgets/game_header.dart`
  - Minimal, centered header with optional back button and avatar.

## Theming & Assets

- Light theme in `lib/theme/app_theme.dart`.
- Assets declared in `pubspec.yaml` under `flutter/assets`:
  - `assets/images/logo.png`
  - `assets/images/coin.png`

## Persistence

- Local: `shared_preferences` via `PreferencesService`.
- In-memory session: `GameState`.
- Firebase Auth for user session.

## Extending

- Replace `MockContentRepository` with a real backend or Firestore collection.
- Add more missions and question types by extending `models` and repository.
- Add badges, leaderboards, and richer profile on `HomePage`.

## Troubleshooting

- If onboarding shows again unexpectedly, ensure `PreferencesService.init()` is called before `runApp` and that `AuthGate` reads `onboarded` correctly.
- If assets fail to load, run `flutter pub get` and check `pubspec.yaml` asset paths.
