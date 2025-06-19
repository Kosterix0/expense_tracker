// add_expense_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:expense_tracker/domain/expense_state.dart';
import 'package:expense_tracker/domain/currency.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final ExpenseState? expense;

  const AddExpenseScreen({Key? key, this.expense})
    : super(key: key);

  @override
  ConsumerState<AddExpenseScreen> createState() =>
      _AddExpenseScreenState();
}

class _AddExpenseScreenState
    extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TransactionType _type;
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  Category? _selectedCategory;
  Currency _selectedCurrency = Currency.PLN;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    if (widget.expense != null) {
      _type = widget.expense!.type;
      _titleCtrl.text = widget.expense!.title;
      _amountCtrl.text =
          widget.expense!.amount.toString();
      _descriptionCtrl.text =
          widget.expense!.description;
      _selectedCategory = widget.expense!.category;
      _selectedCurrency = widget.expense!.currency;
      _selectedDate = widget.expense!.date;
    } else {
      _type = TransactionType.expense;
      _selectedDate = DateTime.now();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
        ),
      );
      return;
    }

    final title = _titleCtrl.text.trim();
    final amount = double.parse(
      _amountCtrl.text.replaceAll(',', '.'),
    );
    final desc = _descriptionCtrl.text.trim();

    if (widget.expense != null) {
      await ref
          .read(transactionProvider.notifier)
          .editExpense(
            widget.expense!.id,
            newTitle: title,
            newAmount: amount,
            newCurrency: _selectedCurrency,
            newDescription: desc,
            newCategory: _selectedCategory!,
            newType: _type,
            newDate: _selectedDate,
          );
    } else {
      await ref
          .read(transactionProvider.notifier)
          .addTransaction(
            title: title,
            amount: amount,
            currency: _selectedCurrency,
            description: desc,
            category: _selectedCategory!,
            type: _type,
            date: _selectedDate,
          );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        _type == TransactionType.expense
            ? Category.values
                .where(
                  (c) => c.index <= Category.other.index,
                )
                .toList()
            : Category.values
                .where(
                  (c) =>
                      c.index >= Category.salary.index,
                )
                .toList();

    return AppScaffold(
      title:
          widget.expense != null
              ? 'Edit Transaction'
              : 'Add Transaction',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
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
                validator:
                    (v) =>
                        (v == null || v.isEmpty)
                            ? 'Please enter a title'
                            : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Expense'),
                      selected:
                          _type ==
                          TransactionType.expense,
                      selectedColor: Colors.green[800],
                      labelStyle: TextStyle(
                        color:
                            _type ==
                                    TransactionType
                                        .expense
                                ? Colors.white
                                : Colors.white70,
                      ),
                      onSelected:
                          (_) => setState(() {
                            _type =
                                TransactionType.expense;
                            _selectedCategory = null;
                          }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Income'),
                      selected:
                          _type ==
                          TransactionType.income,
                      selectedColor: Colors.green[800],
                      labelStyle: TextStyle(
                        color:
                            _type ==
                                    TransactionType
                                        .income
                                ? Colors.white
                                : Colors.white70,
                      ),
                      onSelected:
                          (_) => setState(() {
                            _type =
                                TransactionType.income;
                            _selectedCategory = null;
                          }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Transaction Date'),
                subtitle: Text(
                  DateFormat.yMMMMd().format(
                    _selectedDate,
                  ),
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
                trailing: const Icon(
                  Icons.calendar_today,
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(
                  labelText: 'Amount',
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
                keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final n = double.tryParse(
                    v.replaceAll(',', '.'),
                  );
                  if (n == null || n <= 0) {
                    return 'Invalid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Currency>(
                value: _selectedCurrency,
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
                decoration: const InputDecoration(
                  labelText: 'Currency',
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
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
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
                    categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(
                          cat.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged:
                    (v) => setState(
                      () => _selectedCategory = v,
                    ),
                validator:
                    (v) =>
                        v == null
                            ? 'Please select a category'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
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
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                ),
                onPressed: _save,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  child: Text(
                    widget.expense != null
                        ? 'Update'
                        : 'Save',
                    style: const TextStyle(
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
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }
}
