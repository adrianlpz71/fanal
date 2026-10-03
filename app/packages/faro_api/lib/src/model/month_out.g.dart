// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonthOut _$MonthOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MonthOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'label',
          'ym',
          'start',
          'end',
          'payroll',
          'recurring',
          'installments',
          'other',
          'free',
          'cumulative',
          'items',
        ],
      );
      final val = MonthOut(
        label: $checkedConvert('label', (v) => v as String),
        ym: $checkedConvert('ym', (v) => v as String),
        start: $checkedConvert('start', (v) => DateTime.parse(v as String)),
        end: $checkedConvert('end', (v) => DateTime.parse(v as String)),
        payroll: $checkedConvert('payroll', (v) => v as String),
        recurring: $checkedConvert('recurring', (v) => v as String),
        installments: $checkedConvert('installments', (v) => v as String),
        other: $checkedConvert('other', (v) => v as String),
        free: $checkedConvert('free', (v) => v as String),
        cumulative: $checkedConvert('cumulative', (v) => v as String),
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => MonthItemOut.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MonthOutToJson(MonthOut instance) => <String, dynamic>{
  'label': instance.label,
  'ym': instance.ym,
  'start': instance.start.toIso8601String(),
  'end': instance.end.toIso8601String(),
  'payroll': instance.payroll,
  'recurring': instance.recurring,
  'installments': instance.installments,
  'other': instance.other,
  'free': instance.free,
  'cumulative': instance.cumulative,
  'items': instance.items.map((e) => e.toJson()).toList(),
};
