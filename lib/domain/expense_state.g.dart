// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExpenseState _$ExpenseStateFromJson(Map<String, dynamic> json) =>
    _ExpenseState(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: $enumDecode(_$CurrencyEnumMap, json['currency']),
      baseAmount: (json['baseAmount'] as num).toDouble(),
      description: json['description'] as String,
      category: $enumDecode(_$CategoryEnumMap, json['category']),
      date: DateTime.parse(json['date'] as String),
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$ExpenseStateToJson(_ExpenseState instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'amount': instance.amount,
      'currency': _$CurrencyEnumMap[instance.currency]!,
      'baseAmount': instance.baseAmount,
      'description': instance.description,
      'category': _$CategoryEnumMap[instance.category]!,
      'date': instance.date.toIso8601String(),
      'type': _$TransactionTypeEnumMap[instance.type]!,
    };

const _$CurrencyEnumMap = {
  Currency.PLN: 'PLN',
  Currency.EUR: 'EUR',
  Currency.USD: 'USD',
};

const _$CategoryEnumMap = {
  Category.food: 'food',
  Category.transport: 'transport',
  Category.entertainment: 'entertainment',
  Category.utilities: 'utilities',
  Category.healthcare: 'healthcare',
  Category.education: 'education',
  Category.work: 'work',
  Category.shopping: 'shopping',
  Category.salary: 'salary',
  Category.gift: 'gift',
  Category.bonus: 'bonus',
  Category.other: 'other',
};

const _$TransactionTypeEnumMap = {
  TransactionType.expense: 'expense',
  TransactionType.income: 'income',
};
