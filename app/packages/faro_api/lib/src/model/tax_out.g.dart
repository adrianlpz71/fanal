// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaxOut _$TaxOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'TaxOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'year',
        'region',
        'irpf_general_state',
        'irpf_general_regional',
        'irpf_savings',
        'irpf_total',
        'wealth_taxable',
        'wealth_quota_before_limit',
        'wealth_quota',
        'wealth_joint_limit_applied',
        'wealth_obliged',
        'solidarity_warning',
        'base_general',
        'base_savings',
        'minimum_state',
        'minimum_regional',
        'minimum_quota',
        'general_brackets',
        'savings_brackets',
        'average_rate',
        'marginal_general',
        'marginal_savings',
      ],
    );
    final val = TaxOut(
      year: $checkedConvert('year', (v) => (v as num).toInt()),
      region: $checkedConvert('region', (v) => v as String),
      irpfGeneralState: $checkedConvert(
        'irpf_general_state',
        (v) => v as String,
      ),
      irpfGeneralRegional: $checkedConvert(
        'irpf_general_regional',
        (v) => v as String,
      ),
      irpfSavings: $checkedConvert('irpf_savings', (v) => v as String),
      irpfTotal: $checkedConvert('irpf_total', (v) => v as String),
      wealthTaxable: $checkedConvert('wealth_taxable', (v) => v as String),
      wealthQuotaBeforeLimit: $checkedConvert(
        'wealth_quota_before_limit',
        (v) => v as String,
      ),
      wealthQuota: $checkedConvert('wealth_quota', (v) => v as String),
      wealthJointLimitApplied: $checkedConvert(
        'wealth_joint_limit_applied',
        (v) => v as bool,
      ),
      wealthObliged: $checkedConvert('wealth_obliged', (v) => v as bool),
      solidarityWarning: $checkedConvert(
        'solidarity_warning',
        (v) => v as bool,
      ),
      baseGeneral: $checkedConvert('base_general', (v) => v as String),
      baseSavings: $checkedConvert('base_savings', (v) => v as String),
      minimumState: $checkedConvert('minimum_state', (v) => v as String),
      minimumRegional: $checkedConvert('minimum_regional', (v) => v as String),
      minimumQuota: $checkedConvert('minimum_quota', (v) => v as String),
      generalBrackets: $checkedConvert(
        'general_brackets',
        (v) => (v as List<dynamic>)
            .map((e) => TaxBracketOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      savingsBrackets: $checkedConvert(
        'savings_brackets',
        (v) => (v as List<dynamic>)
            .map((e) => TaxBracketOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      averageRate: $checkedConvert('average_rate', (v) => v as String?),
      marginalGeneral: $checkedConvert('marginal_general', (v) => v as String),
      marginalSavings: $checkedConvert('marginal_savings', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'irpfGeneralState': 'irpf_general_state',
    'irpfGeneralRegional': 'irpf_general_regional',
    'irpfSavings': 'irpf_savings',
    'irpfTotal': 'irpf_total',
    'wealthTaxable': 'wealth_taxable',
    'wealthQuotaBeforeLimit': 'wealth_quota_before_limit',
    'wealthQuota': 'wealth_quota',
    'wealthJointLimitApplied': 'wealth_joint_limit_applied',
    'wealthObliged': 'wealth_obliged',
    'solidarityWarning': 'solidarity_warning',
    'baseGeneral': 'base_general',
    'baseSavings': 'base_savings',
    'minimumState': 'minimum_state',
    'minimumRegional': 'minimum_regional',
    'minimumQuota': 'minimum_quota',
    'generalBrackets': 'general_brackets',
    'savingsBrackets': 'savings_brackets',
    'averageRate': 'average_rate',
    'marginalGeneral': 'marginal_general',
    'marginalSavings': 'marginal_savings',
  },
);

Map<String, dynamic> _$TaxOutToJson(TaxOut instance) => <String, dynamic>{
  'year': instance.year,
  'region': instance.region,
  'irpf_general_state': instance.irpfGeneralState,
  'irpf_general_regional': instance.irpfGeneralRegional,
  'irpf_savings': instance.irpfSavings,
  'irpf_total': instance.irpfTotal,
  'wealth_taxable': instance.wealthTaxable,
  'wealth_quota_before_limit': instance.wealthQuotaBeforeLimit,
  'wealth_quota': instance.wealthQuota,
  'wealth_joint_limit_applied': instance.wealthJointLimitApplied,
  'wealth_obliged': instance.wealthObliged,
  'solidarity_warning': instance.solidarityWarning,
  'base_general': instance.baseGeneral,
  'base_savings': instance.baseSavings,
  'minimum_state': instance.minimumState,
  'minimum_regional': instance.minimumRegional,
  'minimum_quota': instance.minimumQuota,
  'general_brackets': instance.generalBrackets.map((e) => e.toJson()).toList(),
  'savings_brackets': instance.savingsBrackets.map((e) => e.toJson()).toList(),
  'average_rate': instance.averageRate,
  'marginal_general': instance.marginalGeneral,
  'marginal_savings': instance.marginalSavings,
};
