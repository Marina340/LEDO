# LEDO App

Beautiful, consistent Flutter app for onboarding, personality quiz missions, and progress tracking with Firebase Auth.

## Overview

This app guides a user through a one-time onboarding experience, signs in with Firebase Authentication, and lets the user complete quiz missions. Content (missions and questions) is loaded from Firestore, and user progress is saved both locally (for instant resume) and to Firestore (for user stats). The Home page provides an elegant entry point to resume or start fresh, and users can log out at any time.

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
- Content repository in `lib/repositories/`
  - `content_repository_firebase.dart` (Firebase-backed, used by the UI)
  - `content_repository.dart` (abstract + mock implementation for reference/offline)
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
  - Loads missions from `FirebaseContentRepository` (Firestore-backed).
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
- Firestore for missions and cloud progress mirror.

## Firebase Integration

- Auth: `lib/services/auth_service.dart` wraps `FirebaseAuth` for login/logout and exposes `currentUser` and the auth state stream.
- Repository: `lib/repositories/content_repository_firebase.dart` implements `ContentRepository` over Firestore.
  - Constructor requires a `getUserId` callback to read the current UID (e.g., `() => FirebaseAuth.instance.currentUser!.uid`).
  - Pages that use it:
    - `lib/pages/onboarding_page.dart` (for onboarding dialogue, currently local list but repo is instantiated here)
    - `lib/pages/quiz_page.dart` (fetches missions and saves progress)
- Home reset: `lib/pages/home_page.dart` updates `users/{uid}.totalPoints = 0` when you tap “Start over”.

Dependencies (pubspec):
- `firebase_core`
- `firebase_auth`
- `cloud_firestore`

Initialization (example in `main.dart`):
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PreferencesService.init();
  GameState.instance.hydrateFromPrefs();
  runApp(const MyApp());
}
```

## Firestore Data Model

- Collection: `missions`
  - Documents: `mission1`, `mission2`, `mission3` (the repo also accepts `m1/m2/m3` and tries both IDs)
  - Fields (you can choose one of these approaches; the repo supports both):
    - Approach A (string field with full mission JSON object):
      - `content`: string containing the entire mission JSON object (including its `content` array)
      - Optional helper fields for listing/sorting: `title`, `description`, `level`, `order`, `pointsPerAnswer`, `requiredScore`, `nextMissionId`
    - Approach B (flat document with an array field):
      - `id`, `title`, `description`, `pointsPerAnswer`, `requiredScore`, `nextMissionId`
      - `content`: array of content blocks where each block is either:
        - Dialogue: `{ "type": "dialogue", "id": string, "text": string, "character"?: string, "imagePath"?: string, "waitForInput"?: bool }`
        - Question: `{ "type": "question", "id": string, "prompt": string, "questionType": "mcq"|"trueFalse"|"matching"|..., "options": [ { "id": string, "text": string, "imageUrl"?: string, "isCorrect"?: bool, "group"?: string } ], "hint"?: string, "maxAttempts"?: number, "showHintAfterIncorrect"?: bool }`

- Collection: `users`
  - Document: `{uid}`
    - Fields (profile/status):
      - `displayName`: string
      - `email`: string
      - `currentLevel`: number (optional)
      - `currentMissionId`: string (e.g., `m1`)
      - `totalPoints`: number
      - `createdAt`: timestamp
      - `updatedAt`: timestamp
    - Subcollection: `progress`
      - Document: `{missionId}` (e.g., `m1` or `mission1`)
      - Fields:
        - `missionId`: string
        - `score`: number
        - `maxScore`: number
        - `isCompleted`: bool
        - `completedAt`: timestamp|null
        - `answers`: map of questionId -> `{ selectedOptionId: string, isCorrect: bool|null, attempts: number }`

## Data Flow (UI ↔ Repository ↔ Firestore)

- `QuizPage` calls `contentRepo.fetchMissionById(missionId)`
  - The repo tries `missions/{mId}` and alternatively `missions/missionN`.
  - Mission JSON is parsed from either `details`/`content` string or a flat `content` array.
- When the user selects an answer:
  - `GameState.saveProgress()` updates in-memory state and persists last mission progress to `PreferencesService` for instant resume.
  - `FirebaseContentRepository.saveMissionProgress()` writes `users/{uid}/progress/{missionId}` and mirrors `currentMissionId` + `totalPoints` in `users/{uid}`.

## Runtime Behavior (Resume / Start Over)

- Resume
  - `HomePage` shows “Resume where I left off” if `PreferencesService.lastMissionId` is set.
  - Tapping Resume navigates to `QuizPage(missionId: lastMissionId)`. `QuizPage` hydrates `_contentIndex` and `_score` from `PreferencesService` and in-memory `GameState`.

- Start Over
  - On `HomePage`, tapping “Start over” resets local state (`GameState.reset()` and `PreferencesService.clearLastProgress()`).
  - Also sets `users/{uid}.totalPoints = 0` in Firestore.
  - Navigates to `OnboardingPage`.

## Where Firebase Is Wired In

- `lib/pages/onboarding_page.dart`
  - Instantiates `FirebaseContentRepository` with `getUserId: () => AuthService().currentUser!.uid`.
- `lib/pages/quiz_page.dart`
  - Instantiates `FirebaseContentRepository` similarly and loads missions from Firestore.
  - Saves Firestore mission progress after each answer and when finishing a mission.
- `lib/pages/home_page.dart`
  - On “Start over”, resets Firestore `totalPoints` to 0 and clears local progress.

## Extending

- Extend the mission schema (e.g., add new `questionType`s like `fillIn`, `dragDrop`, `grouping`). The parser already supports these keys.
- Add more missions and question types by extending `models` and repository.
- Add badges, leaderboards, and richer profile on `HomePage`.

## Troubleshooting

- If onboarding shows again unexpectedly, ensure `PreferencesService.init()` is called before `runApp` and that `AuthGate` reads `onboarded` correctly.
- If assets fail to load, run `flutter pub get` and check `pubspec.yaml` asset paths.
 - If you see “No content available for this mission”, verify your Firestore mission doc:
   - If `content` is a string, it must be valid JSON (either an array of blocks or a full mission object containing a `content` array).
   - Prefer “Edit as text” in the console to avoid double-escaping JSON.
