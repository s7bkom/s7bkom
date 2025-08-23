import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lucky_draw_admin/firebase_options.dart';
import 'package:lucky_draw_admin/admin_auth_gate.dart'; // Will create this file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
