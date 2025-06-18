// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BudgetState {

 double get amount; Currency get currency; bool get isSet;
/// Create a copy of BudgetState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetStateCopyWith<BudgetState> get copyWith => _$BudgetStateCopyWithImpl<BudgetState>(this as BudgetState, _$identity);

  /// Serializes this BudgetState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetState&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.isSet, isSet) || other.isSet == isSet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,currency,isSet);

@override
String toString() {
  return 'BudgetState(amount: $amount, currency: $currency, isSet: $isSet)';
}


}

/// @nodoc
abstract mixin class $BudgetStateCopyWith<$Res>  {
  factory $BudgetStateCopyWith(BudgetState value, $Res Function(BudgetState) _then) = _$BudgetStateCopyWithImpl;
@useResult
$Res call({
 double amount, Currency currency, bool isSet
});




}
/// @nodoc
class _$BudgetStateCopyWithImpl<$Res>
    implements $BudgetStateCopyWith<$Res> {
  _$BudgetStateCopyWithImpl(this._self, this._then);

  final BudgetState _self;
  final $Res Function(BudgetState) _then;

/// Create a copy of BudgetState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amount = null,Object? currency = null,Object? isSet = null,}) {
  return _then(_self.copyWith(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,isSet: null == isSet ? _self.isSet : isSet // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _BudgetState implements BudgetState {
  const _BudgetState({required this.amount, required this.currency, this.isSet = false});
  factory _BudgetState.fromJson(Map<String, dynamic> json) => _$BudgetStateFromJson(json);

@override final  double amount;
@override final  Currency currency;
@override@JsonKey() final  bool isSet;

/// Create a copy of BudgetState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetStateCopyWith<_BudgetState> get copyWith => __$BudgetStateCopyWithImpl<_BudgetState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetState&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.isSet, isSet) || other.isSet == isSet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,currency,isSet);

@override
String toString() {
  return 'BudgetState(amount: $amount, currency: $currency, isSet: $isSet)';
}


}

/// @nodoc
abstract mixin class _$BudgetStateCopyWith<$Res> implements $BudgetStateCopyWith<$Res> {
  factory _$BudgetStateCopyWith(_BudgetState value, $Res Function(_BudgetState) _then) = __$BudgetStateCopyWithImpl;
@override @useResult
$Res call({
 double amount, Currency currency, bool isSet
});




}
/// @nodoc
class __$BudgetStateCopyWithImpl<$Res>
    implements _$BudgetStateCopyWith<$Res> {
  __$BudgetStateCopyWithImpl(this._self, this._then);

  final _BudgetState _self;
  final $Res Function(_BudgetState) _then;

/// Create a copy of BudgetState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amount = null,Object? currency = null,Object? isSet = null,}) {
  return _then(_BudgetState(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,isSet: null == isSet ? _self.isSet : isSet // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
