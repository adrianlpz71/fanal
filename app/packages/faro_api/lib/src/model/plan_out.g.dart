// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanOut _$PlanOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'PlanOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'asset_id',
        'amount',
        'every_months',
        'day_of_month',
        'start_date',
        'end_date',
        'active',
        'from_account_id',
        'next_date',
        'notes',
      ],
    );
    final val = PlanOut(
      id: $checkedConvert('id', (v) => v as String),
      assetId: $checkedConvert('asset_id', (v) => v as String),
      amount: $checkedConvert('amount', (v) => v as String),
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
      fromAccountId: $checkedConvert('from_account_id', (v) => v as String?),
      nextDate: $checkedConvert(
        'next_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'assetId': 'asset_id',
    'everyMonths': 'every_months',
    'dayOfMonth': 'day_of_month',
    'startDate': 'start_date',
    'endDate': 'end_date',
    'fromAccountId': 'from_account_id',
    'nextDate': 'next_date',
  },
);

Map<String, dynamic> _$PlanOutToJson(PlanOut instance) => <String, dynamic>{
  'id': instance.id,
  'asset_id': instance.assetId,
  'amount': instance.amount,
  'every_months': instance.everyMonths,
  'day_of_month': instance.dayOfMonth,
  'start_date': instance.startDate.toIso8601String(),
  'end_date': instance.endDate?.toIso8601String(),
  'active': instance.active,
  'from_account_id': instance.fromAccountId,
  'next_date': instance.nextDate?.toIso8601String(),
  'notes': instance.notes,
};
