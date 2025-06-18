// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BudgetState _$BudgetStateFromJson(Map<String, dynamic> json) => _BudgetState(
  amount: (json['amount'] as num).toDouble(),
  currency: $enumDecode(_$CurrencyEnumMap, json['currency']),
  isSet: json['isSet'] as bool? ?? false,
  month: (json['month'] as num).toInt(),
  year: (json['year'] as num).toInt(),
  id: json['id'] as String?,
);

Map<String, dynamic> _$BudgetStateToJson(_BudgetState instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'currency': _$CurrencyEnumMap[instance.currency]!,
      'isSet': instance.isSet,
      'month': instance.month,
      'year': instance.year,
      'id': instance.id,
    };

const _$CurrencyEnumMap = {
  Currency.PLN: 'PLN',
  Currency.EUR: 'EUR',
  Currency.USD: 'USD',
};
