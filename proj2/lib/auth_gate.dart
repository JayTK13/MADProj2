import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj2/screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/test_firestore_screen.dart';
import 'screens/home_screen.dart';

// This widget checks the authentication state of the user and directs them to the
//appropriate screen (Home or Login).
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  // The build method listens to the authentication state changes and returns either the
  // HomeScreen if the user is authenticated or the LoginScreen if not. It also shows a
  //loading indicator while waiting for the authentication state to be determined.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
