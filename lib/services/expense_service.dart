import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/domain/expense_state.dart';
import 'package:expense_tracker/domain/currency.dart';
import 'package:expense_tracker/services/currency_service.dart';
import 'package:expense_tracker/domain/budget_state.dart'; // DODAJ TEN IMPORT

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
      final budget = await _getUserBudget(user.uid);

      _expensesSubscription = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .orderBy('date', descending: true)
          .snapshots()
          .listen((qs) async {
            final transactions = await Future.wait(
              qs.docs.map(
                (doc) async =>
                    await _mapDocument(doc, budget),
              ),
            );
            state = transactions;
          });
    }
  }

  Future<BudgetState> _getUserBudget(
    String userId,
  ) async {
    final doc =
        await _firestore
            .collection('users')
            .doc(userId)
            .get();
    if (doc.exists) {
      final data = doc.data()!;
      return BudgetState(
        amount: data['budget'] ?? 0.0,
        currency: Currency.values.firstWhere(
          (c) => c.code == (data['currency'] ?? 'PLN'),
          orElse: () => Currency.PLN,
        ),
        isSet: true,
      );
    }
    return BudgetState(
      amount: 0.0,
      currency: Currency.PLN,
      isSet: false,
    );
  }

  Future<ExpenseState> _mapDocument(
    DocumentSnapshot doc,
    BudgetState budget,
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
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final budget = await _getUserBudget(user.uid);
    double baseAmount = amount;

    if (currency != budget.currency) {
      try {
        baseAmount = await _currencyService.convert(
          amount,
          currency.code,
          budget.currency.code,
        );
      } catch (e) {
        // W przypadku błędu konwersji używamy oryginalnej kwoty
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
          'date': FieldValue.serverTimestamp(),
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
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final budget = await _getUserBudget(user.uid);
    double baseAmount = newAmount;

    if (newCurrency != budget.currency) {
      try {
        baseAmount = await _currencyService.convert(
          newAmount,
          newCurrency.code,
          budget.currency.code,
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
        });
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
