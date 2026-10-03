//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/performance_month_out.dart';
import 'package:faro_api/src/model/series_point_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'performance_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PerformanceOut {
  /// Returns a new [PerformanceOut] instance.
  PerformanceOut({

    required  this.first,

    required  this.days,

    required  this.value,

    required  this.contributed,

    required  this.gain,

    required  this.twr,

    required  this.twrAnnual,

    required  this.ytd,

    required  this.xirr,

    required  this.maxDrawdown,

    required  this.volatility,

    required  this.best,

    required  this.worst,

    required  this.positiveMonths,

    required  this.negativeMonths,

    required  this.months,

    required  this.series,

     this.beforeUntil,

     this.beforeContributed,

     this.beforeValue,
  });

  @JsonKey(
    
    name: r'first',
    required: true,
    includeIfNull: true,
  )


  final DateTime? first;



  @JsonKey(
    
    name: r'days',
    required: true,
    includeIfNull: false,
  )


  final int days;



  @JsonKey(
    
    name: r'value',
    required: true,
    includeIfNull: false,
  )


  final String value;



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
    
    name: r'twr_annual',
    required: true,
    includeIfNull: true,
  )


  final String? twrAnnual;



  @JsonKey(
    
    name: r'ytd',
    required: true,
    includeIfNull: true,
  )


  final String? ytd;



  @JsonKey(
    
    name: r'xirr',
    required: true,
    includeIfNull: true,
  )


  final String? xirr;



  @JsonKey(
    
    name: r'max_drawdown',
    required: true,
    includeIfNull: true,
  )


  final String? maxDrawdown;



  @JsonKey(
    
    name: r'volatility',
    required: true,
    includeIfNull: true,
  )


  final String? volatility;



  @JsonKey(
    
    name: r'best',
    required: true,
    includeIfNull: true,
  )


  final PerformanceMonthOut? best;



  @JsonKey(
    
    name: r'worst',
    required: true,
    includeIfNull: true,
  )


  final PerformanceMonthOut? worst;



  @JsonKey(
    
    name: r'positive_months',
    required: true,
    includeIfNull: false,
  )


  final int positiveMonths;



  @JsonKey(
    
    name: r'negative_months',
    required: true,
    includeIfNull: false,
  )


  final int negativeMonths;



  @JsonKey(
    
    name: r'months',
    required: true,
    includeIfNull: false,
  )


  final List<PerformanceMonthOut> months;



  @JsonKey(
    
    name: r'series',
    required: true,
    includeIfNull: false,
  )


  final List<SeriesPointOut> series;



  @JsonKey(
    
    name: r'before_until',
    required: false,
    includeIfNull: false,
  )


  final DateTime? beforeUntil;



  @JsonKey(
    
    name: r'before_contributed',
    required: false,
    includeIfNull: false,
  )


  final String? beforeContributed;



  @JsonKey(
    
    name: r'before_value',
    required: false,
    includeIfNull: false,
  )


  final String? beforeValue;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PerformanceOut &&
      other.first == first &&
      other.days == days &&
      other.value == value &&
      other.contributed == contributed &&
      other.gain == gain &&
      other.twr == twr &&
      other.twrAnnual == twrAnnual &&
      other.ytd == ytd &&
      other.xirr == xirr &&
      other.maxDrawdown == maxDrawdown &&
      other.volatility == volatility &&
      other.best == best &&
      other.worst == worst &&
      other.positiveMonths == positiveMonths &&
      other.negativeMonths == negativeMonths &&
      other.months == months &&
      other.series == series &&
      other.beforeUntil == beforeUntil &&
      other.beforeContributed == beforeContributed &&
      other.beforeValue == beforeValue;

    @override
    int get hashCode =>
        (first == null ? 0 : first.hashCode) +
        days.hashCode +
        value.hashCode +
        contributed.hashCode +
        gain.hashCode +
        (twr == null ? 0 : twr.hashCode) +
        (twrAnnual == null ? 0 : twrAnnual.hashCode) +
        (ytd == null ? 0 : ytd.hashCode) +
        (xirr == null ? 0 : xirr.hashCode) +
        (maxDrawdown == null ? 0 : maxDrawdown.hashCode) +
        (volatility == null ? 0 : volatility.hashCode) +
        (best == null ? 0 : best.hashCode) +
        (worst == null ? 0 : worst.hashCode) +
        positiveMonths.hashCode +
        negativeMonths.hashCode +
        months.hashCode +
        series.hashCode +
        (beforeUntil == null ? 0 : beforeUntil.hashCode) +
        (beforeContributed == null ? 0 : beforeContributed.hashCode) +
        (beforeValue == null ? 0 : beforeValue.hashCode);

  factory PerformanceOut.fromJson(Map<String, dynamic> json) => _$PerformanceOutFromJson(json);

  Map<String, dynamic> toJson() => _$PerformanceOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

