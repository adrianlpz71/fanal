// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quarter_metrics_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuarterMetricsOut _$QuarterMetricsOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'QuarterMetricsOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'cycles',
            'income',
            'spend',
            'surplus',
            'savings_rate',
            'fixed_avg',
            'portfolio_start',
            'portfolio_end',
            'contributed',
            'gain',
            'twr',
            'networth_start',
            'networth_end',
            'fire_needed',
            'fire_progress',
            'fire_age',
            'out_of_range',
            'goals',
          ],
        );
        final val = QuarterMetricsOut(
          cycles: $checkedConvert('cycles', (v) => (v as num).toInt()),
          income: $checkedConvert('income', (v) => v as String),
          spend: $checkedConvert('spend', (v) => v as String),
          surplus: $checkedConvert('surplus', (v) => v as String),
          savingsRate: $checkedConvert('savings_rate', (v) => v as String?),
          fixedAvg: $checkedConvert('fixed_avg', (v) => v as String?),
          portfolioStart: $checkedConvert(
            'portfolio_start',
            (v) => v as String,
          ),
          portfolioEnd: $checkedConvert('portfolio_end', (v) => v as String),
          contributed: $checkedConvert('contributed', (v) => v as String),
          gain: $checkedConvert('gain', (v) => v as String),
          twr: $checkedConvert('twr', (v) => v as String?),
          networthStart: $checkedConvert('networth_start', (v) => v as String),
          networthEnd: $checkedConvert('networth_end', (v) => v as String),
          fireNeeded: $checkedConvert('fire_needed', (v) => v as String?),
          fireProgress: $checkedConvert('fire_progress', (v) => v as String?),
          fireAge: $checkedConvert('fire_age', (v) => v as String?),
          outOfRange: $checkedConvert(
            'out_of_range',
            (v) => (v as List<dynamic>).map((e) => e as String).toList(),
          ),
          goals: $checkedConvert(
            'goals',
            (v) => (v as List<dynamic>)
                .map((e) => ReviewGoalOut.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'savingsRate': 'savings_rate',
        'fixedAvg': 'fixed_avg',
        'portfolioStart': 'portfolio_start',
        'portfolioEnd': 'portfolio_end',
        'networthStart': 'networth_start',
        'networthEnd': 'networth_end',
        'fireNeeded': 'fire_needed',
        'fireProgress': 'fire_progress',
        'fireAge': 'fire_age',
        'outOfRange': 'out_of_range',
      },
    );

Map<String, dynamic> _$QuarterMetricsOutToJson(QuarterMetricsOut instance) =>
    <String, dynamic>{
      'cycles': instance.cycles,
      'income': instance.income,
      'spend': instance.spend,
      'surplus': instance.surplus,
      'savings_rate': instance.savingsRate,
      'fixed_avg': instance.fixedAvg,
      'portfolio_start': instance.portfolioStart,
      'portfolio_end': instance.portfolioEnd,
      'contributed': instance.contributed,
      'gain': instance.gain,
      'twr': instance.twr,
      'networth_start': instance.networthStart,
      'networth_end': instance.networthEnd,
      'fire_needed': instance.fireNeeded,
      'fire_progress': instance.fireProgress,
      'fire_age': instance.fireAge,
      'out_of_range': instance.outOfRange,
      'goals': instance.goals.map((e) => e.toJson()).toList(),
    };
