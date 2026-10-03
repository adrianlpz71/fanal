// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_patch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurringPatch _$RecurringPatchFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'RecurringPatch',
  json,
  ($checkedConvert) {
    final val = RecurringPatch(
      concept: $checkedConvert('concept', (v) => v as String?),
      amount: $checkedConvert('amount', (v) => v as String?),
      amountIsEstimate: $checkedConvert(
        'amount_is_estimate',
        (v) => v as bool?,
      ),
      categoryId: $checkedConvert('category_id', (v) => v as String?),
      everyMonths: $checkedConvert('every_months', (v) => (v as num?)?.toInt()),
      dayOfMonth: $checkedConvert('day_of_month', (v) => (v as num?)?.toInt()),
      endDate: $checkedConvert(
        'end_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      active: $checkedConvert('active', (v) => v as bool?),
      review: $checkedConvert(
        'review',
        (v) => $enumDecodeNullable(_$RecurringPatchReviewEnumEnumMap, v),
      ),
      estSavingYear: $checkedConvert('est_saving_year', (v) => v as String?),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'amountIsEstimate': 'amount_is_estimate',
    'categoryId': 'category_id',
    'everyMonths': 'every_months',
    'dayOfMonth': 'day_of_month',
    'endDate': 'end_date',
    'estSavingYear': 'est_saving_year',
  },
);

Map<String, dynamic> _$RecurringPatchToJson(RecurringPatch instance) =>
    <String, dynamic>{
      'concept': ?instance.concept,
      'amount': ?instance.amount,
      'amount_is_estimate': ?instance.amountIsEstimate,
      'category_id': ?instance.categoryId,
      'every_months': ?instance.everyMonths,
      'day_of_month': ?instance.dayOfMonth,
      'end_date': ?instance.endDate?.toIso8601String(),
      'active': ?instance.active,
      'review': ?_$RecurringPatchReviewEnumEnumMap[instance.review],
      'est_saving_year': ?instance.estSavingYear,
      'notes': ?instance.notes,
    };

const _$RecurringPatchReviewEnumEnumMap = {
  RecurringPatchReviewEnum.ok: 'ok',
  RecurringPatchReviewEnum.revisar: 'revisar',
  RecurringPatchReviewEnum.cancelar: 'cancelar',
};
