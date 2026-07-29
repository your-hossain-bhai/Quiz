# Data Models

Core entities defined in `lib/models/`.

- **`User`**: Represents an authenticated user profile.
- **`Quiz`**: Core metadata for a quiz (ID, title, description).
- **`Question`**: Individual questions belonging to a quiz, including options and correct answers.
- **`QuizResult`**: The outcome of a completed quiz session (score, time taken).
- **`ScoreboardEntry`**: Ranked user scores used for leaderboards. Stored remotely in Firestore and cached locally via `hive`.
