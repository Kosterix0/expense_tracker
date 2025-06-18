import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/services/budget_service.dart';
import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/domain/currency.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _budgetCtrl = TextEditingController();
  Currency _selectedCurrency = Currency.PLN;

  @override
  void initState() {
    super.initState();
    final budget = ref.read(budgetProvider);
    if (budget.isSet) {
      _budgetCtrl.text = budget.amount.toStringAsFixed(
        2,
      );
      _selectedCurrency = budget.currency;
    }
  }

  @override
  void dispose() {
    _budgetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budget = ref.watch(budgetProvider);

    return AppScaffold(
      title: 'Ustawienia budżetu',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (budget.isSet)
                Text(
                  'Aktualny budżet: ${budget.amount.toStringAsFixed(2)} ${budget.currency.code}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _budgetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nowy miesięczny budżet',
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
                decoration: const InputDecoration(
                  labelText: 'Waluta budżetu',
                  border: OutlineInputBorder(),
                ),
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
                        );
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Budżet zaktualizowany',
                        ),
                      ),
                    );
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
}
