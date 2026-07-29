# State Management

A brief guide to handling app state using the `provider` package.

## Core Providers
Located in `lib/providers/`:
- **`AuthProvider`**: Manages login/signup state and the current user session.
- **`QuizProvider`**: Handles the active quiz state (current question index, selected answers, current score).
- **`ScoreboardProvider`**: Fetches leaderboard data from Firestore and manages the local cache.
- **`ProfileProvider`**: Manages user profile details and stats.

## Adding a New Provider
1. Create a class extending `ChangeNotifier` in `lib/providers/`.
2. Inject it:
   - **Globally**: Add it to `MultiProvider` in `lib/main.dart` if needed everywhere.
   - **Locally**: Wrap a specific page or widget subtree with `ChangeNotifierProvider`.
3. Call `notifyListeners()` whenever state variables change to trigger a UI rebuild.
