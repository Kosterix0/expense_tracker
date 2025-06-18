// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExpenseState {

 String get id; String get title; double get amount; Currency get currency; double get baseAmount; String get description; Category get category; DateTime get date; TransactionType get type;
/// Create a copy of ExpenseState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseStateCopyWith<ExpenseState> get copyWith => _$ExpenseStateCopyWithImpl<ExpenseState>(this as ExpenseState, _$identity);

  /// Serializes this ExpenseState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseState&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.baseAmount, baseAmount) || other.baseAmount == baseAmount)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.date, date) || other.date == date)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,amount,currency,baseAmount,description,category,date,type);

@override
String toString() {
  return 'ExpenseState(id: $id, title: $title, amount: $amount, currency: $currency, baseAmount: $baseAmount, description: $description, category: $category, date: $date, type: $type)';
}


}

/// @nodoc
abstract mixin class $ExpenseStateCopyWith<$Res>  {
  factory $ExpenseStateCopyWith(ExpenseState value, $Res Function(ExpenseState) _then) = _$ExpenseStateCopyWithImpl;
@useResult
$Res call({
 String id, String title, double amount, Currency currency, double baseAmount, String description, Category category, DateTime date, TransactionType type
});




}
/// @nodoc
class _$ExpenseStateCopyWithImpl<$Res>
    implements $ExpenseStateCopyWith<$Res> {
  _$ExpenseStateCopyWithImpl(this._self, this._then);

  final ExpenseState _self;
  final $Res Function(ExpenseState) _then;

/// Create a copy of ExpenseState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? amount = null,Object? currency = null,Object? baseAmount = null,Object? description = null,Object? category = null,Object? date = null,Object? type = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,baseAmount: null == baseAmount ? _self.baseAmount : baseAmount // ignore: cast_nullable_to_non_nullable
as double,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ExpenseState implements ExpenseState {
  const _ExpenseState({required this.id, required this.title, required this.amount, required this.currency, required this.baseAmount, required this.description, required this.category, required this.date, required this.type});
  factory _ExpenseState.fromJson(Map<String, dynamic> json) => _$ExpenseStateFromJson(json);

@override final  String id;
@override final  String title;
@override final  double amount;
@override final  Currency currency;
@override final  double baseAmount;
@override final  String description;
@override final  Category category;
@override final  DateTime date;
@override final  TransactionType type;

/// Create a copy of ExpenseState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseStateCopyWith<_ExpenseState> get copyWith => __$ExpenseStateCopyWithImpl<_ExpenseState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseState&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.baseAmount, baseAmount) || other.baseAmount == baseAmount)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.date, date) || other.date == date)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,amount,currency,baseAmount,description,category,date,type);

@override
String toString() {
  return 'ExpenseState(id: $id, title: $title, amount: $amount, currency: $currency, baseAmount: $baseAmount, description: $description, category: $category, date: $date, type: $type)';
}


}

/// @nodoc
abstract mixin class _$ExpenseStateCopyWith<$Res> implements $ExpenseStateCopyWith<$Res> {
  factory _$ExpenseStateCopyWith(_ExpenseState value, $Res Function(_ExpenseState) _then) = __$ExpenseStateCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, double amount, Currency currency, double baseAmount, String description, Category category, DateTime date, TransactionType type
});




}
/// @nodoc
class __$ExpenseStateCopyWithImpl<$Res>
    implements _$ExpenseStateCopyWith<$Res> {
  __$ExpenseStateCopyWithImpl(this._self, this._then);

  final _ExpenseState _self;
  final $Res Function(_ExpenseState) _then;

/// Create a copy of ExpenseState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? amount = null,Object? currency = null,Object? baseAmount = null,Object? description = null,Object? category = null,Object? date = null,Object? type = null,}) {
  return _then(_ExpenseState(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,baseAmount: null == baseAmount ? _self.baseAmount : baseAmount // ignore: cast_nullable_to_non_nullable
as double,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,
  ));
}


}

// dart format on
