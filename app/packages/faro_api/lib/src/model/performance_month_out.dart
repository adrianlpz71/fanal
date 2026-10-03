//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'performance_month_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PerformanceMonthOut {
  /// Returns a new [PerformanceMonthOut] instance.
  PerformanceMonthOut({

    required  this.year,

    required  this.month,

    required  this.startValue,

    required  this.endValue,

    required  this.netFlow,

    required  this.gain,

    required  this.ret,

    required  this.cumulative,
  });

  @JsonKey(
    
    name: r'year',
    required: true,
    includeIfNull: false,
  )


  final int year;



  @JsonKey(
    
    name: r'month',
    required: true,
    includeIfNull: false,
  )


  final int month;



  @JsonKey(
    
    name: r'start_value',
    required: true,
    includeIfNull: false,
  )


  final String startValue;



  @JsonKey(
    
    name: r'end_value',
    required: true,
    includeIfNull: false,
  )


  final String endValue;



  @JsonKey(
    
    name: r'net_flow',
    required: true,
    includeIfNull: false,
  )


  final String netFlow;



  @JsonKey(
    
    name: r'gain',
    required: true,
    includeIfNull: false,
  )


  final String gain;



  @JsonKey(
    
    name: r'ret',
    required: true,
    includeIfNull: true,
  )


  final String? ret;



  @JsonKey(
    
    name: r'cumulative',
    required: true,
    includeIfNull: true,
  )


  final String? cumulative;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PerformanceMonthOut &&
      other.year == year &&
      other.month == month &&
      other.startValue == startValue &&
      other.endValue == endValue &&
      other.netFlow == netFlow &&
      other.gain == gain &&
      other.ret == ret &&
      other.cumulative == cumulative;

    @override
    int get hashCode =>
        year.hashCode +
        month.hashCode +
        startValue.hashCode +
        endValue.hashCode +
        netFlow.hashCode +
        gain.hashCode +
        (ret == null ? 0 : ret.hashCode) +
        (cumulative == null ? 0 : cumulative.hashCode);

  factory PerformanceMonthOut.fromJson(Map<String, dynamic> json) => _$PerformanceMonthOutFromJson(json);

  Map<String, dynamic> toJson() => _$PerformanceMonthOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

