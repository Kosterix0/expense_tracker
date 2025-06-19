// login_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/screens/dashboard/dashboard_screen.dart';
import 'package:expense_tracker/auth/sign_google.dart';

class SignInScreen extends StatelessWidget {
  final GoogleAuthService _authService =
      GoogleAuthService();

  SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth:
                  500, // Ograniczenie maksymalnej szerokości
              minHeight:
                  500, // Minimalna wysokość dla lepszego wyglądu
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 40.0,
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome!",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[400],
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Sign in with Google to use the expense tracker.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.green[400],
                      minimumSize: const Size(
                        double.infinity,
                        50,
                      ),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: Colors.green[400]!,
                        width: 2,
                      ),
                    ),
                    icon: Image.asset(
                      'assets/google_logo.png',
                      height: 28,
                      width: 28,
                    ),
                    label: const Text(
                      "Sign in with Google",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () async {
                      User? user =
                          await _authService
                              .signInWithGoogle();
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    const DashboardScreen(),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
