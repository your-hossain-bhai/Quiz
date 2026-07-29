import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/firebase_options.dart';
import 'package:quiz_app/models/scoreboard_entry.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:quiz_app/providers/profile_provider.dart';
import 'package:quiz_app/providers/scoreboard_provider.dart';
import 'package:quiz_app/providers/subscription_provider.dart';

import 'package:quiz_app/repository/auth_repository.dart';
import 'package:quiz_app/repository/profile_repository.dart';
import 'package:quiz_app/repository/scoreboard_repository.dart';
import 'package:quiz_app/repository/quiz_repository.dart';
import 'package:quiz_app/repository/ai_repository.dart';
import 'package:quiz_app/services/firestore_service.dart';
import 'package:quiz_app/services/storage_service.dart';
import 'package:quiz_app/services/auth_service.dart';
import 'package:quiz_app/services/hive_storage_service.dart';
import 'package:quiz_app/services/api_client.dart';
import 'package:quiz_app/services/ai_service.dart';
import 'package:quiz_app/services/push_notification_service.dart';

import 'app_route.dart';
import 'providers/quiz_provider.dart';
import 'providers/ai_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  Hive.registerAdapter(ScoreboardEntryAdapter());

  // Initialize Services
  final firestoreService = FirestoreService();
  final storageService = StorageService();
  final authService = AuthService();
  final hiveStorageService = HiveStorageService();
  final apiClient = ApiClient();
  final aiService = AiService();
  final pushNotificationService = PushNotificationService();
  await pushNotificationService.initialize();

  // Initialize Repositories
  final authRepository = AuthRepository(
    authService: authService,
    firestoreService: firestoreService,
  );
  final profileRepository = ProfileRepository(
    firestoreService: firestoreService,
    storageService: storageService,
  );
  final scoreboardRepository = ScoreboardRepository(
    firestoreService: firestoreService,
    hiveStorageService: hiveStorageService,
  );
  final quizRepository = QuizRepository(apiClient: apiClient);
  final aiRepository = AiRepository(aiService: aiService);

  runApp(
    QuizApp(
      authRepository: authRepository,
      profileRepository: profileRepository,
      scoreboardRepository: scoreboardRepository,
      quizRepository: quizRepository,
      aiRepository: aiRepository,
    ),
  );
}

class QuizApp extends StatelessWidget {
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;
  final ScoreboardRepository scoreboardRepository;
  final QuizRepository quizRepository;
  final AiRepository aiRepository;

  const QuizApp({
    super.key,
    required this.authRepository,
    required this.profileRepository,
    required this.scoreboardRepository,
    required this.quizRepository,
    required this.aiRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => QuizProvider(repository: quizRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ScoreboardProvider(repository: scoreboardRepository)
                ..loadHistory(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(profileRepository: profileRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AiProvider(aiRepository: aiRepository),
        ),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: MaterialApp.router(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          scaffoldBackgroundColor: const Color(0xFFF7F8FC),
          cardTheme: CardTheme(
            color: Colors.white,
            elevation: 1,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          textTheme: const TextTheme(
            titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
          ),
          navigationBarTheme: NavigationBarThemeData(
            indicatorColor: Colors.indigo.withValues(alpha: 0.14),
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontWeight: FontWeight.w600),
            ),
            iconTheme: WidgetStateProperty.all(const IconThemeData(size: 24)),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData.dark(useMaterial3: true),
        themeMode: ThemeMode.light,
        routerConfig: AppRoute.routes,
      ),
    );
  }
}
