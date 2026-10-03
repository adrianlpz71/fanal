// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BudgetOut _$BudgetOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BudgetOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['category_id', 'amount', 'active']);
      final val = BudgetOut(
        categoryId: $checkedConvert('category_id', (v) => v as String),
        amount: $checkedConvert('amount', (v) => v as String),
        active: $checkedConvert('active', (v) => v as bool),
      );
      return val;
    }, fieldKeyMap: const {'categoryId': 'category_id'});

Map<String, dynamic> _$BudgetOutToJson(BudgetOut instance) => <String, dynamic>{
  'category_id': instance.categoryId,
  'amount': instance.amount,
  'active': instance.active,
};
