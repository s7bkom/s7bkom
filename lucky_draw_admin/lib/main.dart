import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lucky_draw_admin/admin_auth_gate.dart'; // Will create this file
import 'package:flutter_config/flutter_config.dart'; // Import flutter_config

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables(); // Load environment variables
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: FlutterConfig.get('FIREBASE_API_KEY'),
      appId: FlutterConfig.get('FIREBASE_APP_ID'),
      projectId: FlutterConfig.get('FIREBASE_PROJECT_ID'),
      messagingSenderId: FlutterConfig.get('FIREBASE_MESSAGING_SENDER_ID'),
      // Add other fields from google-services.json as needed
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lucky Draw Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const AdminAuthGate(),
    );
  }
}
