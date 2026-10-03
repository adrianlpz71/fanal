// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_prefill_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaxPrefillOut _$TaxPrefillOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'TaxPrefillOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'year',
            'payroll_net',
            'base_general',
            'realized_gains',
            'income',
            'base_savings',
            'sales',
          ],
        );
        final val = TaxPrefillOut(
          year: $checkedConvert('year', (v) => (v as num).toInt()),
          payrollNet: $checkedConvert('payroll_net', (v) => v as String),
          baseGeneral: $checkedConvert('base_general', (v) => v as String?),
          realizedGains: $checkedConvert('realized_gains', (v) => v as String),
          income: $checkedConvert('income', (v) => v as String),
          baseSavings: $checkedConvert('base_savings', (v) => v as String),
          sales: $checkedConvert('sales', (v) => (v as num).toInt()),
        );
        return val;
      },
      fieldKeyMap: const {
        'payrollNet': 'payroll_net',
        'baseGeneral': 'base_general',
        'realizedGains': 'realized_gains',
        'baseSavings': 'base_savings',
      },
    );

Map<String, dynamic> _$TaxPrefillOutToJson(TaxPrefillOut instance) =>
    <String, dynamic>{
      'year': instance.year,
      'payroll_net': instance.payrollNet,
      'base_general': instance.baseGeneral,
      'realized_gains': instance.realizedGains,
      'income': instance.income,
      'base_savings': instance.baseSavings,
      'sales': instance.sales,
    };
