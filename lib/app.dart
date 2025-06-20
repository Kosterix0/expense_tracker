import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/widgets/app_drawer.dart';


class AppScaffold extends ConsumerWidget {
  final Widget body;
  final String title;
  final TabBar? bottomTabBar;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.body,
    required this.title,
    this.bottomTabBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      drawer:
          user != null ? AppDrawer(user: user) : null,
      appBar: AppBar(
        title: Text(title),
        bottom: bottomTabBar,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
