// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PerformanceOut _$PerformanceOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PerformanceOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'first',
            'days',
            'value',
            'contributed',
            'gain',
            'twr',
            'twr_annual',
            'ytd',
            'xirr',
            'max_drawdown',
            'volatility',
            'best',
            'worst',
            'positive_months',
            'negative_months',
            'months',
            'series',
          ],
        );
        final val = PerformanceOut(
          first: $checkedConvert(
            'first',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          days: $checkedConvert('days', (v) => (v as num).toInt()),
          value: $checkedConvert('value', (v) => v as String),
          contributed: $checkedConvert('contributed', (v) => v as String),
          gain: $checkedConvert('gain', (v) => v as String),
          twr: $checkedConvert('twr', (v) => v as String?),
          twrAnnual: $checkedConvert('twr_annual', (v) => v as String?),
          ytd: $checkedConvert('ytd', (v) => v as String?),
          xirr: $checkedConvert('xirr', (v) => v as String?),
          maxDrawdown: $checkedConvert('max_drawdown', (v) => v as String?),
          volatility: $checkedConvert('volatility', (v) => v as String?),
          best: $checkedConvert(
            'best',
            (v) => v == null
                ? null
                : PerformanceMonthOut.fromJson(v as Map<String, dynamic>),
          ),
          worst: $checkedConvert(
            'worst',
            (v) => v == null
                ? null
                : PerformanceMonthOut.fromJson(v as Map<String, dynamic>),
          ),
          positiveMonths: $checkedConvert(
            'positive_months',
            (v) => (v as num).toInt(),
          ),
          negativeMonths: $checkedConvert(
            'negative_months',
            (v) => (v as num).toInt(),
          ),
          months: $checkedConvert(
            'months',
            (v) => (v as List<dynamic>)
                .map(
                  (e) =>
                      PerformanceMonthOut.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
          ),
          series: $checkedConvert(
            'series',
            (v) => (v as List<dynamic>)
                .map((e) => SeriesPointOut.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
          beforeUntil: $checkedConvert(
            'before_until',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          beforeContributed: $checkedConvert(
            'before_contributed',
            (v) => v as String?,
          ),
          beforeValue: $checkedConvert('before_value', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'twrAnnual': 'twr_annual',
        'maxDrawdown': 'max_drawdown',
        'positiveMonths': 'positive_months',
        'negativeMonths': 'negative_months',
        'beforeUntil': 'before_until',
        'beforeContributed': 'before_contributed',
        'beforeValue': 'before_value',
      },
    );

Map<String, dynamic> _$PerformanceOutToJson(PerformanceOut instance) =>
    <String, dynamic>{
      'first': instance.first?.toIso8601String(),
      'days': instance.days,
      'value': instance.value,
      'contributed': instance.contributed,
      'gain': instance.gain,
      'twr': instance.twr,
      'twr_annual': instance.twrAnnual,
      'ytd': instance.ytd,
      'xirr': instance.xirr,
      'max_drawdown': instance.maxDrawdown,
      'volatility': instance.volatility,
      'best': instance.best?.toJson(),
      'worst': instance.worst?.toJson(),
      'positive_months': instance.positiveMonths,
      'negative_months': instance.negativeMonths,
      'months': instance.months.map((e) => e.toJson()).toList(),
      'series': instance.series.map((e) => e.toJson()).toList(),
      'before_until': ?instance.beforeUntil?.toIso8601String(),
      'before_contributed': ?instance.beforeContributed,
      'before_value': ?instance.beforeValue,
    };
