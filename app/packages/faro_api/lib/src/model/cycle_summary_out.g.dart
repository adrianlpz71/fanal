// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_summary_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CycleSummaryOut _$CycleSummaryOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CycleSummaryOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'carried',
            'payroll',
            'opening',
            'available_now',
            'expected_end',
            'net_movements',
            'pending_total',
            'fixed_spend',
            'variable_spend',
            'installments',
            'savings',
            'savings_rate',
            'days_to_payday',
            'per_day',
          ],
        );
        final val = CycleSummaryOut(
          carried: $checkedConvert('carried', (v) => v as String),
          payroll: $checkedConvert('payroll', (v) => v as String),
          opening: $checkedConvert('opening', (v) => v as String),
          availableNow: $checkedConvert('available_now', (v) => v as String),
          expectedEnd: $checkedConvert('expected_end', (v) => v as String),
          netMovements: $checkedConvert('net_movements', (v) => v as String),
          pendingTotal: $checkedConvert('pending_total', (v) => v as String),
          fixedSpend: $checkedConvert('fixed_spend', (v) => v as String),
          variableSpend: $checkedConvert('variable_spend', (v) => v as String),
          installments: $checkedConvert('installments', (v) => v as String),
          savings: $checkedConvert('savings', (v) => v as String),
          savingsRate: $checkedConvert('savings_rate', (v) => v as String?),
          daysToPayday: $checkedConvert(
            'days_to_payday',
            (v) => (v as num?)?.toInt(),
          ),
          perDay: $checkedConvert('per_day', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'availableNow': 'available_now',
        'expectedEnd': 'expected_end',
        'netMovements': 'net_movements',
        'pendingTotal': 'pending_total',
        'fixedSpend': 'fixed_spend',
        'variableSpend': 'variable_spend',
        'savingsRate': 'savings_rate',
        'daysToPayday': 'days_to_payday',
        'perDay': 'per_day',
      },
    );

Map<String, dynamic> _$CycleSummaryOutToJson(CycleSummaryOut instance) =>
    <String, dynamic>{
      'carried': instance.carried,
      'payroll': instance.payroll,
      'opening': instance.opening,
      'available_now': instance.availableNow,
      'expected_end': instance.expectedEnd,
      'net_movements': instance.netMovements,
      'pending_total': instance.pendingTotal,
      'fixed_spend': instance.fixedSpend,
      'variable_spend': instance.variableSpend,
      'installments': instance.installments,
      'savings': instance.savings,
      'savings_rate': instance.savingsRate,
      'days_to_payday': instance.daysToPayday,
      'per_day': instance.perDay,
    };
