// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movement_patch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovementPatch _$MovementPatchFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'MovementPatch',
      json,
      ($checkedConvert) {
        final val = MovementPatch(
          concept: $checkedConvert('concept', (v) => v as String?),
          amount: $checkedConvert('amount', (v) => v as String?),
          expression: $checkedConvert('expression', (v) => v as String?),
          kind: $checkedConvert(
            'kind',
            (v) => $enumDecodeNullable(_$MovementPatchKindEnumEnumMap, v),
          ),
          status: $checkedConvert(
            'status',
            (v) => $enumDecodeNullable(_$MovementPatchStatusEnumEnumMap, v),
          ),
          date: $checkedConvert(
            'date',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          dueDate: $checkedConvert(
            'due_date',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          cycleId: $checkedConvert('cycle_id', (v) => v as String?),
          categoryId: $checkedConvert('category_id', (v) => v as String?),
          notes: $checkedConvert('notes', (v) => v as String?),
          debtId: $checkedConvert('debt_id', (v) => v as String?),
          month: $checkedConvert('month', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'dueDate': 'due_date',
        'cycleId': 'cycle_id',
        'categoryId': 'category_id',
        'debtId': 'debt_id',
      },
    );

Map<String, dynamic> _$MovementPatchToJson(MovementPatch instance) =>
    <String, dynamic>{
      'concept': ?instance.concept,
      'amount': ?instance.amount,
      'expression': ?instance.expression,
      'kind': ?_$MovementPatchKindEnumEnumMap[instance.kind],
      'status': ?_$MovementPatchStatusEnumEnumMap[instance.status],
      'date': ?instance.date?.toIso8601String(),
      'due_date': ?instance.dueDate?.toIso8601String(),
      'cycle_id': ?instance.cycleId,
      'category_id': ?instance.categoryId,
      'notes': ?instance.notes,
      'debt_id': ?instance.debtId,
      'month': ?instance.month,
    };

const _$MovementPatchKindEnumEnumMap = {
  MovementPatchKindEnum.gasto: 'gasto',
  MovementPatchKindEnum.ingreso: 'ingreso',
  MovementPatchKindEnum.nomina: 'nomina',
  MovementPatchKindEnum.transferencia: 'transferencia',
  MovementPatchKindEnum.reembolso: 'reembolso',
  MovementPatchKindEnum.ajuste: 'ajuste',
};

const _$MovementPatchStatusEnumEnumMap = {
  MovementPatchStatusEnum.planned: 'planned',
  MovementPatchStatusEnum.posted: 'posted',
  MovementPatchStatusEnum.cancelled: 'cancelled',
};
