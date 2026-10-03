// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fire_settings_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FireSettingsOut _$FireSettingsOutFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'FireSettingsOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'configured',
        'target_age',
        'monthly_spend',
        'swr',
        'nominal_return',
        'inflation',
        'costs',
        'contribution_growth',
        'pension_monthly',
        'pension_age',
        'include_taxes',
        'home_value',
        'volatility',
        'horizon_age',
        'capital_override',
        'contribution_override',
      ],
    );
    final val = FireSettingsOut(
      configured: $checkedConvert('configured', (v) => v as bool),
      targetAge: $checkedConvert('target_age', (v) => (v as num).toInt()),
      monthlySpend: $checkedConvert('monthly_spend', (v) => v as String),
      swr: $checkedConvert('swr', (v) => v as String),
      nominalReturn: $checkedConvert('nominal_return', (v) => v as String),
      inflation: $checkedConvert('inflation', (v) => v as String),
      costs: $checkedConvert('costs', (v) => v as String),
      contributionGrowth: $checkedConvert(
        'contribution_growth',
        (v) => v as String,
      ),
      pensionMonthly: $checkedConvert('pension_monthly', (v) => v as String),
      pensionAge: $checkedConvert('pension_age', (v) => (v as num).toInt()),
      includeTaxes: $checkedConvert('include_taxes', (v) => v as bool),
      homeValue: $checkedConvert('home_value', (v) => v as String),
      volatility: $checkedConvert('volatility', (v) => v as String),
      horizonAge: $checkedConvert('horizon_age', (v) => (v as num).toInt()),
      capitalOverride: $checkedConvert('capital_override', (v) => v as String?),
      contributionOverride: $checkedConvert(
        'contribution_override',
        (v) => v as String?,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'targetAge': 'target_age',
    'monthlySpend': 'monthly_spend',
    'nominalReturn': 'nominal_return',
    'contributionGrowth': 'contribution_growth',
    'pensionMonthly': 'pension_monthly',
    'pensionAge': 'pension_age',
    'includeTaxes': 'include_taxes',
    'homeValue': 'home_value',
    'horizonAge': 'horizon_age',
    'capitalOverride': 'capital_override',
    'contributionOverride': 'contribution_override',
  },
);

Map<String, dynamic> _$FireSettingsOutToJson(FireSettingsOut instance) =>
    <String, dynamic>{
      'configured': instance.configured,
      'target_age': instance.targetAge,
      'monthly_spend': instance.monthlySpend,
      'swr': instance.swr,
      'nominal_return': instance.nominalReturn,
      'inflation': instance.inflation,
      'costs': instance.costs,
      'contribution_growth': instance.contributionGrowth,
      'pension_monthly': instance.pensionMonthly,
      'pension_age': instance.pensionAge,
      'include_taxes': instance.includeTaxes,
      'home_value': instance.homeValue,
      'volatility': instance.volatility,
      'horizon_age': instance.horizonAge,
      'capital_override': instance.capitalOverride,
      'contribution_override': instance.contributionOverride,
    };
