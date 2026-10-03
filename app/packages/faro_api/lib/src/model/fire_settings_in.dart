//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'fire_settings_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FireSettingsIn {
  /// Returns a new [FireSettingsIn] instance.
  FireSettingsIn({

     this.targetAge,

     this.monthlySpend,

     this.swr,

     this.nominalReturn,

     this.inflation,

     this.costs,

     this.contributionGrowth,

     this.pensionMonthly,

     this.pensionAge,

     this.includeTaxes,

     this.homeValue,

     this.volatility,

     this.horizonAge,

     this.capitalOverride,

     this.contributionOverride,

     this.clearCapitalOverride = false,

     this.clearContributionOverride = false,
  });

          // minimum: 18
          // maximum: 100
  @JsonKey(
    
    name: r'target_age',
    required: false,
    includeIfNull: false,
  )


  final int? targetAge;



  @JsonKey(
    
    name: r'monthly_spend',
    required: false,
    includeIfNull: false,
  )


  final String? monthlySpend;



  @JsonKey(
    
    name: r'swr',
    required: false,
    includeIfNull: false,
  )


  final String? swr;



  @JsonKey(
    
    name: r'nominal_return',
    required: false,
    includeIfNull: false,
  )


  final String? nominalReturn;



  @JsonKey(
    
    name: r'inflation',
    required: false,
    includeIfNull: false,
  )


  final String? inflation;



  @JsonKey(
    
    name: r'costs',
    required: false,
    includeIfNull: false,
  )


  final String? costs;



  @JsonKey(
    
    name: r'contribution_growth',
    required: false,
    includeIfNull: false,
  )


  final String? contributionGrowth;



  @JsonKey(
    
    name: r'pension_monthly',
    required: false,
    includeIfNull: false,
  )


  final String? pensionMonthly;



          // minimum: 50
          // maximum: 80
  @JsonKey(
    
    name: r'pension_age',
    required: false,
    includeIfNull: false,
  )


  final int? pensionAge;



  @JsonKey(
    
    name: r'include_taxes',
    required: false,
    includeIfNull: false,
  )


  final bool? includeTaxes;



  @JsonKey(
    
    name: r'home_value',
    required: false,
    includeIfNull: false,
  )


  final String? homeValue;



  @JsonKey(
    
    name: r'volatility',
    required: false,
    includeIfNull: false,
  )


  final String? volatility;



          // minimum: 60
          // maximum: 110
  @JsonKey(
    
    name: r'horizon_age',
    required: false,
    includeIfNull: false,
  )


  final int? horizonAge;



  @JsonKey(
    
    name: r'capital_override',
    required: false,
    includeIfNull: false,
  )


  final String? capitalOverride;



  @JsonKey(
    
    name: r'contribution_override',
    required: false,
    includeIfNull: false,
  )


  final String? contributionOverride;



  @JsonKey(
    defaultValue: false,
    name: r'clear_capital_override',
    required: false,
    includeIfNull: false,
  )


  final bool? clearCapitalOverride;



  @JsonKey(
    defaultValue: false,
    name: r'clear_contribution_override',
    required: false,
    includeIfNull: false,
  )


  final bool? clearContributionOverride;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FireSettingsIn &&
      other.targetAge == targetAge &&
      other.monthlySpend == monthlySpend &&
      other.swr == swr &&
      other.nominalReturn == nominalReturn &&
      other.inflation == inflation &&
      other.costs == costs &&
      other.contributionGrowth == contributionGrowth &&
      other.pensionMonthly == pensionMonthly &&
      other.pensionAge == pensionAge &&
      other.includeTaxes == includeTaxes &&
      other.homeValue == homeValue &&
      other.volatility == volatility &&
      other.horizonAge == horizonAge &&
      other.capitalOverride == capitalOverride &&
      other.contributionOverride == contributionOverride &&
      other.clearCapitalOverride == clearCapitalOverride &&
      other.clearContributionOverride == clearContributionOverride;

    @override
    int get hashCode =>
        (targetAge == null ? 0 : targetAge.hashCode) +
        (monthlySpend == null ? 0 : monthlySpend.hashCode) +
        (swr == null ? 0 : swr.hashCode) +
        (nominalReturn == null ? 0 : nominalReturn.hashCode) +
        (inflation == null ? 0 : inflation.hashCode) +
        (costs == null ? 0 : costs.hashCode) +
        (contributionGrowth == null ? 0 : contributionGrowth.hashCode) +
        (pensionMonthly == null ? 0 : pensionMonthly.hashCode) +
        (pensionAge == null ? 0 : pensionAge.hashCode) +
        (includeTaxes == null ? 0 : includeTaxes.hashCode) +
        (homeValue == null ? 0 : homeValue.hashCode) +
        (volatility == null ? 0 : volatility.hashCode) +
        (horizonAge == null ? 0 : horizonAge.hashCode) +
        (capitalOverride == null ? 0 : capitalOverride.hashCode) +
        (contributionOverride == null ? 0 : contributionOverride.hashCode) +
        clearCapitalOverride.hashCode +
        clearContributionOverride.hashCode;

  factory FireSettingsIn.fromJson(Map<String, dynamic> json) => _$FireSettingsInFromJson(json);

  Map<String, dynamic> toJson() => _$FireSettingsInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

