// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_month_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PerformanceMonthOut _$PerformanceMonthOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PerformanceMonthOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'year',
            'month',
            'start_value',
            'end_value',
            'net_flow',
            'gain',
            'ret',
            'cumulative',
          ],
        );
        final val = PerformanceMonthOut(
          year: $checkedConvert('year', (v) => (v as num).toInt()),
          month: $checkedConvert('month', (v) => (v as num).toInt()),
          startValue: $checkedConvert('start_value', (v) => v as String),
          endValue: $checkedConvert('end_value', (v) => v as String),
          netFlow: $checkedConvert('net_flow', (v) => v as String),
          gain: $checkedConvert('gain', (v) => v as String),
          ret: $checkedConvert('ret', (v) => v as String?),
          cumulative: $checkedConvert('cumulative', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'startValue': 'start_value',
        'endValue': 'end_value',
        'netFlow': 'net_flow',
      },
    );

Map<String, dynamic> _$PerformanceMonthOutToJson(
  PerformanceMonthOut instance,
) => <String, dynamic>{
  'year': instance.year,
  'month': instance.month,
  'start_value': instance.startValue,
  'end_value': instance.endValue,
  'net_flow': instance.netFlow,
  'gain': instance.gain,
  'ret': instance.ret,
  'cumulative': instance.cumulative,
};
