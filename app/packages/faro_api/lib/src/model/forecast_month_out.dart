//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'forecast_month_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ForecastMonthOut {
  /// Returns a new [ForecastMonthOut] instance.
  ForecastMonthOut({

    required  this.label,

    required  this.ym,

    required  this.start,

    required  this.end,

    required  this.payroll,

    required  this.recurring,

    required  this.installments,

    required  this.other,

    required  this.free,

    required  this.cumulative,
  });

  @JsonKey(
    
    name: r'label',
    required: true,
    includeIfNull: false,
  )


  final String label;



  @JsonKey(
    
    name: r'ym',
    required: true,
    includeIfNull: false,
  )


  final String ym;



  @JsonKey(
    
    name: r'start',
    required: true,
    includeIfNull: false,
  )


  final DateTime start;



  @JsonKey(
    
    name: r'end',
    required: true,
    includeIfNull: false,
  )


  final DateTime end;



  @JsonKey(
    
    name: r'payroll',
    required: true,
    includeIfNull: false,
  )


  final String payroll;



  @JsonKey(
    
    name: r'recurring',
    required: true,
    includeIfNull: false,
  )


  final String recurring;



  @JsonKey(
    
    name: r'installments',
    required: true,
    includeIfNull: false,
  )


  final String installments;



  @JsonKey(
    
    name: r'other',
    required: true,
    includeIfNull: false,
  )


  final String other;



  @JsonKey(
    
    name: r'free',
    required: true,
    includeIfNull: false,
  )


  final String free;



  @JsonKey(
    
    name: r'cumulative',
    required: true,
    includeIfNull: false,
  )


  final String cumulative;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ForecastMonthOut &&
      other.label == label &&
      other.ym == ym &&
      other.start == start &&
      other.end == end &&
      other.payroll == payroll &&
      other.recurring == recurring &&
      other.installments == installments &&
      other.other == other &&
      other.free == free &&
      other.cumulative == cumulative;

    @override
    int get hashCode =>
        label.hashCode +
        ym.hashCode +
        start.hashCode +
        end.hashCode +
        payroll.hashCode +
        recurring.hashCode +
        installments.hashCode +
        other.hashCode +
        free.hashCode +
        cumulative.hashCode;

  factory ForecastMonthOut.fromJson(Map<String, dynamic> json) => _$ForecastMonthOutFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastMonthOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

