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
      backgroundColor: const Color(0xFFE3F2FD),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Witaj!",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Zaloguj się przez Google, aby korzystać z notatnika.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blueGrey.shade700,
                ),
              ),
              SizedBox(height: 48),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade900,
                  minimumSize: Size(double.infinity, 50),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                  ),
                  side: BorderSide(
                    color: Colors.blue.shade900,
                    width: 2,
                  ),
                ),
                icon: Image.asset(
                  'assets/google_logo.png',
                  height: 28,
                  width: 28,
                ),
                label: Text(
                  "Zaloguj się z Google",
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
                            (_) => DashboardScreen(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
