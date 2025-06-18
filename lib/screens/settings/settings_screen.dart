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
    5,
    (index) => DateTime.now().year + index - 2,
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
      'Styczeń',
      'Luty',
      'Marzec',
      'Kwiecień',
      'Maj',
      'Czerwiec',
      'Lipiec',
      'Sierpień',
      'Wrzesień',
      'Październik',
      'Listopad',
      'Grudzień',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Ustawienia budżetu',
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
                  labelText: 'Miesięczny budżet',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Podaj kwotę budżetu';
                  }
                  final n = double.tryParse(
                    value.replaceAll(',', '.'),
                  );
                  if (n == null || n <= 0) {
                    return 'Nieprawidłowa kwota';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<Currency>(
                value: _selectedCurrency,
                decoration: const InputDecoration(
                  labelText: 'Waluta budżetu',
                  border: OutlineInputBorder(),
                ),
                items:
                    Currency.values.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(
                          '${currency.name} (${currency.code})',
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
                        labelText: 'Miesiąc',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          List.generate(
                                12,
                                (index) => index + 1,
                              )
                              .map(
                                (month) =>
                                    DropdownMenuItem(
                                      value: month,
                                      child: Text(
                                        _getMonthName(
                                          month,
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
                        labelText: 'Rok',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          _years
                              .map(
                                (year) =>
                                    DropdownMenuItem(
                                      value: year,
                                      child: Text(
                                        year.toString(),
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
                          'Budżet na ${_getMonthName(_selectedMonth)} $_selectedYear został ustawiony na ${amount.toStringAsFixed(2)} ${_selectedCurrency.code}',
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
                    'Zapisz budżet',
                    style: TextStyle(fontSize: 16),
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
