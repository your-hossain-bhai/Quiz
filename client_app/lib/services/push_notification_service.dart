import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quiz_app/app_route.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling a background message: ${message.messageId}');
    print('Background message data payload: ${message.data}');
  }
}

class PushNotificationService {
  // Singleton pattern
  static final PushNotificationService _instance =
      PushNotificationService._internal();

  factory PushNotificationService() {
    return _instance;
  }

  PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  Future<void> initialize() async {
    // Request permission from the user
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('PushNotificationService: User granted permission');
      }
      // Get the FCM device token
      String? token = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print('PushNotificationService FCM Token: $token');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('PushNotificationService: User granted provisional permission');
      }
    } else {
      if (kDebugMode) {
        print(
          'PushNotificationService: User declined or has not accepted permission',
        );
      }
    }

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize flutter local notifications
    await _initLocalNotifications();

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Handling a foreground message: ${message.messageId}');
        print('Foreground message data payload: ${message.data}');
      }

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription:
                  'This channel is used for important notifications.',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    // Setup handling for interacted messages (tapped notifications)
    await _setupInteractedMessage();
  }

  Future<void> _setupInteractedMessage() async {
    // 1. Terminated state
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage, isInitial: true);
    }

    // 2. Background state
    // Handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message, isInitial: false);
    });
  }

  void _handleMessage(RemoteMessage message, {bool isInitial = false}) {
    if (kDebugMode) {
      print(
        'PushNotificationService: Handling interacted message: ${message.messageId}',
      );
      print('Message data payload: ${message.data}');
    }

    try {
      final data = message.data;
      // Safely extract the target path
      if (data.containsKey('path')) {
        final path = data['path'];
        if (path != null && path is String && path.isNotEmpty) {
          if (isInitial) {
            // Delay navigation for terminated state to allow go_router to fully mount
            // and auth state to resolve before pushing the route.
            Future.delayed(const Duration(milliseconds: 1000), () {
              AppRoute.routes.push(path);
            });
          } else {
            // App is already running in background, safe to push immediately
            AppRoute.routes.push(path);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          'PushNotificationService: Error parsing route from FCM message: $e',
        );
      }
    }
  }
}
