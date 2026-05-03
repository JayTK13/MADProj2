import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// This screen allows users to either log in or sign up using their email and password.
//It toggles between login and sign-up modes based on user interaction.
class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = AuthService();

  bool isLogin = true;

  void submit() async {
    if (isLogin) {
      await auth.login(emailController.text, passwordController.text);
    } else {
      await auth.signUp(emailController.text, passwordController.text);
    }
  }

  // The build method constructs the UI for the login screen,
  //including text fields for email and password, a submit button, and a toggle button
  //to switch between login and sign-up modes.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vibzcheck Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: submit,
              child: Text(isLogin ? "Login" : "Sign Up"),
            ),

            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(
                isLogin ? "Create account" : "Already have an account? Login",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
