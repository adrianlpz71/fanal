//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/projection_point_out.dart';
import 'package:faro_api/src/model/cut_effect_out.dart';
import 'package:faro_api/src/model/fire_settings_out.dart';
import 'package:faro_api/src/model/fire_result_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'fire_plan_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FirePlanOut {
  /// Returns a new [FirePlanOut] instance.
  FirePlanOut({

    required  this.settings,

    required  this.age,

    required  this.capital,

    required  this.capitalAuto,

    required  this.monthlyContribution,

    required  this.contributionAuto,

    required  this.cyclesUsed,

    required  this.avgSpend,

    required  this.gainRatio,

    required  this.grossAnnual,

    required  this.taxAnnual,

    required  this.base_,

    required  this.pessimistic,

    required  this.optimistic,

    required  this.projection,

    required  this.cutEffect,
  });

  @JsonKey(
    
    name: r'settings',
    required: true,
    includeIfNull: false,
  )


  final FireSettingsOut settings;



  @JsonKey(
    
    name: r'age',
    required: true,
    includeIfNull: false,
  )


  final String age;



  @JsonKey(
    
    name: r'capital',
    required: true,
    includeIfNull: false,
  )


  final String capital;



  @JsonKey(
    
    name: r'capital_auto',
    required: true,
    includeIfNull: false,
  )


  final String capitalAuto;



  @JsonKey(
    
    name: r'monthly_contribution',
    required: true,
    includeIfNull: false,
  )


  final String monthlyContribution;



  @JsonKey(
    
    name: r'contribution_auto',
    required: true,
    includeIfNull: false,
  )


  final String contributionAuto;



  @JsonKey(
    
    name: r'cycles_used',
    required: true,
    includeIfNull: false,
  )


  final int cyclesUsed;



  @JsonKey(
    
    name: r'avg_spend',
    required: true,
    includeIfNull: true,
  )


  final String? avgSpend;



  @JsonKey(
    
    name: r'gain_ratio',
    required: true,
    includeIfNull: true,
  )


  final String? gainRatio;



  @JsonKey(
    
    name: r'gross_annual',
    required: true,
    includeIfNull: false,
  )


  final String grossAnnual;



  @JsonKey(
    
    name: r'tax_annual',
    required: true,
    includeIfNull: false,
  )


  final String taxAnnual;



  @JsonKey(
    
    name: r'base',
    required: true,
    includeIfNull: false,
  )


  final FireResultOut base_;



  @JsonKey(
    
    name: r'pessimistic',
    required: true,
    includeIfNull: false,
  )


  final FireResultOut pessimistic;



  @JsonKey(
    
    name: r'optimistic',
    required: true,
    includeIfNull: false,
  )


  final FireResultOut optimistic;



  @JsonKey(
    
    name: r'projection',
    required: true,
    includeIfNull: false,
  )


  final List<ProjectionPointOut> projection;



  @JsonKey(
    
    name: r'cut_effect',
    required: true,
    includeIfNull: false,
  )


  final List<CutEffectOut> cutEffect;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FirePlanOut &&
      other.settings == settings &&
      other.age == age &&
      other.capital == capital &&
      other.capitalAuto == capitalAuto &&
      other.monthlyContribution == monthlyContribution &&
      other.contributionAuto == contributionAuto &&
      other.cyclesUsed == cyclesUsed &&
      other.avgSpend == avgSpend &&
      other.gainRatio == gainRatio &&
      other.grossAnnual == grossAnnual &&
      other.taxAnnual == taxAnnual &&
      other.base_ == base_ &&
      other.pessimistic == pessimistic &&
      other.optimistic == optimistic &&
      other.projection == projection &&
      other.cutEffect == cutEffect;

    @override
    int get hashCode =>
        settings.hashCode +
        age.hashCode +
        capital.hashCode +
        capitalAuto.hashCode +
        monthlyContribution.hashCode +
        contributionAuto.hashCode +
        cyclesUsed.hashCode +
        (avgSpend == null ? 0 : avgSpend.hashCode) +
        (gainRatio == null ? 0 : gainRatio.hashCode) +
        grossAnnual.hashCode +
        taxAnnual.hashCode +
        base_.hashCode +
        pessimistic.hashCode +
        optimistic.hashCode +
        projection.hashCode +
        cutEffect.hashCode;

  factory FirePlanOut.fromJson(Map<String, dynamic> json) => _$FirePlanOutFromJson(json);

  Map<String, dynamic> toJson() => _$FirePlanOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

