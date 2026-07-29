# Routing Guide

The Quiz App uses `go_router` for declarative routing.

## 1. Defining a Route

All route configuration is centralized in `lib/app_route.dart`. 
The `AppRoute` class holds static string constants for path names, which you should always use to prevent typos when navigating.

To add a new page:
1. Define a constant: `static const String myNewPage = '/my-new-page';`
2. Add a `GoRoute` entry in the `routes` array of the `GoRouter` instance.

## 2. Authentication Redirect

The router is configured with a global `redirect` handler that listens to `FirebaseAuth.instance.authStateChanges()` via a custom `GoRouteRefreshStream`. 

- If a user is **not logged in** and tries to access a protected route, they are automatically redirected to `AppRoute.login`.
- If a user is **logged in** and tries to access login or signup, they are redirected to `AppRoute.home`.

## 3. Passing Arguments

To pass complex objects (like a list of `Question` or a `QuizResult`) to a route, use the `extra` property of `GoRouter`.

**Navigating and passing data:**
```dart
context.push(AppRoute.quizResult, extra: myResultObject);
```

**Retrieving data in `app_route.dart`:**
```dart
GoRoute(
  path: AppRoute.quizResult,
  builder: (context, state) {
    final result = state.extra as QuizResult;
    return ResultPage(result: result);
  },
)
```
