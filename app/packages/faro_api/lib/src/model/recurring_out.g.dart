// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurringOut _$RecurringOutFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'RecurringOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'concept',
        'amount',
        'amount_is_estimate',
        'kind',
        'category_id',
        'every_months',
        'day_of_month',
        'start_date',
        'end_date',
        'active',
        'review',
        'est_saving_year',
        'monthly_cost',
        'yearly_cost',
        'price_changes',
        'notes',
      ],
    );
    final val = RecurringOut(
      id: $checkedConvert('id', (v) => v as String),
      concept: $checkedConvert('concept', (v) => v as String),
      amount: $checkedConvert('amount', (v) => v as String),
      amountIsEstimate: $checkedConvert('amount_is_estimate', (v) => v as bool),
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecode(_$RecurringOutKindEnumEnumMap, v),
      ),
      categoryId: $checkedConvert('category_id', (v) => v as String?),
      everyMonths: $checkedConvert('every_months', (v) => (v as num).toInt()),
      dayOfMonth: $checkedConvert('day_of_month', (v) => (v as num).toInt()),
      startDate: $checkedConvert(
        'start_date',
        (v) => DateTime.parse(v as String),
      ),
      endDate: $checkedConvert(
        'end_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      active: $checkedConvert('active', (v) => v as bool),
      review: $checkedConvert('review', (v) => v as String),
      estSavingYear: $checkedConvert('est_saving_year', (v) => v as String?),
      monthlyCost: $checkedConvert('monthly_cost', (v) => v as String),
      yearlyCost: $checkedConvert('yearly_cost', (v) => v as String),
      priceChanges: $checkedConvert(
        'price_changes',
        (v) => (v as List<dynamic>)
            .map((e) => PriceChangeOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
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
    'estSavingYear': 'est_saving_year',
    'monthlyCost': 'monthly_cost',
    'yearlyCost': 'yearly_cost',
    'priceChanges': 'price_changes',
  },
);

Map<String, dynamic> _$RecurringOutToJson(RecurringOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'concept': instance.concept,
      'amount': instance.amount,
      'amount_is_estimate': instance.amountIsEstimate,
      'kind': _$RecurringOutKindEnumEnumMap[instance.kind]!,
      'category_id': instance.categoryId,
      'every_months': instance.everyMonths,
      'day_of_month': instance.dayOfMonth,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'active': instance.active,
      'review': instance.review,
      'est_saving_year': instance.estSavingYear,
      'monthly_cost': instance.monthlyCost,
      'yearly_cost': instance.yearlyCost,
      'price_changes': instance.priceChanges.map((e) => e.toJson()).toList(),
      'notes': instance.notes,
    };

const _$RecurringOutKindEnumEnumMap = {
  RecurringOutKindEnum.gasto: 'gasto',
  RecurringOutKindEnum.ingreso: 'ingreso',
  RecurringOutKindEnum.nomina: 'nomina',
  RecurringOutKindEnum.transferencia: 'transferencia',
  RecurringOutKindEnum.reembolso: 'reembolso',
  RecurringOutKindEnum.ajuste: 'ajuste',
};
