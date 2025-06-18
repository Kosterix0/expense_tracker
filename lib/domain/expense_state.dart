import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:expense_tracker/domain/currency.dart';

part 'expense_state.freezed.dart';
part 'expense_state.g.dart';

@JsonEnum()
enum Category {
  food,
  transport,
  entertainment,
  utilities,
  healthcare,
  education,
  work,
  shopping,
  salary,
  gift,
  bonus,
  other,
}

extension CategoryExtension on Category {
  String get displayName {
    switch (this) {
      case Category.food:
        return 'Jedzenie';
      case Category.transport:
        return 'Transport';
      case Category.entertainment:
        return 'Rozrywka';
      case Category.utilities:
        return 'Opłaty';
      case Category.healthcare:
        return 'Zdrowie';
      case Category.education:
        return 'Edukacja';
      case Category.work:
        return 'Praca';
      case Category.shopping:
        return 'Zakupy';
      case Category.salary:
        return 'Wynagrodzenie';
      case Category.gift:
        return 'Prezent';
      case Category.bonus:
        return 'Premia';
      case Category.other:
        return 'Inne';
    }
  }
}

@JsonEnum()
enum TransactionType { expense, income }

@freezed
abstract class ExpenseState with _$ExpenseState {
  const factory ExpenseState({
    required String id,
    required String title,
    required double amount,
    required Currency currency,
    required double baseAmount,
    required String description,
    required Category category,
    required DateTime date,
    required TransactionType type,
  }) = _ExpenseState;

  factory ExpenseState.fromJson(
    Map<String, dynamic> json,
  ) => _$ExpenseStateFromJson(json);
}
