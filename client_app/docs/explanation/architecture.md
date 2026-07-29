# Architecture

The Quiz App follows a layered architecture to separate business logic from the user interface.

## 1. Directory Structure

- `lib/models/`: Contains standard Dart data classes (e.g., `User`, `QuizResult`). Models hold no business logic or external dependencies.
- `lib/providers/`: Houses the state management logic using `ChangeNotifier`. Providers interact with services to fetch data and notify listeners (UI) when the state changes.
- `lib/services/`: Wraps external dependencies such as Firebase Firestore (`FirestoreService`), Authentication (`AuthService`), and local caching (`HiveStorageService`).
- `lib/pages/`: Contains the top-level UI screens.
- `lib/widgets/`: Modular, reusable UI components used across multiple pages.
- `lib/utils/`: Helper methods, themes, and constants.

## 2. State Management

We use `Provider` (`ChangeNotifierProvider`) for managing state. 
Providers are injected globally in `lib/main.dart` if their state is required across multiple features (e.g., `AuthProvider`, `ProfileProvider`, `QuizProvider`), or locally if their scope is limited. 

Pages should not call services directly; instead, they should read or watch a Provider which handles the service interaction.

## 3. Storage Strategy

- **Remote**: Firebase Firestore is the primary remote source of truth for users and scores.
- **Local**: `Hive` is used for fast, synchronous local caching (e.g., storing a `ScoreboardEntry` offline using `ScoreboardEntryAdapter`).
