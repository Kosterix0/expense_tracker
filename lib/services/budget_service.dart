import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/domain/budget_state.dart';
import 'package:expense_tracker/domain/currency.dart';

final budgetProvider =
    StateNotifierProvider<BudgetNotifier, BudgetState>((
      ref,
    ) {
      return BudgetNotifier();
    });

class BudgetNotifier extends StateNotifier<BudgetState> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>?
  _budgetsSubscription;

  BudgetNotifier()
    : super(
        BudgetState(
          amount: 0.0,
          currency: Currency.PLN,
          isSet: false,
          month: DateTime.now().month,
          year: DateTime.now().year,
          id: null,
        ),
      ) {
    _init();
  }

  void _init() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _loadCurrentMonthBudget(user.uid);
    }
  }

  void _loadCurrentMonthBudget(String userId) {
    final now = DateTime.now();
    _loadBudgetForMonth(userId, now.month, now.year);
  }

  void _loadBudgetForMonth(
    String userId,
    int month,
    int year,
  ) {
    _budgetsSubscription?.cancel();

    _budgetsSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final doc = snapshot.docs.first;
            final data =
                doc.data() as Map<String, dynamic>;

            state = BudgetState(
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
          } else {
            state = BudgetState(
              amount: 0.0,
              currency: Currency.PLN,
              isSet: false,
              month: month,
              year: year,
              id: null,
            );
          }
        });
  }

  Future<void> setBudget(
    double amount,
    Currency currency,
    int month,
    int year,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final budgetQuery =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('budgets')
            .where('month', isEqualTo: month)
            .where('year', isEqualTo: year)
            .get();

    if (budgetQuery.docs.isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('budgets')
          .doc(budgetQuery.docs.first.id)
          .update({
            'amount': amount,
            'currency': currency.code,
          });
    } else {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('budgets')
          .add({
            'amount': amount,
            'currency': currency.code,
            'month': month,
            'year': year,
          });
    }

    _loadBudgetForMonth(user.uid, month, year);
  }

  Future<BudgetState?> getBudgetForMonth(
    int month,
    int year,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final budgetQuery =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('budgets')
            .where('month', isEqualTo: month)
            .where('year', isEqualTo: year)
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

  @override
  void dispose() {
    _budgetsSubscription?.cancel();
    super.dispose();
  }
}
