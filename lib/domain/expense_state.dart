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
        return 'Food';
      case Category.transport:
        return 'Transport';
      case Category.entertainment:
        return 'Entertainment';
      case Category.utilities:
        return 'Utilities';
      case Category.healthcare:
        return 'Healthcare';
      case Category.education:
        return 'Education';
      case Category.work:
        return 'Work';
      case Category.shopping:
        return 'Shopping';
      case Category.salary:
        return 'Salary';
      case Category.gift:
        return 'Gift';
      case Category.bonus:
        return 'Bonus';
      case Category.other:
        return 'Other';
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
