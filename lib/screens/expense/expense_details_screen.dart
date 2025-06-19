import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:expense_tracker/domain/expense_state.dart';
import 'package:expense_tracker/screens/expense/add_expense_screen.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/domain/currency.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final ExpenseState expense;

  const ExpenseDetailScreen({
    Key? key,
    required this.expense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Transaction Details'),
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
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
            subtitle: Text(
              DateFormat.yMMMMd().format(expense.date),
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
            trailing: Text(
              '${expense.type == TransactionType.expense ? '-' : '+'}${expense.amount.toStringAsFixed(2)} ${expense.currency.symbol}',
              style: TextStyle(
                color:
                    expense.type ==
                            TransactionType.expense
                        ? Colors.red[400]
                        : Colors.green[400],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const Divider(color: Colors.grey),
          _buildDetailRow(
            'Category',
            expense.category.displayName,
          ),
          _buildDetailRow(
            'Type',
            expense.type == TransactionType.expense
                ? 'Expense'
                : 'Income',
          ),
          _buildDetailRow(
            'Currency',
            '${expense.currency.name} (${expense.currency.code})',
          ),
          _buildDetailRow(
            'Description',
            expense.description.isNotEmpty
                ? expense.description
                : 'No description',
          ),
          const Spacer(),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text(
              'Delete Transaction',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[800],
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
                      title: const Text(
                        'Confirm Delete',
                      ),
                      content: const Text(
                        'Are you sure you want to delete this transaction?',
                      ),
                      actions: [
                        TextButton(
                          onPressed:
                              () => Navigator.pop(
                                ctx,
                                false,
                              ),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed:
                              () => Navigator.pop(
                                ctx,
                                true,
                              ),
                          child: const Text(
                            'Delete',
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
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
          const Divider(color: Colors.grey),
        ],
      ),
    );
  }
}
