// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movement_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovementOut _$MovementOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'MovementOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'account_id',
        'cycle_id',
        'date',
        'due_date',
        'kind',
        'status',
        'concept',
        'amount',
        'expression',
        'lines',
        'category_id',
        'source',
        'source_ref',
        'notes',
        'shares',
      ],
    );
    final val = MovementOut(
      id: $checkedConvert('id', (v) => v as String),
      accountId: $checkedConvert('account_id', (v) => v as String),
      cycleId: $checkedConvert('cycle_id', (v) => v as String?),
      date: $checkedConvert(
        'date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      dueDate: $checkedConvert(
        'due_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecode(_$MovementOutKindEnumEnumMap, v),
      ),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$MovementOutStatusEnumEnumMap, v),
      ),
      concept: $checkedConvert('concept', (v) => v as String),
      amount: $checkedConvert('amount', (v) => v as String),
      expression: $checkedConvert('expression', (v) => v as String?),
      lines: $checkedConvert(
        'lines',
        (v) => (v as List<dynamic>)
            .map((e) => MovementLineOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      categoryId: $checkedConvert('category_id', (v) => v as String?),
      source_: $checkedConvert('source', (v) => v as String),
      sourceRef: $checkedConvert('source_ref', (v) => v as String?),
      notes: $checkedConvert('notes', (v) => v as String?),
      debtId: $checkedConvert('debt_id', (v) => v as String?),
      refundOfId: $checkedConvert('refund_of_id', (v) => v as String?),
      shares: $checkedConvert(
        'shares',
        (v) => (v as List<dynamic>)
            .map((e) => ShareBriefOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'accountId': 'account_id',
    'cycleId': 'cycle_id',
    'dueDate': 'due_date',
    'categoryId': 'category_id',
    'source_': 'source',
    'sourceRef': 'source_ref',
    'debtId': 'debt_id',
    'refundOfId': 'refund_of_id',
  },
);

Map<String, dynamic> _$MovementOutToJson(MovementOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'account_id': instance.accountId,
      'cycle_id': instance.cycleId,
      'date': instance.date?.toIso8601String(),
      'due_date': instance.dueDate?.toIso8601String(),
      'kind': _$MovementOutKindEnumEnumMap[instance.kind]!,
      'status': _$MovementOutStatusEnumEnumMap[instance.status]!,
      'concept': instance.concept,
      'amount': instance.amount,
      'expression': instance.expression,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
      'category_id': instance.categoryId,
      'source': instance.source_,
      'source_ref': instance.sourceRef,
      'notes': instance.notes,
      'debt_id': ?instance.debtId,
      'refund_of_id': ?instance.refundOfId,
      'shares': instance.shares.map((e) => e.toJson()).toList(),
    };

const _$MovementOutKindEnumEnumMap = {
  MovementOutKindEnum.gasto: 'gasto',
  MovementOutKindEnum.ingreso: 'ingreso',
  MovementOutKindEnum.nomina: 'nomina',
  MovementOutKindEnum.transferencia: 'transferencia',
  MovementOutKindEnum.reembolso: 'reembolso',
  MovementOutKindEnum.ajuste: 'ajuste',
};

const _$MovementOutStatusEnumEnumMap = {
  MovementOutStatusEnum.planned: 'planned',
  MovementOutStatusEnum.posted: 'posted',
  MovementOutStatusEnum.cancelled: 'cancelled',
};
