// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fire_plan_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FirePlanOut _$FirePlanOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'FirePlanOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'settings',
        'age',
        'capital',
        'capital_auto',
        'monthly_contribution',
        'contribution_auto',
        'cycles_used',
        'avg_spend',
        'gain_ratio',
        'gross_annual',
        'tax_annual',
        'base',
        'pessimistic',
        'optimistic',
        'projection',
        'cut_effect',
      ],
    );
    final val = FirePlanOut(
      settings: $checkedConvert(
        'settings',
        (v) => FireSettingsOut.fromJson(v as Map<String, dynamic>),
      ),
      age: $checkedConvert('age', (v) => v as String),
      capital: $checkedConvert('capital', (v) => v as String),
      capitalAuto: $checkedConvert('capital_auto', (v) => v as String),
      monthlyContribution: $checkedConvert(
        'monthly_contribution',
        (v) => v as String,
      ),
      contributionAuto: $checkedConvert(
        'contribution_auto',
        (v) => v as String,
      ),
      cyclesUsed: $checkedConvert('cycles_used', (v) => (v as num).toInt()),
      avgSpend: $checkedConvert('avg_spend', (v) => v as String?),
      gainRatio: $checkedConvert('gain_ratio', (v) => v as String?),
      grossAnnual: $checkedConvert('gross_annual', (v) => v as String),
      taxAnnual: $checkedConvert('tax_annual', (v) => v as String),
      base_: $checkedConvert(
        'base',
        (v) => FireResultOut.fromJson(v as Map<String, dynamic>),
      ),
      pessimistic: $checkedConvert(
        'pessimistic',
        (v) => FireResultOut.fromJson(v as Map<String, dynamic>),
      ),
      optimistic: $checkedConvert(
        'optimistic',
        (v) => FireResultOut.fromJson(v as Map<String, dynamic>),
      ),
      projection: $checkedConvert(
        'projection',
        (v) => (v as List<dynamic>)
            .map((e) => ProjectionPointOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      cutEffect: $checkedConvert(
        'cut_effect',
        (v) => (v as List<dynamic>)
            .map((e) => CutEffectOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'capitalAuto': 'capital_auto',
    'monthlyContribution': 'monthly_contribution',
    'contributionAuto': 'contribution_auto',
    'cyclesUsed': 'cycles_used',
    'avgSpend': 'avg_spend',
    'gainRatio': 'gain_ratio',
    'grossAnnual': 'gross_annual',
    'taxAnnual': 'tax_annual',
    'base_': 'base',
    'cutEffect': 'cut_effect',
  },
);

Map<String, dynamic> _$FirePlanOutToJson(FirePlanOut instance) =>
    <String, dynamic>{
      'settings': instance.settings.toJson(),
      'age': instance.age,
      'capital': instance.capital,
      'capital_auto': instance.capitalAuto,
      'monthly_contribution': instance.monthlyContribution,
      'contribution_auto': instance.contributionAuto,
      'cycles_used': instance.cyclesUsed,
      'avg_spend': instance.avgSpend,
      'gain_ratio': instance.gainRatio,
      'gross_annual': instance.grossAnnual,
      'tax_annual': instance.taxAnnual,
      'base': instance.base_.toJson(),
      'pessimistic': instance.pessimistic.toJson(),
      'optimistic': instance.optimistic.toJson(),
      'projection': instance.projection.map((e) => e.toJson()).toList(),
      'cut_effect': instance.cutEffect.map((e) => e.toJson()).toList(),
    };
