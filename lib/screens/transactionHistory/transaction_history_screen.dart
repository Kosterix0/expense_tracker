import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:expense_tracker/domain/expense_state.dart';
import 'package:expense_tracker/screens/expense/expense_details_screen.dart';
import 'package:expense_tracker/domain/currency.dart'; // Dodaj ten import

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);

    return AppScaffold(
      title: 'Historia transakcji',
      body: RefreshIndicator(
        onRefresh:
            () async => ref.refresh(transactionProvider),
        child:
            transactions.isEmpty
                ? const Center(
                  child: Text('Brak transakcji'),
                )
                : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  itemCount: transactions.length,
                  separatorBuilder:
                      (_, __) =>
                          const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final t = transactions[i];
                    final isExpense =
                        t.type ==
                        TransactionType.expense;
                    return ListTile(
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      ExpenseDetailScreen(
                                        expense: t,
                                      ),
                            ),
                          ),
                      leading: CircleAvatar(
                        backgroundColor:
                            isExpense
                                ? Colors.red
                                : Colors.green,
                        child: Text(
                          t.category.name
                              .toUpperCase()[0],
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text(t.title),
                      subtitle: Text(
                        '${t.category.displayName} · ${DateFormat.yMMMd().format(t.date)}',
                      ),
                      trailing: Text(
                        '${isExpense ? '-' : '+'}${t.amount.toStringAsFixed(2)} ${t.currency.symbol}',
                        style: TextStyle(
                          color:
                              isExpense
                                  ? Colors.red
                                  : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
