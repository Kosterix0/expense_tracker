import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:expense_tracker/domain/expense_state.dart';
import 'package:expense_tracker/screens/expense/expense_details_screen.dart';
import 'package:expense_tracker/domain/currency.dart';

class TransactionHistoryScreen
    extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen>
  createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  final DateFormat _monthFormat = DateFormat(
    'MMMM yyyy',
  );

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);

    final filteredTransactions =
        transactions.where((t) {
          return t.date.year == _selectedDate.year &&
              t.date.month == _selectedDate.month;
        }).toList();

    return AppScaffold(
      title: 'Transaction History',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 800,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          _selectedDate = DateTime(
                            _selectedDate.year,
                            _selectedDate.month - 1,
                          );
                        });
                      },
                    ),
                    TextButton(
                      onPressed:
                          () => _selectDate(context),
                      child: Text(
                        _monthFormat.format(
                          _selectedDate,
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedDate = DateTime(
                            _selectedDate.year,
                            _selectedDate.month + 1,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh:
                      () async => ref.refresh(
                        transactionProvider,
                      ),
                  child:
                      filteredTransactions.isEmpty
                          ? const Center(
                            child: Text(
                              'No transactions',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          )
                          : ListView.separated(
                            padding:
                                const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                            itemCount:
                                filteredTransactions
                                    .length,
                            separatorBuilder:
                                (_, __) => const Divider(
                                  height: 1,
                                  color: Colors.grey,
                                ),
                            itemBuilder: (_, i) {
                              final t =
                                  filteredTransactions[i];
                              final isExpense =
                                  t.type ==
                                  TransactionType
                                      .expense;
                              return ListTile(
                                tileColor:
                                    Colors.grey[850],
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) =>
                                                ExpenseDetailScreen(
                                                  expense:
                                                      t,
                                                ),
                                      ),
                                    ),
                                leading: CircleAvatar(
                                  backgroundColor:
                                      isExpense
                                          ? Colors
                                              .red[800]
                                          : Colors
                                              .green[800],
                                  child: Text(
                                    t
                                        .category
                                        .displayName
                                        .toUpperCase()[0],
                                    style:
                                        const TextStyle(
                                          color:
                                              Colors
                                                  .white,
                                        ),
                                  ),
                                ),
                                title: Text(
                                  t.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  '${t.category.displayName} · ${DateFormat.yMMMd().format(t.date)}',
                                  style: const TextStyle(
                                    color:
                                        Colors.white70,
                                  ),
                                ),
                                trailing: Text(
                                  '${isExpense ? '-' : '+'}${t.amount.toStringAsFixed(2)} ${t.currency.symbol}',
                                  style: TextStyle(
                                    color:
                                        isExpense
                                            ? Colors
                                                .red[400]
                                            : Colors
                                                .green[400],
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
