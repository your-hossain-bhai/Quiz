import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/models/question.dart';
import 'package:quiz_app/models/quiz_result.dart';
import 'package:quiz_app/pages/ai_page.dart';
import 'package:quiz_app/pages/login_page.dart';
import 'package:quiz_app/pages/result_page.dart';
import 'package:quiz_app/pages/review_answers_page.dart';
import 'package:quiz_app/pages/scoreboard_page.dart';
import 'package:quiz_app/pages/signup_page.dart';

import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/quiz_loading_page.dart';
import 'pages/quiz_management_page.dart';
import 'pages/quiz_question_page.dart';
import 'pages/subscription_page.dart';
import 'utils/go_route_refresh_stream.dart';

class AppRoute {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String quizQuestion = '/quiz-question';
  static const String quizLoading = '/quiz-loading';
  static const String quizManagement = '/quiz-management';
  static const String quizResult = '/quiz-result';
  static const String reviewAnswers = '/review-answers';
  static const String scoreboard = '/scoreboard';
  static const String profile = '/profile';
  static const String ai = '/ai-interaction';
  static const String subscription = '/subscription';

  static final routes = GoRouter(
    initialLocation: login,
    refreshListenable: GoRouteRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final isLoginRoute =
          state.matchedLocation == login || state.matchedLocation == signup;

      if (!isLoggedIn && !isLoginRoute) {
        return login;
      } else if (isLoggedIn && isLoginRoute) {
        return home;
      }
      return null;
    },
    routes: [
      GoRoute(path: home, builder: (context, state) => HomePage()),
      GoRoute(path: login, builder: (context, state) => LoginPage()),
      GoRoute(path: signup, builder: (context, state) => SignupPage()),
      GoRoute(
        path: quizQuestion,
        builder: (context, state) =>
            QuizQuestionPage(questions: state.extra as List<Question>),
      ),
      GoRoute(
        path: quizLoading,
        builder: (context, state) => QuizLoadingPage(),
      ),
      GoRoute(
        path: quizManagement,
        builder: (context, state) => QuizManagementPage(),
      ),
      GoRoute(
        path: quizResult,
        builder: (context, state) {
          final result = state.extra as QuizResult;
          return ResultPage(result: result);
        },
      ),
      GoRoute(
        path: reviewAnswers,
        builder: (context, state) {
          final result = state.extra as QuizResult;
          return ReviewAnswersPage(result: result);
        },
      ),
      GoRoute(
        path: AppRoute.scoreboard,
        builder: (context, state) => ScoreboardPage(),
      ),
      GoRoute(
        path: AppRoute.profile,
        builder: (context, state) => ProfilePage(),
      ),
      GoRoute(path: AppRoute.ai, builder: (context, state) => AiPage()),
      GoRoute(
        path: AppRoute.subscription,
        builder: (context, state) => SubscriptionPage(),
      ),
    ],
  );
}
