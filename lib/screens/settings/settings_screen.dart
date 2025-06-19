import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/services/budget_service.dart';
import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/domain/currency.dart';
import 'package:expense_tracker/domain/budget_state.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _budgetCtrl = TextEditingController();
  Currency _selectedCurrency = Currency.PLN;
  late int _selectedMonth;
  late int _selectedYear;
  final List<int> _years = List.generate(
    2050 - DateTime.now().year + 1,
    (index) => DateTime.now().year + index,
  );

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _loadCurrentBudget();
  }

  Future<void> _loadCurrentBudget() async {
    final budget = await ref
        .read(budgetProvider.notifier)
        .getBudgetForMonth(
          _selectedMonth,
          _selectedYear,
        );

    if (budget != null && budget.isSet) {
      setState(() {
        _budgetCtrl.text = budget.amount.toStringAsFixed(
          2,
        );
        _selectedCurrency = budget.currency;
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Budget Settings',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _budgetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monthly Budget',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: Colors.white70,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.green,
                    ),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter budget amount';
                  }
                  final n = double.tryParse(
                    value.replaceAll(',', '.'),
                  );
                  if (n == null || n <= 0) {
                    return 'Invalid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<Currency>(
                value: _selectedCurrency,
                decoration: const InputDecoration(
                  labelText: 'Budget Currency',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: Colors.white70,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.green,
                    ),
                  ),
                ),
                dropdownColor: Colors.grey[800],
                style: const TextStyle(
                  color: Colors.white,
                ),
                items:
                    Currency.values.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(
                          '${currency.name} (${currency.code})',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(
                      () => _selectedCurrency = value,
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedMonth,
                      decoration: const InputDecoration(
                        labelText: 'Month',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(
                          color: Colors.white70,
                        ),
                        enabledBorder:
                            OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                        focusedBorder:
                            OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.green,
                              ),
                            ),
                      ),
                      dropdownColor: Colors.grey[800],
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      menuMaxHeight: 300,
                      alignment: Alignment.bottomCenter,
                      items:
                          List.generate(
                                12,
                                (index) => index + 1,
                              )
                              .map(
                                (
                                  month,
                                ) => DropdownMenuItem(
                                  value: month,
                                  child: Text(
                                    _getMonthName(month),
                                    style:
                                        const TextStyle(
                                          color:
                                              Colors
                                                  .white,
                                        ),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) async {
                        if (value != null) {
                          setState(
                            () => _selectedMonth = value,
                          );
                          await _loadCurrentBudget();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(
                          color: Colors.white70,
                        ),
                        enabledBorder:
                            OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                        focusedBorder:
                            OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.green,
                              ),
                            ),
                      ),
                      dropdownColor: Colors.grey[800],
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      menuMaxHeight: 300,
                      alignment: Alignment.bottomCenter,
                      items:
                          _years
                              .map(
                                (
                                  year,
                                ) => DropdownMenuItem(
                                  value: year,
                                  child: Text(
                                    year.toString(),
                                    style:
                                        const TextStyle(
                                          color:
                                              Colors
                                                  .white,
                                        ),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) async {
                        if (value != null) {
                          setState(
                            () => _selectedYear = value,
                          );
                          await _loadCurrentBudget();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  minimumSize: const Size(
                    double.infinity,
                    50,
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!
                      .validate()) {
                    final amount = double.parse(
                      _budgetCtrl.text.replaceAll(
                        ',',
                        '.',
                      ),
                    );
                    await ref
                        .read(budgetProvider.notifier)
                        .setBudget(
                          amount,
                          _selectedCurrency,
                          _selectedMonth,
                          _selectedYear,
                        );

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Budget for ${_getMonthName(_selectedMonth)} $_selectedYear set to ${amount.toStringAsFixed(2)} ${_selectedCurrency.code}',
                        ),
                        duration: const Duration(
                          seconds: 3,
                        ),
                      ),
                    );

                    Navigator.pop(context);
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  child: Text(
                    'Save Budget',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _budgetCtrl.dispose();
    super.dispose();
  }
}
