import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/domain/expense_state.dart';
import 'package:expense_tracker/domain/currency.dart';
import 'package:expense_tracker/services/currency_service.dart';
import 'package:expense_tracker/services/budget_service.dart';
import 'package:expense_tracker/domain/budget_state.dart';

class ExpenseNotifier
    extends StateNotifier<List<ExpenseState>> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
  final CurrencyService _currencyService =
      CurrencyService();
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot>?
  _expensesSubscription;

  ExpenseNotifier() : super([]) {
    _authSubscription = FirebaseAuth.instance
        .authStateChanges()
        .listen(_handleAuthChange);
  }

  void _handleAuthChange(User? user) async {
    _expensesSubscription?.cancel();
    state = [];

    if (user != null) {
      _expensesSubscription = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .orderBy('date', descending: true)
          .snapshots()
          .listen((qs) async {
            final transactions = await Future.wait(
              qs.docs.map(
                (doc) async => await _mapDocument(doc),
              ),
            );
            state = transactions;
          });
    }
  }

  Future<ExpenseState> _mapDocument(
    DocumentSnapshot doc,
  ) async {
    final data = doc.data() as Map<String, dynamic>;

    double baseAmount =
        data['baseAmount'] ?? data['amount'];
    final transactionCurrency = Currency.values
        .firstWhere(
          (c) => c.code == (data['currency'] ?? 'PLN'),
          orElse: () => Currency.PLN,
        );

    return ExpenseState(
      id: doc.id,
      title: data['title'] as String,
      amount: data['amount'] as double,
      currency: transactionCurrency,
      baseAmount: baseAmount,
      description: data['description'] as String,
      category: Category.values.byName(
        data['category'] as String,
      ),
      date: (data['date'] as Timestamp).toDate(),
      type: TransactionType.values.byName(
        data['type'] as String,
      ),
    );
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required Currency currency,
    required String description,
    required Category category,
    required TransactionType type,
    required DateTime date,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final budget = await _getBudgetForTransactionDate(
      date,
    );

    double baseAmount = amount;
    Currency targetCurrency = Currency.PLN;

    if (budget != null) {
      targetCurrency = budget.currency;
    }

    if (currency != targetCurrency) {
      try {
        baseAmount = await _currencyService.convert(
          amount,
          currency.code,
          targetCurrency.code,
        );
      } catch (e) {
        baseAmount = amount;
      }
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .add({
          'title': title,
          'amount': amount,
          'currency': currency.code,
          'baseAmount': baseAmount,
          'description': description,
          'category': category.name,
          'date': Timestamp.fromDate(date),
          'type': type.name,
        });
  }

  Future<void> editExpense(
    String id, {
    required String newTitle,
    required double newAmount,
    required Currency newCurrency,
    required String newDescription,
    required Category newCategory,
    required TransactionType newType,
    required DateTime newDate,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final budget = await _getBudgetForTransactionDate(
      newDate,
    );

    double baseAmount = newAmount;
    Currency targetCurrency = Currency.PLN;

    if (budget != null) {
      targetCurrency = budget.currency;
    }

    if (newCurrency != targetCurrency) {
      try {
        baseAmount = await _currencyService.convert(
          newAmount,
          newCurrency.code,
          targetCurrency.code,
        );
      } catch (e) {
        baseAmount = newAmount;
      }
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc(id)
        .update({
          'title': newTitle,
          'amount': newAmount,
          'currency': newCurrency.code,
          'baseAmount': baseAmount,
          'description': newDescription,
          'category': newCategory.name,
          'type': newType.name,
          'date': Timestamp.fromDate(newDate),
        });
  }

  Future<BudgetState?> _getBudgetForTransactionDate(
    DateTime date,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final budgetQuery =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('budgets')
            .where('month', isEqualTo: date.month)
            .where('year', isEqualTo: date.year)
            .get();

    if (budgetQuery.docs.isNotEmpty) {
      final doc = budgetQuery.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      return BudgetState(
        amount: data['amount'] as double,
        currency: Currency.values.firstWhere(
          (c) => c.code == data['currency'],
          orElse: () => Currency.PLN,
        ),
        isSet: true,
        month: data['month'] as int,
        year: data['year'] as int,
        id: doc.id,
      );
    }

    return null;
  }

  Future<void> deleteExpense(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc(id)
        .delete();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _expensesSubscription?.cancel();
    super.dispose();
  }
}

final transactionProvider = StateNotifierProvider<
  ExpenseNotifier,
  List<ExpenseState>
>((ref) => ExpenseNotifier());
