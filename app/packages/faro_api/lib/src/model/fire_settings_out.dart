//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'fire_settings_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FireSettingsOut {
  /// Returns a new [FireSettingsOut] instance.
  FireSettingsOut({

    required  this.configured,

    required  this.targetAge,

    required  this.monthlySpend,

    required  this.swr,

    required  this.nominalReturn,

    required  this.inflation,

    required  this.costs,

    required  this.contributionGrowth,

    required  this.pensionMonthly,

    required  this.pensionAge,

    required  this.includeTaxes,

    required  this.homeValue,

    required  this.volatility,

    required  this.horizonAge,

    required  this.capitalOverride,

    required  this.contributionOverride,
  });

  @JsonKey(
    
    name: r'configured',
    required: true,
    includeIfNull: false,
  )


  final bool configured;



  @JsonKey(
    
    name: r'target_age',
    required: true,
    includeIfNull: false,
  )


  final int targetAge;



  @JsonKey(
    
    name: r'monthly_spend',
    required: true,
    includeIfNull: false,
  )


  final String monthlySpend;



  @JsonKey(
    
    name: r'swr',
    required: true,
    includeIfNull: false,
  )


  final String swr;



  @JsonKey(
    
    name: r'nominal_return',
    required: true,
    includeIfNull: false,
  )


  final String nominalReturn;



  @JsonKey(
    
    name: r'inflation',
    required: true,
    includeIfNull: false,
  )


  final String inflation;



  @JsonKey(
    
    name: r'costs',
    required: true,
    includeIfNull: false,
  )


  final String costs;



  @JsonKey(
    
    name: r'contribution_growth',
    required: true,
    includeIfNull: false,
  )


  final String contributionGrowth;



  @JsonKey(
    
    name: r'pension_monthly',
    required: true,
    includeIfNull: false,
  )


  final String pensionMonthly;



  @JsonKey(
    
    name: r'pension_age',
    required: true,
    includeIfNull: false,
  )


  final int pensionAge;



  @JsonKey(
    
    name: r'include_taxes',
    required: true,
    includeIfNull: false,
  )


  final bool includeTaxes;



  @JsonKey(
    
    name: r'home_value',
    required: true,
    includeIfNull: false,
  )


  final String homeValue;



  @JsonKey(
    
    name: r'volatility',
    required: true,
    includeIfNull: false,
  )


  final String volatility;



  @JsonKey(
    
    name: r'horizon_age',
    required: true,
    includeIfNull: false,
  )


  final int horizonAge;



  @JsonKey(
    
    name: r'capital_override',
    required: true,
    includeIfNull: true,
  )


  final String? capitalOverride;



  @JsonKey(
    
    name: r'contribution_override',
    required: true,
    includeIfNull: true,
  )


  final String? contributionOverride;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FireSettingsOut &&
      other.configured == configured &&
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
      other.contributionOverride == contributionOverride;

    @override
    int get hashCode =>
        configured.hashCode +
        targetAge.hashCode +
        monthlySpend.hashCode +
        swr.hashCode +
        nominalReturn.hashCode +
        inflation.hashCode +
        costs.hashCode +
        contributionGrowth.hashCode +
        pensionMonthly.hashCode +
        pensionAge.hashCode +
        includeTaxes.hashCode +
        homeValue.hashCode +
        volatility.hashCode +
        horizonAge.hashCode +
        (capitalOverride == null ? 0 : capitalOverride.hashCode) +
        (contributionOverride == null ? 0 : contributionOverride.hashCode);

  factory FireSettingsOut.fromJson(Map<String, dynamic> json) => _$FireSettingsOutFromJson(json);

  Map<String, dynamic> toJson() => _$FireSettingsOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

