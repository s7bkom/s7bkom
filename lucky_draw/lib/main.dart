import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lucky_draw/auth_gate.dart';
import 'package:flutter_config/flutter_config.dart'; // Import flutter_config

// This function will be called when a background message is received
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure FlutterConfig is initialized for background messages as well
  await FlutterConfig.loadEnvVariables();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: FlutterConfig.get('FIREBASE_API_KEY'),
      appId: FlutterConfig.get('FIREBASE_APP_ID'),
      projectId: FlutterConfig.get('FIREBASE_PROJECT_ID'),
      // Add other fields from google-services.json as needed
      // messagingSenderId: FlutterConfig.get('FIREBASE_MESSAGING_SENDER_ID'),
      // storageBucket: FlutterConfig.get('FIREBASE_STORAGE_BUCKET'),
    ),
  );
  print('Handling a background message: ${message.messageId}');
  // You can add more logic here to handle the notification, e.g., show a local notification
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables(); // Load environment variables
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: FlutterConfig.get('FIREBASE_API_KEY'),
      appId: FlutterConfig.get('FIREBASE_APP_ID'),
      projectId: FlutterConfig.get('FIREBASE_PROJECT_ID'),
      // Add other fields from google-services.json as needed
      // messagingSenderId: FlutterConfig.get('FIREBASE_MESSAGING_SENDER_ID'),
      // storageBucket: FlutterConfig.get('FIREBASE_STORAGE_BUCKET'),
    ),
  );

  // Request permission for notifications
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  // Get FCM token
  String? token = await messaging.getToken();
  print('FCM Token: $token');
  // Save this token to the user's profile in Firestore when they log in or sign up
  // This will be handled in AuthGate or AuthScreen after authentication.

  // Listen for foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      // You can show a local notification here
    }
  });

  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lucky Draw',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 106, 253, 255)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
