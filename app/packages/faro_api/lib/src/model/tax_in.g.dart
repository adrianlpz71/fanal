// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaxIn _$TaxInFromJson(Map<String, dynamic> json) => $checkedCreate(
  'TaxIn',
  json,
  ($checkedConvert) {
    final val = TaxIn(
      baseGeneral: $checkedConvert('base_general', (v) => v as String? ?? '0'),
      baseSavings: $checkedConvert('base_savings', (v) => v as String? ?? '0'),
      netWealth: $checkedConvert('net_wealth', (v) => v as String?),
      homeValue: $checkedConvert('home_value', (v) => v as String?),
      rememberBaseGeneral: $checkedConvert(
        'remember_base_general',
        (v) => v as bool? ?? false,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'baseGeneral': 'base_general',
    'baseSavings': 'base_savings',
    'netWealth': 'net_wealth',
    'homeValue': 'home_value',
    'rememberBaseGeneral': 'remember_base_general',
  },
);

Map<String, dynamic> _$TaxInToJson(TaxIn instance) => <String, dynamic>{
  'base_general': ?instance.baseGeneral,
  'base_savings': ?instance.baseSavings,
  'net_wealth': ?instance.netWealth,
  'home_value': ?instance.homeValue,
  'remember_base_general': ?instance.rememberBaseGeneral,
};
