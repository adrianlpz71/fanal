// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_stats_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CycleStatsOut _$CycleStatsOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CycleStatsOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'cycle_id',
            'label',
            'status',
            'payroll',
            'income',
            'spend',
            'fixed',
            'variable',
            'installments',
            'savings',
            'savings_rate',
            'by_category',
          ],
        );
        final val = CycleStatsOut(
          cycleId: $checkedConvert('cycle_id', (v) => v as String),
          label: $checkedConvert('label', (v) => v as String),
          status: $checkedConvert('status', (v) => v as String),
          payroll: $checkedConvert('payroll', (v) => v as String),
          income: $checkedConvert('income', (v) => v as String),
          spend: $checkedConvert('spend', (v) => v as String),
          fixed: $checkedConvert('fixed', (v) => v as String),
          variable: $checkedConvert('variable', (v) => v as String),
          installments: $checkedConvert('installments', (v) => v as String),
          savings: $checkedConvert('savings', (v) => v as String),
          savingsRate: $checkedConvert('savings_rate', (v) => v as String?),
          byCategory: $checkedConvert(
            'by_category',
            (v) => (v as List<dynamic>)
                .map(
                  (e) => CategoryAmountOut.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'cycleId': 'cycle_id',
        'savingsRate': 'savings_rate',
        'byCategory': 'by_category',
      },
    );

Map<String, dynamic> _$CycleStatsOutToJson(CycleStatsOut instance) =>
    <String, dynamic>{
      'cycle_id': instance.cycleId,
      'label': instance.label,
      'status': instance.status,
      'payroll': instance.payroll,
      'income': instance.income,
      'spend': instance.spend,
      'fixed': instance.fixed,
      'variable': instance.variable,
      'installments': instance.installments,
      'savings': instance.savings,
      'savings_rate': instance.savingsRate,
      'by_category': instance.byCategory.map((e) => e.toJson()).toList(),
    };
