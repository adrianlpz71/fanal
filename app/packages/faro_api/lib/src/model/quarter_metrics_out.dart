//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/review_goal_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quarter_metrics_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class QuarterMetricsOut {
  /// Returns a new [QuarterMetricsOut] instance.
  QuarterMetricsOut({

    required  this.cycles,

    required  this.income,

    required  this.spend,

    required  this.surplus,

    required  this.savingsRate,

    required  this.fixedAvg,

    required  this.portfolioStart,

    required  this.portfolioEnd,

    required  this.contributed,

    required  this.gain,

    required  this.twr,

    required  this.networthStart,

    required  this.networthEnd,

    required  this.fireNeeded,

    required  this.fireProgress,

    required  this.fireAge,

    required  this.outOfRange,

    required  this.goals,
  });

  @JsonKey(
    
    name: r'cycles',
    required: true,
    includeIfNull: false,
  )


  final int cycles;



  @JsonKey(
    
    name: r'income',
    required: true,
    includeIfNull: false,
  )


  final String income;



  @JsonKey(
    
    name: r'spend',
    required: true,
    includeIfNull: false,
  )


  final String spend;



  @JsonKey(
    
    name: r'surplus',
    required: true,
    includeIfNull: false,
  )


  final String surplus;



  @JsonKey(
    
    name: r'savings_rate',
    required: true,
    includeIfNull: true,
  )


  final String? savingsRate;



  @JsonKey(
    
    name: r'fixed_avg',
    required: true,
    includeIfNull: true,
  )


  final String? fixedAvg;



  @JsonKey(
    
    name: r'portfolio_start',
    required: true,
    includeIfNull: false,
  )


  final String portfolioStart;



  @JsonKey(
    
    name: r'portfolio_end',
    required: true,
    includeIfNull: false,
  )


  final String portfolioEnd;



  @JsonKey(
    
    name: r'contributed',
    required: true,
    includeIfNull: false,
  )


  final String contributed;



  @JsonKey(
    
    name: r'gain',
    required: true,
    includeIfNull: false,
  )


  final String gain;



  @JsonKey(
    
    name: r'twr',
    required: true,
    includeIfNull: true,
  )


  final String? twr;



  @JsonKey(
    
    name: r'networth_start',
    required: true,
    includeIfNull: false,
  )


  final String networthStart;



  @JsonKey(
    
    name: r'networth_end',
    required: true,
    includeIfNull: false,
  )


  final String networthEnd;



  @JsonKey(
    
    name: r'fire_needed',
    required: true,
    includeIfNull: true,
  )


  final String? fireNeeded;



  @JsonKey(
    
    name: r'fire_progress',
    required: true,
    includeIfNull: true,
  )


  final String? fireProgress;



  @JsonKey(
    
    name: r'fire_age',
    required: true,
    includeIfNull: true,
  )


  final String? fireAge;



  @JsonKey(
    
    name: r'out_of_range',
    required: true,
    includeIfNull: false,
  )


  final List<String> outOfRange;



  @JsonKey(
    
    name: r'goals',
    required: true,
    includeIfNull: false,
  )


  final List<ReviewGoalOut> goals;





    @override
    bool operator ==(Object other) => identical(this, other) || other is QuarterMetricsOut &&
      other.cycles == cycles &&
      other.income == income &&
      other.spend == spend &&
      other.surplus == surplus &&
      other.savingsRate == savingsRate &&
      other.fixedAvg == fixedAvg &&
      other.portfolioStart == portfolioStart &&
      other.portfolioEnd == portfolioEnd &&
      other.contributed == contributed &&
      other.gain == gain &&
      other.twr == twr &&
      other.networthStart == networthStart &&
      other.networthEnd == networthEnd &&
      other.fireNeeded == fireNeeded &&
      other.fireProgress == fireProgress &&
      other.fireAge == fireAge &&
      other.outOfRange == outOfRange &&
      other.goals == goals;

    @override
    int get hashCode =>
        cycles.hashCode +
        income.hashCode +
        spend.hashCode +
        surplus.hashCode +
        (savingsRate == null ? 0 : savingsRate.hashCode) +
        (fixedAvg == null ? 0 : fixedAvg.hashCode) +
        portfolioStart.hashCode +
        portfolioEnd.hashCode +
        contributed.hashCode +
        gain.hashCode +
        (twr == null ? 0 : twr.hashCode) +
        networthStart.hashCode +
        networthEnd.hashCode +
        (fireNeeded == null ? 0 : fireNeeded.hashCode) +
        (fireProgress == null ? 0 : fireProgress.hashCode) +
        (fireAge == null ? 0 : fireAge.hashCode) +
        outOfRange.hashCode +
        goals.hashCode;

  factory QuarterMetricsOut.fromJson(Map<String, dynamic> json) => _$QuarterMetricsOutFromJson(json);

  Map<String, dynamic> toJson() => _$QuarterMetricsOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

