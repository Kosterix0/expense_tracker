import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:expense_tracker/domain/currency.dart';

part 'budget_state.freezed.dart';
part 'budget_state.g.dart';

@freezed
abstract class BudgetState with _$BudgetState {
  const factory BudgetState({
    required double amount,
    required Currency currency,
    @Default(false) bool isSet,
  }) = _BudgetState;

  factory BudgetState.fromJson(
    Map<String, dynamic> json,
  ) => _$BudgetStateFromJson(json);
}
