// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurringIn _$RecurringInFromJson(Map<String, dynamic> json) => $checkedCreate(
  'RecurringIn',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['concept', 'amount', 'start_date']);
    final val = RecurringIn(
      concept: $checkedConvert('concept', (v) => v as String),
      amount: $checkedConvert('amount', (v) => v as String),
      amountIsEstimate: $checkedConvert(
        'amount_is_estimate',
        (v) => v as bool? ?? false,
      ),
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecodeNullable(_$RecurringInKindEnumEnumMap, v),
      ),
      categoryId: $checkedConvert('category_id', (v) => v as String?),
      everyMonths: $checkedConvert(
        'every_months',
        (v) => (v as num?)?.toInt() ?? 1,
      ),
      dayOfMonth: $checkedConvert(
        'day_of_month',
        (v) => (v as num?)?.toInt() ?? 1,
      ),
      startDate: $checkedConvert(
        'start_date',
        (v) => DateTime.parse(v as String),
      ),
      endDate: $checkedConvert(
        'end_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      accountId: $checkedConvert('account_id', (v) => v as String?),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'amountIsEstimate': 'amount_is_estimate',
    'categoryId': 'category_id',
    'everyMonths': 'every_months',
    'dayOfMonth': 'day_of_month',
    'startDate': 'start_date',
    'endDate': 'end_date',
    'accountId': 'account_id',
  },
);

Map<String, dynamic> _$RecurringInToJson(RecurringIn instance) =>
    <String, dynamic>{
      'concept': instance.concept,
      'amount': instance.amount,
      'amount_is_estimate': ?instance.amountIsEstimate,
      'kind': ?_$RecurringInKindEnumEnumMap[instance.kind],
      'category_id': ?instance.categoryId,
      'every_months': ?instance.everyMonths,
      'day_of_month': ?instance.dayOfMonth,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': ?instance.endDate?.toIso8601String(),
      'account_id': ?instance.accountId,
      'notes': ?instance.notes,
    };

const _$RecurringInKindEnumEnumMap = {
  RecurringInKindEnum.gasto: 'gasto',
  RecurringInKindEnum.ingreso: 'ingreso',
  RecurringInKindEnum.nomina: 'nomina',
  RecurringInKindEnum.transferencia: 'transferencia',
  RecurringInKindEnum.reembolso: 'reembolso',
  RecurringInKindEnum.ajuste: 'ajuste',
};
