import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucky_draw_admin/screens/admin_home_screen.dart'; // Will create this
import 'package:lucky_draw_admin/screens/admin_auth_screen.dart'; // Will create this

class AdminAuthGate extends StatelessWidget {
  const AdminAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const AdminAuthScreen();
        }
        // Optional: Check if the user is an admin based on custom claims or a separate Firestore collection
        // For simplicity, we'll assume any logged-in user can access the admin panel for now.
        return const AdminHomeScreen();
      },
    );
  }
}
