//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/tax_bracket_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tax_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TaxOut {
  /// Returns a new [TaxOut] instance.
  TaxOut({

    required  this.year,

    required  this.region,

    required  this.irpfGeneralState,

    required  this.irpfGeneralRegional,

    required  this.irpfSavings,

    required  this.irpfTotal,

    required  this.wealthTaxable,

    required  this.wealthQuotaBeforeLimit,

    required  this.wealthQuota,

    required  this.wealthJointLimitApplied,

    required  this.wealthObliged,

    required  this.solidarityWarning,

    required  this.baseGeneral,

    required  this.baseSavings,

    required  this.minimumState,

    required  this.minimumRegional,

    required  this.minimumQuota,

    required  this.generalBrackets,

    required  this.savingsBrackets,

    required  this.averageRate,

    required  this.marginalGeneral,

    required  this.marginalSavings,
  });

  @JsonKey(
    
    name: r'year',
    required: true,
    includeIfNull: false,
  )


  final int year;



  @JsonKey(
    
    name: r'region',
    required: true,
    includeIfNull: false,
  )


  final String region;



  @JsonKey(
    
    name: r'irpf_general_state',
    required: true,
    includeIfNull: false,
  )


  final String irpfGeneralState;



  @JsonKey(
    
    name: r'irpf_general_regional',
    required: true,
    includeIfNull: false,
  )


  final String irpfGeneralRegional;



  @JsonKey(
    
    name: r'irpf_savings',
    required: true,
    includeIfNull: false,
  )


  final String irpfSavings;



  @JsonKey(
    
    name: r'irpf_total',
    required: true,
    includeIfNull: false,
  )


  final String irpfTotal;



  @JsonKey(
    
    name: r'wealth_taxable',
    required: true,
    includeIfNull: false,
  )


  final String wealthTaxable;



  @JsonKey(
    
    name: r'wealth_quota_before_limit',
    required: true,
    includeIfNull: false,
  )


  final String wealthQuotaBeforeLimit;



  @JsonKey(
    
    name: r'wealth_quota',
    required: true,
    includeIfNull: false,
  )


  final String wealthQuota;



  @JsonKey(
    
    name: r'wealth_joint_limit_applied',
    required: true,
    includeIfNull: false,
  )


  final bool wealthJointLimitApplied;



  @JsonKey(
    
    name: r'wealth_obliged',
    required: true,
    includeIfNull: false,
  )


  final bool wealthObliged;



  @JsonKey(
    
    name: r'solidarity_warning',
    required: true,
    includeIfNull: false,
  )


  final bool solidarityWarning;



  @JsonKey(
    
    name: r'base_general',
    required: true,
    includeIfNull: false,
  )


  final String baseGeneral;



  @JsonKey(
    
    name: r'base_savings',
    required: true,
    includeIfNull: false,
  )


  final String baseSavings;



  @JsonKey(
    
    name: r'minimum_state',
    required: true,
    includeIfNull: false,
  )


  final String minimumState;



  @JsonKey(
    
    name: r'minimum_regional',
    required: true,
    includeIfNull: false,
  )


  final String minimumRegional;



      /// Cuota que corresponde al mínimo personal (se resta)
  @JsonKey(
    
    name: r'minimum_quota',
    required: true,
    includeIfNull: false,
  )


  final String minimumQuota;



      /// Escala estatal + autonómica
  @JsonKey(
    
    name: r'general_brackets',
    required: true,
    includeIfNull: false,
  )


  final List<TaxBracketOut> generalBrackets;



  @JsonKey(
    
    name: r'savings_brackets',
    required: true,
    includeIfNull: false,
  )


  final List<TaxBracketOut> savingsBrackets;



  @JsonKey(
    
    name: r'average_rate',
    required: true,
    includeIfNull: true,
  )


  final String? averageRate;



  @JsonKey(
    
    name: r'marginal_general',
    required: true,
    includeIfNull: false,
  )


  final String marginalGeneral;



  @JsonKey(
    
    name: r'marginal_savings',
    required: true,
    includeIfNull: false,
  )


  final String marginalSavings;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TaxOut &&
      other.year == year &&
      other.region == region &&
      other.irpfGeneralState == irpfGeneralState &&
      other.irpfGeneralRegional == irpfGeneralRegional &&
      other.irpfSavings == irpfSavings &&
      other.irpfTotal == irpfTotal &&
      other.wealthTaxable == wealthTaxable &&
      other.wealthQuotaBeforeLimit == wealthQuotaBeforeLimit &&
      other.wealthQuota == wealthQuota &&
      other.wealthJointLimitApplied == wealthJointLimitApplied &&
      other.wealthObliged == wealthObliged &&
      other.solidarityWarning == solidarityWarning &&
      other.baseGeneral == baseGeneral &&
      other.baseSavings == baseSavings &&
      other.minimumState == minimumState &&
      other.minimumRegional == minimumRegional &&
      other.minimumQuota == minimumQuota &&
      other.generalBrackets == generalBrackets &&
      other.savingsBrackets == savingsBrackets &&
      other.averageRate == averageRate &&
      other.marginalGeneral == marginalGeneral &&
      other.marginalSavings == marginalSavings;

    @override
    int get hashCode =>
        year.hashCode +
        region.hashCode +
        irpfGeneralState.hashCode +
        irpfGeneralRegional.hashCode +
        irpfSavings.hashCode +
        irpfTotal.hashCode +
        wealthTaxable.hashCode +
        wealthQuotaBeforeLimit.hashCode +
        wealthQuota.hashCode +
        wealthJointLimitApplied.hashCode +
        wealthObliged.hashCode +
        solidarityWarning.hashCode +
        baseGeneral.hashCode +
        baseSavings.hashCode +
        minimumState.hashCode +
        minimumRegional.hashCode +
        minimumQuota.hashCode +
        generalBrackets.hashCode +
        savingsBrackets.hashCode +
        (averageRate == null ? 0 : averageRate.hashCode) +
        marginalGeneral.hashCode +
        marginalSavings.hashCode;

  factory TaxOut.fromJson(Map<String, dynamic> json) => _$TaxOutFromJson(json);

  Map<String, dynamic> toJson() => _$TaxOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

