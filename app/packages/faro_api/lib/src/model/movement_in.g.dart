// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movement_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovementIn _$MovementInFromJson(Map<String, dynamic> json) => $checkedCreate(
  'MovementIn',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['concept']);
    final val = MovementIn(
      id: $checkedConvert('id', (v) => v as String?),
      concept: $checkedConvert('concept', (v) => v as String),
      amount: $checkedConvert('amount', (v) => v as String?),
      expression: $checkedConvert('expression', (v) => v as String?),
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecodeNullable(_$MovementInKindEnumEnumMap, v),
      ),
      status: $checkedConvert(
        'status',
        (v) => $enumDecodeNullable(_$MovementInStatusEnumEnumMap, v),
      ),
      date: $checkedConvert(
        'date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      dueDate: $checkedConvert(
        'due_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      accountId: $checkedConvert('account_id', (v) => v as String?),
      cycleId: $checkedConvert('cycle_id', (v) => v as String?),
      month: $checkedConvert('month', (v) => v as String?),
      categoryId: $checkedConvert('category_id', (v) => v as String?),
      notes: $checkedConvert('notes', (v) => v as String?),
      toAccountId: $checkedConvert('to_account_id', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'dueDate': 'due_date',
    'accountId': 'account_id',
    'cycleId': 'cycle_id',
    'categoryId': 'category_id',
    'toAccountId': 'to_account_id',
  },
);

Map<String, dynamic> _$MovementInToJson(MovementIn instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'concept': instance.concept,
      'amount': ?instance.amount,
      'expression': ?instance.expression,
      'kind': ?_$MovementInKindEnumEnumMap[instance.kind],
      'status': ?_$MovementInStatusEnumEnumMap[instance.status],
      'date': ?instance.date?.toIso8601String(),
      'due_date': ?instance.dueDate?.toIso8601String(),
      'account_id': ?instance.accountId,
      'cycle_id': ?instance.cycleId,
      'month': ?instance.month,
      'category_id': ?instance.categoryId,
      'notes': ?instance.notes,
      'to_account_id': ?instance.toAccountId,
    };

const _$MovementInKindEnumEnumMap = {
  MovementInKindEnum.gasto: 'gasto',
  MovementInKindEnum.ingreso: 'ingreso',
  MovementInKindEnum.nomina: 'nomina',
  MovementInKindEnum.transferencia: 'transferencia',
  MovementInKindEnum.reembolso: 'reembolso',
  MovementInKindEnum.ajuste: 'ajuste',
};

const _$MovementInStatusEnumEnumMap = {
  MovementInStatusEnum.planned: 'planned',
  MovementInStatusEnum.posted: 'posted',
};
