# Getting Started

Welcome to the Quiz App! This tutorial will guide you through setting up the project locally for development.

## Prerequisites

Before you begin, ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.11.5 or higher recommended)
- [Git](https://git-scm.com/downloads)
- A code editor (like VS Code or Android Studio)
- [Firebase CLI](https://firebase.google.com/docs/cli) (optional, if you intend to reconfigure Firebase)

## 1. Clone the Repository

Clone the project to your local machine:
```bash
git clone <repository_url>
cd quiz_app
```

## 2. Install Dependencies

Fetch all the required Dart and Flutter packages:
```bash
flutter pub get
```

## 3. Generate Hive Adapters (If needed)

The app uses `hive` for local storage, which requires code generation for custom adapters. If you modify any models stored in Hive, you'll need to run the build runner:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## 4. Run the App

You are now ready to run the app. Make sure you have an emulator running or a physical device connected:
```bash
flutter run
```

## Next Steps
Now that the app is running, check out the [Architecture Explanation](../explanation/architecture.md) to understand how the code is structured!
