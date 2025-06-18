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
  StreamSubscription<DocumentSnapshot>?
  _budgetSubscription;

  BudgetNotifier()
    : super(
        BudgetState(
          amount: 0.0,
          currency: Currency.PLN,
          isSet: false,
        ),
      ) {
    _init();
  }

  void _init() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _budgetSubscription = _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
            if (snapshot.exists) {
              final data =
                  snapshot.data()
                      as Map<String, dynamic>;
              if (data.containsKey('budget') &&
                  data.containsKey('currency')) {
                state = BudgetState(
                  amount: data['budget'] as double,
                  currency: Currency.values.firstWhere(
                    (c) => c.code == data['currency'],
                    orElse: () => Currency.PLN,
                  ),
                  isSet: true,
                );
              }
            }
          });
    }
  }

  Future<void> setBudget(
    double amount,
    Currency currency,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set({
          'budget': amount,
          'currency': currency.code,
        }, SetOptions(merge: true));

    state = BudgetState(
      amount: amount,
      currency: currency,
      isSet: true,
    );
  }

  @override
  void dispose() {
    _budgetSubscription?.cancel();
    super.dispose();
  }
}
