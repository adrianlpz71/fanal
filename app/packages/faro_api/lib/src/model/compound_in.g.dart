// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compound_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompoundIn _$CompoundInFromJson(Map<String, dynamic> json) => $checkedCreate(
  'CompoundIn',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['annual_rate', 'years']);
    final val = CompoundIn(
      initial: $checkedConvert('initial', (v) => v as String? ?? '0'),
      contribution: $checkedConvert('contribution', (v) => v as String? ?? '0'),
      periods: $checkedConvert(
        'periods',
        (v) => $enumDecodeNullable(_$CompoundInPeriodsEnumEnumMap, v),
      ),
      timing: $checkedConvert(
        'timing',
        (v) => $enumDecodeNullable(_$CompoundInTimingEnumEnumMap, v),
      ),
      annualIncrease: $checkedConvert(
        'annual_increase',
        (v) => v as String? ?? '0',
      ),
      annualRate: $checkedConvert('annual_rate', (v) => v as String),
      years: $checkedConvert('years', (v) => (v as num).toInt()),
      convention: $checkedConvert(
        'convention',
        (v) => $enumDecodeNullable(_$CompoundInConventionEnumEnumMap, v),
      ),
      inflation: $checkedConvert('inflation', (v) => v as String? ?? '0'),
      taxOnWithdrawal: $checkedConvert(
        'tax_on_withdrawal',
        (v) => v as bool? ?? false,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'annualIncrease': 'annual_increase',
    'annualRate': 'annual_rate',
    'taxOnWithdrawal': 'tax_on_withdrawal',
  },
);

Map<String, dynamic> _$CompoundInToJson(CompoundIn instance) =>
    <String, dynamic>{
      'initial': ?instance.initial,
      'contribution': ?instance.contribution,
      'periods': ?_$CompoundInPeriodsEnumEnumMap[instance.periods],
      'timing': ?_$CompoundInTimingEnumEnumMap[instance.timing],
      'annual_increase': ?instance.annualIncrease,
      'annual_rate': instance.annualRate,
      'years': instance.years,
      'convention': ?_$CompoundInConventionEnumEnumMap[instance.convention],
      'inflation': ?instance.inflation,
      'tax_on_withdrawal': ?instance.taxOnWithdrawal,
    };

const _$CompoundInPeriodsEnumEnumMap = {
  CompoundInPeriodsEnum.number12: 12,
  CompoundInPeriodsEnum.number1: 1,
};

const _$CompoundInTimingEnumEnumMap = {
  CompoundInTimingEnum.inicio: 'inicio',
  CompoundInTimingEnum.final_: 'final',
};

const _$CompoundInConventionEnumEnumMap = {
  CompoundInConventionEnum.nominal: 'nominal',
  CompoundInConventionEnum.efectivo: 'efectivo',
};
