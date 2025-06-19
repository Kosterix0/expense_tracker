import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/auth/sign_google.dart';
import 'package:expense_tracker/screens/dashboard/dashboard_screen.dart';
import 'package:expense_tracker/screens/transactionHistory/transaction_history_screen.dart';
import 'package:expense_tracker/auth/screens/login_screen.dart';
import 'package:expense_tracker/screens/settings/settings_screen.dart';
import 'package:expense_tracker/screens/export/export_screen.dart';

class AppDrawer extends StatelessWidget {
  final User user;
  const AppDrawer({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final auth = GoogleAuthService();
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green[800],
              ),
              padding: const EdgeInsets.only(left: 16),
              alignment: Alignment.centerLeft,
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.dashboard,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  const DashboardScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.history,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Transaction History',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  const TransactionHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Budget Settings',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.import_export,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Export Data',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  const ExportScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Colors.grey),
                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () async {
                      try {
                        await auth.signOut();
                        Navigator.of(
                          context,
                        ).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder:
                                (_) => SignInScreen(),
                          ),
                          (route) => false,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Logout failed: ${e.toString()}',
                              ),
                              backgroundColor:
                                  Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Logged in as: ${user.email ?? 'Unknown'}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
