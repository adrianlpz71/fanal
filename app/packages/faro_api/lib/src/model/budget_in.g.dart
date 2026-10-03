// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BudgetIn _$BudgetInFromJson(Map<String, dynamic> json) => $checkedCreate(
  'BudgetIn',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['amount']);
    final val = BudgetIn(amount: $checkedConvert('amount', (v) => v as String));
    return val;
  },
);

Map<String, dynamic> _$BudgetInToJson(BudgetIn instance) => <String, dynamic>{
  'amount': instance.amount,
};
