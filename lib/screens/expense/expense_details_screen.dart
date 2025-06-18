import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:expense_tracker/domain/expense_state.dart';
import 'package:expense_tracker/screens/expense/add_expense_screen.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/domain/currency.dart'; // Dodaj ten import

class ExpenseDetailScreen extends ConsumerWidget {
  final ExpenseState expense;

  const ExpenseDetailScreen({
    Key? key,
    required this.expense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły transakcji'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => AddExpenseScreen(
                        expense: expense,
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildDetailsView(context, ref),
    );
  }

  Widget _buildDetailsView(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              expense.title,
              style:
                  Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: Text(
              DateFormat.yMMMMd().format(expense.date),
            ),
            trailing: Text(
              '${expense.type == TransactionType.expense ? '-' : '+'}${expense.amount.toStringAsFixed(2)} ${expense.currency.symbol}',
              style: TextStyle(
                color:
                    expense.type ==
                            TransactionType.expense
                        ? Colors.red
                        : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const Divider(),
          _buildDetailRow(
            'Kategoria',
            expense.category.displayName,
          ),
          _buildDetailRow(
            'Typ',
            expense.type == TransactionType.expense
                ? 'Wydatek'
                : 'Przychód',
          ),
          _buildDetailRow(
            'Waluta',
            '${expense.currency.name} (${expense.currency.code})',
          ),
          _buildDetailRow(
            'Opis',
            expense.description.isNotEmpty
                ? expense.description
                : 'Brak opisu',
          ),
          const Spacer(),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Usuń transakcję'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(
                double.infinity,
                50,
              ),
            ),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: const Text('Usuwać?'),
                      content: const Text(
                        'Czy na pewno chcesz usunąć tę transakcję?',
                      ),
                      actions: [
                        TextButton(
                          onPressed:
                              () => Navigator.pop(
                                ctx,
                                false,
                              ),
                          child: const Text('Anuluj'),
                        ),
                        TextButton(
                          onPressed:
                              () => Navigator.pop(
                                ctx,
                                true,
                              ),
                          child: const Text(
                            'Usuń',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
              );

              if (confirm == true) {
                await ref
                    .read(transactionProvider.notifier)
                    .deleteExpense(expense.id);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(value),
          const Divider(),
        ],
      ),
    );
  }
}
