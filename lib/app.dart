import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/widgets/app_drawer.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:expense_tracker/services/budget_service.dart';
import 'package:expense_tracker/domain/expense_state.dart';
import 'package:expense_tracker/domain/currency.dart'; // Dodaj ten import

class AppScaffold extends ConsumerWidget {
  final Widget body;
  final String title;
  final TabBar? bottomTabBar;
  final Widget? floatingActionButton;

  const AppScaffold({
    Key? key,
    required this.body,
    required this.title,
    this.bottomTabBar,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser!;
    final transactions = ref.watch(transactionProvider);
    final budget = ref.watch(budgetProvider);

    // Oblicz sumę wydatków (w walucie budżetu)
    double totalExpenses = 0;
    for (var t in transactions) {
      if (t.type == TransactionType.expense) {
        totalExpenses += t.baseAmount;
      }
    }

    // Oblicz pozostały budżet
    double remaining = 0;
    if (budget.isSet) {
      remaining = budget.amount - totalExpenses;
    }

    return Scaffold(
      drawer: AppDrawer(user: user),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            if (budget.isSet)
              Text(
                'Pozostały budżet: ${remaining.toStringAsFixed(2)} ${budget.currency.code}',
                style: const TextStyle(fontSize: 14),
              ),
          ],
        ),
        bottom: bottomTabBar,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
